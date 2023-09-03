FROM phusion/baseimage:focal-1.1.0 as build

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY ./sources.list /etc/apt/sources.list

RUN apt-get update; \
  DEBIAN_FRONTEND="noninteractive" apt-get install --no-install-recommends -y \
  git unzip curl; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY ./flutter/ /root/flutter

# https://flutter.cn/community/china/
ENV PUB_HOSTED_URL https://pub.flutter-io.cn
ENV FLUTTER_STORAGE_BASE_URL https://storage.flutter-io.cn
ENV PATH /root/flutter/bin:$PATH

RUN flutter channel stable; \
    flutter config --enable-web;

WORKDIR /var/jenkins_home/workspace
