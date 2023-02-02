FROM public.ecr.aws/lambda/python:3.9

RUN pip install pillow
RUN pip install requests

CMD [ "app.handler" ]
