resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name = "DummyMachine"
  public_key = tls_private_key.ssh.public_key_openssh
}

output "ssh_private_key_pem" {
  value = tls_private_key.ssh.private_key_pem
  sensitive = true
}

output "ssh_public_key_pem" {
  value = tls_private_key.ssh.public_key_pem
}



resource "aws_security_group" "app_securitygroup" {
  name = "AppSecurityGroup"
  description = "AppSecurityGroup"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    cidr_blocks = ["10.0.2.0/24"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  ingress {
    cidr_blocks = ["10.0.2.0/24"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    "Name" = "AppSecurityGroup"
  }
  
}

resource "aws_security_group" "load_balance_securitygroup" {
  name = "LoadBalanceSecurityGroup"
  description = "LoadBalanceSecurityGroup"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    "Name" = "LoadBalanceSecurityGroup"
  }
  
}


resource "aws_network_interface" "appinstance_interface" {
  subnet_id = aws_subnet.private.id
  private_ips = ["10.0.1.20"]
  security_groups = [aws_security_group.app_securitygroup.id]
  tags = {
    "Name" = "AppInstanceInterface"
  }
}


resource "aws_instance" "ec2instance" {
  instance_type = "t2.micro"
  ami = "ami-0d8f9265cd415c863"
  network_interface {
     network_interface_id = aws_network_interface.appinstance_interface.id
     device_index = 0
  }
  user_data = "${file("app-user-data.sh")}"
  key_name = aws_key_pair.ssh.key_name
  root_block_device {
    volume_size = "10"
  }
  tags = {
    "Name" = "AppInstance"
  }
}


resource "aws_instance" "load_balance" {
  instance_type = "t2.micro"
  ami = "ami-0d8f9265cd415c863"
  subnet_id = aws_subnet.public.id
  security_groups = [aws_security_group.load_balance_securitygroup.id]
  user_data = "${file("loadbalance-user-data.sh")}"
  key_name = aws_key_pair.ssh.key_name
  disable_api_termination = false
  ebs_optimized = false
  root_block_device {
    volume_size = "10"
  }
  tags = {
    "Name" = "LoadBalance1"
  }
}

resource "aws_eip" "load_balance" {
  instance = aws_instance.load_balance.id
  vpc = true
}


output "load_balance_ip" {
  value = aws_eip.load_balance.public_ip
}

output "app_private_ip" {
  value = aws_instance.ec2instance.private_ip
}
