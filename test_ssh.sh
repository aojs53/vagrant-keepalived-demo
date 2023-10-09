for i in $(seq 1 10)
do
  echo -n "$(date): "
  ssh lvs hostname
done
