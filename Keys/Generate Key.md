**************************************************
cd {ProjectLocation}/AppLog/Keys
ssh-keygen -t rsa -f id_rsa
openssl rsa -in id_rsa -pubout -out id_rsa.pem
**************************************************
