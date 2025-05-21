resource "aws_lb" "alb-livechat" {
  name               = "alb-livechat"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "app_alb_listener" {
  load_balancer_arn = aws_lb.alb-livechat.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 8080              # Porta do seu app na instância
  protocol = "HTTP"
  vpc_id   = aws_vpc.livechat-vpc.id
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "8080"
  }
  target_type = "ip"
}
