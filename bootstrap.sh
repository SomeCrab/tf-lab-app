#!/bin/bash
set -euo pipefail

sudo dnf update -y
sudo dnf install -y amazon-ssm-agent nginx python3 python3-pip

sudo systemctl enable --now amazon-ssm-agent
sudo systemctl enable nginx

# App
sudo mkdir -p /opt/app
sudo cp app.py /opt/app/
sudo chown -R ec2-user:ec2-user /opt/app

# venv
sudo -u ec2-user python3 -m venv /opt/app/venv
sudo -u ec2-user /opt/app/venv/bin/pip install --upgrade pip
sudo -u ec2-user /opt/app/venv/bin/pip install -r requirements.txt

# systemd service
sudo cp flask-app.service /etc/systemd/system/flask-app.service
sudo systemctl daemon-reload
sudo systemctl enable --now flask-app

# nginx
sudo cp nginx.conf /etc/nginx/conf.d/flask.conf
sudo rm -f /etc/nginx/conf.d/default.conf || true
sudo systemctl restart nginx
