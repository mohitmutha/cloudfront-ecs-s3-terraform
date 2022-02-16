resource "aws_s3_bucket" "cf-s3-ecs-demo-bucket" {
  bucket = "cf-s3-ecs-demo-bucket"

  tags = {
    Name        = "cf-s3-ecs-demo-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "cf-s3-ecs-demo-bucket" {
  bucket = aws_s3_bucket.cf-s3-ecs-demo-bucket.id
  acl    = "private"
}

locals {
  mime_types = jsondecode(file("${path.module}/mime.json"))
}

resource "aws_s3_object" "website-public" {
  for_each = fileset("../client/build", "**/*.*")
  bucket = aws_s3_bucket.cf-s3-ecs-demo-bucket.id
  key = each.key
  source = "../client/build/${each.value}"
  etag = filemd5("../client/build/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
}
