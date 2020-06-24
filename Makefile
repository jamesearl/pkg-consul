NAME=consul
VERSION=1.8.0
REVISION=1
CONSUL_VERSION=$(VERSION)
MAINT=james.earl.3@gmail.com
DESCRIPTION="HashiCorp's Consul v$(CONSUL_VERSION)"

DEB=$(NAME)_$(VERSION)-$(REVISION)
DEB_64=$(DEB)_amd64.deb
SRC_64=https://releases.hashicorp.com/consul/$(CONSUL_VERSION)/consul_$(CONSUL_VERSION)_linux_amd64.zip

.PHONY: dev build publish-gemfury ls uninstall install clean

dev: clean build install

build: dist/$(DEB_64)

publish-gemfury:
	fury push dist/$(DEB_64) --public

ls:
	gemfury versions "$(NAME)"

bin/:
	mkdir -p ./bin

dist/:
	mkdir -p ./dist

bin/consul_$(CONSUL_VERSION)_linux_amd64: bin/
	wget -nc -nv -O - $(SRC_64) | gunzip >bin/consul_$(CONSUL_VERSION)_linux_amd64
	chmod +x bin/consul_$(CONSUL_VERSION)_linux_amd64

dist/$(DEB_64): dist/ bin/consul_$(CONSUL_VERSION)_linux_amd64
	fpm -s dir \
		--description $(DESCRIPTION) \
		-t deb \
		-p dist/$(DEB_64) \
		-n $(NAME) \
		--provides $(NAME) \
		-v $(VERSION) \
		--iteration $(REVISION) \
		-a amd64 \
		-m $(MAINT) \
		--deb-no-default-config-files \
		bin/consul_$(CONSUL_VERSION)_linux_amd64=/usr/bin/consul

clean:
	rm -rf dist/*

uninstall:
	sudo apt remove -y $(NAME) || true

install:
	sudo apt install -y --reinstall --allow-downgrades ./dist/$(DEB_64)
