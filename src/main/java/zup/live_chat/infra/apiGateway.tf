resource "aws_apigatewayv2_api" "livechat" {
  name                       = "livechat"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_integration" "alb_integration" {
  api_id                  = aws_apigatewayv2_api.livechat.id
  integration_type        = "HTTP_PROXY"
  integration_method      = "ANY"
  integration_uri         = "http://${aws_lb.alb-livechat.dns_name}:80/"
  payload_format_version  = "1.0"
  description             = "Proxy for ALB/ECS Fargate"
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

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.livechat_apigateway.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      ip                      = "$context.identity.sourceIp"
      caller                  = "$context.identity.caller"
      user                    = "$context.identity.user"
      requestTime             = "$context.requestTime"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      protocol                = "$context.protocol"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
  default_route_settings {
    logging_level = "INFO"
    data_trace_enabled = true
  }
}

# OnConnect
resource "aws_apigatewayv2_route" "ConnectRoute" {
  api_id         = aws_apigatewayv2_api.livechat.id
  route_key      = "$connect"
  operation_name = "ConnectRoute"
  target         = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

# OnDisconnect
resource "aws_apigatewayv2_route" "DisconnectRoute" {
  api_id         = aws_apigatewayv2_api.livechat.id
  route_key      = "$disconnect"
  operation_name = "DisconnectRoute"
  target         = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

# SendMessage
resource "aws_apigatewayv2_route" "SendRoute" {
  api_id         = aws_apigatewayv2_api.livechat.id
  route_key      = "sendmessage"
  operation_name = "SendRoute"
  target         = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}