FROM golang:1.15 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
ADD . .
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o topology-updater main.go

# Use distroless as minimal base image to package the purge binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM alpine:3.14
WORKDIR /
COPY --from=builder /workspace/topology-updater .
COPY scripts/topologyUpdater.sh .

RUN apk update \
  && apk add bash curl jq redis

USER 65532:65532

ENTRYPOINT ["/topology-updater"]
