// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    property alias text: _label.text

    property bool isSwitched
    property string color:    internals.colors.light
    property string fill:     internals.colors.foreground

    property var onSwitch

    id: _root

    Text {
        id:    _label
        color: _root.color

        font.family:    "Inter"           
        font.pointSize: 10
        font.weight:    Font.Bold

        anchors.top:              parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Button {
        property int _radius: parent.width / 2

        id:      _switch
        width:   parent.width
        display: AbstractButton.IconOnly

        anchors.top:              _label.bottom
        anchors.topMargin:        10
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

        Rectangle {
            id:           _indicator
            radius:       _switch._radius
            antialiasing: true
            color:        _root.fill

            anchors.fill: parent

            Rectangle {
                id:           _icon
                width:        parent.height
                height:       parent.height
                radius:       _switch._radius
                antialiasing: true
                color:        _root.color
                
                property real _startLocation: 0.5
                property real _finalLocation: (parent.width - parent.height) - 0.5

                x: _root.isSwitched ? _icon._finalLocation : _icon._startLocation

                states: [
                    State {
                        when: _root.isSwitched
                        PropertyChanges {
                            target: _icon
                            x: _icon._finalLocation
                        }
                    },
                    State {
                        when: _root.isSwitched == false
                        PropertyChanges {
                            target: _icon
                            x: _icon._startLocation
                        }
                    }
                ]

                transitions: Transition {
                    NumberAnimation {
                        property:    "x"
                        easing.type: Easing.InOutQuad
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