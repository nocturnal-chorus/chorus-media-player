FROM phusion/baseimage:focal-1.1.0

EXPOSE 1701
ARG module
WORKDIR /app/${module}

COPY scripts/start /etc/service/${module}/run
COPY ${module}/conf /app/${module}/conf
COPY ${module}/${module} /app/${module}/
