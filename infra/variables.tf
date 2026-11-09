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
