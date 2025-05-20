resource "aws_apigatewayv2_api" "livechat" {
  name                       = "livechat"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_deployment" "Deployment" {
  api_id = aws_apigatewayv2_api.livechat.id

  depends_on = [
    aws_apigatewayv2_route.ConnectRoute,
    aws_apigatewayv2_route.DisconnectRoute,
    aws_apigatewayv2_route.SendRoute,
  ]
}

resource "aws_apigatewayv2_stage" "Stage" {
  api_id        = aws_apigatewayv2_api.livechat.id
  name          = "Prod"
  description   = "Prod Stage"
  deployment_id = aws_apigatewayv2_deployment.Deployment.id
}

# OnConnect
resource "aws_apigatewayv2_integration" "ConnectIntegrat" {
  api_id             = aws_apigatewayv2_api.livechat.id
  integration_type   = "AWS_PROXY"
  description        = "Connect Integration"
  integration_uri    = "http://${aws_lb.alb-livechat.dns_name}/connect"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "ConnectRoute" {
  api_id         = aws_apigatewayv2_api.livechat.id
  route_key      = "$connect"
  operation_name = "ConnectRoute"
  target         = "integrations/${aws_apigatewayv2_integration.ConnectIntegrat.id}"
}

# OnDisconnect
resource "aws_apigatewayv2_integration" "DisconnectInteg" {
  api_id             = aws_apigatewayv2_api.livechat.id
  integration_type   = "AWS_PROXY"
  description        = "Disconnect Integration"
  integration_uri    = "http://${aws_lb.alb-livechat.dns_name}/Disconnect"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "DisconnectRoute" {
  api_id         = aws_apigatewayv2_api.livechat.id
  route_key      = "$disconnect"
  operation_name = "DisconnectRoute"
  target         = "integrations/${aws_apigatewayv2_integration.DisconnectInteg.id}"
}

# SendMessage
resource "aws_apigatewayv2_integration" "SendInteg" {
  api_id             = aws_apigatewayv2_api.livechat.id
  integration_type   = "AWS_PROXY"
  description        = "Send Integration"
  integration_uri    = "http://${aws_lb.alb-livechat.dns_name}/sendMessage"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "SendRoute" {
  api_id         = aws_apigatewayv2_api.livechat.id
  route_key      = "sendmessage"
  operation_name = "SendRoute"
  target         = "integrations/${aws_apigatewayv2_integration.SendInteg.id}"
}

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

# Exemplo: Anexando a policy ao usuário admin
resource "aws_iam_user_policy_attachment" "attach_apigatewayv2_basic" {
  user       = "matheus 2k25"
  policy_arn = aws_iam_policy.apigatewayv2_basic.arn
}