# fitbit-grafana
*A dockerised app to download Fitbit data and display it in Grafana*

![Screenshot of heart-rate data displayed in Grafana](https://pbs.twimg.com/media/D57EGRsXoAUzHPE.jpg:small)

## Setup

1. [Install Docker Compose](https://docs.docker.com/compose/install/)
2. [Register a Fitbit application](https://dev.fitbit.com/apps/new) to get API credentials. Make sure to use these settings:
  - OAuth 2.0 Application Type: `Personal`
  - Callback URL: `http://localhost:4567/callback`
3. Copy the `fitbit-export.env.default` file to `fitbit-export.env`, setting the client id and secret using your API credentials
4. Run `docker-compose up` in the same directory as your copy of this repository
5. [Load Grafana](http://localhost:3000) and add an InfluxDB data source, using these settings:
  - URL: `http://influxdb:8086`
  - Database: `fitbit`
  - User: `fitbit`
  - Password: `fitbit`
6. Add a dashboard and panel using this query: `SELECT mean("value") FROM "heartrate" WHERE $timeFilter GROUP BY time(5m) fill(null)`

## Usage

### Fitbit export

The interface used to export data from Fitbit can be visited at [http://localhost:4567](http://localhost:4567).

Paths:

* `/heartrate/:date` - export heartdate data from this date

### Grafana

Grafana can be accessed at [http://localhost:3000](http://localhost:3000).
