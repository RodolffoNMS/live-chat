#ecs
resource "aws_iam_role" "ecs_service_role" {
  name = "ecsServiceRole"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_service_attach" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
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
#

#api gateway
resource "aws_iam_policy" "apigatewayv2_basic" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:PUT",
          "apigateway:DELETE"
        ]
        Resource = "arn:aws:apigateway:${var.region}::/*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_apigatewayv2_basic" {
  user       = var.user
  policy_arn = aws_iam_policy.apigatewayv2_basic.arn
}
#

# load balancer
resource "aws_iam_policy" "alb_describe_access" {
  name        = "AlbFullAccessPolicy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "alb_policy_attachment" {
  user       = var.user
  policy_arn = aws_iam_policy.alb_describe_access.arn
}

# security groups
resource "aws_iam_policy" "manage_security_groups" {
  name        = "ManageSecurityGroups"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:*"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "admin_manage_sg" {
  user       = var.user
  policy_arn = aws_iam_policy.manage_security_groups.arn
}
#

resource "aws_iam_policy" "manage_iam_role_policy" {
  description = "allow role management"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:DetachRolePolicy",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:CreatePolicy",
          "iam:ListInstanceProfiles",
          "iam:GetLoginProfile",
          "iam:ListInstanceProfilesForRole",
          "iam:GetPolicyVersion",
          "iam:ListUserPolicies",
          "iam:ListRoles",
          "iam:ListPolicyVersions",
          "iam:DeleteRole",
          "iam:DeletePolicy",
          "iam:AttachUserPolicy",
          "iam:PassRole"
        ]
        Resource = "arn:aws:iam::561605471088:role/*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "admin_iam_role_policy" {
  user       = var.user
  policy_arn = aws_iam_policy.manage_iam_role_policy.arn
}