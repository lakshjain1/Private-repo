#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE

VALIDATE $? "NodeJS Repo added"

yum install nodejs -y &>> $LOGFILE

VALIDATE $? "NodeJS Installed"

id roboshop 

if [ $? -ne 0 ]; then
    useradd roboshop &>> $LOGFILE
else
    echo "roboshop user already exists" &>> $LOGFILE
fi

VALIDATE $? "roboshop user created"

ls /app &>> $LOGFILE

if [ $? -ne 0 ]; then
    mkdir /app &>> $LOGFILE
else
    echo "/app already exists" &>> $LOGFILE
fi

VALIDATE $? "/app directory created"

curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip -y &>> $LOGFILE

VALIDATE $? "Catalogue App Downloaded"

cd /app

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Catalogue App Unzipped"

npm install &>> $LOGFILE

VALIDATE $? "Catalogue Dependencies Installed"

cp /home/centos/Private-repo/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Catalogue Service Copied"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "SystemD Daemon Reloaded"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Catalogue Service Enabled"
systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Catalogue Service Started"

echo -e "$G Catalogue Setup Completed $N"