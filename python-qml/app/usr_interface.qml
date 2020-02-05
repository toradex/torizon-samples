import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 1.0

Window {
    id: root
    visible: true
    width: 200
    height: 150
    maximumHeight: 150
    maximumWidth: 200
    minimumHeight: 150
    minimumWidth: 200
    color: "#0c0000"
    opacity: 1
    title: "Env Window"

    Button {
        id: button
        x: 62
        y: 40
        width: 94
        height: 37
        text: qsTr("Temp/Hum")
        clip: false
        checkable: false
        iconSource: ""
        opacity: 1
        onClicked: pythonObj.generateEvent()
    }

    Image {
        id: image
        x: 35
        y: 41
        width: 31
        height: 35
        opacity: 1
        source: "ui_image.png"
        fillMode: Image.PreserveAspectCrop
    }

    Text {
        id: temperature
        x: 44
        y: 83
        width: 122
        height: 13
        color: "#f9d212"
        text: "Tem:  "
        lineHeight: 1
        fontSizeMode: Text.Fit
        wrapMode: Text.WordWrap
        font.pixelSize: 12
    }
    signal showReadings(double reading,string type)
    Component.onCompleted: pythonObj.readSignal.connect(showReadings)

    Connections {
        target: root
        onShowReadings: setValues(reading,type) // first letter of signal must be capital for handler
    }

    Text {
        id: humidity
        x: 44
        y: 102
        width: 122
        height: 17
        color: "#c4e5e0"
        text: "Hum:"
        lineHeight: 1
        font.pixelSize: 12
        wrapMode: Text.NoWrap
        fontSizeMode: Text.Fit
    }

    function setValues(val, type)
    {
        if (type === 'tmp')
            temperature.text = 'Tem:  ' + val.toFixed(1);
        else if(type === 'hum')
            humidity.text = "Hum: " + val.toFixed(1);
    }
}
