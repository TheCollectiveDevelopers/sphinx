import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent

    property string backgroundSource: ""
    property bool blurActive: false

    AnimatedImage {
        id: screenBg
        anchors.fill: parent
        property bool triedFallbackPath: false
        source: Qt.resolvedUrl(root.backgroundSource)
        fillMode: Image.PreserveAspectCrop

        onStatusChanged: {
            if (status === Image.Error && !triedFallbackPath) {
                triedFallbackPath = true
                source = Qt.resolvedUrl("../" + root.backgroundSource)
            }
        }
    }

    FastBlur {
        anchors.fill: parent
        source: screenBg
        radius: root.blurActive ? 60 : 0

        Behavior on radius {
            NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
        }
    }

    Rectangle{
        anchors.fill: parent
        color: "#20000000"
        opacity: root.blurActive ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
        }
    }
}
