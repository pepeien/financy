// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Rectangle {
    property string title

    height: 80
    width: parent.width
    color: "transparent"

    Components.Button {
        id: backButton
        width: parent.height * 0.8
        height: parent.height * 0.8
        visible: stack.depth > 1

        // Props
        hasShadow: true
        backgroundColor: colorScheme.background

        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter

        onClick: function() {
            if (stack.depth === 1) {
                return;
            }

            stack.pop();
        }

        Image {
            id: icon
            source: "qrc:/Icons/Back.svg"
            width: parent.width * 0.35
            height: parent.height * 0.35

            antialiasing: true
            visible: false

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColorOverlay {
            anchors.fill: icon
            source: icon
            color: colorScheme.light
            antialiasing: true
        }
    }

    Text {
        text: title
        color: colorScheme.dark

        font.family: "Inter"
        font.pointSize: 40
        font.weight: Font.DemiBold

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
}