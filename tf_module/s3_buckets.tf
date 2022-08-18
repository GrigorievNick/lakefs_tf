data "aws_s3_bucket" "lakefs" {
  bucket = var.lakefs_bucket
}
