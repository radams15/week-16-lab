resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/22"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    "Name" = "Dummy"
  }
}

resource "aws_subnet" "private" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "PriSub1"
  }
}

resource "aws_subnet" "public" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "DummySubnetNAT"
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "DummyGateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }
}


resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "public" {
  vpc = true
}

resource "aws_nat_gateway" "public" {
  allocation_id = aws_eip.public.id
  subnet_id = aws_subnet.public.id
  tags = {
    "Name" = "DummyNatGateway"
  }
}

output "public_ip" {
  value = aws_eip.public.public_ip
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.nat.id
}
