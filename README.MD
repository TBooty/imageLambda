Thumbnail generator

Required:
	- AWS Role with IAM permissions to create infrastructure

Image thumbnail generator.

Images are stored full size in S3 bucket.

when requested from S3 bucket they will return full size.

When requested from the Access Point it will kick off the images lambda.

This lambda will use the pre-signed link from the request download the file and transform it to 256x256 and return the requested images

terraform - contains terraform to create the infrastructure required 

Pillow zip contains the python packages required for the lambda to run.

If you want to create your own zip.

Edit the docker file with whatever packages you want to pip install

Build the docker image

Run docker image

Run docker container ls to get the ID of the container

run the command `docker containerIDHERE:/var/lang/lib/python3.9/site-packages/ /test`

Create folder named python and drag contents from docker image here


![architecture](architecture.png "architecture")