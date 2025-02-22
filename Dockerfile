# forked from https://github.com/angristan/docker-pleroma
# MIT License
# Copyright (c) 2019 Aries(orlea)
# Copyright (c) 2018 Angristan


FROM elixir:1.8-alpine

ENV UID=911 GID=911 \
    MIX_ENV=prod

ARG PLEROMA_VER=develop

RUN apk -U upgrade \
    && apk add --no-cache \
       build-base \
       git \
       imagemagick

RUN addgroup -g ${GID} pleroma \
    && adduser -h /pleroma -s /bin/sh -D -G pleroma -u ${UID} pleroma

USER pleroma
WORKDIR pleroma

RUN git clone -b develop https://git.pleroma.social/pleroma/pleroma.git /pleroma \
    && git checkout ${PLEROMA_VER}

COPY config/prod.secret.exs /pleroma/config/prod.secret.exs
COPY config/keys.secret.exs /pleroma/config/keys.secret.exs

RUN mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get \
    && mix compile

VOLUME /pleroma/uploads/

CMD ["mix", "phx.server"]
