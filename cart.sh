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

rm -rf /app/* &>> $LOGFILE

VALIDATE $? "/app directory cleaned"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "cart App Downloaded"

cd /app

unzip /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "cart App Unzipped"

npm install &>> $LOGFILE

VALIDATE $? "cart Dependencies Installed"

cp /home/centos/Private-repo/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "cart Service Copied"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "SystemD Daemon Reloaded"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "cart Service Enabled"
systemctl start cart &>> $LOGFILE
VALIDATE $? "cart Service Started"

echo -e "$G cart Setup Completed $N"