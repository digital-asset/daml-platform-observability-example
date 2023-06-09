# [Daml Enterprise](https://www.digitalasset.com/products/daml-enterprise) - Observability Example

This project demonstrates a [Daml
Enterprise](https://www.digitalasset.com/products/daml-enterprise)
deployment's observability features, along with example Grafana dashboards.  

The project is self-contained: providing scripts to generate requests for
which metrics are collected for display in the Grafana dashboards.  It requires
Daml v2.6.0 or newer and have been tested on MacOS and Linux — some Docker
images may not be available for Windows.

**Please bear in mind that this project is provided for illustrative purposes only,
and as such may not be production quality and/or may not fit your use-cases.**

**This repository does not accept Pull Requests at the moment.**

## License

**You may use the contents of this repo in parts or in whole according to the
0BSD license:**

> Copyright (c) 2023 Digital Asset (Switzerland) GmbH and/or its affiliates
>
> Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
>
> THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO
> THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT
> SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR
> ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
> OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH
> THE USE OR PERFORMANCE OF THIS SOFTWARE.

## TL;DR Quick Start

To quickly get up and running, make sure you have the [prerequisites](#Prerequisites) installed
and then:

* Ensure you have enough resources allocated to running the example
containers; if a memory resource limit is reached then a container will be
randomly killed.  In particular, the `daml_observability_canton`
container can reach a steady state memory usage of 4 GB.
* Deploy the containers locally, which include several Daml Enterprise
components, Prometheus, Grafana, and related containers. This is done with the
command: `docker compose up`.
* Start the request generation.  There are three scripts that generate the requests
and running them in multiple terminals is best.  The scripts are:
  * `scripts/generate-grpc-load.sh <number loops>`: this runs the ledger API
  conformance suite in a loop for \<number loop\> times.  The default
  number of loops is 10.  This will generate gRPC traffic that has successful
  and unsuccessful return codes. Press `[Ctrl]+[c]` multiple times to stop the
  script.
  * `scripts/send-json-api-requests.sh`: this generates HTTP traffic against
  the [HTTP JSON API Service](https://docs.daml.com/json-api/) which has successful and unsuccessful requests.  It
  will loop continuously until stopped with `[Ctrl]+[c]`.
  * `scripts/send-trigger-requests.sh`: generates traffic for the [Trigger Service](https://docs.daml.com/tools/trigger-service/index.html).  It
  will loop continuously until stopped with `[Ctrl]+[c]`.
* Login to the Grafana dashboard at
[http://localhost:3000/dashboards](http://localhost:3000/dashboards).  The
default user and password: `digitalasset`.  Make sure the time range is set to
'5 minutes' and refresh is set to '10 seconds' to see results quickly.
* When you shutdown, it is recommended that the volumes are cleaned up to free up disk space and
avoid unnecessary steps later (e.g., upgrade databases if a new [Daml
Enterprise](https://www.digitalasset.com/products/daml-enterprise) version is
released).

You should see a dashboard like this:
![Example  
Network Operation Center Health Dashboard](./images/noc_dashboard.png "Example Network Operations Center Health Dashboard")

## Prerequisites

* [**Docker**](https://docs.docker.com/get-docker/)
* [**Docker Compose plugin `2.x`**](https://github.com/docker/compose)
* Artifactory credentials to access our private
[Canton Enterprise Docker images](https://digitalasset.jfrog.io/ui/repos/tree/General/canton-enterprise-docker/digitalasset/canton-enterprise/latest)

Docker Compose will automatically build the [image for the HTTP JSON API
service](daml-service/) from the release JAR file. 

The [`.env`](./.env) file has environment variables to select which Canton and
SDK versions are being used.  See the section "Accessing Daml Enterprise
Docker Images" below for more details. Please be aware that different Daml
Enterprise versions may not generate all the metrics in the Grafana dashboards so
they may not show up in the dashboard.

## Components

You can find a Docker Compose setup here with the following services:

* Daml Platform:
  * All-in-one Canton node (domain topology manager, mediator, sequencer and participant)
  * HTTP JSON API service
  * PostgreSQL database (used by the Canton node and the HTTP JSON API service)
* Monitoring:
  * Prometheus `2.x`
  * Grafana `9.x`
  * Node Exporter
  * Loki + Promtail `2.x`

Prometheus and Loki are [preconfigured as datasources for Grafana](./grafana/datasources.yml). You can add other
services/exporters in the [Docker compose file](./docker-compose.yml) and scrape them changing the
[Prometheus configuration](./prometheus/prometheus.yml).

Use the `Makefile` — run `make help` for available commands!

## Startup

Start everything (blocking command, show all logs):

```sh
docker compose up
```

Start everything (detached: background, not showing logs)

```sh
docker compose up -d
```

If you see the error message `no configuration file provided: not found`
please check that you are placed at the root of this project.

### Starting a Remote Canton Console

```sh
docker exec -it daml_observability_canton_console bin/canton -c /canton/config/console.conf
```

## Stopping

* If you used a blocking `docker compose up`, just cancel via keyboard with `[Ctrl]+[c]`

* If you detached compose: `docker compose down`

### Cleanup Everything

Stop everything, remove networks and all Canton, Prometheus & Grafana data stored in volumes:

```sh
docker compose down --volumes
```

## Important Endpoints to Explore

* Prometheus: http://localhost:9090/
* Grafana: http://localhost:3000/ (default user and password: `digitalasset`)
* Loki: http://localhost:5000/ (default user and password: `digitalasset`)
* Participant's Ledger API endpoint: http://localhost:10011/

Check all exposed services/ports in the [Docker compose YAML](./docker-compose.yml) definition.

### Canton Console

```sh
docker exec -it daml_observability_canton_console bin/canton -c /canton/config/console.conf
```

### Logs

```sh
docker logs daml_observability_postgres
docker logs daml_observability_prometheus
docker logs daml_observability_grafana
```
You can open multiple terminals and follow logs (blocking command) of a specific container:

```
docker logs -f daml_observability_postgres
docker logs -f daml_observability_prometheus
docker logs -f daml_observability_grafana
```

## Configuration

### Canton and HTTP JSON API Log Level

For the Canton node and HTTP JSON API service only, you can change `LOG_LEVEL` in the [`.env`](./.env) file:

```sh
LOG_LEVEL=DEBUG
```

### Prometheus

[`prometheus.yml`](./prometheus/prometheus.yml) [[documentation]](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)

Reload or restart on changes:
* Reload:
  * Signal: `docker exec -it daml_observability_prometheus -- kill -HUP 1`
  * HTTP: `curl -X POST http://localhost:9090/-/reload`
* Restart: `docker compose restart prometheus`

### Grafana

* Grafana itself: [`grafana.ini`](./grafana/grafana.ini) [[documentation]](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/)
* Data sources: [`datasources.yml`](./grafana/datasources.yml) [[documentation]](https://grafana.com/docs/grafana/latest/datasources/)
* Dashboard providers: [`dashboards.yml`](./grafana/dashboards.yml) [[documentation]](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards)

Restart on changes: `docker compose restart grafana`

#### Dashboards

All dashboards (JSON files) are auto-loaded from directory
[`grafana/dashboards/`](./grafana/dashboards/)

* Automatic: place your JSON files in the folder (loaded at startup, reloaded
  every 30 seconds)
* Manual: create/edit via Grafana UI

##### Examples Source

* Prometheus and Grafana [[source]](https://github.com/grafana/grafana/tree/main/public/app/plugins/datasource/prometheus/dashboards/)
* Node exporter full [[source]](https://grafana.com/grafana/dashboards/1860-node-exporter-full/)
* Loki and Promtail [[source]](https://grafana.com/grafana/dashboards/14055-loki-stack-monitoring-promtail-loki/)


## Accessing [Daml Enterprise](https://www.digitalasset.com/products/daml-enterprise) Docker Images

* Get an access key from Digital Asset.  This step needs to be performed
once.  If you haven't logged in before, you can get an access key by logging
in to [digitalasset.jfrog.io](https://digitalasset.jfrog.io) and generating an identity token on your [Artifactory profile
page](https://digitalasset.jfrog.io/ui/admin/artifactory/user_profile). If
your email is john.doe@digitalasset.com, your Artifactory username is
`john.doe`.

* Make sure the Docker daemon is logged in to `digitalasset-docker.jfrog.io`:

    ```sh
    docker login digitalasset-docker.jfrog.io -u <your-username>
    ```
* Assign the [`.env`](./.env) file environment variables `CANTON_IMAGE` and
`CANTON_VERSION` to the version you want. Several  ```.env``` example
configurations are shown below.

  * This example retrieves the [Daml
  Enterprise](https://www.digitalasset.com/products/daml-enterprise) Docker
  images for Daml v2.6.0.

  ```sh
  CANTON_IMAGE=digitalasset-docker.jfrog.io/digitalasset/canton-enterprise
  CANTON_VERSION=2.6.0
  SDK_VERSION=2.6.0
  LOG_LEVEL=INFO
  ```

  * This example is for a weekly snapshot release that can be used to verify a bug is fixed.  This requires help from the support team.

  ```sh
  CANTON_IMAGE=digitalasset-docker.jfrog.io/digitalasset/canton-enterprise
  CANTON_VERSION=20221129
  SDK_VERSION=2.5.0-snapshot.20221201.11065.0.caac1d10
  LOG_LEVEL=INFO
  ```

  * This example shows how to switch from the [Daml
  Enterprise](https://www.digitalasset.com/products/daml-enterprise) Docker
  images to the open source version (pulled from Docker Hub) set the variables
  to a similar value below. This example retrieves the v2.5.0 images for the
  open source repo of Daml.

  ```sh
  CANTON_IMAGE=digitalasset/canton-open-source
  CANTON_VERSION=2.6.0
  SDK_VERSION=2.6.0
  LOG_LEVEL=INFO
  ```
