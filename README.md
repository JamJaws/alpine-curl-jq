# Alpine Docker Image with curl and jq

Simple Alpine image with curl and jq.

## Usage

```sh
docker run --rm jamjaws/alpine-curl-jq 'curl --version && jq --version'
```

Get your public IP:

```sh
docker run --rm jamjaws/alpine-curl-jq 'curl -fsS "https://api.ipify.org?format=json" | jq -er .ip'
```

The entrypoint is `sh -c`; pass the whole command as one quoted argument.

Supports `linux/amd64`, `linux/arm64`, `linux/arm/v7`, and `linux/arm/v6`.
Tags follow the Alpine version (major, minor, and patch). `latest` and the current version tags are rebuilt weekly.

## Build and test

Requires Docker with Compose:

```sh
./test.sh
```
