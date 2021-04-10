# Create Security Group for ASG

resource "aws_security_group" "dfsc_asg_sg" {
  vpc_id = aws_vpc.dfsc_vpc.id
  name   = "ASG Security Group"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
 ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [
      aws_security_group.dfsc_alb_sg.id
    ]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [
      aws_security_group.dfsc_bastion_sg.id
    ]
  }
  tags = {
    Name        = "DFSC ASG Security Group"
    Terraform   = "true"
  } 
}

# Create Launch Configuration

resource "aws_launch_configuration" "dfsc_launch_config" {
  name_prefix   = "DFSC Launch Configuration"
  image_id      = "ami-0f2ed58082cb08a4d"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.dfsc_asg_sg.id]
  key_name = aws_key_pair.ssh-key.key_name
  lifecycle {
    create_before_destroy = true
  }
}

# Create DFSC FrontEnd ASG

resource "aws_autoscaling_group" "dfsc_front_end" {
  name                 = "DFSC FrontEnd ASG"
  launch_configuration = aws_launch_configuration.dfsc_launch_config.name
  health_check_type    = "ELB"
  min_size             = 0
  max_size             = 0
  desired_capacity     = 0

  vpc_zone_identifier = [
    aws_subnet.dfsc-private-1a.id,
    aws_subnet.dfsc-private-1b.id
  ]
  target_group_arns = [aws_lb_target_group.dfsc-front-end-tg.arn]
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "DFSC FrontEnd ASG"
    propagate_at_launch = true  
  }
}

# Create DFSC Backend ASG

resource "aws_autoscaling_group" "dfsc_back_end" {
  name                 = "DFSC BackEnd ASG"
  launch_configuration = aws_launch_configuration.dfsc_launch_config.name
  health_check_type    = "ELB"
  min_size             = 0
  max_size             = 0
  desired_capacity     = 0

  vpc_zone_identifier = [
    aws_subnet.dfsc-private-1a.id,
    aws_subnet.dfsc-private-1b.id
  ]
  target_group_arns = [aws_lb_target_group.dfsc-back-end-tg.arn]
  lifecycle {
    create_before_destroy = true
  }
 tag {
    key                 = "Name"
    value               = "DFSC FrontEnd ASG"
    propagate_at_launch = true  
  }
}