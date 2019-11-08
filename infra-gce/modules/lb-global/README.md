## Prerequisites

mkdir ssl_cert
cd ssl_cert

Generate private key:
openssl genrsa -out example.key 2048

To generate a signed certificate, you need a CSR:
openssl req -new -key example.key -out example.csr

Generate the certificate:
openssl x509 -req -days 365 -in example.csr -signkey example.key -out example.crt