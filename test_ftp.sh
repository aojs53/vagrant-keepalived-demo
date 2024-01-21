cd /dev/shm

if [ "$1" != "" ];
then
  debug="debug; "
fi

do_lftp () {
  lftp_cmd="$1"
  cmd=$debug
  cmd="$cmd $lftp_cmd"
  echo "LFTP_CMD: $cmd"
  lftp -c "$cmd"
  echo ----------------
}

exec_with_comment () {
  cmd="$1"
  comment="$2"

  echo -n '### '
  echo ---- $comment
  $cmd
  echo ----------------
}


echo '# PASV connection'
echo
echo '## GET operation'
LFTP_CMD='open -u vagrant,vagrant lvs; ls; mget 10M.*;'
do_lftp "$LFTP_CMD"
exec_with_comment 'ls -l 10M.*' 'List local downloaded file.'
echo
echo '## PUT operation'
LFTP_CMD='open -u vagrant,vagrant lvs; mrm 10M.*; mput 10M.*; ls'
do_lftp "$LFTP_CMD"
exec_with_comment 'rm 10M.*' 'Removed test files.'

echo '# ACTIVE connection'
echo
echo '## GET operation'
echo
LFTP_CMD='set ftp:passive-mode false; open -u vagrant,vagrant lvs; ls -l; mget 10M.*'
do_lftp "$LFTP_CMD"
exec_with_comment 'ls -l 10M.*' 'List local downloaded file.'
echo 
echo '## PUT operation'
LFTP_CMD='set ftp:passive-mode false; open -u vagrant,vagrant lvs; mrm 10M.*; mput 10M.*; ls'
do_lftp "$LFTP_CMD"
exec_with_comment 'rm 10M.*' 'Removed test files.'



