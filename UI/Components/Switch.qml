// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    property alias text: _label.text

    property bool isSwitched:  false
    property string color:     internals.colors.light
    property string fill:      internals.colors.foreground
    property var onSwitch

    id: _root

    Text {
        id: _label
        color: _root.color

        font.family:    "Inter"           
        font.pointSize: 10
        font.weight:    Font.Bold

        anchors.top: parent.top
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

                NumberAnimation on x {
                    running: _root.isSwitched
                    from:    _icon._startLocation
                    to:      _icon._finalLocation
                }

                NumberAnimation on x {
                    running: _root.isSwitched == false
                    from:    _icon._finalLocation
                    to:      _icon._startLocation
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