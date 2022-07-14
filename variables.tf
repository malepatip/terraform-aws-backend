#Values are retrived from terraform.tfvars file
variable "org_name" {
  description = "Your Organization name"
  type        = string
}
variable "team_name" {
  description = "Your Team name"
  type        = string
}
variable "project_id" {
  description = "Your Project ID"
  type        = string
}
variable "env" {
  description = "Your deployment environment"
  type        = map(any)
  default = {
    "dev" = "dev"
  }
}
variable "region" {
  description = "Your AWS Region"
  type        = string
}
variable "principal_arns" {
  description = "List of principle arns allowed to assume the IAM role"
  default     = null
  type        = list(string)
}
variable "force_destroy_state" {
  description = "Force destroy the s3 bucket containing state files"
  default     = true
  type        = bool
}
