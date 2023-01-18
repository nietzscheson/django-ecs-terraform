# resource "aws_s3_bucket" "default" {
#   bucket = local.name
# 
#   acl = "public-read"
#   policy = <<EOF
#     {
#         "Version": "2012-10-17",
#         "Statement": [
#             {
#             "Sid": "PublicReadGetObject",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::${local.name}/*"
#             }
#         ]
#     }
#   EOF
# 
#   versioning {
#     enabled = true
#   }
# }

resource "aws_s3_bucket" "default" {
  bucket = local.name
}

# resource "aws_s3_bucket_acl" "default" {
#   bucket = aws_s3_bucket.default.id
#   acl    = "private"
# }
# 
# resource "aws_s3_bucket_versioning" "default" {
#   bucket = aws_s3_bucket.default.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }