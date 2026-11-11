resource "aws_sns_topic" "alarms" {
  name = "${local.name}-alarms"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "bedrock_slow" {
  alarm_name        = "${local.name}-bedrock-slow"
  alarm_description = "Bedrock bruker i snitt mer enn ${var.bedrock_alarm_threshold_ms} ms i minst 3 av de siste 5 minuttene."

  namespace   = local.metrics_namespace
  metric_name = "wishifai.bedrock.duration.avg"
  statistic   = "Average"
  period      = 60

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.bedrock_alarm_threshold_ms
  evaluation_periods  = 5
  datapoints_to_alarm = 3
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}
