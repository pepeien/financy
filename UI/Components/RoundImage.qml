// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Item {
    property alias imageSource: _image.source
    property alias imageWidth:  _image.sourceSize.width
    property alias imageHeight: _image.sourceSize.height

    width:  _image.sourceSize.width
    height: _image.sourceSize.height

    Image {
        id:           _image
        width:        imageWidth
        height:       imageHeight
        fillMode:     Image.PreserveAspectCrop
        antialiasing: true

        anchors.verticalCenter: parent.verticalCenter

        layer.enabled: true
        layer.effect:  OpacityMask {
            maskSource: Rectangle {
                width:   _image.sourceSize.width
                height:  _image.sourceSize.height
                radius:  _image.sourceSize.width / 2
                visible: false
            }
        }
    }
}