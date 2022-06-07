FROM fluent/fluent-bit:1.8-debug

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      libssl-dev \
      lua5.1 \
      luarocks && \
    luarocks install luaossl

RUN mkdir -pv /source

WORKDIR /source
