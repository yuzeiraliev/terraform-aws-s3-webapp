resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${var.prefix}-${var.name}"

  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  acl = "public-read"
  #adding additional lines for proper ordering of resource creation
  depends_on = [
  aws_s3_bucket_ownership_controls.example,
  aws_s3_bucket_public_access_block.example
  ]
}
#adding additional blocks becuase of failed/outdated tutorial
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
#adding new blocks finishes here
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  #adding additional lines for proper ordering of resource creation
  depends_on = [
  aws_s3_bucket_ownership_controls.example,
  aws_s3_bucket_public_access_block.example
  ]
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_object" "webapp" {
  acl          = "public-read"
  key          = "index.html"
  bucket       = aws_s3_bucket.bucket.id
  #adding additional lines for proper ordering of resource creation
  depends_on = [
  aws_s3_bucket_ownership_controls.example,
  aws_s3_bucket_public_access_block.example
  ]
  content      = file("${path.module}/assets/index.html")
  content_type = "text/html"
}
