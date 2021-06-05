#!/bin/bash -v

sudo yum update -y
sudo yum install -y ruby
sudo yum install wget -y
wget https://aws-codedeploy-ap-southeast-1.s3.ap-southeast-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
sudo yum install python-pip -y
sudo pip install flask
sudo pip install flask_restful