#!/bin/bash
set -euo pipefail

: "${DB_HOST:?DB_HOST is required}"
: "${DB_NAME:?DB_NAME is required}"
: "${DB_USER:?DB_USER is required}"
: "${DB_PASSWORD_SSM_NAME:?DB_PASSWORD_SSM_NAME is required}"
: "${DB_REGION:?DB_REGION is required}"

sudo dnf install -y awscli

DB_PASSWORD=$(aws ssm get-parameter \
  --name "$DB_PASSWORD_SSM_NAME" \
  --with-decryption \
  --query 'Parameter.Value' \
  --output text \
  --region "$DB_REGION")

sudo dnf update -y
sudo dnf install -y amazon-ssm-agent nginx python3 python3-pip

sudo systemctl enable --now amazon-ssm-agent
sudo systemctl enable nginx

# App
sudo mkdir -p /opt/app
sudo cp app.py /opt/app/
sudo chown -R ec2-user:ec2-user /opt/app

# .env file
sudo bash -c "cat > /opt/app/.env" <<EOF
DB_HOST=$DB_HOST
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
EOF
sudo chown ec2-user:ec2-user /opt/app/.env

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
