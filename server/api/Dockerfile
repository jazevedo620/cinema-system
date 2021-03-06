FROM alpine:3.10

# Set the working directory to /app
WORKDIR /app
COPY ./api/requirements.txt /app

# Copy the current directory contents into the container at /app
RUN apk update
RUN apk add build-base musl-dev python3
RUN apk add linux-headers python3-dev pcre-dev uwsgi-python3 libffi libffi-dev
RUN apk add --virtual build-deps gcc musl-dev postgresql-dev

# Install any needed packages specified in requirements.txt
RUN pip3 install --trusted-host pypi.python.org -r requirements.txt
RUN apk del build-base musl-dev python3-dev libffi-dev

COPY ./api/ /app/

# Use 5000 as wsgi port
EXPOSE 5000

# Run app.py when the container launches
CMD ["uwsgi", "--ini", "config_uwsgi.ini"]
