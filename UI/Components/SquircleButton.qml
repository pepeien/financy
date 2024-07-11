import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Components.Button {
    default property alias data: _content.data

    // Container Props
    property alias backgroundBorder:            _content.backgroundBorder
    property alias backgroundRadius:            _content.backgroundRadius
    property alias backgroundTopLeftRadius:     _content.backgroundTopLeftRadius
    property alias backgroundTopRightRadius:    _content.backgroundTopRightRadius
    property alias backgroundBottomLeftRadius:  _content.backgroundBottomLeftRadius
    property alias backgroundBottomRightRadius: _content.backgroundBottomRightRadius

    property bool hasShadow:            false
    property bool disableWillOverwrite: true
    property var backgroundColor:       "transparent"

    id: _root

    Components.SquircleContainer {
        id:     _content
        height: _root.height
        width:  _root.width

        hasShadow:              isDisabled && disableWillOverwrite ? false : _root.hasShadow
        backgroundColor:        isDisabled && disableWillOverwrite ? "transparent" : _root.backgroundColor
        backgroundBorder.width: isDisabled && disableWillOverwrite ? 2.5 :  0
        backgroundBorder.color: isDisabled && disableWillOverwrite ? internal.colors.foreground : "transparent"
    }
}