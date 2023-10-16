cd /dev/shm

if [ "$1" != "" ];
then
  debug="debug; "
fi

echo 'PASV connection'
lftp -c "$debug; open -u vagrant,vagrant lvs; ls; mget hello.*;"
ls -l hello.*
rm hello.*

echo 'ACTIVE connection (May be not able to connect.'
lftp -c 'set ftp:passive-mode false; open -u vagrant,vagrant lvs; ls -l; mget hello.*'
ls -l hello.*
rm hello.*


