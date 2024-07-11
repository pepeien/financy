import QtQuick

// Components
import "qrc:/Components" as Components

Item {
    default property alias data: content.data

    // Header
    property alias title:    header.title
    property alias onReturn: header.onReturn

    // Footer
    property alias leftButton:        footer.leftButton
    property alias leftButtonOnClick: footer.leftButtonOnClick
    property alias leftButtonIcon:    footer.leftButtonIcon

    property alias centerButton:        footer.centerButton
    property alias centerButtonOnClick: footer.centerButtonOnClick
    property alias centerButtonIcon:    footer.centerButtonIcon

    property alias rightButton:        footer.rightButton
    property alias rightButtonOnClick: footer.rightButtonOnClick
    property alias rightButtonIcon:    footer.rightButtonIcon

    readonly property alias headerComponent: header
    readonly property alias footerComponent: footer

    property var onRoute: function(){}

    Component.onCompleted: function() {
        onRoute();
    }

    Components.Header {
        id: header

        anchors.top:  parent.top
        anchors.left: parent.left
    }

    Item {
        id:     content
        height: parent.height - header.height - footer.height
        width:  parent.width

        anchors.top:       header.bottom
        anchors.left:      parent.left
    }

    Components.Footer {
        id: footer

        rightButtonIcon: "qrc:/Icons/Cog.svg"
        rightButtonOnClick: function() {
            stack.push("qrc:/Pages/Settings.qml");
        }
    }
}