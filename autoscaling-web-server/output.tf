
output "elb-dns" {
	value = "${aws_lb.alb.dns_name}"
}