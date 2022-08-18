# This will cause state changes per user, but meh.
# It is just to test that we can get to lakeFS / etc for debugging any issue.
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
locals {
  legacy_cidr_block         = ["10.0.0.0/8"]
  cato_vpn_cidr_block       = ["172.29.0.0/16"]
  global_protect_cidr_block = ["100.127.0.0/16"]
  af_allowed_cidr_blocks = concat(local.global_protect_cidr_block, local.cato_vpn_cidr_block, local.legacy_cidr_block)
}
##################################
# Security Groups
##################################
resource "aws_security_group" "sg_server" {
  name   = "Allow EC2 access"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "allow_my_ip_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = local.af_allowed_cidr_blocks
  security_group_id = aws_security_group.sg_server.id
}

# Allow ingress to UI
resource "aws_security_group_rule" "allow_my_ip_8000" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = local.af_allowed_cidr_blocks
  security_group_id = aws_security_group.sg_server.id
}

resource "aws_security_group_rule" "allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_server.id
}

##################################
# AMI
##################################

data "aws_ami" "amzn2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

##################################
# Server Instance
##################################

# Lookup the RDS as it could have been created from a snapshot
data "aws_db_instance" "lakefs" {
  db_instance_identifier = local.rds_identifier
  depends_on             = [
    aws_db_instance.lakefs,
    aws_db_instance.lakefs_from_snapshot,
  ]
}

resource "aws_instance" "server" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.sg_server.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.lakefs_server.name

  user_data = templatefile(
    "${path.module}/server-cloud-init.yaml",
    {
      # TODO using the rds admin user for convenience
      database_connection_string = format(
        "postgresql://%s:%s@%s/%s",
        var.rds_admin_user,
        var.rds_admin_password,
        data.aws_db_instance.lakefs.endpoint,
        data.aws_db_instance.lakefs.db_name
      )
      region             = var.region
      account_id         = var.aws_account_id
      encrypt_secret_key = "1111"
    })
  tags = {
    // TODO naming automatic
    Name                 = "af-eu1-prd-lakefs-server"
  }
}