SHELL := /bin/bash
.DEFAULT_GOAL := help

.PHONY: help
## help: Makefile: Prints this help message
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

.PHONY: up
## up: Docker compose: Start everything (blocking)
up:
	docker compose -p obs up --abort-on-container-exit

.PHONY: upd
## upd: Docker compose: Start everything (detached)
upd:
	docker compose -p obs up -d

.PHONY: down
## down: Docker compose: Stop everything
down:
	docker compose -p obs down

.PHONY: clean
## clean: Docker compose: Stop everything and remove volumes
clean:
	docker compose -p obs down --volumes

.PHONY: monitoring
## monitoring: Docker compose: Start only Prometheus, Loki & Grafana
monitoring:
	docker compose -p obs up grafana --abort-on-container-exit

.PHONY: daml
## daml: Docker compose: Start only Postgres, Canton & HTTP JSON API
daml:
	docker compose -p obs up http-json -d

.PHONY: prom
## prom: Prometheus: Access Web UI
prom:
	$$(command -v xdg-open || command -v open) http://localhost:9090/

.PHONY: prom-reload
## prom-reload: Prometheus: Reload configuration
prom-reload:
	docker exec -it obs-prometheus-1 kill -HUP 1

.PHONY: prom-restart
## prom-restart: Prometheus: Restart
prom-restart:
	docker compose -p obs restart prometheus

.PHONY: prom-logs
## prom-logs: Prometheus: Follow logs (blocking)
prom-logs:
	docker logs -f obs-prometheus-1

.PHONY: grafana
## grafana: Grafana: Access Web UI
grafana:
	$$(command -v xdg-open || command -v open) http://localhost:3000/

.PHONY: grafana-restart
## grafana-restart: Grafana: Restart
grafana-restart:
	docker compose -p obs restart grafana

.PHONY: grafana-logs
## grafana-logs: Grafana: Follow logs (blocking)
grafana-logs:
	docker logs -f obs-grafana-1

.PHONY: console
## console: Canton: Open Console
console:
	docker exec -it obs-console-1 bin/canton -c /canton/config/console.conf

.PHONY: debug
## debug: Canton: Open Shell
debug:
	docker exec -it obs-console-1 /bin/bash

.PHONY: canton-restart
## canton-restart: Canton: Restart
canton-restart:
	docker compose -p obs restart canton

.PHONY: canton-logs
## canton-logs: Canton: Follow logs (blocking)
canton-logs:
	docker logs -f obs-canton-1

.PHONY: http-json-restart
## http-json-restart: HTTP JSON API: Restart
http-json-restart:
	docker compose -p obs restart http-json

.PHONY: http-json-logs
## http-json-logs: HTTP JSON API: Follow logs (blocking)
http-json-logs:
	docker logs -f obs-http-json-1
