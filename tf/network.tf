resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.1.0/25"
  availability_zone = "eu-central-1a"
tags = {
    "Name" = "public | eu-central-1a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.1.128/25"
  availability_zone = "eu-central-1b"
tags = {
    "Name" = "public | eu-central-1b"
  }
}
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.2.0/25"
  availability_zone = "eu-central-1a"
tags = {
    "Name" = "private | eu-central-1a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.2.128/25"
  availability_zone = "eu-central-1b"
tags = {
    "Name" = "private | eu-central-1b"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.prod_vpc.id
  tags = {
    "Name" = "public"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.prod_vpc.id
  tags = {
    "Name" = "private"
  }
}
resource "aws_route_table_association" "public_a_subnet" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private_a_subnet" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.prod_vpc.id
}

resource "aws_eip" "nat" {
  
}

resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.nat.id
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}


resource "aws_security_group" "egress_all" {
  name        = "egress-all"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.prod_vpc.id
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress_api" {
  name        = "ingress-api"
  description = "Allow ingress to API"
  vpc_id      = aws_vpc.prod_vpc.id
ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "http" {
  name        = "http"
  description = "HTTP traffic"
  vpc_id      = aws_vpc.prod_vpc.id
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}