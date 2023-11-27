FROM alpine:3.18.4

RUN apk update
RUN apk upgrade --no-cache

RUN apk add --no-cache curl jq
