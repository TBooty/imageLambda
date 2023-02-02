variable "region" {
  description = "The AWS Region"
  type        = string
  default     = "us-east-2"
}


variable "image_bucket_name" {
  description = "The name of the images bucket"
  type        = string
  default     = ""
}

variable "s3_object_access_point_name" {
  description = "The name of the S3 access point"
  type        = string
  default     = ""
}


variable "lambda_access_point_name" {
  description = "The name of the Lambda access point"
  type        = string
  default     = ""
}

variable "lambda_name" {
  description = "The name of the lambda that will resize images"
  type        = string
  default     = ""
}