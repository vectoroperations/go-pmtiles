FROM golang:1.22.7-alpine3.19 AS builder

# Install required build tools
RUN apk add --no-cache gcc musl-dev

COPY . /workspace
WORKDIR /workspace

# Set environment variables for iOS arm64 cross-compilation
ENV CGO_ENABLED=1
ENV GOOS=darwin
ENV GOARCH=arm64
ENV CC=gcc
ENV CGO_CFLAGS="-fembed-bitcode"

# Build the static library and header files
RUN go build -buildmode=c-archive -o /workspace/libpmtiles.a

# Create a smaller final image with just the compiled files
FROM alpine:3.19

COPY --from=builder /workspace/libpmtiles.a /output/libpmtiles.a
COPY --from=builder /workspace/libpmtiles.h /output/libpmtiles.h

# Create a volume to access the output files
VOLUME /output

# Keep container running to allow file copy
CMD ["tail", "-f", "/dev/null"]
