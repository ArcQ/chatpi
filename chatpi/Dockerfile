FROM elixir:1.9.4-alpine AS development

RUN mix local.hex --force \
  && apk add --update build-base git postgresql-dev postgresql-client\
  && mix archive.install hex phx_new 1.4.0 --force \
  && mix local.rebar --force \
  && rm -rf /var/cache/apk/*

RUN mkdir -p /chatpi
COPY . /chatpi
WORKDIR /chatpi

EXPOSE 4000

FROM development AS builder
RUN mix deps.get --only prod \
      && MIX_ENV=prod mix compile \
      && MIX_ENV=prod mix release

FROM elixir:1.9.4-alpine AS production

COPY --from=builder ./chatpi/_build/prod /chatpi/_build/prod

EXPOSE $PORT

CMD ["/chatpi/_build/prod/rel/chatpi/bin/chatpi", "start"]
