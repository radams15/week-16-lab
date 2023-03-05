resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name = "EC2Key"
  public_key = tls_private_key.ssh.public_key_openssh
}

output "ssh_private_key_pem" {
  value = tls_private_key.ssh.private_key_pem
  sensitive = true
}

output "ssh_public_key_pem" {
  value = tls_private_key.ssh.public_key_pem
}

resource "aws_security_group" "allow_ssh_http" {
  name = "allow_ssh_http"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "my_ec2_instance" {
  instance_type = "t2.micro"
  ami = "ami-008f4281d2c5de558"
  security_groups = [aws_security_group.allow_ssh_http.id]
  subnet_id = aws_subnet.private_subnet.id
  user_data = "${file("app-user-data.sh")}"
  key_name = aws_key_pair.ssh.key_name
  root_block_device {
    volume_size = "10"
  }
  tags = {
    "Name" = "rhys-adams-AppInstance"
  }
}

output "app_private_ip" {
  value = aws_instance.my_ec2_instance.private_ip
}
