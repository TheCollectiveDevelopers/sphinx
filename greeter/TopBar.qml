import QtQuick
import QtQuick.Controls

Item {
    id: topBar
    width: parent.width
    height: 50

    // Battery charge level (0–100).
    // Auto-populated if SDDM exposes a `battery` context property;
    // stays -1 (hidden) otherwise. Can also be set explicitly from Main.qml.
    property int batteryLevel: -1

    FontLoader {
        id: uiFont
        source: config.subHeadingFont
    }

    Component.onCompleted: {
        try {
            if (typeof battery !== "undefined" && battery !== null) {
                batteryLevel = Qt.binding(function () { return battery.chargeLevel })
            }
        } catch (e) {}
    }

    // ─── Session Selector (left) ────────────────────────────────────────────

    ComboBox {
        id: sessionSelector
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        model: sessionModel
        textRole: "name"
        currentIndex: sessionModel.lastIndex
        onActivated: sessionModel.lastIndex = currentIndex

        background: Rectangle {
            implicitWidth: 160
            implicitHeight: 32
            color: sessionSelector.pressed ? "#66000000" : "#44000000"
            radius: 16
            border.color: "#33ffffff"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        contentItem: Text {
            leftPadding: 14
            rightPadding: 28
            text: sessionSelector.displayText
            color: "white"
            font.pixelSize: 13
            font.family: uiFont.font.family
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        indicator: Text {
            x: sessionSelector.width - width - 12
            y: (sessionSelector.height - height) / 2
            text: sessionSelector.popup.visible ? "\u25B4" : "\u25BE"
            color: "#99ffffff"
            font.pixelSize: 9
        }

        popup: Popup {
            y: sessionSelector.height + 4
            width: sessionSelector.width
            padding: 6
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            background: Rectangle {
                color: "#EE141414"
                radius: 12
                border.color: "#33ffffff"
                border.width: 1
            }

            contentItem: ListView {
                implicitHeight: contentHeight
                model: sessionSelector.delegateModel
                currentIndex: sessionSelector.highlightedIndex
                clip: true
            }
        }

        delegate: ItemDelegate {
            width: sessionSelector.width - 12
            height: 36
            highlighted: sessionSelector.highlightedIndex === index

            background: Rectangle {
                color: highlighted ? "#44ffffff" : "transparent"
                radius: 8
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            contentItem: Text {
                leftPadding: 8
                text: model.name
                color: "white"
                font.pixelSize: 13
                font.family: uiFont.font.family
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // ─── Right-side status row ──────────────────────────────────────────────

    Row {
        id: statusRow
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        // Battery indicator (shown only when available)
        Row {
            id: batteryIndicator
            property bool hasBatteryData: topBar.batteryLevel >= 0
            property int clampedLevel: Math.max(0, Math.min(100, topBar.batteryLevel))
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            visible: true

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 12

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 20
                    height: 12
                    radius: 2
                    color: "transparent"
                    border.color: "#ccffffff"
                    border.width: 1

                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                        width: batteryIndicator.hasBatteryData
                               ? Math.max(2, (parent.width - 4) * batteryIndicator.clampedLevel / 100)
                               : Math.max(2, (parent.width - 4) * 0.45)
                        height: parent.height - 4
                        radius: 1
                        color: batteryIndicator.hasBatteryData
                               ? (batteryIndicator.clampedLevel > 20 ? "#ccffffff" : "#ff8080")
                               : "#99ffffff"
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: 6
                    radius: 1
                    color: "#ccffffff"
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: batteryIndicator.hasBatteryData ? (batteryIndicator.clampedLevel + "%") : "--"
                color: "white"
                font.pixelSize: 13
                font.family: uiFont.font.family
            }
        }

        // Power button
        Rectangle {
            id: powerBtn
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 32
            radius: 16
            color: powerBtnMA.containsMouse ? "#66000000" : "#44000000"
            border.color: "#33ffffff"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "\u23FB"
                color: "white"
                font.pixelSize: 15
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

    // ─── Power menu popup ───────────────────────────────────────────────────

    Popup {
        id: powerMenu
        y: topBar.height + 4
        padding: 8
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#EE141414"
            radius: 12
            border.color: "#33ffffff"
            border.width: 1
        }

        contentItem: Column {
            spacing: 4

            Repeater {
                model: ListModel {
                    ListElement { itemLabel: "Sleep";     itemAction: "suspend"  }
                    ListElement { itemLabel: "Restart";   itemAction: "reboot"   }
                    ListElement { itemLabel: "Shut Down"; itemAction: "powerOff" }
                }

                delegate: Rectangle {
                    width: 160
                    height: 40
                    radius: 8
                    color: menuItemMA.containsMouse ? "#33ffffff" : "transparent"
                    opacity: (model.itemAction === "suspend"  && !sddm.canSuspend)  ||
                             (model.itemAction === "reboot"   && !sddm.canReboot)   ||
                             (model.itemAction === "powerOff" && !sddm.canPowerOff) ? 0.4 : 1.0

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        text: model.itemLabel
                        color: "white"
                        font.pixelSize: 14
                        font.family: uiFont.font.family
                    }

                    MouseArea {
                        id: menuItemMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            powerMenu.close()
                            if      (model.itemAction === "suspend")  sddm.suspend()
                            else if (model.itemAction === "reboot")   sddm.reboot()
                            else                                      sddm.powerOff()
                        }
                    }
                }
            }
        }
    }
}
