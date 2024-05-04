// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    property bool hasShadow: false
    property string backgroundColor: "transparent"

    Rectangle {
        id: base
        color: backgroundColor
        radius: 15

        anchors.fill: parent

        layer.enabled: hasShadow
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4

            source: base
            radius: 4
            samples: 16
            color: Qt.rgba(0, 0, 0, 0.25)
            spread: 0

            anchors.fill: base
        }
    }
}