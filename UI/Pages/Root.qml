import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    anchors.fill: parent

    Rectangle {
        id:           mask
        radius:       4
        color:        internal.colors.background

        border.width: 1
        border.color: Qt.lighter(internal.colors.dark, 0.5)
        anchors.fill: parent

        Behavior on color {
            ColorAnimation {
                easing.type: Easing.InOutQuad
                duration:    200
            }
        }
    }

    Item {
        anchors.fill:  mask
        layer.enabled: true
        layer.effect:  OpacityMask {
            maskSource: mask
        }

        StackView {
            id:           stack
            initialItem:  "qrc:/Pages/Login.qml"
            anchors.fill: parent
        }
    }
}