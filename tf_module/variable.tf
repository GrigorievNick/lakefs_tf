## General
variable "aws_account_id" {
  type        = string
  description = "Needed for Guards to ensure code is being deployed to the correct account"
}

variable "region" {
  type        = string
  description = "The default region for the application / deployment"
  default = "eu-west-1"
}

variable "naming_prefix" {
  type = string
  default = "lakefs-eu1-prd-"
}

variable "mandatory_tags" {
  type        = map(string)
  description = "Default tags added to all resources, this will be added to the provider"
}
variable "lakefs_bucket" {
  type = string
  description = "s3 bucket to store lakefs namespace info"
}
## Network configuration
variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ec2_instance_type" {
  type = string
}
## LakeFS RDS configuration
variable "db_instance_type" {
  type = string
}
variable "rds_admin_user" {
  type    = string
  default = "lakefs_admin"
}

variable "rds_admin_password" {
  type      = string
  sensitive = true
  default = "lakefs_admin"
}

variable "rds_snapshot_id" {
  description = "Optional RDS Snapshot ID to restore from"
  type        = string
  default     = ""
}