// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

Text {
    font.family: "Inter"

    Behavior on color {
        ColorAnimation {
            easing.type: Easing.InOutQuad
            duration:    200
        }
    }
}