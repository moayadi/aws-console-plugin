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
	GO111MODULE=on GOOS=$(OS) GOARCH="$(GOARCH)" go build -o build/awsconsole cmd/aws/main.go

start:
	vault server -dev -dev-root-token-id=root -log-level=trace -dev-listen-address=:8201 -dev-plugin-dir=./build/ &

enable:
	vault secrets enable -path=awsconsole awsconsole

config: 
	vault write awsconsole/roles/network \
    role_arns=arn:aws:iam::578479370890:role/network-admin-role \
    credential_type=assumed_role console_login=true \
	console_duration=1800

creds:
	vault write awsconsole/sts/network

fmt:
	go fmt $$(go list ./...)


.PHONY: build clean fmt start enable
