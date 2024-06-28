// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Components.Modal {
    property var purchase

    property var onSubmit

    id: _root

    Components.SquircleContainer {
        width:  670
        height: 180

        hasShadow:       true
        backgroundColor: Qt.lighter(internal.colors.background, 0.965)

        Components.Text {
            id:    _title
            color: internal.colors.dark
            text:  "You're about to delete " + (purchase?.name ?? "")

            font.pointSize: 15
            font.weight:    Font.Bold

            anchors.top:              parent.top
            anchors.topMargin:        10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Components.Text {
            id:    _disclaimer
            color: internal.colors.light
            text:  "This action cannot be reversed"

            font.pointSize: 12
            font.weight:    Font.Normal

            anchors.top:              _title.bottom
            anchors.topMargin:        15
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Components.SquircleButton {
            id:     _submitButton
            width:  parent.width * 0.45
            height: 60

            backgroundColor: internal.colors.dark

            anchors.bottom:           parent.bottom
            anchors.bottomMargin:     25
            anchors.horizontalCenter: parent.horizontalCenter

            onClick: function() {
                _root.close();

                if (!_root.onSubmit) {
                    return;
                }

                _root.onSubmit();
            }

            Components.Text {
                text:  "Delete"
                color: internal.colors.background

                font.weight:    Font.Bold
                font.pointSize: 15

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter:   parent.verticalCenter
            }
        }
    }
}
