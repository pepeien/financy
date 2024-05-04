// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Components.SquircleContainer {
    default property alias data: click.data

    // Props
    required property var onClick;

    // Consts
    property real normalOpacity: 1.0
    property real fadedOpacity: 0.9

    NumberAnimation on opacity {
        running: click.containsMouse
        from: normalOpacity
        to: fadedOpacity
    }

    NumberAnimation on opacity {
        running: click.containsMouse == false
        from: fadedOpacity
        to: normalOpacity
    }

    MouseArea {
        id: click
        hoverEnabled: true

        anchors.fill: parent

        onClicked: {
            if (!onClick) {
                return;
            }

            onClick();
        }

        onEntered: {
            cursorShape = Qt.PointingHandCursor;
        }

        onExited: {
            cursorShape = Qt.ArrowCursor;
        }
    }
}