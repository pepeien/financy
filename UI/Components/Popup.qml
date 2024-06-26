// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Popup {
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from:     0.0
            to:       1.0
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from:     1.0
            to:       0.0
        }
    }
}