data "aws_vpc" "vpc_net" {
  id = var.vpc_id
}

resource "aws_db_instance" "mariadb" {
  allocated_storage    = var.storage_size
  storage_type         = "gp2"
  engine               = "mariadb"
  engine_version       = "10.4"
  instance_class       = "db.t2.micro"
  multi_az             = true
  db_subnet_group_name = var.rds_subnet_group
  name                 = var.dbname
  username             = var.dbuser
  password             = var.dbpass
}

resource "aws_security_group" "rds_sg" {
  name = "wp-rds-sg"  
  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = [data.aws_vpc.vpc_net.cidr_block]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    # "-1" means "all"
  }
}