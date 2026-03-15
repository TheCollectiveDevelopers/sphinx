import QtQuick
import QtQuick.Controls

Rectangle{
    id: inputBox
    width: 200
    height: 35
    color: "#88000000"
    radius: 100
    border.color: "#88D7D7D7"
    border.width: 1

    property string password: input.text
    signal accepted()

    function clear(){
        input.text = ""
    }

    transform: Translate { id: shakeTranslate }

    function error(){
        shakeAnimation.start()
        input.selectAll()
    }

    SequentialAnimation {
        id: shakeAnimation
        loops: 1

        NumberAnimation { target: shakeTranslate; property: "x"; from: 0; to: -8; duration: 60; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeTranslate; property: "x"; from: -8; to: 8; duration: 60; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeTranslate; property: "x"; from: 8; to: -8; duration: 65; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeTranslate; property: "x"; from: -8; to: 8; duration: 70; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeTranslate; property: "x"; from: 8; to: -8; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeTranslate; property: "x"; from: -8; to: 8; duration: 90; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeTranslate; property: "x"; from: 8; to: 0; duration: 90; easing.type: Easing.InOutQuad }
    }

    TextField{
        id: input
        anchors.fill: parent
        placeholderText: "Enter your password"
        placeholderTextColor: "#88D7D7D7"
        echoMode: TextInput.Password

        background: Rectangle{
            color: "transparent"
        }

        onAccepted: () => inputBox.accepted()
    }
}