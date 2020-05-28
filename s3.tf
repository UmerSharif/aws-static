resource "aws_s3_bucket" "website" {
  bucket = "${var.project}-website-${var.company}.io"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.website.bucket}/*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_object" "website" {
  for_each = fileset(path.module, "website/build/**/*.*")

  bucket = aws_s3_bucket.website.bucket
  key    = replace(each.value, "website/build/", "")
  source = "${path.module}/${each.value}"
  content_type = lookup(
    var.file_extensions,
    element(
      reverse(split(".", each.value)),
      0
    ),
    "text/plain"
  )
}

output "website_endpoint" {
  value = aws_s3_bucket.website.website_endpoint
}
