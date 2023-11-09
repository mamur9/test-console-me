
variable "region" {
  description = "The AWS region for these resources, such as us-east-1."
}

variable "consoleme_instance_identifier" {
  type        = list(string)
  default     = []
}

variable "profile" {
  description = "The AWS profile"
}