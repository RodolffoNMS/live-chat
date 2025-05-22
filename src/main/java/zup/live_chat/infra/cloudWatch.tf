resource "aws_cloudwatch_log_group" "livechat_apigateway" {
  name = "/aws/apigateway/livechat"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ecs_livechat" {
  name              = "/ecs/my-app"
  retention_in_days = 7
}