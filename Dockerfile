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
    luarocks install --tree /luarocks/usr/local luaossl && \
    luarocks install --tree /luarocks/usr/local lrexlib-pcre2 && \
    luarocks install --tree /luarocks/usr/local luautf8 && \
    luarocks install --tree /luarocks/usr/local xmlua && \
    luarocks install --tree /luarocks/usr/local base64 && \
    # Here we do a bit of black magic to find which .so files are depended by the newly installed lua libraries:
    # Start by finding all .so files in the install prefix, which is /luarocks/usr/local
    find /luarocks/usr/local -type f -name '*.so' \
      # Pipe the found .so through ldd, which will output all the system libraries used by the lua module
      | xargs ldd  \
      # Run through an awk filter, which will skip all standard .so files which are already in the production image
      | awk '$3 && $1 !~ /libc\.so|vdso\.so|ld-linux|libpthread\.so|libm\.so|libdl\.so/ {print $3}' \
      # Add those libraries to tar archive that will be sent to stdout. Note the -h flag, which is used to deference symlinks
      | tar cf - -C / -h --verbatim-files-from -T - \
      # Untar in the /luarocks directory, which is what we will unpack in the final image
      | tar xf - -C /luarocks && \
    # Same as above, but use dpkg -L to retrieve libraries not visible in ldd output. These are loaded through luajit FFI by xmlua
    dpkg -L libxml2 libicu67 \
      | awk '/\.so./' \
      | tar cf - -C / -h --verbatim-files-from -T - \
      | tar xf - -C /luarocks

FROM fluent/fluent-bit:1.9

COPY --from=luarocks-installer /luarocks /

WORKDIR /source
