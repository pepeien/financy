import QtQuick

Transition {
    PropertyAnimation {
        property:    "opacity"
        from:        1
        to:          0
        duration:    200
        easing.type: Easing.InOutQuad
    }
}