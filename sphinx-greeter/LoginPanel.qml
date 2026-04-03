import QtQuick

Column {
    id: root

    property var usersModel: null
    property bool interacted: false
    property int selectedSessionIndex: 0
    property string nameFontFamily: ""

    signal loginRequested(string username, string password, int sessionIndex)

    function error() {
        passwordInput.error()
    }

    function loginAttemptCompleted() {
        passwordInput.enableInput()
    }

    spacing: 10
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 60
    opacity: root.interacted ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
    }

    onInteractedChanged: {
        if (root.interacted)
            passwordInput.focusInput()
    }

    UserListSelector {
        id: userSelector
        usersModel: root.usersModel
        width: parent.width
        onSelectionChanged: passwordInput.clear()
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: userSelector.selectedUserRealName ? userSelector.selectedUserRealName : userSelector.selectedUserName
        color: "white"
        font.pixelSize: 20
        font.family: root.nameFontFamily
        font.letterSpacing: 0.5
    }

    Input {
        id: passwordInput
        anchors.horizontalCenter: parent.horizontalCenter

        onAccepted: {
            if (userSelector.selectedUserName)
                passwordInput.disableInput()
                root.loginRequested(userSelector.selectedUserName, passwordInput.password, root.selectedSessionIndex)
        }
    }
}
