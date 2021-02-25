#--------------------------------------------------------------
# Configure AWS credentials
#--------------------------------------------------------------

provider aws {
  access_key 			  = "${var.aws_access_key}"
  secret_key 			  = "${var.aws_secret_key}"
  region                  = "${var.aws_region}"
}

#--------------------------------------------------------------
# Main vpc
#--------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"

  tags = {
    Name = "Main VPC"
  }
}

#--------------------------------------------------------------
# Internet gateway
#--------------------------------------------------------------

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "Internet gateway | Main VPC"
  }
}

#--------------------------------------------------------------
# Public subnets
#--------------------------------------------------------------

resource "aws_subnet" "main_public_1a" {
  vpc_id     = "${aws_vpc.main.id}"
  
  cidr_block = "${lookup(var.subnet,"public_subnet_cidr_1")}"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "Public Subnet 1 - az - 1a | Main VPC"
  }
}

resource "aws_subnet" "main_public_1b" {
  vpc_id     = "${aws_vpc.main.id}"
  
  cidr_block = "${lookup(var.subnet,"public_subnet_cidr_2")}"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "Public Subnet 2 - az - 1b | Main VPC"
  }
}

resource "aws_subnet" "main_public_1c" {
  vpc_id     = "${aws_vpc.main.id}"
  
  cidr_block = "${lookup(var.subnet,"public_subnet_cidr_3")}"
  availability_zone = "ap-southeast-1c"

  tags = {
    Name = "Public Subnet 3 - az - 1c | Main VPC"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

#--------------------------------------------------------------
# NAT gateway
#--------------------------------------------------------------

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.main_public_1a.id}"

  tags = {
    Name = "NAT gateway | Main VPC"
  }

  depends_on = ["aws_internet_gateway.gw"]
}

#--------------------------------------------------------------
# Private subnets
#--------------------------------------------------------------

resource "aws_subnet" "main_private_1a" {
  vpc_id     = "${aws_vpc.main.id}"
  
  cidr_block = "${lookup(var.subnet,"private_subnet_cidr_1")}"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "Private Subnet 1 - az - 1a | Main VPC"
  }
}

resource "aws_subnet" "main_private_1b" {
  vpc_id     = "${aws_vpc.main.id}"
  
  cidr_block = "${lookup(var.subnet,"private_subnet_cidr_2")}"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "Private Subnet 2 - az - 1b | Main VPC"
  }
}

resource "aws_subnet" "main_private_1c" {
  vpc_id     = "${aws_vpc.main.id}"
  
  cidr_block = "${lookup(var.subnet,"private_subnet_cidr_3")}"
  availability_zone = "ap-southeast-1c"

  tags = {
    Name = "Private Subnet 3 - az - 1c | Main VPC"
  }
}

#--------------------------------------------------------------
# Route table for public subnets
#--------------------------------------------------------------

resource "aws_route_table" "public-subnet-rt" {
	vpc_id = "${aws_vpc.main.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.gw.id}"
	}
}

resource "aws_route_table_association" "main_public_1a" {
	subnet_id = "${aws_subnet.main_public_1a.id}"
	route_table_id = "${aws_route_table.public-subnet-rt.id}"
}

resource "aws_route_table_association" "main_public_1b" {
	subnet_id = "${aws_subnet.main_public_1b.id}"
	route_table_id = "${aws_route_table.public-subnet-rt.id}"
}

resource "aws_route_table_association" "main_public_1c" {
	subnet_id = "${aws_subnet.main_public_1c.id}"
	route_table_id = "${aws_route_table.public-subnet-rt.id}"
}

#--------------------------------------------------------------
# Route table for private subnets
#--------------------------------------------------------------

resource "aws_route_table" "private-subnet-rt" {
	vpc_id = "${aws_vpc.main.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_nat_gateway.gw.id}"
	}
}

resource "aws_route_table_association" "main_private_1a" {
	subnet_id = "${aws_subnet.main_private_1a.id}"
	route_table_id = "${aws_route_table.private-subnet-rt.id}"
}

resource "aws_route_table_association" "main_private_1b" {
	subnet_id = "${aws_subnet.main_private_1b.id}"
	route_table_id = "${aws_route_table.private-subnet-rt.id}"
}

resource "aws_route_table_association" "main_private_1c" {
	subnet_id = "${aws_subnet.main_private_1c.id}"
	route_table_id = "${aws_route_table.private-subnet-rt.id}"
}

#--------------------------------------------------------------
# Network ACL
#--------------------------------------------------------------

resource "aws_network_acl" "all" {
   vpc_id = "${aws_vpc.main.id}"
    egress {
        protocol = "-1"
        rule_no = 2
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    ingress {
        protocol = "-1"
        rule_no = 1
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    tags {
        Name = "default nacl"
    }
}

#--------------------------------------------------------------
# SSH key pair
#--------------------------------------------------------------

resource "aws_key_pair" "ssh_key" {
  key_name = "ssh_key"
  public_key = "${var.ssh_public_key}"
}

#--------------------------------------------------------------
# Security Groups
#--------------------------------------------------------------

resource "aws_security_group" "alb" {
   name        = "allow_http"
   vpc_id      = "${aws_vpc.main.id}"

   ingress {
     from_port = 80
	 to_port = 80
	 protocol = "tcp"
	 
	 cidr_blocks = ["0.0.0.0/0"]
   }
   
   egress {
	 from_port = 0
	 to_port = 0
	 protocol = "-1"
	 
	 cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name = "ALB security group"
   }
}

resource "aws_security_group" "web_server" {
   name        = "allow_alb_only"
   vpc_id      = "${aws_vpc.main.id}"

   ingress {
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     
     security_groups = ["${aws_security_group.alb.id}"]
   }
   
   egress {
	 from_port = 0
	 to_port = 0
	 protocol = "-1"
	 
	 cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name = "Web server security group"
   }
}

#--------------------------------------------------------------
# Application Load Balancer
#--------------------------------------------------------------

resource "aws_lb" "alb" {
  name               	 = "${lookup(var.elb, "name")}"
  internal           	 = "${lookup(var.elb,"internal")}"
  load_balancer_type 	 = "${lookup(var.elb,"load_balancer_type")}"
  subnets            	 = ["${aws_subnet.main_public_1a.id}","${aws_subnet.main_public_1b.id}","${aws_subnet.main_public_1c.id}"]
  security_groups    	 = ["${aws_security_group.alb.id}"]

  tags = {
    Name 				 = "Application load balancer"
  }
}

resource "aws_lb_target_group" "alb_target_group" {  
  name     				 = "alb-target-group"  
  port     				 = "${lookup(var.elb, "port")}"  
  protocol 				 = "${lookup(var.elb, "protocol")}"  
  vpc_id   				 = "${aws_vpc.main.id}"   
  
  tags {    
    name 				 = "Load balancer target group"    
  }   
   
  health_check {    
    healthy_threshold    = "${lookup(var.elb, "healthy_threshold")}"    
    unhealthy_threshold  = "${lookup(var.elb, "unhealthy_threshold")}"    
    timeout              = "${lookup(var.elb, "timeout")}"    
    interval             = "${lookup(var.elb, "interval")}"    
    path                 = "${lookup(var.elb, "path")}"    
    port                 = "${lookup(var.elb, "port")}"
	matcher              = "${lookup(var.elb, "matcher")}"
  } 
}

resource "aws_lb_listener" "alb_listener" {  
  load_balancer_arn 	 = "${aws_lb.alb.arn}"  
  port              	 = "${lookup(var.elb, "port")}"  
  protocol          	 = "${lookup(var.elb, "protocol")}"
  
  default_action {    
    target_group_arn 	 = "${aws_lb_target_group.alb_target_group.arn}"
    type             	 = "forward"  
  }
}

#--------------------------------------------------------------
# Auto Scaling
#--------------------------------------------------------------

resource "aws_launch_configuration" "autoscale_launch" {
  image_id 					= "${lookup(var.ec2,"image_id")}"
  instance_type 			= "${lookup(var.ec2,"instance_type")}"
  security_groups 			= ["${aws_security_group.web_server.id}"]
  key_name 					= "${aws_key_pair.ssh_key.id}"
  user_data = <<-EOF
              #!/bin/bash
			  sudo su
              yum -y install httpd
              yum -y install php
			  cd /var/www/html
			  echo "<html>  \
			   <head>  \
               <title>PHP Test</title>  \
               </head>  \
               <body>  \
               <?php echo 'Hello World! from '; echo gethostname(); ?>  \
               </body>  \
               </html>" >> index.php
			  service httpd start
              EOF
}

resource "aws_autoscaling_group" "autoscale_group" {
  launch_configuration 		= "${aws_launch_configuration.autoscale_launch.id}"
  vpc_zone_identifier 		= ["${aws_subnet.main_private_1a.id}","${aws_subnet.main_private_1b.id}","${aws_subnet.main_private_1c.id}"]
  target_group_arns  	    = ["${aws_lb_target_group.alb_target_group.arn}"]
  min_size 					= "${lookup(var.autoscale,"min_size")}"
  max_size 					= "${lookup(var.autoscale,"max_size")}"
  health_check_grace_period = "${lookup(var.autoscale,"health_check_grace_period")}"
  health_check_type         = "${lookup(var.autoscale,"health_check_type")}"
  
  tag {
    key 					= "Name"
    value 					= "web instance"
    propagate_at_launch 	= true
  }
}

resource "aws_autoscaling_policy" "scale-up" {
  name 						= "scale up policy"
  scaling_adjustment 		= 1
  adjustment_type 			= "ChangeInCapacity"
  cooldown 					= "${lookup(var.autoscale,"cooldown")}"
  autoscaling_group_name 	= "${aws_autoscaling_group.autoscale_group.name}"
}

resource "aws_autoscaling_policy" "scale-down" {
  name 						= "scale down policy"
  scaling_adjustment 		= -1
  adjustment_type 			= "ChangeInCapacity"
  cooldown 					= "${lookup(var.autoscale,"cooldown")}"
  autoscaling_group_name 	= "${aws_autoscaling_group.autoscale_group.name}"
}

#--------------------------------------------------------------
# Cloudwatch Alarm
#--------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name                = "EC2 cpu usage high"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "${lookup(var.cloudwatch,"evaluation_periods")}"
  metric_name               = "${lookup(var.cloudwatch,"metric_name")}"
  namespace                 = "${lookup(var.cloudwatch,"namespace")}"
  period                    = "${lookup(var.cloudwatch,"period")}"
  statistic                 = "${lookup(var.cloudwatch,"statistic")}"
  threshold                 = "${lookup(var.cloudwatch,"high_threshold")}"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  
  dimensions {
	AutoScalingGroupName 	= "${aws_autoscaling_group.autoscale_group.name}"
  }

  alarm_description 		= "This metric monitor EC2 instance cpu utilization"
  alarm_actions 			= ["${aws_autoscaling_policy.scale-up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_normal_alarm" {
  alarm_name                = "EC2 cpu usage normal"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "${lookup(var.cloudwatch,"evaluation_periods")}"
  metric_name               = "${lookup(var.cloudwatch,"metric_name")}"
  namespace                 = "${lookup(var.cloudwatch,"namespace")}"
  period                    = "${lookup(var.cloudwatch,"period")}"
  statistic                 = "${lookup(var.cloudwatch,"statistic")}"
  threshold                 = "${lookup(var.cloudwatch,"low_threshold")}"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  
  dimensions {
	AutoScalingGroupName 	= "${aws_autoscaling_group.autoscale_group.name}"
  }

  alarm_description			= "This metric monitor EC2 instance cpu utilization"
  alarm_actions 			= ["${aws_autoscaling_policy.scale-down.arn}"]
}  

#--------------------------------------------------------------
# Attach auto Scaling to Load Balancer
#--------------------------------------------------------------

resource "aws_autoscaling_attachment" "alb_autoscale" {
  alb_target_group_arn   	= "${aws_lb_target_group.alb_target_group.arn}"
  autoscaling_group_name 	= "${aws_autoscaling_group.autoscale_group.id}"
}
