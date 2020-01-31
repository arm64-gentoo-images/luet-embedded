BACKEND?=docker
CONCURRENCY?=1

# Abs path only. It gets copied in chroot in pre-seed stages
LUET?=/usr/bin/luet
export ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DESTINATION?=$(ROOT_DIR)/output
TARGET?=targets
COMPRESSION?=gzip
CLEAN?=false
TREE?=distro

# For ARM image build script
export LUET_CONFIG?=$(ROOT_DIR)/conf/luet.yaml
export LUET_BIN?=$(LUET)
export LUET_PACKAGES?=distro/raspbian-0.20191208 distro/raspbian-boot-0.20191208 system/luet-develop-0.5
export IMAGE_NAME?=luet_os.img

.PHONY: all
all: deps build

.PHONY: deps
deps:
	@echo "Installing luet"
	go get -u github.com/mudler/luet
	go get -u github.com/MottainaiCI/mottainai-cli

.PHONY: clean
clean:
	sudo rm -rf build/ *.tar *.metadata.yaml

.PHONY: build
build: clean
	mkdir -p $(ROOT_DIR)/build
	sudo $(LUET) build --clean=$(CLEAN) `cat $(ROOT_DIR)/$(TARGET) | xargs echo` --destination $(ROOT_DIR)/build --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: build-all
build-all: clean
	mkdir -p $(ROOT_DIR)/build
	sudo $(LUET) build --clean=$(CLEAN) --all --destination $(ROOT_DIR)/build --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: rebuild
rebuild:
	sudo $(LUET) build --clean=$(CLEAN) `cat $(ROOT_DIR)/$(TARGET) | xargs echo` --destination $(ROOT_DIR)/build --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: rebuild-all
rebuild-all:
	sudo $(LUET) build --clean=$(CLEAN) --all --destination $(ROOT_DIR)/build --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: create-repo
create-repo:
	sudo luet create-repo --tree "$(TREE)" \
    --output $(ROOT_DIR)/build \
    --packages $(ROOT_DIR)/build \
    --name "luet-embedded" \
    --descr "Luet embedded Repo" \
    --urls "http://localhost:8000" \
    --tree-compression gzip \
    --tree-path tree.tar \
    --type http

.PHONY: serve-repo
serve-repo:
	cd build && python -m SimpleHTTPServer 8000

.PHONY: image
image:
	scripts/arm_image.sh

.PHONY: image-clean
image-clean:
	scripts/arm_clean.sh