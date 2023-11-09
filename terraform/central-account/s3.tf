resource "random_string" "omnipotence" {
  length  = 4
  special = false
  number  = false
  upper   = false
}

resource "aws_s3_bucket" "consoleme_files_bucket" {
  bucket = "${lower(var.bucket_name_prefix)}-${random_string.omnipotence.result}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true
  tags          = merge(tomap({ "Name" = var.bucket_name_prefix }), var.default_tags)
}

resource "aws_s3_bucket_object" "consoleme_config" {
  bucket = aws_s3_bucket.consoleme_files_bucket.bucket
  key    = "config.yaml"

  content = templatefile("${path.module}/templates/example_config_terraform.yaml", tomap({
    account                           = var.account
    account-dev                       = var.account-dev
    account-ent                       = var.account-ent
    account-label                     = var.account-label
    account-dev-label                 = var.account-dev-label
    account-ent-label                 = var.account-ent-label
    slack-webhook-url                 = var.slack-webhook-url
    application_admin                 = var.application_admin
    region                            = data.aws_region.current.name
    jwt_email_key                     = var.lb-authentication-jwt-email-key
    jwt_groups_key                    = var.lb-authentication-jwt-groups-key
    user_facing_url                   = var.user_facing_url == "" ? "https://${aws_lb.public-to-private-lb.dns_name}:${var.lb_port}" : var.user_facing_url
    logout_url                        = var.logout_url
  }))
}
