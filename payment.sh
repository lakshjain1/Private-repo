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

yum install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installing Python3 and dependencies"

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Downloading payment component"

cd /app &>> $LOGFILE

unzip /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "Extracting payment component"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "Installing payment dependencies"

cp /home/centos/Private-repo/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "payment systemd file copied"

systemctl daemon-reload &>> $LOGFILE

systemctl enable payment &>> $LOGFILE

systemctl start payment &>> $LOGFILE

VALIDATE $? "Starting payment service"

echo -e "$G Payment Setup Completed $N"