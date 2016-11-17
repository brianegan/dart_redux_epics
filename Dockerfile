FROM johnpryan/dart-content-shell-docker

MAINTAINER brian@brianegan.com

RUN apt-get update
RUN apt-get install -y lcov

ENV PATH $PATH:/usr/lib/dart/bin
