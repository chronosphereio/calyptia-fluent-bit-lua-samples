FROM debian:bullseye-slim as luarocks-installer

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpcre2-dev \
      libssl-dev \
      libxml2 \
      lua5.1 \
      luarocks && \
    luarocks install --tree /luarocks luaossl && \
    luarocks install --tree /luarocks lrexlib-pcre2 && \
    luarocks install --tree /luarocks luautf8 && \
    luarocks install --tree /luarocks xmlua && \
    luarocks install --tree /luarocks base64

FROM fluent/fluent-bit:1.9-debug

COPY --from=luarocks-installer /luarocks /usr/local

WORKDIR /source
