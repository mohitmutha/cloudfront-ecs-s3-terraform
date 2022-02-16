locals {
  s3_origin_id = "cloudfront-ecs-demo-webapp-origin"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "cloudfront-ecs-demo-webapp-origin"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "cloudfront-ecs-demo-webapp"
  default_root_object = "index.html"
  origin {
    domain_name = aws_s3_bucket.cf-s3-ecs-demo-bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  
  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "IN", "IR"]
    }
  }

  tags = {
    Environment = "development"
    Name        = "my-tag"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront_dns" {
  value = aws_cloudfront_distribution.cf_distribution.domain_name
}

data "aws_iam_policy_document" "cf_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cf-s3-ecs-demo-bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cf_s3_bucket_policy" {
  bucket = aws_s3_bucket.cf-s3-ecs-demo-bucket.id
  policy = data.aws_iam_policy_document.cf_s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "cf_s3_bucket_acl" {
  bucket = aws_s3_bucket.cf-s3-ecs-demo-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  //ignore_public_acls      = true
  //restrict_public_buckets = true
}