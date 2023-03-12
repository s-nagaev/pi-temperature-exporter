<h1 align="center">
    <picture>
      <img width=250 alt="Pi Temp Exporter logo" src="doc/logo.png">
    </picture>
    <p>Pi Temperature Exporter</p>
</h1>

A simple application for collecting Raspberry Pi's CPU and GPU temperatures and exporting them for [Prometheus](https://prometheus.io) consumption.

## Installation

The application can be run in two ways: running the binary file directly on the Raspberry Pi or in a [Docker container](https://hub.docker.com/r/pysergio/pi-temp-exporter).

### Automated

Automated install/update of the application:

```shell
curl https://raw.githubusercontent.com/s-nagaev/pi-temperature-exporter/main/scripts/install.sh | bash
```

This script installs the binary to `/usr/local/bin` directory and sets up the systemd accordingly.

### Manual

You can manually download a binary release from the [release page](https://github.com/s-nagaev/pi-temperature-exporter/releases).

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

Then you can start the application using the `docker-compose up -d` command.

## Usage

Once the Pi Temperature Exporter is installed and running, you can verify that metrics are being exported by cURLing the `/metrics` endpoint:

```shell
curl http://localhost:9002/metrics
```

You should see output like this:

```text
# HELP pi_cpu_temperature CPU Temperature in Celsius
# TYPE pi_cpu_temperature gauge
pi_cpu_temperature 57.939
# HELP pi_gpu_temperature GPU Temperature in Celsius
# TYPE pi_gpu_temperature gauge
pi_gpu_temperature 56.5
```

Success! The Pi Temperature Exporter is now exposing metrics that Prometheus can scrape!

### Configure your Prometheus instance

If you need information about Prometheus installation steps, please, visit the [official documentation page](https://prometheus.io/docs/introduction/first_steps/) first.

The following `prometheus.yml` example configuration file will tell the Prometheus instance to scrape, and how frequently, from the Pi Temperature Exporter via your Raspberry Pi IP address. Suppose, your Raspberry Pi's local IP address is `192.168.0.100`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:

- job_name: temperature
  static_configs:
  - targets: ['192.168.0.100:9002']
```

### Health Check

The application also exposes a `/health` endpoint, which can be used for health check purposes.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
