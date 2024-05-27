// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Rectangle {
    default property alias data: content.data

    property bool hasShadow:         false
    property string backgroundColor: "transparent"
    property real backgroundRadius:  Math.min((height * 0.25), 9)

    property real backgroundTopLeftRadius:     backgroundRadius
    property real backgroundTopRightRadius:    backgroundRadius
    property real backgroundBottomLeftRadius:  backgroundRadius
    property real backgroundBottomRightRadius: backgroundRadius

    color: "transparent"

    Rectangle {
        id:     base
        color:  backgroundColor

        topLeftRadius:     backgroundTopLeftRadius
        topRightRadius:    backgroundTopRightRadius
        bottomLeftRadius:  backgroundBottomLeftRadius
        bottomRightRadius: backgroundBottomRightRadius

        anchors.fill: parent

        Behavior on color {
            ColorAnimation {
                easing.type: Easing.InOutQuad
                duration:    200
            }
        }
    }

    Item {
        id: content
        z: 1
        clip: true

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