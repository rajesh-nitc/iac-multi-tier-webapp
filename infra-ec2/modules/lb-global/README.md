## ssl

mkdir ssl_cert
cd ssl_cert

Generate private key:
openssl genrsa -out example.key 2048

To generate a signed certificate, you need a CSR:
openssl req -new -key example.key -out example.csr

Generate the certificate:
openssl x509 -req -days 365 -in example.csr -signkey example.key -out example.crt

## ssh

aws ec2 create-key-pair --key-name mykeypair2 --query 'KeyMaterial' --output text > ~/.ssh/mykeypair2.pem
chmod 400 ~/.ssh/mykeypair2.pem
ssh -i ~/.ssh/mykeypair2.pem ubuntu@3.133.12.214