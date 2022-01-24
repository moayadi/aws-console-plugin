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
	GO111MODULE=on GOOS=$(OS) GOARCH="$(GOARCH)" go build -o vault/plugins/awsnew cmd/aws/main.go

start:
	vault server -dev -dev-root-token-id=root -log-level=trace -dev-plugin-dir=./vault/plugins

enable:
	vault secrets enable -path=awsnew awsnew
	vault write awsnew/config/root \
    access_key=<AWS_ACCESS_KEY_ID> \
    secret_key=<AWS_SECRET_ACCESS_KEY> \
    region=us-east-1
	vault write awsnew/roles/deploy \
    role_arns=<AWS_ROLE_ARN> \
    credential_type=assumed_role console_login=true \
	console_duration=1800

deploy:
	vault write awsnew/sts/deploy ttl=60m

clean:
	rm -f ./vault/plugins/awsnew

fmt:
	go fmt $$(go list ./...)

register:
	export SHA256=$(sha256sum ./vault/plugins/awsnew | cut -d ' ' -f1)
	echo $SHA256
	vault plugin register -sha256=$SHA256 secret new

.PHONY: build clean fmt start enable
