FROM phusion/baseimage:focal-1.1.0

EXPOSE 8091
ARG module
WORKDIR /app/${module}

COPY service/scripts/start /etc/service/${module}/run
COPY service/${module}/${module} /app/${module}/
