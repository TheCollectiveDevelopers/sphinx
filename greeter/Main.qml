import QtQuick

Rectangle{
    id: greeter
    anchors.fill: parent
    color: "#333333"
    focus: true

    FontLoader{
        id: headingFont
        source: config.headingFont
    }

    FontLoader{
        id: subHeadingFont
        source: config.subHeadingFont
    }

    property var currentTime: new Date()
    property bool interacted: false

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: currentTime = new Date()
    }

    Image{
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background)
        fillMode: Image.PreserveAspectCrop
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: (mouse) => { interacted = true; mouse.accepted = false }
        onPositionChanged: interacted = true
    }

    Keys.onPressed: interacted = true

    Column{
        id: timeWidget
        spacing: -10
        anchors.centerIn: parent
        transformOrigin: Item.Center

        scale: interacted ? 0.9 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }

        transform: Translate {
            y: interacted ? (40 + timeWidget.height / 2 - greeter.height / 2) : 0
            Behavior on y {
                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
            }
        }

        Text{
            anchors.horizontalCenter: parent.horizontalCenter
            text: currentTime.toLocaleTimeString(Qt.locale(), "hh:mm")
            color: config.headingColor
            font.pixelSize: config.headingFontSize
            font.family: headingFont.font.family
        }

        Text{
            anchors.horizontalCenter: parent.horizontalCenter
            text: currentTime.toLocaleDateString(Qt.locale(), "dddd, d'th' MMMM")
            color: config.headingColor
            font.pixelSize: config.subHeadingFontSize
            font.family: subHeadingFont.font.family
            font.letterSpacing: 0.5
        }
    }
}