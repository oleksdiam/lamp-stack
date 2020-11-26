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

resource "aws_security_group" "ssh" {
  name = "ssh-sg"  
  ingress {
    protocol    = "tcp"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    cidr_blocks = var.ssh_access_cidr
  }
  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_launch_template" "bastion_template" {
  name = "bastion-template"

  image_id = "ami-04bf6dcdc9ab498ca"
  instance_type = "t2.micro"
  key_name = "odiam-keypair"
  disable_api_termination = true

  vpc_security_group_ids = [aws_security_group.ssh.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "bastion"
    }
  }
#   user_data = filebase64("${path.module}/userdata.sh")
}

resource "aws_autoscaling_group" "bastion_asg" {
  launch_template {
      id      = aws_launch_template.bastion_template.id
      version = "latest"
  }
  vpc_zone_identifier  = var.public_subnets
  health_check_type    = "EC2"

  min_size = 1
  max_size = 1
  desired_capacity = 1
  tag {
    key                 = "Name"
    value               = "bastion-asg"    
    propagate_at_launch = true
  }
}
