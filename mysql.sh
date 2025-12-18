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

yum module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling default mysql module"

cp /home/centos/Private-repo/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Copying mysql repo file"

yum install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling mysql service"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Starting mysql service"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "Setting mysql root password"