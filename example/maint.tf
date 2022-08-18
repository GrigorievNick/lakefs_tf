module "lakefs" {
  source = "../tf_module"

  mandatory_tags = {}
  default_tag  ="hello"

  aws_account_id = "xxx"
  region = "eu-west-1"
  subnet_ids = [xxx]
  vpc_id     = "vpc-xxx"
  db_instance_type = "db.m6i.2xlarge"
  ec2_instance_type = "m5.2xlarge"
  lakefs_bucket = ""
}