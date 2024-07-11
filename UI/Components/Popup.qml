import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Popup {
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from:     0.0
            to:       1.0
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from:     1.0
            to:       0.0
        }
    }
}