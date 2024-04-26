FROM ruby:3.3.1-slim-bullseye

ENV TZ="America/New_York"

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends \
  apt-utils \
  build-essential \
  git \
  imagemagick \
  iproute2 \
  libpq-dev \
  openssh-client \
  vim

RUN gem install bundler
RUN gem install foreman

WORKDIR /workspace
