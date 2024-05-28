// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Item {
    // Alias Props
    property alias color:     _input.color
    property alias text:      _input.text
    property alias validator: _input.validator

    function clear() {
        _input.clear();
    }

    property alias label: inputLabel.text
    property alias hint:  inputHint.text

    // Value Props
    property int minLength: 0
    property int maxLength: 0

    property real inputHeight: 60

    // Out Props
    readonly property var input: _input

    // Vars
    readonly property real textPadding: 16
    readonly property bool hasStatus:   root.minLength > 0 || root.maxLength > 0
    readonly property bool hasHint:     inputHint.text.length > 0

    id:     root
    width:  120 + root.textPadding
    height: root.inputHeight + 20

    Components.SquircleContainer {
        id:     _inputContainer
        height: root.inputHeight
        width:  root.width
        clip:   true

        backgroundColor: internal.colors.foreground

        anchors.horizontalCenter: parent.horizontalCenter

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

        TextInput {
            id:            _input
            height:        parent.height
            width:         parent.width - (root.textPadding * 2)
            text:          ""
            maximumLength: root.maxLength > 0 ? root.maxLength : -1

            verticalAlignment: TextInput.AlignVCenter

            font.family:    "Inter"           
            font.pointSize: Math.round(root.inputHeight * 0.2)
            font.weight:    Font.Normal

            anchors.left:           parent.left
            anchors.leftMargin:     root.textPadding
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Item {
        id:      _lengthStatus
        visible: root.hasStatus
        opacity: 0.7

        anchors.top:          _inputContainer.bottom
        anchors.right:        _inputContainer.right
        anchors.topMargin: 5
        anchors.rightMargin:  _lenghtMin.contentWidth + _lenghtMax.contentWidth + 5

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

    Components.Text {
        id:      inputHint
        visible: root.hasHint
        color:   _input.color
        opacity: inputLabel.opacity

        font.family:    _input.font.family
        font.pointSize: 8
        font.weight:    Font.Bold

        anchors.top:        _inputContainer.bottom
        anchors.left:       _inputContainer.left
        anchors.topMargin:  5
        anchors.leftMargin: 5
    }
}