# This Python file uses the following encoding: utf-8

# if__name__ == "__main__":
#     pass

#Reference : https://github.com/Sensirion/libsensors-python/blob/master/sensirion_sensors.py


from collections import OrderedDict
import glob
import threading
import time
from os import path


class Sensor(object):
    """
    Representation of one sensor that can measure one or more value.
    Instances of this class are returned by find_sensors_by_type() and find_sensor_by_type().
    """
    def __init__(self, units):
        self._units = units

    def get_units(self):
        """
        :returns a tuple with the units of the values that are measured by this sensor
        """
        return self._units

    def get_values(self):
        """
        :returns a tuple with the current values measured by this sensor
        """
        raise NotImplementedError

    def is_available(self):
        """
        :returns true if the sensor is plugged in and ready to measure
        """
        try:
            self.get_values()
            return True
        except Exception:
            return False

    def get_number_of_values(self):
        return len(self._units)

    def read_file(self, file_path):
        with open(file_path, 'r') as f:
            value = f.read().strip()
        return value


class SFxxSensor(Sensor):
    UNIT_NODE = 'unit'
    VALUE_NODE = 'measured_value'

    def __init__(self, base_path):
        unit_file = path.join(base_path, self.UNIT_NODE)
        unit = self.read_file(unit_file).strip()
        super(SFxxSensor, self).__init__((unit,))
        self.value_file = path.join(base_path, self.VALUE_NODE)

    def get_values(self):
        return float(self.read_file(self.value_file)),


class SHT3xSensor(Sensor):
    TEMPERATURE_NODE = 'hwmon/hwmon1/temp1_input'
    HUMIDITY_NODE = 'hwmon/hwmon1/humidity1_input'
    TEMPERATURE_UNIT = '°C'
    HUMIDITY_UNIT = '%'

    SCALE_FACTOR = 1000

    def __init__(self, base_path):
        super(SHT3xSensor, self).__init__((self.TEMPERATURE_UNIT, self.HUMIDITY_UNIT))
        self.temperature_file = path.join(base_path, self.TEMPERATURE_NODE)
        self.humidity_file = path.join(base_path, self.HUMIDITY_NODE)

    def get_values(self):
        return float(self.read_file(self.temperature_file)) / self.SCALE_FACTOR, \
               float(self.read_file(self.humidity_file)) / self.SCALE_FACTOR


def find_sensors_by_type(sensor_type):
    """
    Find all sensors of a certain type that are connected to the system.
    :param sensor_type: one of "sfm3000", "sdp600", "sfxx", "sht3x"
    :return: a list of Sensor instances.
    """
    sensor_details = {
        'sht3x': ('44', '*', SHT3xSensor),
    }
    path_template = '/sys/bus/i2c/devices/{0}-00{1}/'
    if sensor_type not in sensor_details:
        raise ValueError('Unknown sensor type ' + sensor_type)

    address, bus, sensor_class = sensor_details[sensor_type]
    pattern = path_template.format(bus, address)
    paths = glob.glob(pattern)
    loaded_sensors = []
    for p in paths:
        try:
            loaded_sensors.append(sensor_class(p))
        except Exception:
            pass
    return [s for s in loaded_sensors if s.is_available()]


def find_sensor_by_type(sensor_type):
    """
    Find one sensor of a certain type that is connected to the system.
    :param sensor_type: one of "sfm3000", "sdp600", "sfxx", "sht3x"
    :return: an instance of the Sensor class or None, if none was found.
    """
    sensors = find_sensors_by_type(sensor_type)
    if sensors:
        return sensors[0]


class SensorReader(threading.Thread):
    """
    Subclass of Thread that periodically reads sensor values and calls a user defined callback.
    The callback is called on the same thread as the measurements are done. Therefore it should return quickly, so as
    to not delay the next measurement. Should the reader not be able to fulfil the required sampling rate, it will
    skip readings, so that the time between measurements will always be a multiple of the measurement period.
    To read sensor values synchronously, call the run() method. This will block the calling thread and call the
    measurement callbacks on the same thread. To cancel, raise an exception from your callback.
    To read sensor values asynchronously, call the start() method. This will start a new thread to read the sensors
    and call the callback. To stop the thread, either raise an exception from the callback or call the stop() method.
    """
    def __init__(self, sensors, frequency, callback):
        """
        Initializes the sensor reader.
        :param sensors: a list of Sensor instances. These will be read out by this instance.
        :param frequency: desired read out frequency in Hz.
        :param callback: a callable to be called on new readings.
        The signature of the callback is as follows:
        - timestamp in seconds
        - ordered dictionary with Sensor instances as keys and the measured values as values
        """
        super(SensorReader, self).__init__(name=SensorReader.__name__)
        self._sensors = sensors
        self._interval = 1.0 / frequency
        self._callback = callback
        self._keep_going = True

    def run(self):
        iteration_start = time.time()
        self._keep_going = True
        while self._keep_going:
            values = OrderedDict()
            for sensor in self._sensors:
                try:
                    sensor_values = sensor.get_values()
                except Exception:
                    sensor_values = (None,) * sensor.get_number_of_values()
                values[sensor] = sensor_values
            self._callback(iteration_start, values)

            now = time.time()
            while iteration_start < now:
                iteration_start += self._interval
            time.sleep(iteration_start - now)

    def join(self, timeout=None):
        self.stop()
        super(SensorReader, self).join(timeout)

    def stop(self):
        self._keep_going = False
