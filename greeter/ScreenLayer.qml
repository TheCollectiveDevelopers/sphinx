import QtQuick

Rectangle {
    id: root

    property int screenIndex: -1
    property int primaryScreenIndex: -1
    property var screenGeometry: null
    property bool interacted: false
    property var currentTime: new Date()

    property string backgroundSource: ""
    property var usersModel: null
    property int selectedSessionIndex: 0

    property color headingColor: "white"
    property int headingFontSize: 70
    property int subHeadingFontSize: 22
    property string headingFontFamily: ""
    property string subHeadingFontFamily: ""

    signal loginRequested(string username, string password, int sessionIndex)

    function showLoginError() {
        if (isPrimary)
            loginPanel.error()
    }

    x: screenGeometry ? screenGeometry.x : 0
    y: screenGeometry ? screenGeometry.y : 0
    width: screenGeometry ? screenGeometry.width : 0
    height: screenGeometry ? screenGeometry.height : 0
    color: "transparent"

    readonly property bool isPrimary: root.screenIndex === root.primaryScreenIndex

    BackgroundLayer {
        anchors.fill: parent
        backgroundSource: root.backgroundSource
        blurActive: root.interacted
    }

    ClockWidget {
        visible: root.isPrimary
        currentTime: root.currentTime
        interacted: root.interacted
        textColor: root.headingColor
        headingFontSize: root.headingFontSize
        subHeadingFontSize: root.subHeadingFontSize
        headingFontFamily: root.headingFontFamily
        subHeadingFontFamily: root.subHeadingFontFamily
    }

    LoginPanel {
        id: loginPanel
        visible: root.isPrimary
        width: parent.width
        usersModel: root.usersModel
        interacted: root.interacted
        selectedSessionIndex: root.selectedSessionIndex
        nameFontFamily: root.subHeadingFontFamily

        onLoginRequested: (username, password, sessionIndex) => {
            root.loginRequested(username, password, sessionIndex)
        }
    }
}
