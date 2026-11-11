output "service_url" {
  description = "Offentlig adresse til tjenesten"
  value       = aws_ecs_express_gateway_service.app.ingress_paths[0].endpoint
}

output "bucket_name" {
  description = "S3-bucket for opplastede bilder"
  value       = aws_s3_bucket.images.bucket
}

output "dashboard_url" {
  description = "Lenke til CloudWatch-dashbordet"
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards/dashboard/${aws_cloudwatch_dashboard.main.dashboard_name}"
}
