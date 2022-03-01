resource "aws_cloudwatch_log_group" "log-group" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_stream" "log-stream" {
  name           = "${var.name}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log-group.name
}

resource "aws_cloudwatch_log_group" "nginx-log-group" {
  name              = "/ecs/${var.name}-nginx"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_stream" "nginx-log-stream" {
  name           = "${var.name}-nginx-log-stream"
  log_group_name = aws_cloudwatch_log_group.nginx-log-group.name
}