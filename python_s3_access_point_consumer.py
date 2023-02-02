import boto3
import cv2
import os
from botocore.config import Config
import PIL.Image as Image
import io

s3 = boto3.client('s3', config=Config(signature_version='s3v4'))

aws_account_id = os.getenv('AWS_ACCOUNT_ID')


def get_object(bucket, key, output_path):
    object_body = s3.get_object(Bucket=bucket, Key=key)
    response_bytes = object_body["Body"].read()
    image = Image.open(io.BytesIO(response_bytes))
    image.save(output_path)


print('Original object from the S3 bucket:')
get_object("images-bucket-main",
           "cat.png", 'original_cat.png')

print('Object transformed by S3 Object Lambda:')

get_object(f'arn:aws:s3-object-lambda:us-east-2:{aws_account_id}:accesspoint/images-ap',
           "cat.png", 'resized_cat.png')


im = cv2.imread('original_cat.png')
h, w, c = im.shape

im2 = cv2.imread('resized_cat.png')
h2, w2, c2 = im2.shape

# assert it's a resized image
assert (h2 == 256)
assert (w2 == 256)
assert (h != h2)
assert (w != w2)
