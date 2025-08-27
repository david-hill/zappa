#openssl x509 -req -in cyrus-imapd.csr -CA myCA.crt -CAkey myCA.key -CAcreateserial -out cyrus-imapd.crt -days 398 -sha256 
openssl ca -config openssl-ca.cnf -out certificate.pem.crt -extensions req_ext -infiles cyrus-imapd.csr 
