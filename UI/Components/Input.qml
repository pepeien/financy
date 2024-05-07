// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Components.SquircleContainer {
    // Alias Props
    property alias color: _input.color
    property alias label: inputLabel.text

    // Out Props
    property var input: _input

    // Vars
    property real textPadding: 16

    id: root
    height: 60
    width: 120
    backgroundColor: internals.colors.foreground

    Rectangle {
        height: parent.height
        width: parent.width  - (textPadding * 2)
        color: "transparent"
        clip: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        TextInput {
            id: _input
            verticalAlignment: TextInput.AlignVCenter

            font.family: "Inter"           
            font.pointSize: Math.round(root.height * 0.25)
            font.weight: Font.Normal

            anchors.fill: parent
        }
    }

    Label {
        id: inputLabel
        color: _input.color
        leftPadding: textPadding
        opacity: 0.77

        font.family: _input.font.family
        font.pointSize: _input.font.pointSize
        font.weight: Font.Light

        anchors.verticalCenter: parent.verticalCenter

        states: [
            State {
                when: _input.activeFocus || _input.text !== ""
                AnchorChanges {
                    target: inputLabel

                    anchors.verticalCenter: undefined
                    anchors.top: parent.top
                }
                PropertyChanges {
                    target: inputLabel

                    font.pointSize: Math.round(_input.font.pointSize * 0.65)
                    topPadding: 2
                }
            }
        ]

        transitions: [
            Transition {
                AnchorAnimation {
                    duration: 200
                }

                NumberAnimation {
                    duration: 200
                    property: "font.pointSize"
                }

                NumberAnimation {
                    duration: 200
                    property: "topPadding"
                }
            }
        ]
    }
}