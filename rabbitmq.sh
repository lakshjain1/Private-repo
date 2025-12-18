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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Setting up Erlang Repository"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Setting up RabbitMQ Repository"

yum install rabbitmq-server -y &>> $LOGFILE

VALIDATE $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server &>> $LOGFILE

VALIDATE $? "Enabling RabbitMQ Service"

systemctl start rabbitmq-server &>> $LOGFILE

VALIDATE $? "Starting RabbitMQ Service"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE

VALIDATE $? "Adding RabbitMQ User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

VALIDATE $? "Setting Permissions for RabbitMQ User"

echo -e "$G RabbitMQ Installation Completed $N"