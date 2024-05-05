// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Rectangle {
    property string title

    width: parent.width
    height: 125
    color: "transparent"

    // Top Bar
    Rectangle {
        id: handler
        width: parent.width
        height: 40
        color: "transparent"

        Components.Button {
            id: closeButton
            height: 40
            width: 40
            color: "transparent"
            anchors.right: parent.right

            onClick: function() {
                Window.window.close();
            }

            onHover: function() {
                color = "#d13639";
                closeIconOverlay.color = "white";
            }

            onLeave: function() {
                color = "transparent";
                closeIconOverlay.color = colorScheme.dark;
            }

            Image {
                id: closeIcon
                source: "qrc:/Icons/Close.svg"
                width: closeButton.width * 0.35
                height: closeButton.height * 0.35

                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ColorOverlay {
                id: closeIconOverlay
                anchors.fill: closeIcon
                source: closeIcon
                color: colorScheme.dark
                antialiasing: true
            }
        }

        Components.Button {
            id: minimizeButton
            height: 40
            width: 40
            color: "transparent"
            anchors.right: closeButton.left

            onClick: function() {
                Window.window.showMinimized();
            }

            onHover: function () {
                color = "#17525252";
            }

            onLeave: function () {
                color = "transparent";
            }

            Image {
                id: minimizeIcon
                source: "qrc:/Icons/Minimize.svg"
                width: minimizeButton.width * 0.35
                height: minimizeButton.height * 0.35

                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height * 0.25
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ColorOverlay {
                anchors.fill: minimizeIcon
                source: minimizeIcon
                color: colorScheme.dark
                antialiasing: true
            }
        }
    }

    Rectangle {
        width: parent.width

        anchors.top: handler.bottom

        Components.SquircleButton {
            id: backButton
            width: 60
            height: 60
            visible: stack.depth > 1

            // Props
            hasShadow: true
            backgroundColor: colorScheme.background

            anchors.left: parent.left
            anchors.leftMargin: 20

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

        // Title
        Text {
            id: titleText
            text: title
            color: colorScheme.dark

            font.family: "Inter"
            font.pointSize: 40
            font.weight: Font.DemiBold

            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}