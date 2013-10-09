FROM ubuntu:precise
MAINTAINER Ted Lilley <ted.lilley@gmail.com>

EXPOSE 3001

ENV RAILS_ENV production
ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://ubuntu.wikimedia.org/ubuntu precise main restricted universe multiverse" > /etc/apt/sources.list
RUN apt-get update

