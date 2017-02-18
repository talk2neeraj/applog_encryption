# AppLog
Creating developer encrypted log file from Mac Application and tool to decrypt the log back using own public private key
Create Public and Private key for your application.
**************************************************
cd {ProjectLocation}/AppLog/Keys
ssh-keygen -t rsa -f id_rsa
openssl rsa -in id_rsa -pubout -out id_rsa.pem
**************************************************
Build and run Decrypter app once and kill it.
Build the framwork and import/include in your Mac Project.
Start adding log for your appplication using APP_LOG_INFO or APP_LOG_DEBUG helper app.
Add multiple logs at different places in your code.
Run your app and go through your flow where you have added these logs.
Open the log file at "/Library/Log/LogService" by clicking on it, decryptor app will open automatically.
