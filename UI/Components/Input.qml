// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Components.SquircleContainer {
    // Alias Props
    property alias color: _input.color
    property alias text:  _input.text
    property alias label: inputLabel.text

    // Value Props
    property int minLength: 0
    property int maxLength: 0

    // Out Props
    readonly property var input: _input

    // Vars
    readonly property real textPadding: 16

    id: root
    height:          60
    width:           120
    backgroundColor: internals.colors.foreground

    Rectangle {
        id:     _inputContainer
        height: parent.height  - (textPadding * 2)
        width:  parent.width  - (textPadding * 2)
        color:  "transparent"
        clip:   true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter:   parent.verticalCenter

        TextInput {
            id:                _input
            text:              ""
            verticalAlignment: TextInput.AlignVCenter
            topPadding:        4
            maximumLength:     root.maxLength > 0 ? root.maxLength : -1

            font.family:    "Inter"           
            font.pointSize: Math.round(root.height * 0.2)
            font.weight:    Font.Normal

            anchors.fill: parent
        }
    }

    Label {
        id:          inputLabel
        color:       _input.color
        leftPadding: textPadding
        opacity:     0.77

        font.family:    _input.font.family
        font.pointSize: _input.font.pointSize
        font.weight:    Font.Bold

        anchors.verticalCenter: parent.verticalCenter

        states: [
            State {
                when: _input.activeFocus || _input.text !== ""
                AnchorChanges {
                    target: inputLabel

                    anchors.verticalCenter: undefined
                    anchors.top:            parent.top
                }
                PropertyChanges {
                    target: inputLabel

                    font.pointSize: Math.round(_input.font.pointSize * 0.65)
                    topPadding:     4
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

    Item {
        id:      _lengthStatus
        visible: root.minLength > 0 | root.maxLength > 0
        opacity: 0.7

        anchors.bottom:       _inputContainer.bottom
        anchors.right:        _inputContainer.right
        anchors.bottomMargin: -22.5
        anchors.rightMargin:  _lenghtMin.contentWidth + _lenghtMax.contentWidth - 10

        Components.Text {
            id:           _lenghtMin
            text:         _input.text.length > root.minLength ? _input.text.length  : _input.text.length - root.minLength
            color:        _input.color
            antialiasing: true

            font.pointSize: 8
            font.weight:    Font.Bold
        }

        Components.Text {
            id:           _lenghtMax
            text:         "/ " + root.maxLength
            color:        _lenghtMin.color
            antialiasing: true

            anchors.left:       _lenghtMin.right
            anchors.leftMargin: 2

            font.family:    _lenghtMin.font.family
            font.pointSize: _lenghtMin.font.pointSize
            font.weight:    _lenghtMin.font.weight
        }
    }
}