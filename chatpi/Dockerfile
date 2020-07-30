FROM elixir:1.7.4-alpine

RUN mix local.hex --force \
  && apk add --update build-base git postgresql-dev postgresql-client nodejs npm \
  && mix archive.install hex phx_new 1.4.0 --force \
  && mix local.rebar --force \
  && rm -rf /var/cache/apk/*

RUN mkdir -p /chatpi
COPY . /chatpi
WORKDIR /chatpi

EXPOSE 4000
