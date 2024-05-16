// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import Qt.labs.platform

// Components
import "qrc:/Components" as Components

Item {
    // Props In
    property var color:   "white"
    property alias label: _label.text

    // Props Out
    property alias picker: _dialog

    id: _root

    Components.Text {
        id:    _label
        color: internal.colors.dark
        
        font.pointSize: 10
        font.weight:    Font.DemiBold

        anchors.top:              parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Components.SquircleButton {
        id:              _button
        width:           parent.width
        height:          parent.height * 0.9
        backgroundColor: _dialog.currentColor

        anchors.top:       _label.bottom
        anchors.topMargin: _label.text == "" ? 0 : 15

        onClick: function() {
            _dialog.open();
        }

        ColorDialog {
            id: _dialog

            color:        _root.color
            currentColor: _root.color
        }
    }
}