ARG ALPINE_TAG

FROM alpine:$ALPINE_TAG

RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache curl jq

LABEL org.opencontainers.image.authors="John Mogensen <jamjaws@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/JamJaws/alpine-curl-jq"
LABEL org.opencontainers.image.base.name="alpine"
LABEL org.opencontainers.image.title="Alpine with curl and jq"

ENTRYPOINT ["sh", "-c"]
CMD ["curl --help"]
