// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Dialogs

// Components
import "qrc:/Components" as Components

Item {
    property alias selectedColor: _dialog.selectedColor
    property alias label:         _label.text

    Text {
        id:    _label
        color: internals.colors.dark

        font.family:    "Inter"           
        font.pointSize: 10
        font.weight:    Font.DemiBold

        anchors.top:              parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Components.SquircleButton {
        id:              _button
        width:           parent.width
        height:          parent.height * 0.9
        backgroundColor: _dialog.selectedColor

        anchors.top:       _label.bottom
        anchors.topMargin: _label.text == "" ? 0 : 15

        onClick: function() {
            _dialog.open();
        }

        ColorDialog {
            id: _dialog
        }
    }
}