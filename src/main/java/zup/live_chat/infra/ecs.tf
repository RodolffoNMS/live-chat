resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}

resource "aws_ecs_task_definition" "fargate_task" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = "app"
    image = "public.ecr.aws/l2o0d1c9/livechat-backend:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_service" "fargate_service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.fargate_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.private.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.livechat-vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

