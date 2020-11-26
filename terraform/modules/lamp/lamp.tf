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

data "aws_acm_certificate" "acm_odiam" {
  domain   = "odiam-wp.support-coe.com"
  statuses = ["ISSUED"]
}

resource "aws_security_group" "alb" {
  name = "alb-group"  
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    # "-1" means "all"
  }
}

resource "aws_security_group" "app" {
  name = "wp-app-sg"  
  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    # "-1" means "all"
  }
}

resource "aws_launch_template" "lamp_template" {
  name = "lamp-template"
  image_id = "ami-04bf6dcdc9ab498ca"
  instance_type = "t2.micro"
  key_name = "odiam-keypair"

  vpc_security_group_ids = [aws_security_group.app.id, var.ssh_sg_id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app"
    }
  }
  user_data = filebase64("${path.module}/files/userdata.sh")
}

resource "aws_autoscaling_group" "app_asg" {
  launch_template {
      id      = aws_launch_template.lamp_template.id
      version = "latest"
  }
  vpc_zone_identifier  = var.private_subnets
  health_check_type    = "EC2"

  min_size = 1
  max_size = 1
  desired_capacity = 1
  tag {
    key                 = "Name"
    value               = "app-asg"    
    propagate_at_launch = true
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name          = "alb-tg"
  port          = 80
  protocol      = "HTTP"
  vpc_id        = var.vpc_id

  health_check {
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb" "app_alb" {
  name               = "alb-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false
  tags = {
    Name  = "app-alb"    
  }
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP" 

  default_action {
    type     = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.acm_odiam.arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}
