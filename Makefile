
.PHONY: all

all: Dockerfile.done


Dockerfile.done: Dockerfile src/*
	docker build -t scan2mint .
	touch Dockerfile.done

.PHONY: run
run: Dockerfile.done
	docker run --mount type=bind,source="$(CURDIR)"/source,target=/app/source \
	           --mount type=bind,source="$(CURDIR)"/destination,target=/app/destination \
		   --mount type=bind,source="$(CURDIR)"/etc,target=/app/etc --rm --name "scan2mint" -it scan2mint


.PHONY: copy

copy: Dockerfile.done
	cp destination/*.jpg /home/mike/

