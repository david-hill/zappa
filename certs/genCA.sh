openssl genrsa  -out myCA.key 4096
#openssl req -x509 -new -nodes -key myCA.key -sha256 -days 398 -out myCA.crt -subj '/CN=Root CA/O=davidchill'
openssl req -x509 -new -nodes -key myCA.key -sha256 -days 3980 -out myCA.crt -subj '/CN=Root CA/O=davidchill'

