

data "aws_availability_zones" "availability_zone" {}


resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  instance_tenancy = "default"

  enable_dns_hostnames = true

  enable_dns_support = true


}

#_----------------------------------------subnets public-------------------------------------

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.publick_cidr_block[0]
  availability_zone       = data.aws_availability_zones.availability_zone.names[0]
  map_public_ip_on_launch = true

  depends_on = [aws_vpc.vpc]

}


resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.publick_cidr_block[1]
  availability_zone       = data.aws_availability_zones.availability_zone.names[1]
  map_public_ip_on_launch = true

  depends_on = [aws_vpc.vpc]

}

locals {
  subnets_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

#------------------------------------private subnet---------------------------------------

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_cidr_block[0]
  availability_zone = data.aws_availability_zones.availability_zone.names[0]

  depends_on = [aws_vpc.vpc]

}


resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_cidr_block[1]
  availability_zone = data.aws_availability_zones.availability_zone.names[1]

  depends_on = [aws_vpc.vpc]

}

locals {
  private_subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
}

#----------------------------------public network---------------------------

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  depends_on = [aws_vpc.vpc]

}

resource "aws_route_table" "subnets_route_subnet" {
  count  = length(var.publick_cidr_block)
  vpc_id = aws_vpc.vpc.id
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.id
  }

  depends_on = [
    aws_vpc.vpc,
    aws_internet_gateway.internet_gateway
  ]

}

resource "aws_route_table_association" "publick_association" {
  count          = length(var.publick_cidr_block)
  route_table_id = aws_route_table.subnets_route_subnet[count.index].id
  subnet_id      = element(local.subnets_ids, count.index)

  depends_on = [aws_route_table.subnets_route_subnet]

}


#-------------------------------------private network---------------------------

resource "aws_eip" "nat" {
  count = length(var.private_cidr_block)
  vpc   = true
}

resource "aws_nat_gateway" "nat_gateaway" {
  count         = length(var.private_cidr_block)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(local.subnets_ids, count.index)

  depends_on = [aws_eip.nat]
}

resource "aws_route_table" "private_subnet_route" {
  count  = length(var.private_cidr_block)
  vpc_id = aws_vpc.vpc.id
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  depends_on = [
    aws_vpc.vpc,
    aws_nat_gateway.nat_gateaway
  ]
}


resource "aws_route_table_association" "private_subnets_associate" {
  count          = length(var.private_cidr_block)
  gateway_id     = aws_nat_gateway.nat_gateaway.id
  route_table_id = aws_route_table.private_subnet_route.id

  depends_on = [
    aws_nat_gateway.nat_gateaway,
    aws_route_table.private_subnet_route
  ]


}



