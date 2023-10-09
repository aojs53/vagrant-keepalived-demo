cd /dev/shm

echo 'PASV connection'
lftp -c 'open -u vagrant,vagrant lvs; ls -l; mget hello.*;'
ls -l hello.*
rm hello.*

echo 'ACTIVE connection (May be not able to connect.'
lftp -c 'set ftp:passive-mode false; open -u vagrant,vagrant lvs; ls -l; mget hello.*'
ls -l hello.*
rm hello.*


