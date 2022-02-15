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

resource "aws_s3_object" "website-public" {
  for_each = fileset("../client/public", "**/*.*")
  bucket = aws_s3_bucket.cf-s3-ecs-demo-bucket.id
  key = each.key
  source = "../client/public/${each.value}"
  etag = filemd5("../client/public/${each.value}")
}