import QtQuick

Text {
    font.family: "Inter"

    Behavior on color {
        ColorAnimation {
            easing.type: Easing.InOutQuad
            duration:    200
        }
    }
}