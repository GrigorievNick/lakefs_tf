resource "aws_iam_role" "lakefs_server" {
  name = "${var.naming_prefix}-lakefs-demo-server"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.naming_prefix}-lakefs-demo-server"
  }
}

resource "aws_iam_role_policy_attachment" "lakefs_server" {
  role       = aws_iam_role.lakefs_server.name
  policy_arn = aws_iam_policy.lakefs.arn
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.lakefs_server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "lakefs_server" {
  name = "${var.naming_prefix}lakefs-demo-server"
  role = aws_iam_role.lakefs_server.name
}

resource "aws_iam_policy" "lakefs" {
  name = "${var.naming_prefix}-lakefs-demo"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version   = "2012-10-17"
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = [
          data.aws_s3_bucket.lakefs.arn,
          "${data.aws_s3_bucket.lakefs.arn}/*",
        ]
      }
    ]
  })
}