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

resource "aws_s3_bucket" "site" {
  bucket = "${local.domain}"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "assets" {
  bucket = "assets.${local.domain}"
}

resource "aws_cloudfront_distribution" "site_distribution" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = ["${local.domain}", "www.${local.domain}"]

  origin {
    origin_id   = "S3-Website-${aws_s3_bucket.site.id}"
    domain_name = "${aws_s3_bucket.site.website_endpoint}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Website-${aws_s3_bucket.site.id}"

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

resource "aws_cloudfront_distribution" "assets_distribution" {
  enabled = true
  aliases = ["assets.${local.domain}"]

  origin {
    origin_id   = "S3-${aws_s3_bucket.assets.id}"
    domain_name = "${aws_s3_bucket.assets.bucket_regional_domain_name}"
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

resource "cloudflare_record" "root" {
  domain  = "${local.domain}"
  name    = "@"
  type    = "CNAME"
  value   = "${aws_cloudfront_distribution.site_distribution.0.domain_name}"
  proxied = true
}

resource "cloudflare_record" "www" {
  domain  = "${local.domain}"
  name    = "www"
  type    = "CNAME"
  value   = "${local.domain}"
  proxied = true
}

resource "cloudflare_record" "assets" {
  domain  = "${local.domain}"
  name    = "assets"
  type    = "CNAME"
  value   = "${aws_cloudfront_distribution.assets_distribution.0.domain_name}"
  proxied = true
}

resource "cloudflare_page_rule" "always_use_https" {
  zone     = "${local.domain}"
  target   = "http://*${local.domain}/*"
  priority = 1

  actions = {
    always_use_https = true
  }
}

resource "cloudflare_page_rule" "redirect_www" {
  zone     = "${local.domain}"
  target   = "www.${local.domain}/*"
  priority = 2

  actions = {
    forwarding_url {
      url         = "https://${local.domain}/$1"
      status_code = 301
    }
  }
}

resource "cloudflare_page_rule" "redirect_rss" {
  zone     = "${local.domain}"
  target   = "${local.domain}/rss"
  priority = 3

  actions = {
    forwarding_url {
      url         = "/index.xml"
      status_code = 301
    }
  }
}
