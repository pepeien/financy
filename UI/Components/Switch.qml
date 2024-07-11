import QtQuick
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Item {
    // Props
    property alias labelText:    _label.text

    property alias buttonHeight: _switch.height
    property alias buttonWidth:  _switch.width

    property bool isSwitched:   false
    property string color:      internal.colors.light
    property string fill:       internal.colors.foreground

    property var onSwitch

    id: _root

    Components.Text {
        id:      _label
        color:   _root.color
        visible: text != ""
        
        font.pointSize: 10
        font.weight:    Font.Bold

        anchors.top:              parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Button {
        id:      _switch
        width:   _root.width
        height:  25
        display: AbstractButton.IconOnly

        readonly property int _radius: _switch.height / 2

        anchors.top:              _label.visible ? _label.bottom : _root.top
        anchors.topMargin:        _label.visible ? 10 : 0
        anchors.horizontalCenter: parent.horizontalCenter

        layer.enabled: true
        layer.effect:  OpacityMask {
            maskSource: Rectangle {
                width:   _switch.width
                height:  _switch.height
                radius:  _switch._radius
                visible: true
            }
        }

        background: Rectangle {
            color: "transparent"
        }

        Rectangle {
            id:           _indicator
            radius:       _switch._radius
            antialiasing: true
            color:        _root.fill

            anchors.fill: parent

            Rectangle {
                property real _size:          _indicator.height * 0.78
                property real _padding:       _indicator.height * 0.22
                property real _startLocation: _padding
                property real _finalLocation: _indicator.width - _size - _padding

                id:           _icon
                width:        _size
                height:       _size
                radius:       _switch._radius
                color:        _root.color
                antialiasing: true

                anchors.left:           parent.left
                anchors.leftMargin:     _root.isSwitched ? _finalLocation : _startLocation
                anchors.verticalCenter: parent.verticalCenter

                Behavior on anchors.leftMargin {
                    PropertyAnimation {
                        easing.type: Easing.InOutQuad
                        duration:    200
                    }
                }
            }
        }

        MouseArea {
            hoverEnabled: true

            anchors.fill: parent

            onClicked: {
                _root.isSwitched = !_root.isSwitched;

                if (!onSwitch) {
                    return;
                }

                onSwitch();
            }

            onEntered: {
                cursorShape = Qt.PointingHandCursor;
            }

            onExited: {
                cursorShape = Qt.ArrowCursor;
            }
        }
    }
}