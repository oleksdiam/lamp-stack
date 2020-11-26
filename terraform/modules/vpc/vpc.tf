data "aws_vpc" "vpc_net" {
  id = var.vpc_id
}
data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.vpc_net.id]
  }
}
data "aws_availability_zones" "azones" {
  state = "available"
}
locals {
  azs_number = var.azs_count > length(data.aws_availability_zones.azones.zone_ids) ? length(data.aws_availability_zones.azones.zone_ids) : var.azs_count
}

resource "aws_subnet" "subnet_public" {
  count             = var.azs_count > length(data.aws_availability_zones.azones.zone_ids) ? length(data.aws_availability_zones.azones.zone_ids) : var.azs_count
  availability_zone = data.aws_availability_zones.azones.names[count.index]
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(data.aws_vpc.vpc_net.cidr_block, 6, var.cidr_start_index + count.index)
  tags = {
    AZ  = data.aws_availability_zones.azones.names[count.index]
    Name = "public-subnet"
  }
}
resource "aws_subnet" "subnet_private" {
  count             = local.azs_number
  availability_zone = data.aws_availability_zones.azones.names[count.index]
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(data.aws_vpc.vpc_net.cidr_block, 6, var.cidr_start_index + local.azs_number + count.index)
  tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "subnet_db" {
  count             = local.azs_number
  availability_zone = data.aws_availability_zones.azones.names[count.index]
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(data.aws_vpc.vpc_net.cidr_block, 6, var.cidr_start_index + 2*local.azs_number + count.index)
  tags = {
    Name = "db-subnet"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_main"
  subnet_ids = aws_subnet.subnet_db.*.id
  tags = {
    Name = "DB_subnet_group"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id  = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw.id
  }
  tags = {
    Name = "rt-public"
  }
}

resource "aws_route_table_association" "rta_public" {
  count          = local.azs_number
  subnet_id      = aws_subnet.subnet_public.*.id[count.index]
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table" "rt_private" {
  count   = var.single_nat_gateway ? 1 : local.azs_number
  vpc_id  = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.*.id[count.index]
  }
  tags = {
    Name = "rt-private"
  }
}
resource "aws_route_table_association" "rta_private" {
  count   = var.single_nat_gateway ? 1 : local.azs_number
  subnet_id      = aws_subnet.subnet_private.*.id[count.index]
  route_table_id = aws_route_table.rt_private.*.id[count.index]
}

resource "aws_nat_gateway" "ngw" {
  count   = var.single_nat_gateway ? 1 : local.azs_number
  allocation_id = aws_eip.nat.*.id[count.index]
  subnet_id     = aws_subnet.subnet_public.*.id[count.index]
  depends_on    = [aws_eip.nat]
  tags = {
    Name = "NAT_gw"
  }
}

resource "aws_eip" "nat" {
  count   = var.single_nat_gateway ? 1 : local.azs_number
  vpc         = true
}
