ARG TARGET=armv7-unknown-linux-musleabihf

FROM --platform=$BUILDPLATFORM ghcr.io/cross-rs/$TARGET:latest as builder
ARG TARGET
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup target add $TARGET

WORKDIR /usr/src/pi-temp-exporter
COPY Cargo.toml Cargo.lock .
COPY src /usr/src/pi-temp-exporter/src
RUN cargo build --target $TARGET --release

FROM alpine:latest AS runtime
ARG TARGET

LABEL org.label-schema.schema-version = "1.0"
LABEL org.label-schema.name = "Pi Temperature Exporter"
LABEL org.label-schema.vendor = "nagaev.sv@gmail.com"
LABEL org.label-schema.vcs-url = "https://github.com/s-nagaev/pi-temperature-exporter"

COPY --from=builder /usr/src/pi-temp-exporter/target/$TARGET/release/pi-temp-exporter /usr/local/bin

EXPOSE 9002

CMD ["/usr/local/bin/pi-temp-exporter"]
