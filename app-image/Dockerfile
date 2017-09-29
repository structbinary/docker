FROM python:3.4

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python-mysqldb \
        libmysqlclient-dev \
        python-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src
RUN mkdir bettercal
WORKDIR /usr/src/bettercal
ADD ./angular-ui /usr/src/bettercal/angular-ui
ADD ./django-app /usr/src/bettercal/django-app
ADD ./sample-app /usr/src/bettercal/sample-app
WORKDIR /usr/src/bettercal/sample-app
RUN pip install -r requirements.txt
RUN python manage.py migrate
EXPOSE 80
CMD ["python", "manage.py", "runserver", "0.0.0.0:80"]