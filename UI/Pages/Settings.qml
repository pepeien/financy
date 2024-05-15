// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

// Types
import Financy.Colors 1.0

// Components
import "qrc:/Components" as Components

Components.Page {
    title:              "Settings"
    rightButtonIcon:    ""
    rightButtonOnClick: undefined

    Components.SquircleContainer {
        property real _padding: 30

        id:     _theme
        width:  parent.width * 0.35
        height: 80

        anchors.horizontalCenter: parent.horizontalCenter

        backgroundColor: internal.colors.background
        hasShadow:       true

        Components.Text {
            text:  "Theme"
            color: internal.colors.dark

            font.pointSize: 16
            font.weight:    Font.Bold

            anchors.left:           parent.left
            anchors.leftMargin:     _theme._padding
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width:  1
            height: parent.height - (_theme._padding * 1.5)
            color:  internal.colors.light

            anchors.right:          _switch.left
            anchors.rightMargin:    10
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color {
                ColorAnimation {
                    easing.type: Easing.InOutQuad
                    duration:    200
                }
            }
        }

        Components.Switch {
            id:     _switch
            width:  60
            height: 25

            anchors.right:          parent.right
            anchors.rightMargin:    _theme._padding
            anchors.verticalCenter: parent.verticalCenter

            color:      internal.colors.background
            fill:       internal.colors.light
            isSwitched: internal.colorsTheme == Colors.Dark

            onSwitch: function() {
                internal.updateTheme(internal.colorsTheme == Colors.Dark ? Colors.Light : Colors.Dark);
            }
        }
    }
}