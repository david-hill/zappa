#openssl req -new -nodes -config etc/pki/tls/openssl.cnf -out cyrus-imapd.csr -keyout cyrus-impad.pem -days 398 -extensions req_ext
openssl req -new -nodes -config openssl-ca-davidchill.cnf -out davidchill.csr -keyout davidchill.pem -days 3980 -extensions req_ext

