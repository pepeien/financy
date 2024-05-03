// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    property bool hasShadow
    required property string backgroundColor

    Rectangle {
        id: base
        color: backgroundColor
        radius: 15

        anchors.fill: parent

        layer.enabled: hasShadow
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4

            radius: base.radius
            samples: 16
            color: colors.foreground
            source: base

            anchors.fill: base
        }
    }
}