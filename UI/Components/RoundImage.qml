// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Item {
    property alias imageWidth: sourceItem.width
    property alias imageHeight: sourceItem.height
    property alias imageSource: sourceItem.source

    Image {
        id: sourceItem
        fillMode: Image.PreserveAspectCrop
        
        anchors.verticalCenter: parent.verticalCenter

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mask
        }
    }

    Rectangle {
        id: mask
        width: parent.width / 2
        height: width
        radius: width / 2
        visible: false
    }
}