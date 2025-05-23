resource "aws_lb" "nlb-livechat" {
  name               = "nlb-livechat"
  load_balancer_type = "network"
  internal           = false
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "app_tg" {
  name        = "app-tg"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = aws_vpc.livechat-vpc.id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    port                = "8080"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb-livechat.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}