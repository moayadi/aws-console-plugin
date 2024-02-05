GOARCH = amd64

UNAME = $(shell uname -s)

ifndef OS
	ifeq ($(UNAME), Linux)
		OS = linux
	else ifeq ($(UNAME), Darwin)
		OS = darwin
	endif
endif

.DEFAULT_GOAL := all

all: fmt build start

build:
	# build the plugin and store it in the build directory (build)	
	GO111MODULE=on GOOS=$(OS) GOARCH="$(GOARCH)" go build -o build/awsconsole cmd/aws/main.go

start:
	# start the vault server in dev mode with the plugin directory set to the build directory
	vault server -dev -dev-root-token-id=root -dev-listen-address=:8201 -dev-plugin-dir=./build/ &

check:
	# check the plugin is installed
	vault plugin list secret

enable:
	# enable the external plugin
	vault secrets enable -path=awsconsole awsconsole

config:
	# configure the plugin with the root credentials
	vault write awsconsole/config/root \
	access_key=AKIAI44QH8DHBEXAMPLE \
	secret_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
	region=us-west-1

role: 
	# create a role for the network admin
	vault write awsconsole/roles/network \
    role_arns=arn:aws:iam::578479370890:role/network-admin-role \
    credential_type=assumed_role console_login=true \
	console_duration=1800

sts:
	# create a short lived token for the network admin
	vault write awsconsole/sts/network ttl=1h

fmt:
	go fmt $$(go list ./...)


.PHONY: build clean fmt start enable
