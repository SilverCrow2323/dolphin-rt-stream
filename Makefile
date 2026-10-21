VERSION := $(shell cat VERSION)

.PHONY: all deb muos test lint clean version

all: deb muos

deb:
	bash tools/build-deb.sh dist

muos:
	bash tools/build-muos.sh dist

test:
	cd tests && python3 -m unittest discover -v
	cd tests && python3 -m unittest lua.test_gui -v

lint:
	python3 -m py_compile pc/portal/*.py pc/standalone/*.py
	for f in pc/portal/*.sh pc/standalone/*.sh muos/DolphinStream/*.sh muos/DolphinStream/tools/*.sh; do sh -n $$f || exit 1; done

version:
	@echo $(VERSION)

clean:
	rm -rf dist
