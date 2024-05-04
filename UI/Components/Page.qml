// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

// Components
import "qrc:/Components" as Components

Rectangle {
    default property alias data: content.data

    property alias title: header.title

    color: colorScheme.background

    Components.Header {
        id: header
    }

    Rectangle {
        id: content
        color: "transparent"

        anchors.topMargin: header.height + 30
        anchors.fill: parent
    }
}