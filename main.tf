locals {
  env_namespace         = join("_", [var.org_name, var.team_name, var.project_id, var.env["dev"]])
  general_namespace     = join("_", [var.org_name, var.team_name, var.project_id])
  #s3 bucket naming based on best practices: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
  s3_bucket_namespace   = join("-", [var.org_name, var.team_name, var.project_id, var.env["dev"]])
  tags = {
    "Owner"       = var.team_name
    "Environment" = var.env["dev"]
    "Name"        = join("_", [var.org_name, var.team_name, var.project_id])
  }
}
data "aws_region" "current" {}

resource "aws_resourcegroups_group" "resourcegroups_group" {
  name = "${local.general_namespace}-group"
  resource_query {
    query = <<JSON
    {
      "ResourceTypeFilters": [
        "AWS::AllSupported"
      ],
      "TagFilters": [
        {
          "Key": "ResourceGroup",
          "Values": ["${local.general_namespace}"]
        }
      ]
    }
    JSON
  }
}

resource "aws_kms_key" "kms_key" {
  tags = {
    ResourceGroup = local.general_namespace
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${local.s3_bucket_namespace}-state-bucket"
  force_destroy = var.force_destroy_state
  versioning {
    enable = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorith = "aws:kms"
        kms_master_key_id = aws_kms_key.kms_key.arn
      }
    }
  }
  tags = {
    ResourceGroup = local.general_namespace
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "dynamodb_table" {
  name  = "${local.general_namespace}-state-lock"
  hash_key = "StateLockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "StateLockID"
    type = "S"
  }
  tags = {
    ResourceGroup = local.general_namespace
  }
}