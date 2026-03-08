import QtQuick

Rectangle{
    anchors.fill: parent
    color: "#333333"

    FontLoader{
        id: headingFont
        source: config.headingFont
    }

    FontLoader{
        id: subHeadingFont
        source: config.subHeadingFont
    }

    property var currentTime: new Date()

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

    Column{
        spacing: -10
        anchors.centerIn: parent

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