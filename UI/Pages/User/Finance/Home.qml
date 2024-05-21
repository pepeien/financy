// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

// Components
import "qrc:/Components" as Components

Components.Page {
    title: "Account Home"

    Components.FinancyHistory {
        width:  parent.width * 0.95
        height: parent.height * 0.5

        anchors.horizontalCenter: parent.horizontalCenter

        account: internal.selectedAccount
    }
}