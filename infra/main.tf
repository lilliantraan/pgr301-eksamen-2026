locals {
  name                    = "wishifai-${var.candidate_number}"
  execution_role_arn      = "arn:aws:iam::244530008913:role/ecsTaskExecutionRole"
  infrastructure_role_arn = "arn:aws:iam::244530008913:role/service-role/ecsInfrastructureRoleForExpressServices"
}

data "aws_ecr_repository" "app" {
  name = local.name
}

resource "aws_s3_bucket" "images" {
  bucket        = "${local.name}-images"
  force_destroy = true
}

resource "aws_ecs_express_gateway_service" "app" {
  service_name            = local.name
  execution_role_arn      = local.execution_role_arn
  infrastructure_role_arn = local.infrastructure_role_arn
  task_role_arn           = aws_iam_role.task.arn
  health_check_path       = "/api/health"
  wait_for_steady_state   = true

  primary_container {
    image          = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
    container_port = 8080

    environment {
      name  = "AWS_REGION"
      value = var.region
    }

    environment {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.images.bucket
    }
  }

  scaling_target {
    auto_scaling_metric       = "AVERAGE_CPU"
    auto_scaling_target_value = 60
    min_task_count            = 1
    max_task_count            = 2
  }

  depends_on = [aws_iam_role_policy.task]
}
