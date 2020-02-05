import sys
from sensirion_sensors import find_sensor_by_type, SensorReader
from os.path import abspath, dirname, join
import random
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QUrl
from PySide2.QtCore import QObject, Signal, Slot

value = [float(0.0),float(0.0)]

class EventGenerator(QObject):
    def __init__(self):
        QObject.__init__(self)

    readSignal = Signal(float,str)
    @Slot()
    def generateEvent(self):
        global value
        readSensor()
        self.readSignal.emit(value[0],'tmp')
        self.readSignal.emit(value[1],'hum')

        
def readSensor():
    shtObj = find_sensor_by_type('sht3x')

    if not shtObj:
        sys.stderr.writelines("couldn't find any sensor\n")
        return

    def reportSensorValues(sensorName):
        def sensorValue(timestamp, values):
            global value
            if sys.version_info >= (3, 0):
                value = list(values.values())[0]
            else:
                value = values.values()[0]

            sensorObj.stop()
        return sensorValue

    try:
        sensorObj = SensorReader((shtObj,), 1, report_sensor_values('shtObj'))
        sensorObj.start()
    finally:
        sensorObj.join()         

if __name__ == '__main__':
    appObj = QGuiApplication(sys.argv)
    engineObj = QQmlApplicationEngine()

    eventObj = EventGenerator()
    engineObj.rootContext().setContextProperty("pythonObj", eventObj)

    qmlFile = join(dirname(__file__), 'usr_interface.qml')
    engineObj.load(QUrl(qmlFile))

    if not engineObj.rootObjects():
        sys.exit(-1)
    
    
    sys.exit(appObj.exec_())
