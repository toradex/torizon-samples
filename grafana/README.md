# collectd-influxdb-grafana

## Quick setup for Colibri IMX6

Transfer the grafana directory to the device

Build the _collectd_ container

```
docker-compose -f docker-compose.yml build --pull
```

Start services

```
docker-compose -f docker-compose.yml up
```

Grafana web UI should be available at port 3000 of the device (default user/pw: `admin`/`admin`)
