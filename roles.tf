resource "aws_iam_role" "uploader" {
  name = "uploader"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = { "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      },
    ]
  })

  tags = {
    description = "role to upload items into s3 upload bucket"
  }
}


resource "aws_iam_policy" "uploader_policy" {
  name = "uploader_policy"
  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "listcontentsofbucketorupload",
        "Action": [
          "s3:GetObject",
          "s3:GetObjectAttributes",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::785931089885-upload-bucket/*"
      },
      {
         "Sid": "AllowListAllbucketsinconsole",
         "Action": ["s3:ListAllMyBuckets", "s3:GetBucketLocation"],
         "Effect": "Allow",
         "Resource": ["arn:aws:s3:::*"]
     }
    ]
    }
)
}

resource "aws_iam_role" "downloader" {
  name = "downloader"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = { "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      },
    ]
  })

  tags = {
    description = "user to download items from processed s3 bucket"
  }
}


resource "aws_iam_policy" "downloader_policy" {
  name = "downloader_policy"

  policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "getcontentsofbucket",
        "Action": [
          "s3:GetObject",
          "s3:GetObjectAttributes",
          "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::785931089885-processed-bucket/*"
      },
      {
         "Sid": "AllowListAllbucketsinconsole",
         "Action": [
          "s3:ListAllMyBuckets", 
          "s3:GetBucketLocation"
         ],
         "Effect": "Allow",
         "Resource": "arn:aws:s3:::*"
      }
    ]
  }
  ) 
  }

  resource "aws_iam_policy_attachment" "uploader_policy" {
  name       = "Uploader policy attachment"
  roles      = [aws_iam_role.uploader.name]
  policy_arn = aws_iam_policy.uploader_policy.arn
}

  resource "aws_iam_policy_attachment" "downloader_policy" {
  name       = "Downloader policy attachment"
  roles      = [aws_iam_role.downloader.name]
  policy_arn = aws_iam_policy.downloader_policy.arn
}