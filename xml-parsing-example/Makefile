run-example: build
	docker run --rm -t --name flb-lua-libxml2-example -v$(PWD):/source flb-lua-libxml2-example /fluent-bit/bin/fluent-bit -c flb.conf

build:
	docker build -t flb-lua-libxml2-example .

.PHONY: build run-example
