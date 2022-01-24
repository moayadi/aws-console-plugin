# aws-console-plugin

## Background

The current HashiCorp Vault AWS Secret Engine currently supports the creation of short lived API keys using the IAM User, AssumeRole or the FederationToken methods.  However these API keys cannot be used for AWS Console login, having to rely on SSO configurations to be in place.  What if there was a way to generate a short lived AWS Console login access that is shortlived?

This plugin is an updated HashiCorp AWS Secret Engine that will generate an AWS Console login for assumed roles.  

This method only works for for AWS STS AssumeRole and GederFederationToken API operations.

For more information on this, see here: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html

## Getting Started

Assuming that you have an existing go environment, clone the repository and build the plugin with make command.

Update the parameters in the Makefile:
```
    access_key=<AWS_ACCESS_KEY_ID>
    secret_key=<AWS_SECRET_ACCESS_KEY>
    role_arns=<AWS_ROLE_ARN>

```
These are required by the updated AWS Secret Engine to assume the role correctly.  Once parameters are updated:

```
make enable
```

This will mount the secret engine and configure it accordingly.  To test the plugin:

```
make deploy
vault write awsnew/sts/deploy ttl=60m
Key                Value
---                -----
lease_id           awsnew/sts/deploy/AXIopURRZWzOBk1YmWQTa7Lu
lease_duration     59m59s
lease_renewable    false
access_key         ASIAU5RVXXXXXXZYQYBN
arn                arn:aws:sts::111111111:assumed-role/vault-s3readonly/vault-token-deploy-1643010300-4YGjNyzrzhIxMWl9KrBK
console_login      https://signin.aws.amazon.com/federation?Action=login&Issuer=Example.com&Destination=https%3A%2F%2Fconsole.aws.amazon.com%2F&SigninToken=bDs28RNlOWnHwjncvZY_nvyTlFgNqwGM6PREbQOxG-QITf82Z25QFiajOB32E5NsQKfAMK0x16zeVq1vu7xEzgqDBv3XZM57BxsQiXoqs9IovqsYZn7qquPvK-YY2iHtrNH1ZEpgx6ZVeoy3hFD5oXaHTNOD-PiAKef4wNGKcwWYFSwJsWfhu1UXViM1Kfh9-Njpt_4ITljWJW0XYt7ye2M_QWNg1rNvy07LckdgljAYZoc3F_Mi59m_ZGCelP1fDY2PU4RuTppmTfXCaZglpDKpnUxHvM
secret_key         Zy/34GYYYYYYYYYYYYftmjRzSOKicQ+nwlwdkzTV
security_token     FwoGZXIvYXdzEFkaDBb8h0Jf+2A7EIfKoSLWAQNW7UHlrVA8FkOZZZZZZZZZZZZHvft7yWZRkrZpbIj1A0sWqm/ldXlfsmXffFh46QVlphJeG03JeOLSwaxyMV+mMsb9K4cf5Ovan9P7gpS8hKk/ZKLIhgXRvrZPZ+W7CiMDNEAa+y+8EmcRVJtCTsaV9RJ4r1uvgLzVHpF7iIgQMsFwLH4rpQD

```

You will see a new field, console_login.  Copy this to your browser, you should able to login to the AWS Console with the corresponding role.