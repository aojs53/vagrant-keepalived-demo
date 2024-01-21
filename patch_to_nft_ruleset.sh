#! /bin/bash

DEBUG=0

sleep 1

if [ $DEBUG -eq 1 ];
then
  log=/dev/shm/patch_to_nft_rule.log
  exec &> >(awk '{print strftime("[%Y/%m/%d %H:%M:%S] "),$0 } { fflush() } ' >> $log)
fi

target_rules=( 'ct state { invalid } drop' \
               'reject with icmpx type admin-prohibited' \
             )

get_handle_for() {
  table="$1"
  chain="$2"
  rule="$3"

  NFT_CMD="nft --handle list chain $table $chain"
  handle=$($NFT_CMD | grep "$rule" | LANG=C perl -ne '/handle ([0-9]+)/; print $1' 2>&1 )

  if [ $DEBUG -eq 1 ];
  then
    echo "get_handle_for():" >&2
    echo NFT_CMD:      >&2
    echo "$($NFT_CMD)" >&2
    echo rule: $rule    >&2
    echo handle: $handle >&2
    echo >&2
  fi

  if ! bash -c "echo $handle | egrep '^[0-9]+$' > /dev/null 2>&1 ";
  then
    echo "Could not get handle number from:"  >&2 
    echo "$($NFT_CMD)" >&2
    echo "for:"   >&2
    echo $rule    >&2
    echo          >&2
    echo "exit."  >&2
    exit 1
  fi

  echo $handle
}


delete_rule () {
  table="$1"
  chain="$2"
  handle="$3"

  NFT_CMD="nft delete rule $table $chain handle $handle"

  if [ $DEBUG -eq 1 ];
  then
    echo "delete_rule():" >&2
    echo Target_chain: >&2
    nft --handle list chain $table $chain >&2
    echo >&2
    echo NFT_CMD: >&2
    echo "$NFT_CMD" >&2
    echo >&2
  fi

  $NFT_CMD

  if [ $DEBUG -eq 1 ];
  then
    echo "After deletion:" >&2
    nft --handle list chain $table $chain >&2
  fi
}

for i in "${target_rules[@]}"
do
  handle=$(get_handle_for "inet firewalld" "filter_INPUT" "$i")
  if [ $? -ne 0 ];
  then
    exit 1
  fi
  delete_rule "inet firewalld" "filter_INPUT" "$handle"
done


