resource "aws_security_group" "app" {
  name        = "${var.prefix}-app"
  description = "Allow inbound app traffic"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${var.prefix}-app" }
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.app.id
  description       = "App port from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8000
  to_port           = 8000
}

resource "aws_vpc_security_group_egress_rule" "all" {
  ip_protocol       = "-1"
  security_group_id = aws_security_group.app.id
  description       = "All outbound"
  cidr_ipv4         = "0.0.0.0/0"
}
