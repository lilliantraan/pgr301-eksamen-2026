output "service_url" {
  description = "Offentlig adresse til tjenesten"
  value       = aws_ecs_express_gateway_service.app.ingress_paths[0].endpoint
}

output "bucket_name" {
  description = "S3-bucket for opplastede bilder"
  value       = aws_s3_bucket.images.bucket
}
