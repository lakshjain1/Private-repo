#!/bin/bash 

#She bang line

ID=$(id -u) # Get user ID if it is 0 then root user
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum install nginx -y &>> $LOGFILE

VALIDATE $? "Nginx Installed"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "Nginx Enabled"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "Nginx Started"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "Nginx Default content removed"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "Web content downloaded"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "Changed directory to nginx html"

unzip /tmp/web &>> $LOGFILE

VALIDATE $? "Web content unzipped"

cp /home/centos/Private-repo/roboshop.conf /etc/nginx/conf.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "Nginx config copied"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "Nginx restarted"

echo -e "$G Web Server Setup Completed $N"