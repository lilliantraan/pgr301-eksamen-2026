locals {
  # Må være lik namespace i MetricsConfig.java
  metrics_namespace = local.name
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = local.name

  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "text", x = 0, y = 0, width = 24, height = 1
        properties = { markdown = "## Forretning: bruk og kvalitet" }
      },
      {
        type = "metric", x = 0, y = 1, width = 12, height = 6
        properties = {
          title   = "Analyserte bilder (sum per 5 min)"
          region  = var.region
          view    = "timeSeries"
          stat    = "Sum"
          period  = 300
          metrics = [[local.metrics_namespace, "wishifai.images.analyzed.count", { label = "Bilder" }]]
        }
      },
      {
        type = "metric", x = 12, y = 1, width = 12, height = 6
        properties = {
          title  = "Gaveforslag per analyse (snitt per 5 min)"
          region = var.region
          view   = "timeSeries"
          period = 300
          metrics = [
            [local.metrics_namespace, "wishifai.suggestions.per.analysis.sum", { id = "s", stat = "Sum", visible = false }],
            [local.metrics_namespace, "wishifai.suggestions.per.analysis.count", { id = "c", stat = "Sum", visible = false }],
            [{ expression = "s / c", id = "snitt", label = "Forslag per bilde" }]
          ]
        }
      },
      {
        type       = "text", x = 0, y = 7, width = 24, height = 1
        properties = { markdown = "## Hvor blir tiden av? Rekognition vs Bedrock" }
      },
      {
        type = "metric", x = 0, y = 8, width = 12, height = 6
        properties = {
          title  = "Responstid, snitt (ms)"
          region = var.region
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          metrics = [
            [local.metrics_namespace, "wishifai.rekognition.duration.avg", { label = "Rekognition" }],
            [local.metrics_namespace, "wishifai.bedrock.duration.avg", { label = "Bedrock" }]
          ]
          annotations = {
            horizontal = [{ label = "Alarmterskel", value = var.bedrock_alarm_threshold_ms }]
          }
        }
      },
      {
        type = "metric", x = 12, y = 8, width = 12, height = 6
        properties = {
          title  = "Responstid, tregeste kall (ms)"
          region = var.region
          view   = "timeSeries"
          stat   = "Maximum"
          period = 60
          metrics = [
            [local.metrics_namespace, "wishifai.rekognition.duration.max", { label = "Rekognition" }],
            [local.metrics_namespace, "wishifai.bedrock.duration.max", { label = "Bedrock" }]
          ]
        }
      },
      {
        type       = "text", x = 0, y = 14, width = 24, height = 1
        properties = { markdown = "## Applikasjon: Spring Boot Actuator" }
      },
      {
        type = "metric", x = 0, y = 15, width = 8, height = 6
        properties = {
          title  = "HTTP-responstid /api/analyze (ms)"
          region = var.region
          view   = "timeSeries"
          period = 60
          metrics = [[{
            expression = "SEARCH('Namespace=\"${local.metrics_namespace}\" MetricName=\"http.server.requests.avg\" uri=\"/api/analyze\"', 'Average', 60)"
            id         = "http"
          }]]
        }
      },
      {
        type = "metric", x = 8, y = 15, width = 8, height = 6
        properties = {
          title  = "JVM heap brukt (bytes)"
          region = var.region
          view   = "timeSeries"
          period = 60
          metrics = [
            [{ expression = "SEARCH('Namespace=\"${local.metrics_namespace}\" MetricName=\"jvm.memory.used.value\" area=\"heap\"', 'Maximum', 60)", id = "heap", visible = false }],
            [{ expression = "SUM(heap)", id = "heapsum", label = "Heap totalt" }]
          ]
        }
      },
      {
        type = "metric", x = 16, y = 15, width = 8, height = 6
        properties = {
          title   = "CPU-bruk i Java-prosessen (0-1)"
          region  = var.region
          view    = "timeSeries"
          stat    = "Average"
          period  = 60
          metrics = [[local.metrics_namespace, "process.cpu.usage.value", { label = "CPU" }]]
        }
      },
      {
        type       = "text", x = 0, y = 21, width = 24, height = 1
        properties = { markdown = "## Infrastruktur: ECS Express" }
      },
      {
        type = "metric", x = 0, y = 22, width = 12, height = 6
        properties = {
          title  = "CPU og minne i containeren (%)"
          region = var.region
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", local.name, "ClusterName", "default", { label = "CPU" }],
            ["AWS/ECS", "MemoryUtilization", "ServiceName", local.name, "ClusterName", "default", { label = "Minne" }]
          ]
        }
      },
      {
        type = "metric", x = 12, y = 22, width = 12, height = 6
        properties = {
          title   = "Kjørende containere"
          region  = var.region
          view    = "timeSeries"
          stat    = "Maximum"
          period  = 60
          metrics = [["AWS/ECS", "LiveTaskCount", "ServiceName", local.name, "ClusterName", "default", { label = "Tasks" }]]
        }
      }
    ]
  })
}

