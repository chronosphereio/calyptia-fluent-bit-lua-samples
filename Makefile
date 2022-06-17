build: Dockerfile
	docker build -t samples .

run.%: build
	docker run --rm --name $@ -v$(PWD)/$*:/source samples /fluent-bit/bin/fluent-bit -c flb.conf

.PHONY: build
