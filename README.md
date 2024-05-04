# Alpine Docker Image with curl and jq

Simple Alpine image with curl and jq, nothing more, nothing less. It is only a few MB in size.

## Pull image

```shell
docker pull jamjaws/alpine-curl-jq
```

## Example usage

```shell
docker run -it --rm jamjaws/alpine-curl-jq "sh" "-c" "curl http://artscene.textfiles.com/asciiart/unicorn"
```
