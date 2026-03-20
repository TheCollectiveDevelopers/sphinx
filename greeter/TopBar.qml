import QtQuick
import QtQuick.Controls

Item {
    id: topBar
    width: parent.width
    height: 50
    property int chromePadding: 10
    property int selectedSessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property color accentColor: config && config.color ? config.color : "#6f78d8"
    property color accentDark: Qt.darker(accentColor, 180)


    FontLoader {
        id: uiFont
        source: config.subHeadingFont
    }

    // ─────────────────────────────────────────
    // Session switcher
    // ─────────────────────────────────────────

    Item {
        id: sessionSwitcher
        anchors.left: parent.left
        anchors.leftMargin: topBar.chromePadding
        anchors.topMargin: topBar.chromePadding
        anchors.top: parent.top
        width: 220
        height: 36

        Rectangle {
            id: cogButton
            width: 40
            height: 40
            radius: 100
            color: cogMouse.containsMouse ? "#55000000" : "#33000000"
            border.color: "#33ffffff"
            border.width: 2

            Behavior on color { ColorAnimation { duration: 140 } }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: + 0
                anchors.horizontalCenterOffset: + 0.25
                text: "\u2699"
                color: "white"
                font.pixelSize: Math.round(cogButton.height * 0.66)
                font.family: uiFont.font.family
                renderType: Text.NativeRendering
                antialiasing: true
                layer.enabled: true
                layer.smooth: true
            }

            MouseArea {
                id: cogMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (sessionPanel.opened)
                        sessionPanel.close()
                    else
                        sessionPanel.open()
                }
            }
        }

        Popup {
            id: sessionPanel
            x: sessionSwitcher.x
            y: sessionSwitcher.y + cogButton.height - 8
            width: parent.width
            height: 24 + Math.max(sessionsList.contentHeight, 30)
            padding: 0
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            enter: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                    NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 220; easing.type: Easing.OutCubic }
                }
            }

            exit: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 140; easing.type: Easing.OutCubic }
                    NumberAnimation { property: "scale"; from: 1.0; to: 0.97; duration: 140; easing.type: Easing.OutCubic }
                }
            }

            background: Rectangle {
                radius: 14
                color: Qt.alpha(topBar.accentDark, 0.38)
                border.color: "#33ffffff"
                border.width: 1
            }

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                ComboBox {
                    id: sessionProxy
                    visible: false
                    model: sessionModel
                    textRole: "name"
                }

                ListView {
                    id: sessionsList
                    width: parent.width
                    height: contentHeight
                    model: sessionProxy.delegateModel
                    clip: true
                    spacing: 6

                    delegate: Rectangle {

                        required property int index

                        width: sessionsList.width
                        height: 30
                        radius: 9

                        scale: sessionMouse.containsMouse ? 1.02 : 1

                        color: topBar.selectedSessionIndex === index
                               ? Qt.alpha(topBar.accentColor, 0.45)
                               : (sessionMouse.containsMouse
                                  ? Qt.alpha(topBar.accentColor, 0.28)
                                  : "#30000000")

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 120 } }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            text: sessionProxy.textAt(index)
                            color: "white"
                            font.pixelSize: 13
                            font.family: uiFont.font.family
                            elide: Text.ElideRight
                            width: parent.width - 20
                            renderType: Text.NativeRendering
                            antialiasing: true
                            layer.enabled: true
                            layer.smooth: true
                        }

                        MouseArea {
                            id: sessionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                topBar.selectedSessionIndex = index
                                sessionPanel.close()
                            }
                        }
                    }
                }
            }
        }
    }

    // ─────────────────────────────────────────
    // Right-side status row
    // ─────────────────────────────────────────

    Row {
        id: statusRow
        anchors.right: parent.right
        anchors.rightMargin: topBar.chromePadding
        anchors.top: parent.top
        anchors.topMargin: topBar.chromePadding
        spacing: 14

        Rectangle {
            id: powerBtn
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40
            radius: 100
            color: powerBtnMA.containsMouse ? "#55000000" : "#33000000"
            border.color: "#33ffffff"
            border.width: 2

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: + 0
                anchors.horizontalCenterOffset: + 0.25
                text: "\u23FB"
                color: "white"
                font.pixelSize: Math.round(powerBtn.height * 0.66)
                font.family: uiFont.font.family
                renderType: Text.NativeRendering
                antialiasing: true
                layer.enabled: true
                layer.smooth: true
            }

            MouseArea {
                id: powerBtnMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerMenu.x = statusRow.x + statusRow.width - powerMenu.width
                    powerMenu.open()
                }
            }
        }
    }

    // ─────────────────────────────────────────
    // Power menu
    // ─────────────────────────────────────────

    Popup {
        id: powerMenu
        y: topBar.height + 4
        padding: 8
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 220; easing.type: Easing.OutCubic }
            }
        }

        exit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 140; easing.type: Easing.OutCubic }
                NumberAnimation { property: "scale"; from: 1.0; to: 0.97; duration: 140; easing.type: Easing.OutCubic }
            }
        }

        background: Rectangle {
            color: Qt.alpha(topBar.accentDark, 0.38)
            radius: 14
            border.color: "#33ffffff"
            border.width: 1
        }

        contentItem: Column {
            spacing: 6

            Repeater {
                model: ListModel {
                    ListElement { itemLabel: "Sleep";     itemAction: "suspend"  }
                    ListElement { itemLabel: "Restart";   itemAction: "reboot"   }
                    ListElement { itemLabel: "Shut Down"; itemAction: "powerOff" }
                }

                delegate: Rectangle {

                    width: 160
                    height: 30
                    radius: 9

                    scale: menuItemMA.containsMouse ? 1.02 : 1

                    color: menuItemMA.containsMouse
                           ? Qt.alpha(topBar.accentColor, 0.28)
                           : "#30000000"

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 120 } }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: model.itemLabel
                        color: "white"
                        font.pixelSize: 13
                        font.family: uiFont.font.family
                        renderType: Text.NativeRendering
                        antialiasing: true
                        layer.enabled: true
                        layer.smooth: true
                    }

                    MouseArea {
                        id: menuItemMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            powerMenu.close()

                            if (model.itemAction === "suspend")
                                sddm.suspend()
                            else if (model.itemAction === "reboot")
                                sddm.reboot()
                            else
                                sddm.powerOff()
                        }
                    }
                }
            }
        }
    }
}