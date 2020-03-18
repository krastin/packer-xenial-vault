default: all

all: xenial-vault-vbox.box

xenial-vault-vbox.box: template.json scripts/provision.sh http/preseed.cfg
	packer validate template.json
	packer build -force -only=xenial-vault-vbox template.json
	vagrant box add ./xenial-vault-vbox.box  --name xenial-vault

test: xenial-vault-vbox.box
	bundle exec kitchen test vbox

.PHONY: clean
clean:
	-bundle exec kitchen destroy
	-vagrant box remove -f xenial-vault --provider virtualbox
	-rm -fr output-*/ *.box