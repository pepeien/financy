import QtQuick

Transition {
    PropertyAnimation {
        property:    "opacity"
        from:        0
        to:          1
        duration:    200
        easing.type: Easing.InOutQuad
    }
}