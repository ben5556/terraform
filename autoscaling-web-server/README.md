# terraform

This script sets up an auto scaling web server environment in a private subnet running behind a load balancer (deployed in public subnet).

Script Creates the following resources in AWS:

1) VPC
2) 2Private & Public subnets
3) Internet & NAT Gateway
4) Route tables
5) Security Groups
6) Application Load Balancer
7) Auto Scaling EC2 instances with: User Data script to install Apache web server and display a simple Hello World HTML page.

