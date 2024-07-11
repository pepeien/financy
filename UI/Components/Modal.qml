import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Components.Popup {
    default property alias data: _content.data

    property alias dataWidth:  _content.width
    property alias dataHeight: _content.height

    id:     _root
    width:  parent.width
    height: parent.height + headerComponent.height + footerComponent.height
    modal:  true
    y:      -headerComponent.height

    property bool _isOverContent: false

    background: Components.SquircleContainer {
        backgroundColor:  Qt.rgba(0, 0, 0, 0.4)
        backgroundRadius: 0

        MouseArea {
            anchors.fill: parent

            onClicked: function(event) {
                if (_root._isOverContent) {
                    return;
                }

                _root.close();
            }
        }
    }

    Item {
        id:     _content
        width:  parent.width * 0.6
        height: parent.height * 0.5

        anchors.centerIn: parent

        MouseArea {
            hoverEnabled: true

            anchors.fill: parent

            onEntered: function() {
                _root._isOverContent = true;
            }

            onExited: function() {
                _root._isOverContent = false;
            }
        }
    }

    Components.SquircleButton {
        width:  60
        height: 60

        backgroundColor: internal.colors.background

        anchors.bottom:           parent.bottom
        anchors.bottomMargin:     25
        anchors.horizontalCenter: parent.horizontalCenter

        onClick: function() {
            _root.close();
        }

        Image {
            id:                _icon
            source:           "qrc:/Icons/Close.svg"
            sourceSize.width:  parent.width * 0.5
            sourceSize.height: parent.height * 0.5
            antialiasing:      true
            visible:           false

            anchors.verticalCenter:   parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColorOverlay {
            anchors.fill: _icon
            source:       _icon
            color:        internal.colors.light
            antialiasing: true
        }
    }
}