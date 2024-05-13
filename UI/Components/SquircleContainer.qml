// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Rectangle {
    default property alias data: content.data

    property bool hasShadow:         false
    property string backgroundColor: "transparent"

    color: "transparent"

    Rectangle {
        id:     base
        color:  backgroundColor
        radius: 15

        anchors.fill: parent
    }

    Item {
        id: content
        z: 1

        anchors.left: base.left
        anchors.fill: base
    }

    MultiEffect {
        source: base

        anchors.fill: base

        shadowEnabled:          hasShadow
        shadowHorizontalOffset: 0
        shadowVerticalOffset:   4
        shadowBlur:             0.25
        shadowColor:            Qt.rgba(0, 0, 0, 0.25)
        shadowScale:            1
    }
}