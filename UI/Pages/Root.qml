// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Item {
    anchors.fill: parent

    Rectangle {
        id: mask
        radius: 4
        anchors.fill: parent
    }

    Item {
        anchors.fill: mask
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mask
        }

        StackView {
            id: stack
            initialItem: "qrc:/Pages/Login.qml"
            anchors.fill: parent
        }
    }
}