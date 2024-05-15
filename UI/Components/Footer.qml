// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Rectangle {
    property alias leftButtonOnClick: _leftButton.onClick
    property alias leftButtonIcon:    _leftButtonIcon.source

    property alias centerButtonOnClick: _centerButton.onClick
    property alias centerButtonIcon:    _centerButtonIcon.source

    property alias rightButtonOnClick: _rightButton.onClick
    property alias rightButtonIcon:    _rightButtonIcon.source

    width:  parent.width
    height: 125
    color:  "transparent"

    anchors.bottom:       parent.bottom
    anchors.left:         parent.left

    Components.SquircleButton {
        id:     _leftButton
        width:  42
        height: 42
        visible: leftButtonIcon != ""

        backgroundColor: Qt.lighter(internal.colors.foreground, 1.1)
        hasShadow:       true

        anchors.right:          _centerButton.left
        anchors.rightMargin:    30
        anchors.verticalCenter: parent.verticalCenter

        Image {
            id:                _leftButtonIcon
            sourceSize.width:  parent.width * 0.5
            sourceSize.height: parent.height * 0.5
            antialiasing:      true
            visible:           false

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColorOverlay {
            anchors.fill: _leftButtonIcon
            source:       _leftButtonIcon
            color:        internal.colors.light
            antialiasing: true
        }
    }

    Components.SquircleButton {
        id:     _centerButton
        width:  50
        height: 50
        visible: centerButtonIcon != ""

        backgroundColor: _leftButton.backgroundColor
        hasShadow:       true

        anchors.verticalCenter:   parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id:                _centerButtonIcon
            sourceSize.width:  parent.width * 0.5
            sourceSize.height: parent.height * 0.5
            antialiasing:      true
            visible:           false

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColorOverlay {
            anchors.fill: _centerButtonIcon
            source:       _centerButtonIcon
            color:        internal.colors.light
            antialiasing: true
        }
    }

    Components.SquircleButton {
        id:      _rightButton
        width:   _leftButton.width
        height:  _leftButton.height
        visible: rightButtonIcon != ""

        backgroundColor: _leftButton.backgroundColor
        hasShadow:       true

        anchors.left:           _centerButton.right
        anchors.leftMargin:     _leftButton.anchors.rightMargin
        anchors.verticalCenter: parent.verticalCenter

        Image {
            id:                _rightButtonIcon
            sourceSize.width:  parent.width * 0.6
            sourceSize.height: parent.height * 0.6
            antialiasing:      true
            visible:           false

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColorOverlay {
            anchors.fill: _rightButtonIcon
            source:       _rightButtonIcon
            color:        internal.colors.light
            antialiasing: true
        }
    }
}