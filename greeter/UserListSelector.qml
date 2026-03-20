import QtQuick

ListView {
    id: root

    property var usersModel: null
    property int initialIndex: (usersModel && usersModel.lastIndex >= 0) ? usersModel.lastIndex : 0
    readonly property string selectedUserName: root.currentItem ? root.currentItem.userName : ""
    readonly property string selectedUserRealName: root.currentItem ? root.currentItem.realName : ""

    signal selectionChanged()

    width: parent ? parent.width : 0
    height: 80
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    orientation: ListView.Horizontal
    spacing: 16
    clip: true
    model: root.usersModel
    currentIndex: root.initialIndex

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
            onClicked: root.currentIndex = index
        }
    }

    onCurrentIndexChanged: root.selectionChanged()
}
