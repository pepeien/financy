// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Rectangle {
    default property alias data: click.data

    property string backgroundColor: "transparent"
    property bool isDisabled:        false

    color: backgroundColor

    // Props
    property var onClick;
    property var onHover;
    property var onLeave;

    Behavior on color {
        ColorAnimation {
            easing.type: Easing.InOutQuad
            duration:    200
        }
    }

    Behavior on opacity {
        PropertyAnimation {
            easing.type: Easing.InOutQuad
            duration:    200
        }
    }

    MouseArea {
        id:           click
        hoverEnabled: !isDisabled

        anchors.fill: parent

        onClicked: {
            if (!onClick || isDisabled) {
                return;
            }

            onClick();
        }

        onEntered: {
            if (isDisabled) {
                return;
            }

            if (!onHover) {
                cursorShape = Qt.PointingHandCursor;

                return;
            }

            onHover(this);
        }

        onExited: {
            if (isDisabled) {
                return;
            }

            if (!onLeave) {
                cursorShape = Qt.ArrowCursor;

                return;
            }

            onLeave(this);
        }
    }
}