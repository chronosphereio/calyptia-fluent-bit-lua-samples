FROM fluent/fluent-bit:1.8-debug

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      libxml2 \
      lua5.1 \
      luarocks && \
    luarocks install xmlua

RUN mkdir -pv /source

WORKDIR /source
