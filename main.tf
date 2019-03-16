terraform {
  backend "s3" {
    region = "eu-west-1"
    bucket = "infrastructure.noodlesandwich.com"
    key    = "terraform/state/monospacedmonologues.com"
  }
}

locals {
  domain = "monospacedmonologues.com"
}

provider "aws" {
  region = "eu-west-1"
}

provider "cloudflare" {}

resource "aws_s3_bucket" "assets" {
  bucket = "assets.${local.domain}"
}

resource "aws_cloudfront_distribution" "assets_distribution" {
  enabled = true
  aliases = ["assets.${local.domain}"]

  origin {
    domain_name = "${aws_s3_bucket.assets.bucket_regional_domain_name}"
    origin_id   = "S3-${aws_s3_bucket.assets.id}"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.assets.id}"

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "cloudflare_record" "assets" {
  domain  = "${local.domain}"
  name    = "assets"
  type    = "CNAME"
  value   = "${aws_cloudfront_distribution.assets_distribution.0.domain_name}"
  proxied = true
}
