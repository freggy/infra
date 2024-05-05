# Infra

This contains IaC for my personal projects.

## Setup

- `brew install opentofu sops age`
- `touch .envrc`
- setup opentofu by `cd tf && tofu init`
- write into .envrc `export SOPS_AGE_KEY=<path/to/your/age-file.txt>`

## Cluster naming

This is a fully qualified cluster name: `<purpose><counter>-<region>-<domain>`
e.g. `app1-euc-76k-io`. Domain part can be omitted, because it is used to
uniquely identify the cluster.

all current purposes:

- `app`: cluster hosting all kinds of applications

all current regions:

- `euc`: europe central

## Notes

- scripts should always expect being executed in the root directory i.e `./bin/flux-push`.
- flux artifacts should be pushed into `ghcr.io/freggy/infra/flux`
