#openssl x509 -req -in cyrus-imapd.csr -CA myCA.crt -CAkey myCA.key -CAcreateserial -out cyrus-imapd.crt -days 398 -sha256 
openssl ca -config openssl-ca-davidchill.cnf -out davidchill.pem.crt -extensions req_ext -infiles davidchill.csr 
