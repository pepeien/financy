// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Components.Page {
    readonly property var history: internal.selectedAccount.getHistory()

    id:     _root
    title: "Account Home"

    Components.FinancyHistory {
        id:     _history
        width:  parent.width * 0.95
        height: parent.height * 0.4

        anchors.horizontalCenter: parent.horizontalCenter

        history: _root.history
    }

    Components.SquircleContainer {
        width: _history.width
        height: _root.height - _history.height - 250 - 30

        backgroundColor: internal.colors.foreground
        hasShadow:       true

        anchors.top:              _history.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin:        30

        ScrollView {
            id:     _scroll
            height: parent.height
            width:  parent.width
            clip:   true

            contentWidth:  -1
            contentHeight: 100 * history.length

            ScrollBar.vertical: Components.ScrollBar {
                isVertical: true
            }

            ListView {
                model: _root.history

                delegate: Rectangle {
                    required property int index

                    readonly property var statement: _root.history[index]

                    width: _scroll.width
                    height: 100
                    color: "transparent"

                    Text {
                        text: internal.getLongMonth(statement.date)
                    }
                }
            }
        }
    }
}