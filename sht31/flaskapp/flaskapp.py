from flask import Flask, Response, render_template
from influxdb import InfluxDBClient

import os
import json
import time
from datetime import datetime

client = InfluxDBClient(host='influxdb', port=8086)
client.switch_database('sht31')

app = Flask(__name__)


@app.route('/')
def index():
    return render_template('index.html')


@app.route("/current")
def current():
    result = client.query('SELECT LAST(*) FROM "conditions"')
    return result.raw


@app.route("/fromtime/<fromTime>/totime/<toTime>")
def range(fromTime, toTime):
    result = client.query(
        'SELECT * FROM "conditions" WHERE time >= \'{}\' AND time <= \'{}\''.format(fromTime, toTime))
    return result.raw


@app.route("/lastnduration/<lastNDuration>")
def last(lastNDuration):
    result = client.query(
        'SELECT * FROM "conditions" WHERE time > now() - {}'.format(lastNDuration))
    return result.raw


@app.route('/sensor-data')
def sensor_data():
    def generate_sensor_data():
        while True:
            result_raw = current()
            result_raw["series"][0]["values"][0][0] = datetime.now().strftime(
                '%Y-%m-%d %H:%M:%S')
            json_data = json.dumps(result_raw)
            yield f"data:{json_data}\n\n"
            time.sleep(1)

    return Response(generate_sensor_data(), mimetype='text/event-stream')


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=True, host='0.0.0.0', port=port)
