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

    Item {
        width:  _history.width
        height: _root.height - _history.height - 250 - 30

        anchors.top:              _history.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin:        30

        Components.SquircleContainer {
            id:     _purchases
            width:  parent.width * 0.50 - 30
            height: parent.height

            ScrollView {
                id:     _scroll
                height: parent.height
                width:  parent.width
                clip:   true

                contentWidth: -1

                ScrollBar.vertical: Components.ScrollBar {
                    isVertical: true
                }

                ListView {
                    id: list
                    model:   _history.selectedHistory.purchases
                    spacing: 10

                    delegate: Components.SquircleContainer {
                        required property int index
                        readonly property var purchase: _history.selectedHistory.purchases[index]

                        width: _scroll.width - 100
                        height: 100

                        backgroundColor: Qt.lighter(internal.colors.background, 0.965)

                        Text {
                            text: purchase.date + purchase.name
                        }
                    }
                }
            }
        }

        Components.SquircleContainer {
            width:  _purchases.width
            height: _purchases.height

            backgroundColor: internal.colors.background
            hasShadow:       true

            anchors.left:       _purchases.right
            anchors.leftMargin: 30
        }
    }
}