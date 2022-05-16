FROM fluent/fluent-bit:1.8-debug

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      libpcre2-dev \
      lua5.1 \
      luarocks && \
    luarocks install lrexlib-pcre2 && \
    luarocks install base64

RUN mkdir -pv /source

WORKDIR /source
