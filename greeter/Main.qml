import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle{
    id: greeter
    anchors.fill: parent
    color: "#000000"
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

    AnimatedImage{
        id: bg
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background)
        fillMode: Image.PreserveAspectCrop
    }

    FastBlur{
        anchors.fill: parent
        source: bg
        radius: interacted ? 60 : 0

        Behavior on radius {
            NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
        }
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
            NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
        }

        transform: Translate {
            y: interacted ? (40 + timeWidget.height / 2 - greeter.height / 2) : 0
            Behavior on y {
                NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
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

    Column{
        id: inputLayout
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        opacity: interacted ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
        }

        ListView {
            id: userList
            width: 500
            height: 60
            anchors.horizontalCenter: parent.horizontalCenter
            orientation: ListView.Horizontal
            spacing: 16
            clip: true
            model: userModel
            currentIndex: userModel.lastIndex

            preferredHighlightBegin: width / 2 - 50
            preferredHighlightEnd: width / 2 + 50
            highlightRangeMode: ListView.StrictlyEnforceRange

            delegate: Item {
                id: userDelegate
                height: 60
                width: 60
                property bool isSelected: ListView.isCurrentItem
                property string userName: model.name
                property string realName: model.realName

                Avatar {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: model.icon
                    selected: userDelegate.isSelected
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: userList.currentIndex = index
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: userList.currentItem.realName ? userList.currentItem.realName : userList.currentItem.userName
            color: "white"
            font.pixelSize: 18
            font.family: subHeadingFont.font.family
            font.letterSpacing: 0.5
        }

        Input {
            anchors.horizontalCenter: parent.horizontalCenter
            id: passwordInput
        }
    }
}