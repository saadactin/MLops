terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Metadata Locals ---
locals {
  project_name = "DevOps-SRE-Day10-Systemd-and-Signals"
  environment  = "Learning"
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    Day         = "10-Systemd-Services-and-Process-Signals"
    Cost        = "Free-Tier-Eligible"
  }
}

# --- 1. Automatic SSH Key Pair ---
resource "tls_private_key" "lab_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "lab_key_pair" {
  key_name   = "linux-devops-lab-day10-key"
  public_key = tls_private_key.lab_key.public_key_openssh
  tags       = local.common_tags
}

resource "local_file" "private_key" {
  content         = tls_private_key.lab_key.private_key_pem
  filename        = "${path.module}/linux_lab_key.pem"
  file_permission = "0400"
}

# --- 2. Amazon Linux 2023 AMI ---
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- 3. Security Group (Port 22 SSH, Port 8080 API) ---
resource "aws_security_group" "ec2_sg" {
  name        = "linux-day10-sg"
  description = "Security group for Day 10 Systemd and Process Signals Lab"

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom API Port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# --- 4. Free Tier EC2 Instance (t3.micro - $0 Cost) ---
resource "aws_instance" "basic_ec2" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type # t3.micro ($0 Free Tier)
  key_name      = aws_key_pair.lab_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  root_block_device {
    volume_size           = 8 # 8 GB Free Tier
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y python3 htop jq

              # Setup lab folder for ec2-user
              mkdir -p /home/ec2-user/day10_systemd_lab
              chown -R ec2-user:ec2-user /home/ec2-user/day10_systemd_lab

              # ========================================================
              # PRODUCTION INCIDENT: The Flapping Service Disaster
              # ========================================================
              mkdir -p /opt/payment-processor
              cat << 'PYCODE' > /opt/payment-processor/processor.py
              import os
              import sys
              import time

              CONFIG_FILE = "/etc/payment_processor/config.env"

              print("[STARTUP] Initializing Payment Processor Daemon...", flush=True)

              if not os.path.exists(CONFIG_FILE):
                  print(f"[FATAL ERROR] Configuration file {CONFIG_FILE} not found! Cannot connect to bank gateway.", file=sys.stderr, flush=True)
                  sys.exit(1)

              print("[SUCCESS] Connected to Bank Gateway. Processing payment transactions...", flush=True)
              while True:
                  print("[TRANSACTION] Processed batch of 10 payments.", flush=True)
                  time.sleep(5)
              PYCODE
              chmod +x /opt/payment-processor/processor.py

              # Create the systemd service unit file with auto-restart
              cat << 'UNIT' > /etc/systemd/system/payment-processor.service
              [Unit]
              Description=Production Payment Processor Daemon
              After=network.target

              [Service]
              Type=simple
              User=root
              ExecStart=/usr/bin/python3 /opt/payment-processor/processor.py
              Restart=always
              RestartSec=2

              [Install]
              WantedBy=multi-user.target
              UNIT

              # Reload systemd and start the failing service
              systemctl daemon-reload
              systemctl enable payment-processor.service
              systemctl start payment-processor.service

              # Welcome Banner
              cat << 'BANNER' > /home/ec2-user/README_DAY10.txt
              ======================================================================
                 ⚙️ WELCOME TO DAY 10: LINUX SYSTEMD SERVICES & PROCESS SIGNALS
                                (100% Free Tier - $0 Cost)
              ======================================================================

              Today you will master how real production backend systems run, survive,
              and auto-heal using the Linux init system: systemd!

              [CHALLENGE 1] Turn a Raw Python Script into a Real Self-Healing Service
              - Build a custom unit file from scratch at /etc/systemd/system/saad-api.service.
              - Enable on boot & test auto-restart!

              [CHALLENGE 2] Linux Signals & Graceful vs Forceful Shutdown
              - Learn SIGTERM (15) vs SIGKILL (9) vs SIGHUP (1).

              [CHALLENGE 3] Production Incident: "The Flapping Service Disaster"
              - A critical service 'payment-processor.service' is crashing and flapping!
              - Diagnose using 'systemctl status' and 'journalctl -u payment-processor -e'.
              - Fix the root cause and restore 100% uptime!

              ======================================================================
              BANNER
              chown ec2-user:ec2-user /home/ec2-user/README_DAY10.txt
              echo "cat /home/ec2-user/README_DAY10.txt" >> /home/ec2-user/.bashrc
              EOF

  tags = merge(local.common_tags, {
    Name = "DevOps-SRE-Day10-Systemd-EC2"
  })
}
