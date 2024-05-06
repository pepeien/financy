// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Rectangle {
    default property alias data: click.data
    property string backgroundColor: "transparent"

    color: backgroundColor

    // Props
    property var onClick;
    property var onHover;
    property var onLeave;

    // Consts
    property real normalOpacity: 1.0
    property real fadedOpacity: 0.7

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

            if (!onHover) {
                return;
            }

            onHover();
        }

        onExited: {
            cursorShape = Qt.ArrowCursor;

            if (!onLeave) {
                return;
            }

            onLeave();
        }
    }
}