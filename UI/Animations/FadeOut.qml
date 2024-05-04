// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

Transition {
    PropertyAnimation {
        property: "opacity"
        from: 1
        to: 0
        duration: 200
        easing.type: Easing.InOutQuad
    }
}