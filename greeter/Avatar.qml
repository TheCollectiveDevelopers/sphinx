import QtQuick
import Qt5Compat.GraphicalEffects

Item{
    id: avatar

    property bool selected: false
    property string source: ""

    width: 100
    height: 100

    Image{
        id: mask
        visible: false
        source: selected ? "./assets/main-mask.png" : "./assets/secondary-mask.png"
        layer.enabled: true
        layer.smooth: true
        sourceSize: Qt.size(400, 400)
    }

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
        maskSource: mask
    }
}