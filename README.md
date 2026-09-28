# Alpine with curl and jq

An Alpine Linux image containing curl and jq for scripts, CI jobs, and containerized HTTP requests.

Supported platforms: `linux/amd64`, `linux/arm64`, `linux/arm/v7`, and `linux/arm/v6`.

## Usage

```sh
docker pull jamjaws/alpine-curl-jq:latest
docker run --rm jamjaws/alpine-curl-jq:latest 'curl --version && jq --version'
```

The entrypoint is `sh -c`: pass your entire shell command as **one argument**. Running without a command prints curl help. Do not append another `sh -c` as separate arguments unless you override the entrypoint.

For example, fetch and parse an IP address while propagating HTTP errors:

```sh
docker run --rm --user 65532:65532 --read-only \
  --cap-drop ALL --security-opt no-new-privileges=true \
  jamjaws/alpine-curl-jq:latest '
    set -eu
    response=$(curl --fail --silent --show-error \
      --connect-timeout 5 --max-time 30 "https://api.ipify.org?format=json")
    printf "%s\n" "$response" | jq --exit-status --raw-output .ip
  '
```

The image retains Alpine's root default for compatibility, but curl and jq work without root. Use `--user` as above; add a writable volume or tmpfs if your command needs to write files.

For a direct executable invocation, override the entrypoint:

```sh
docker run --rm --entrypoint curl jamjaws/alpine-curl-jq:latest --version
docker run --rm --entrypoint jq jamjaws/alpine-curl-jq:latest --version
```

## Image tags and updates

The default `ALPINE_TAG` in [Dockerfile](Dockerfile) is the source of truth for the base version. Dependabot proposes version updates weekly, and PR checks build that same base.

| Tag | Behavior |
| --- | --- |
| `latest` | Most recent successful publishing build from `main`. |
| Alpine major, such as `3` | Refreshed with `latest` on `main`. |
| Alpine major/minor, such as `3.24` | Refreshed while that minor version is the base on `main`. |
| Alpine full version, such as `3.24.1` | Refreshed by builds using that base on `main`, or by a matching Git release tag. |
| `build-<run-id>-<attempt>` | Identifies a particular successful workflow build. |

Alpine version tags are **mutable**: a rebuild can include newer curl, jq, and security patches without changing the Alpine version. Older base versions are not rebuilt on the weekly schedule once `main` moves on. APK packages intentionally follow their Alpine branch instead of pinning package revisions that may disappear from its repositories.

For an exact image, pin its digest. Find it with:

```sh
docker buildx imagetools inspect jamjaws/alpine-curl-jq:latest
```

Use the reported digest with the `jamjaws/alpine-curl-jq@sha256:...` reference syntax. Build tags provide convenient traceability; a digest identifies the exact content.

## Build and test locally

```sh
docker build --pull --platform linux/amd64 -t alpine-curl-jq:local .
./tests/run-container.sh alpine-curl-jq:local linux/amd64
```

The test runner requires a Linux Docker host, Bash, Python 3, and curl. Choose another supported platform when needed; foreign architectures require emulation. Set `TEST_PORT` if the default local fixture port, 8765, is occupied.

Tests serve a local JSON fixture, exercise curl and jq in a non-root container with a read-only filesystem, check the CA bundle, and verify that an HTTP 404 fails. They do not depend on a public API. The negative test also detects an entrypoint that accidentally skips the test script.

To lint locally, install the corresponding tools and run:

```sh
hadolint --ignore DL3018 Dockerfile
actionlint
shellcheck test.sh tests/*.sh
```

## CI and publishing

The workflows lint the Dockerfile, shell scripts, and workflow definitions before building all four platforms. Each platform gets runtime tests and a vulnerability scan. Fixable HIGH or CRITICAL vulnerabilities block publication.

Publishing builds stage images by digest. Only after every platform passes does the publishing job assemble the multi-platform image and update its tags; it does not rebuild the tested images. Published images include OCI version/revision labels, build provenance, and an SBOM.

Publishing runs on:

- Pushes to `main`.
- A weekly schedule, Mondays at 03:17 UTC, to refresh APK packages even without source changes.
- Manual workflow dispatch on `main`.
- Git tags such as `v3.24.1`, which must match the Dockerfile's Alpine version. These update only the full-version and build tags, leaving `latest` and major/minor aliases untouched.

Pull requests build and test without Docker Hub credentials or registry writes.

Repository configuration:

- Variable `DOCKERHUB_USERNAME`: an account permitted to publish `jamjaws/alpine-curl-jq`.
- Secret `DOCKERHUB_TOKEN`: a Docker Hub access token with write access to that image.

Actions are pinned to commit SHAs and updated by Dependabot. Workflow permissions default to read-only. A scheduled heartbeat updates only the `schedule` branch using `GITHUB_TOKEN`, keeping scheduled workflows active during quiet periods; no personal access token is required.

## License

[MIT](LICENCE).
