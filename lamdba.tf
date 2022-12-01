resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "full_s3_attach" {
  name       = "Downloader policy attachment"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "full_lamdba_attach" {
  name       = "Downloader policy attachment"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_policy_attachment" "full_cloudwatch_attach" {
  name       = "Downloader policy attachment"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy" "lamdba_policy" {
  name = "lamdba_policy"
  role = aws_iam_role.iam_for_lambda.name

  policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
      "Sid": "AllowS3Access",
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "AllowAllLambda",
      "Action": [
        "lambda:*",
        "s3-object-lambda:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "AllowAllCloudWatch",
      "Action": [
        "CloudWatch:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
    ]
  }
  ) 
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}

resource "aws_lambda_function" "processor_function" {
  filename      = "lambda_function.zip"
  function_name = "image_processor"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
}