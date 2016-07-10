default: build debug

build:
	docker build -t ck-vpn .

debug:
	# TODO: Reduce permission required
	# See https://docs.docker.com/engine/reference/run/#/runtime-privilege-and-linux-capabilities
	# docker run --rm -it --privileged -p 500:500/udp -p 4500:4500/udp -v $(PWD)/debug.etc:/etc --name ck-vpn-debug ck-vpn
	docker run --rm -it --privileged -p 80:80 -p 500:500/udp -p 4500:4500/udp --name ck-vpn-debug -e 'IPSEC_DEBUG_OPTIONS=--debug-all' ck-vpn

debug-shell:
	docker exec -it --privileged ck-vpn-debug /bin/sh

run:
	docker run

test: test-unit test-acceptance

test-acceptance:
	# test-acceptance requires sudo permission
	@sudo true
	bats tests/test-acceptance.sh

test-unit:
	bats tests/*-test.sh

test-from-vm:
	docker run --rm -it --privileged ck-vpn charon-cmd --host 192.168.99.100 --identity tester.docker

test-from-osx-on-vm-ip:
	sudo charon-cmd --host $(shell docker-machine ip) --identity tester.osx

bootstrap-osx:
	brew update
	brew install bats nmap docker docker-machine
	brew cask install virtualbox
	docker-machine create --driver=virtualbox default
	docker-machine start
