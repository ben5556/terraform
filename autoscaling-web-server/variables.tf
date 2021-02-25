#--------------------------------------------------------------
# Master variables file
#--------------------------------------------------------------

variable "aws_access_key" {
  default = "<your_aws_access_key_here>"
}

variable "aws_secret_key" {
  default = "<your_aws_access_key_here>"
}

variable "aws_region" {
  default = "<your_aws_region_here>"
}

variable "vpc_cidr" {
  default = "10.0.0.0/20"
}

variable "ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9QgATSGApta4xRsb6wzsiMjRlPwukmWifD4q1sWN0iBNBBHHhtD7QwbmVMaa1ZJpUjBgb7XxmYBmYUUXec7d57nrQYsargwKb8MWpKw8nvZ+VkXQK+mrwTfpBaCpQUm8VvXZDmuH0EPY6Mng/gN/U3xd/VqKKonqUY9PLao6QRMEBCzssphU7SegYLjAgjvJJtexsRHmQ0j4VprFntZWQH8IBzc1Hs5i4zQ+P/zhhu8EDAZd14luorqy6ffn7nxcpTAxbD0CJpXyPMD7SeuzJt7n4GBtFKwYdAypMExQqlgnGeM/aSEH4qVQNQ29XAWw+4kgZ/BFi6Dfpke9CnyaF"
}  

variable "subnet" {  
  type = "map"

  default = {
    public_subnet_cidr_1 = "10.0.1.0/24"
	public_subnet_cidr_2 = "10.0.2.0/24"
	public_subnet_cidr_3 = "10.0.3.0/24"
	
	private_subnet_cidr_1 = "10.0.4.0/24"
	private_subnet_cidr_2 = "10.0.5.0/24"
	private_subnet_cidr_3 = "10.0.6.0/24"
  }
}

variable "ec2" {  
  type = "map"

  default = {
    image_id = "ami-0b419c3a4b01d1859"
	instance_type = "t2.micro"
  }
}

variable "autoscale" {  
  type = "map"

  default = {
    min_size = 2
	max_size = 4
	health_check_grace_period = 300
	health_check_type         = "ELB"
	cooldown = 300
  }
}

variable "elb" {  
  type = "map"

  default = {
    name     = "web-elb"
    internal = "false"
	load_balancer_type = "application"
	port     = "80"  
    protocol = "HTTP"
	healthy_threshold   = 3    
    unhealthy_threshold = 3    
    timeout             = 10    
    interval            = 30    
    path                = "/"
	matcher             = "200"
  }
}

variable "cloudwatch" {  
  type = "map"

  default = {
    evaluation_periods        = "2"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/EC2"
    period                    = "120"
    statistic                 = "Average"
    high_threshold            = "80"
	low_threshold             = "10"
  }
}

variable "elb_targetgroup" {
  type = "map"
  
  default = {
    target_type = "lambda"
	health_check_path                = "/"
	health_check_port                = 80
    health_check_interval            = 30
    health_check_healthy_threshold   = 2
    health_check_unhealthy_threshold = 2
    health_check_timeout             = 5
	health_check_matcher             = "200"
  } 	
}