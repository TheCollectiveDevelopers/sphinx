import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: greeter
    anchors.fill: parent
    color: "#000000"
    focus: true

    FontLoader {
        id: headingFont
        source: config.headingFont
    }

    FontLoader {
        id: subHeadingFont
        source: config.subHeadingFont
    }

    property var currentTime: new Date()
    property bool interacted: false

    signal loginFailed()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: greeter.currentTime = new Date()
    }

    Timer {
        interval: 1000 * 60 * 5
        running: true
        repeat: true
        onTriggered: greeter.interacted = false
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: (mouse) => { greeter.interacted = true; mouse.accepted = false }
        onPositionChanged: greeter.interacted = true
    }

    Keys.onPressed: greeter.interacted = true

    Repeater {
        model: screenModel

        delegate: Rectangle {
            id: screenItem
            x: geometry.x
            y: geometry.y
            width: geometry.width
            height: geometry.height
            color: "transparent"

            AnimatedImage {
                id: screenBg
                anchors.fill: parent
                source: Qt.resolvedUrl(config.background)
                fillMode: Image.PreserveAspectCrop
            }

            FastBlur {
                anchors.fill: parent
                source: screenBg
                radius: greeter.interacted ? 60 : 0

                Behavior on radius {
                    NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                }
            }

            Column {
                id: timeWidget
                visible: index === screenModel.primary
                spacing: -10
                anchors.centerIn: parent
                transformOrigin: Item.Center

                scale: greeter.interacted ? 0.9 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                }

                transform: Translate {
                    y: greeter.interacted ? (40 + timeWidget.height / 2 - screenItem.height / 2) : 0
                    Behavior on y {
                        NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: greeter.currentTime.toLocaleTimeString(Qt.locale(), "hh:mm")
                    color: config.headingColor
                    font.pixelSize: config.headingFontSize
                    font.family: headingFont.font.family
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: greeter.currentTime.toLocaleDateString(Qt.locale(), "dddd, d'th' MMMM")
                    color: config.headingColor
                    font.pixelSize: config.subHeadingFontSize
                    font.family: subHeadingFont.font.family
                    font.letterSpacing: 0.5
                }
            }

            Column {
                id: inputLayout
                visible: index === screenModel.primary
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 60
                opacity: greeter.interacted ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                }

                ListView {
                    id: userList
                    width: screenItem.width
                    height: 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    orientation: ListView.Horizontal
                    spacing: 16
                    clip: true
                    model: userModel
                    currentIndex: userModel.lastIndex

                    preferredHighlightBegin: width / 2 - 40
                    preferredHighlightEnd: width / 2 + 40
                    highlightRangeMode: ListView.StrictlyEnforceRange

                    delegate: Item {
                        id: userDelegate
                        anchors.verticalCenter: parent.verticalCenter
                        width: isSelected ? 80 : 50
                        height: isSelected ? 80 : 50
                        opacity: isSelected ? 1 : 0.8
                        property bool isSelected: ListView.isCurrentItem
                        property string userName: model.name
                        property string realName: model.realName

                        Behavior on width {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }

                        Behavior on height {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }

                        Behavior on opacity {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }

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

                    onCurrentIndexChanged: {
                        passwordInput.clear()
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: userList.currentItem.realName ? userList.currentItem.realName : userList.currentItem.userName
                    color: "white"
                    font.pixelSize: 20
                    font.family: subHeadingFont.font.family
                    font.letterSpacing: 0.5
                }

                Input {
                    id: passwordInput
                    anchors.horizontalCenter: parent.horizontalCenter

                    onAccepted: () => {
                        sddm.login(userList.currentItem.userName, passwordInput.password, topBarWidget.selectedSessionIndex)
                    }
                }
            }

            Connections {
                target: greeter
                function onLoginFailed() {
                    if (index === screenModel.primary)
                        passwordInput.error()
                }
            }
        }
    }

    TopBar {
        id: topBarWidget
        anchors.top: parent.top
        width: parent.width
        z: 10
    }

    Connections {
        target: sddm
        function onLoginFailed() { greeter.loginFailed() }
    }
}
