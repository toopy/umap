# syntax=docker/dockerfile:1.4

FROM debian:bullseye AS base

RUN apt update \
 && apt install -y --no-install-recommends \
      gdal-bin \
      python3-minimal \
 && apt autoremove -y \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /srv/umap /etc/umap \
 && useradd -N umap -d /srv/umap \
 && chown umap:users /etc/umap /srv/umap

ENV PATH $PATH:/srv/umap/.local/bin

USER umap

WORKDIR /srv/umap

FROM base AS build

USER root

RUN apt update \
 && apt install -y --no-install-recommends \
      autoconf \
      build-essential \
      libxml2-dev \
      libxslt1-dev \
      libgdal-dev \
      libgeos-dev \
      libproj-dev \
      python3-dev \
      python3-pip \
      zlib1g-dev \
 && apt autoremove -y \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER umap

RUN --mount=target=/tmp/umap pip install --user /tmp/umap

FROM base AS prod

COPY --chown=umap:users ./umap/settings/local.py.sample /etc/umap/umap.conf
COPY --from=build /srv/umap/.local /srv/umap/.local

EXPOSE 8019

CMD [ "umap", "runserver", "0.0.0.0:8019" ]
