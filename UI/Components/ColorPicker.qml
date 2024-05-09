// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Dialogs

// Components
import "qrc:/Components" as Components

Components.SquircleButton {
    property alias selectedColor: _dialog.selectedColor

    backgroundColor: _dialog.selectedColor

    onClick: function() {
        _dialog.open();
    }

    ColorDialog {
        id: _dialog
    }
}