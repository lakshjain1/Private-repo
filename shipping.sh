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

yum install maven -y &>> $LOGFILE

VALIDATE $? "Installing Maven"

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

cd /app &>> $LOGFILE

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading Shipping Service Code"

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Extracting Shipping Service Code"

mvn clean package &>> $LOGFILE

VALIDATE $? "Building Shipping Service Code"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

cp /home/centos/Private/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Shipping Service File Copied"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "SystemD Daemon Reloaded"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "Shipping Service Enabled"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "Shipping Service Started"

echo -e "$G Shipping Service Setup Completed $N"