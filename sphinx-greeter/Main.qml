import QtQuick

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

        delegate: ScreenLayer {
            id: screenLayer
            screenIndex: index
            primaryScreenIndex: screenModel.primary
            screenGeometry: geometry
            interacted: greeter.interacted
            currentTime: greeter.currentTime
            backgroundSource: config.background
            usersModel: userModel
            selectedSessionIndex: topBarWidget.selectedSessionIndex
            headingColor: config.headingColor
            headingFontSize: config.headingFontSize
            subHeadingFontSize: config.subHeadingFontSize
            headingFontFamily: headingFont.font.family
            subHeadingFontFamily: subHeadingFont.font.family

            onLoginRequested: (username, password, sessionIndex) => {
                sddm.login(username, password, sessionIndex)
            }

            Connections {
                target: greeter
                function onLoginFailed() {
                    screenLayer.showLoginError()
                    screenLayer.loginAttemptCompleted()
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
