variable "region" {
  description = "AWS-regionen ressursene opprettes i"
  type        = string
  default     = "eu-west-1"
}

variable "candidate_number" {
  description = "Kandidatnummer, brukes for unike ressursnavn"
  type        = string
  default     = "49"
}

variable "image_tag" {
  description = "Image-taggen i ECR som skal deployes (commit-SHA)"
  type        = string
}

variable "alarm_email" {
  description = "E-postadresse som får varsel når alarmen utløses"
  type        = string
}

variable "bedrock_alarm_threshold_ms" {
  description = "Alarmterskel for gjennomsnittlig responstid fra Bedrock, i millisekunder"
  type        = number
  default     = 20000
}