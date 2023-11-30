ARG ALPINE_TAG

FROM alpine:$ALPINE_TAG

RUN apk update
RUN apk upgrade --no-cache

RUN apk add --no-cache curl jq
