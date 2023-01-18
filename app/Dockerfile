# pull official base image
FROM python:3.9.0

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt ./
RUN pip install -r requirements.txt

# copy project
COPY . ./

# ENTRYPOINT [ "sh", "./entrypoint.sh" ]

RUN python manage.py collectstatic --no-input

# CMD gunicorn -w 3 -b :8000 hello_django.wsgi:application