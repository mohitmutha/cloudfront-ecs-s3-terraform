resource "aws_lb_target_group" "my_api" {
  name        = "my-api"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.prod_vpc.id

  health_check {
    enabled = true
    path    = "/health"
  }

  depends_on = [aws_alb.my_api]
}

resource "aws_alb" "my_api" {
  name               = "my-api-lb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.egress_all.id,
  ]

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_alb_listener" "my_api_http" {
  load_balancer_arn = aws_alb.my_api.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_api.arn
  }
}

output "alb_url" {
  value = "http://${aws_alb.my_api.dns_name}"
}