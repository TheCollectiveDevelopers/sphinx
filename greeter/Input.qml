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
    
    TextField{
        id: input
        anchors.fill: parent
        placeholderText: "Enter your password"
        placeholderTextColor: "#88D7D7D7"
        echoMode: TextInput.Password

        background: Rectangle{
            color: "transparent"
        }
    }
}