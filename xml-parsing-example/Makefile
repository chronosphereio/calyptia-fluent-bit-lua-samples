run-example: build
	docker run --rm -ti --name example -v$(PWD):/source example /fluent-bit/bin/fluent-bit -c flb.conf

build:
	docker build -t example .

.PHONY: build run-example
