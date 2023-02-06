<p align="center">
    <picture>
      <img width=130 alt="Pi Temp Exporter logo" src="./doc/logo.png">
    </picture>
</p>

# Pi Temperature Exporter

A simple application for collecting Raspberry Pi's CPU and GPU temperatures and exporting them for Prometheus consumption.

## Usage

The application can be run in two ways: directly on the Raspberry Pi or as a Docker container.

### Direct

To run the application directly on the Raspberry Pi, use the following command:

```shell
curl https://raw.githubusercontent.com/s-nagaev/pi-temp-exporter/main/scripts/install.sh | bash
```

This script installs the binary to `$HOME/.local/bin` directory and sets up the systemd accordingly.

### Docker

To run this application as a Docker container, simply use the following command:

```shell
docker run --name pi-temp-exporter -p 9002:9002 pysergio/pi-temp-exporter
```

> Note: when running as a Docker container, only the CPU temperature can be exported.

Alternatively, you can use the following Docker Compose file to set up the application:

```yaml
version: '3'

services:
  pi-temp-exporter:
    image: pysergio/pi-temp-exporter
    ports:
      - "9002:9002"
```

Then you can start the application using `docker-compose up` command.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
