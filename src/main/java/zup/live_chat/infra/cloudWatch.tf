resource "aws_cloudwatch_log_group" "livechat_apigateway" {
  name = "/aws/apigateway/livechat"
  retention_in_days = 14
}