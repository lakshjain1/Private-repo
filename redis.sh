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

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y --skip-broken &>> $LOGFILE

VALIDATE $? "Remi Repo Installation"

yum module enable redis:remi-6.2 -y &>> $LOGFILE

yum install redis -y &>> $LOGFILE

VALIDATE $? "Redis Installation"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOGFILE

VALIDATE $? "Updating Redis Configuration"

systemctl enable redis &>> $LOGFILE

VALIDATE $? "Enable Redis Service"

systemctl start redis &>> $LOGFILE

VALIDATE $? "Start Redis Service"

echo -e "$G Redis Installation Completed Successfully $N"