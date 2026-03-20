import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle{
    id: avatar

    property bool selected: false
    property string source: ""

    width: 100
    height: 100
    color: "#88000000"
    radius: width / 2

    Image{
        id: content
        visible: false
        anchors.centerIn: parent
        source: avatar.source
        layer.enabled: true
        layer.smooth: true
    }

    OpacityMask{
        anchors.fill: parent
        source: content
        cached: true
        maskSource: Rectangle{
            width: 400
            height: 400
            radius: 200
            color: "white"
        }
    }
}