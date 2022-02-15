locals {
  s3_origin_id = "cloudfront-ecs-demo-webapp-origin"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "cloudfront-ecs-demo-webapp-origin"
}


