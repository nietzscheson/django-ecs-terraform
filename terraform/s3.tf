#resource "aws_s3_bucket" "default" {
#  bucket = local.name
#  force_destroy = true
#}
#
#resource "aws_s3_bucket_versioning" "default" {
#  bucket = aws_s3_bucket.default.id
#  versioning_configuration {
#    status = "Enabled"
#  }
#}
#
#resource "aws_s3_bucket_policy" "default" {
#  bucket = aws_s3_bucket.default.id
#
#  policy = jsonencode({
#    "Version": "2012-10-17",
#    "Statement": [
#      {
#        "Sid": "PublicReadGetObject",
#        "Effect": "Allow",
#        "Principal": "*",
#        "Action": "s3:GetObject",
#        "Resource": "arn:aws:s3:::${local.name}/*"
#      }
#    ]
#  })
#}
#
#resource "aws_s3_bucket_cors_configuration" "default" {
#  bucket = aws_s3_bucket.default.id
#
#  cors_rule {
#    allowed_headers = ["*"]
#    allowed_methods = ["GET"]
#    allowed_origins = ["*"]
#    max_age_seconds = 3000
#  }
#}