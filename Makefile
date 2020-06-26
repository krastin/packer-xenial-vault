# check if needed binaries exist
EXECUTABLES = curl jq sort egrep tail
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

# if no version given, use the lates open source one
ifndef $VERSION
    $(warning vault version undefined - assuming latest oss version)
    VERSION = $(shell curl -sL https://releases.hashicorp.com/vault/index.json | jq -r '.versions[].version' | sort -V | egrep -v 'beta|rc|alpha|ent' | tail -1)
endif

default: all

all: xenial-vault-${VERSION}.box

xenial-vault-${VERSION}.box: template.json scripts/provision.sh http/preseed.cfg
	@echo "Building xenial-vault v.${VERSION}"
	packer validate template.json
	packer build -force -only=xenial-vault -var version='${VERSION}' template.json
	vagrant box add --force --name xenial-vault --box-version ${VERSION} ./xenial-vault-vbox.box  

publish: xenial-vault-${VERSION}.box
	vagrant cloud publish --box-version ${VERSION} --force --release krastin/xenial-vault ${VERSION} virtualbox xenial-vault-${VERSION}.box

test: xenial-vault-${VERSION}.box
	bundle exec kitchen test default-krastin-xenial-vault

.PHONY: clean 
clean:
	-bundle exec kitchen destroy
	-vagrant box remove -f xenial-vault --provider virtualbox
	-rm -fr output-*/ *.box