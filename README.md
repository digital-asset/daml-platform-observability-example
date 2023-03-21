# Daml Platform - Observability Example

This repo demonstrates how you can set up your Daml deployment to leverage the observability
features available, along with a few example Grafana dashboards for monitoring Daml services.

## License

**Please bear in mind that this project is provided for illustrative purposes only,
and as such may not be production quality and/or may not fit your use-cases.
You may use the contents of this repo in parts or in whole according to the 0BSD license:**

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

> **This repository does not accept Pull Requests at the moment.**

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

## Prerequisites

* [**Docker**](https://docs.docker.com/get-docker/)
* [**Docker Compose plugin `2.x`**](https://github.com/docker/compose)
* Artifactory credentials to access our private
[Canton Enterprise Docker images](https://digitalasset.jfrog.io/ui/repos/tree/General/canton-enterprise-docker/digitalasset/canton-enterprise/latest)

Docker Compose will automagically build the [image for the HTTP JSON API service](./http-json/) from the release JAR file.
Check the [`.env`](./.env) file to know which Canton and SDK version are used.

⚠️ You can test different versions changing `CANTON_VERSION`, `SDK_VERSION` but there is no guarantees that it will be
compatible with the currently committed configurations and Grafana dashboards.

## Startup

Start everything (blocking command, show all logs):

```sh
docker compose -p obs up
```

Start everything (detached: background, not showing logs)

```sh
docker compose -p obs up -d
```

If you see the error message `no configuration file provided: not found`
please check that you are placed at the root of this project.

## Access

* Prometheus: http://localhost:9090/
* Grafana: http://localhost:3000/ (default user and password: `digitalasset`)
* Loki: http://localhost:5000/ (default user and password: `digitalasset`)
* Participant's Ledger API endpoint: http://localhost:10011/

Check all exposed services/ports in the [Docker compose YAML](./docker-compose.yml) definition.

### Canton Console

```sh
docker exec -it obs-console-1 bin/canton -c /canton/config/console.conf
```

### Logs

```sh
docker logs obs-postgres-1
docker logs obs-prometheus-1
docker logs obs-grafana-1
```
You can open multiple terminals and follow logs (blocking command) of a specific container:

```
docker logs -f obs-postgres-1
docker logs -f obs-prometheus-1
docker logs -f obs-grafana-1
```

## Configuration

### Log level

For the Canton node and HTTP JSON API service only, you can change `LOG_LEVEL` in the [`.env`](./.env) file:

```sh
LOG_LEVEL=DEBUG
```

### Prometheus

[`prometheus.yml`](./prometheus/prometheus.yml) [[documentation]](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)

Reload or restart on changes:
* Reload:
  * Signal: `docker exec -it obs-prometheus-1 -- kill -HUP 1`
  * HTTP: `curl -X POST http://localhost:9090/-/reload`
* Restart: `docker compose -p obs restart prometheus`

### Grafana

* Grafana itself: [`grafana.ini`](./grafana/grafana.ini) [[documentation]](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/)
* Data sources: [`datasources.yml`](./grafana/datasources.yml) [[documentation]](https://grafana.com/docs/grafana/latest/datasources/)
* Dashboard providers: [`dashboards.yml`](./grafana/dashboards.yml) [[documentation]](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards)

Restart on changes: `docker compose -p obs restart grafana`

#### Dashboards

All dashboards (JSON files) are auto-loaded from directory [`grafana/dashboards/`](./grafana/dashboards/)

* Automatic: place your JSON files in the folder (loaded at startup, reloaded every 30 seconds)
* Manual: create/edit via Grafana UI

##### Examples Source

* Prometheus and Grafana [[source]](https://github.com/grafana/grafana/tree/main/public/app/plugins/datasource/prometheus/dashboards/)
* Node exporter full [[source]](https://grafana.com/grafana/dashboards/1860-node-exporter-full/)
* Loki and Promtail [[source]](https://grafana.com/grafana/dashboards/14055-loki-stack-monitoring-promtail-loki/)

## Stop

* If you used a blocking `docker compose -p obs up`, just cancel via keyboard with `[Ctrl]+[c]`

* If you detached compose: `docker compose -p obs down`

### Cleanup Everything

Stop everything, remove networks and all Canton, Prometheus & Grafana data stored in volumes:

```sh
docker compose -p obs down --volumes
```

## Using private Canton/Daml docker images

⚠️ **Digital Asset internal only**

* Make sure your the Docker daemon is logged in to `digitalasset-docker.jfrog.io`:

    ```sh
    docker login digitalasset-docker.jfrog.io -u <your-username>
    ```

  If you haven't logged in before, you can get an access key by logging in to
  [digitalasset.jfrog.io](https://digitalasset.jfrog.io) using your Google account and
  generating an identity token on your
  [Artifactory profile page](https://digitalasset.jfrog.io/ui/admin/artifactory/user_profile).
  If your email is john.doe@digitalasset.com => your Artifactory useername is `john.doe`.

* Check the [`.env`](./.env) file and change `CANTON_IMAGE`, `CANTON_VERSION` to switch from
the open source version (pulled from Docker Hub) to a snapshot of the enterprise version. Example:

  ```sh
  CANTON_IMAGE=digitalasset-docker.jfrog.io/digitalasset/canton-enterprise
  CANTON_VERSION=20221129
  SDK_VERSION=2.5.0-snapshot.20221201.11065.0.caac1d10
  ```
