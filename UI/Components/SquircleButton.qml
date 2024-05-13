// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Components.Button {
    default property alias data: content.data

    // Container Props
    property alias hasShadow:       content.hasShadow
    property alias backgroundColor: content.backgroundColor

    Components.SquircleContainer {
        id: content

        anchors.fill: parent
    }
}