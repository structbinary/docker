FROM nginx
MAINTAINER Sandeep Mahto "sandeep.mahto@kickdrumtech.com"

COPY start.sh /
COPY nginx.conf /etc/nginx/
COPY nginx-secure.conf /etc/nginx/

COPY dhparams.pem /etc/ssl/private/
CMD /start.sh
