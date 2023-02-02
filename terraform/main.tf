terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
  default_tags {
   tags = {
     Environment = "Test"
     Project     = "ThumbnailGenerator"
   }
 }
}

#Create the main images bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.image_bucket_name
}

#Attach a private ACL to this bucket
resource "aws_s3_bucket_acl" "s3_acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private"
}

#Create the access point to the S3 bucket
resource "aws_s3_access_point" "images_access_point" {
  bucket = aws_s3_bucket.s3_bucket.id
  name   = var.s3_object_access_point_name
}

#Configure AP to use lambda
resource "aws_s3control_object_lambda_access_point" "images_thumbnail" {
  name = var.lambda_access_point_name

  configuration {
    supporting_access_point = aws_s3_access_point.images_access_point.arn

    transformation_configuration {
      actions = ["GetObject"]

      content_transformation {
        aws_lambda {
          function_arn = aws_lambda_function.images_lambda.arn
        }
      }
    }
  }
}

#Setup source code for lambda to use
provider "archive" {}
data "archive_file" "zip" {
  type        = "zip"
  source_file = "../lambda_function.py"
  output_path = "thumbnail_generator.zip"
}

#Reference to AWS managed policy
data "aws_iam_policy" "AmazonS3ObjectLambdaExecutionRolePolicy" {
  name = "AmazonS3ObjectLambdaExecutionRolePolicy"
}

#Allow lambda to assume role
data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "ThumbnailLambdaPolicy"
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

#Attach that managed AWS policy to the lambda role
resource "aws_iam_role_policy_attachment" "sto-readonly-role-policy-attach" {
  role       = aws_iam_role.thumbnail_lambda_role.name
  policy_arn = data.aws_iam_policy.AmazonS3ObjectLambdaExecutionRolePolicy.arn
}

#Lambda role to use for the service
resource "aws_iam_role" "thumbnail_lambda_role" {
  name               = "thumbnail_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}

resource "aws_lambda_layer_version" "pillow_layer" {
  filename   = "Pillow3.zip"
  layer_name = "pillowlayer"
  compatible_runtimes = ["python3.9"]
}

#Lambda infrastructure
resource "aws_lambda_function" "images_lambda" {
  function_name = var.lambda_name
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role    = aws_iam_role.thumbnail_lambda_role.arn
  handler = "lambda_function.handler"
  layers = [aws_lambda_layer_version.pillow_layer.arn]
  runtime = "python3.9"
  timeout = 900
}
