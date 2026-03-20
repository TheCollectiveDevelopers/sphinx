import QtQuick

Column {
    id: root

    property var currentTime: new Date()
    property bool interacted: false
    property color textColor: "white"
    property int headingFontSize: 70
    property int subHeadingFontSize: 22
    property string headingFontFamily: ""
    property string subHeadingFontFamily: ""

    spacing: -10
    anchors.centerIn: parent
    transformOrigin: Item.Center
    layer.enabled: true
    layer.smooth: true
    layer.textureSize: Qt.size(width * 2, height * 2)

    scale: root.interacted ? 0.9 : 1.0
    Behavior on scale {
        NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
    }

    transform: Translate {
        y: root.interacted ? (40 + root.height / 2 - (root.parent ? root.parent.height : 0) / 2) : 0
        Behavior on y {
            NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.currentTime.toLocaleTimeString(Qt.locale(), "hh:mm")
        color: root.textColor
        font.pixelSize: root.headingFontSize
        font.family: root.headingFontFamily
        renderType: Text.NativeRendering
        antialiasing: true
        layer.enabled: true
        layer.smooth: true
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.currentTime.toLocaleDateString(Qt.locale(), "dddd, d'th' MMMM")
        color: root.textColor
        font.pixelSize: root.subHeadingFontSize
        font.family: root.subHeadingFontFamily
        font.letterSpacing: 0.5
        renderType: Text.NativeRendering
        antialiasing: true
        layer.enabled: true
        layer.smooth: true
    }
}
