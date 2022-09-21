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
  bucket = local.domain
}

resource "aws_s3_bucket_acl" "site" {
  bucket = aws_s3_bucket.site.bucket
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket" "assets" {
  bucket = "assets.${local.domain}"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_response_headers_policy" "managed_cors_with_everything" {
  name = "Managed-CORS-with-preflight-and-SecurityHeadersPolicy"
}

resource "aws_cloudfront_distribution" "site_distribution" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = [local.domain, "www.${local.domain}"]

  origin {
    origin_id   = "S3-Website-${aws_s3_bucket.site.id}"
    domain_name = aws_s3_bucket_website_configuration.site.website_endpoint

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
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 300
  }
}

resource "aws_cloudfront_distribution" "assets_distribution" {
  enabled = true
  aliases = ["assets.${local.domain}"]

  origin {
    origin_id   = "S3-${aws_s3_bucket.assets.id}"
    domain_name = aws_s3_bucket.assets.bucket_regional_domain_name
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.assets.id}"

    viewer_protocol_policy     = "allow-all"
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.managed_cors_with_everything.id
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

resource "cloudflare_zone" "site" {
  zone = local.domain
}

resource "cloudflare_record" "root" {
  zone_id = cloudflare_zone.site.id
  name    = "@"
  type    = "CNAME"
  value   = aws_cloudfront_distribution.site_distribution.domain_name
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.site.id
  name    = "www"
  type    = "CNAME"
  value   = local.domain
  proxied = true
}

resource "cloudflare_record" "assets" {
  zone_id = cloudflare_zone.site.id
  name    = "assets"
  type    = "CNAME"
  value   = aws_cloudfront_distribution.assets_distribution.domain_name
  proxied = true
}

resource "cloudflare_record" "google_verification" {
  zone_id = cloudflare_zone.site.id
  name    = "@"
  type    = "TXT"
  value   = "google-site-verification=8IZ4RTYSQArXX4XbKdoSAP1G7aMRFQPg3ONvbvhiglc"
}

resource "cloudflare_page_rule" "always_use_https" {
  zone_id  = cloudflare_zone.site.id
  target   = "http://*${local.domain}/*"
  priority = 1

  actions {
    always_use_https = true
  }
}

resource "cloudflare_page_rule" "redirect_www" {
  zone_id  = cloudflare_zone.site.id
  target   = "www.${local.domain}/*"
  priority = 2

  actions {
    forwarding_url {
      url         = "https://${local.domain}/$1"
      status_code = 301
    }
  }
}

resource "cloudflare_page_rule" "redirect_rss" {
  zone_id  = cloudflare_zone.site.id
  target   = "${local.domain}/rss"
  priority = 3

  actions {
    forwarding_url {
      url         = "/index.xml"
      status_code = 301
    }
  }
}

resource "cloudflare_worker_script" "plausible_proxy" {
  name    = "plsbl_proxy"
  content = file("infrastructure/plausible-proxy.js")
}

resource "cloudflare_worker_route" "plausible_route" {
  zone_id     = cloudflare_zone.site.id
  pattern     = "${local.domain}/plsbl/*"
  script_name = cloudflare_worker_script.plausible_proxy.name
}
