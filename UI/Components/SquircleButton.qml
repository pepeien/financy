// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Components.Button {
    default property alias data: _content.data

    // Container Props
    property alias backgroundBorder: _content.backgroundBorder

    property bool hasShadow:       false
    property var backgroundColor:  "transparent"

    id: _root

    Components.SquircleContainer {
        id: _content
        
        hasShadow:              isDisabled ? false : _root.hasShadow
        backgroundColor:        isDisabled ? "transparent" : _root.backgroundColor
        backgroundBorder.width: isDisabled ? 2.5 :  0
        backgroundBorder.color: isDisabled ? internal.colors.foreground : "transparent"

        anchors.fill: parent
    }
}