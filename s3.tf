resource "aws_s3_bucket" "upload_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-upload-bucket"

  tags = {
    Name        = "upload s3 bucket"
  }
}

resource "aws_s3_bucket" "processed_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-processed-bucket"

  tags = {
    Name        = "Processed s3 bucket"
  }
}

resource "aws_s3_bucket_acl" "upload_acl" {
  bucket = aws_s3_bucket.upload_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_acl" "processed_acl" {
  bucket = aws_s3_bucket.processed_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "upload_public_block" {
  bucket = aws_s3_bucket.upload_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.allow_png_images_only_upload]
}

resource "aws_s3_bucket_public_access_block" "processed_public_block" {
  bucket = aws_s3_bucket.processed_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.allow_png_images_only_processed]
}

resource "aws_s3_bucket_policy" "allow_png_images_only_upload" {
  bucket = aws_s3_bucket.upload_bucket.id
  policy = data.aws_iam_policy_document.allow_png_images_only_upload.json
}

resource "aws_s3_bucket_policy" "allow_png_images_only_processed" {
  bucket = aws_s3_bucket.processed_bucket.id
  policy = data.aws_iam_policy_document.allow_png_images_only_processed.json
}


data "aws_iam_policy_document" "allow_png_images_only_upload" {
  statement {
    principals {
      type = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-upload-bucket/*.png"
    ]
  }

  statement {
    principals {
      type = "*"
      identifiers = ["*"]
    }

    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    not_resources = [
      "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-upload-bucket/*.png"
    ]
  }
}

data "aws_iam_policy_document" "allow_png_images_only_processed" {
  statement {
    principals {
      type = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-processed-bucket/*.png"
    ]
  }
  
  statement {
    principals {
      type = "*"
      identifiers = ["*"]
    }

    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    not_resources = [
      "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-processed-bucket/*.png"
    ]
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

output "bucket_policy" {
  value = data.aws_iam_policy_document.allow_png_images_only_upload.json
}