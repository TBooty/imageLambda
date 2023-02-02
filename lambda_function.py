import boto3
import requests
import io
from PIL import Image


def handler(event, context):
    """
    Retrieve the operation context object from the event. This object indicates where the WriteGetObjectResponse request
    should be delivered and has a presigned URL in 'inputS3Url' where we can download the requested object from.
    The 'userRequest' object has information related to the user who made this 'GetObject' request to 
    S3 Object Lambda.
    """
    get_context = event["getObjectContext"]
    route = get_context["outputRoute"]
    token = get_context["outputToken"]
    s3_url = get_context["inputS3Url"]

    """
    In this case, we're resizing .png images that are stored in S3 and are accessible through the presigned URL
    'inputS3Url'.
    """
    image_request = requests.get(s3_url)
    image = Image.open(io.BytesIO(image_request.content))
    image.thumbnail((256, 256), Image.ANTIALIAS)

    transformed = io.BytesIO()
    image.save(transformed, "png")

    # Send the resized image back to the client.
    s3 = boto3.client('s3')
    s3.write_get_object_response(Body=transformed.getvalue(), RequestRoute=route, RequestToken=token)

    # Gracefully exit the Lambda function.
    return {'status_code': 200}
