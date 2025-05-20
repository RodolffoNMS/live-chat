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

  execution_arn = aws_iam_role.apigateway_cloudwatch.arn
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