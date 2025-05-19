# 1. Security Group para o ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP and HTTPS"
  vpc_id      = aws_vpc.livechat-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Target Group (grupo de destino para o tráfego do ALB)
resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.livechat-vpc.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# 3. Application Load Balancer
resource "aws_lb" "alb-livechat" {
  name               = "ALB-livechat"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id]

  enable_deletion_protection = false
}

# 4. Listener para o ALB (porta 8080)
resource "aws_lb_listener" "app_alb_listener" {
  load_balancer_arn = aws_lb.alb-livechat.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}