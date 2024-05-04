// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

StackView {
    id: stack
    initialItem: "qrc:/Pages/Login.qml"

    anchors.fill: parent
}