// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Components.Page {
    readonly property var history: internal.selectedAccount.getHistory()

    property var statements: []

    property int purchaseHeight:       45
    property int statementTitleHeight: 40
    property int statementHeight:      purchaseHeight + statementTitleHeight

    id:    _root
    title: "Account Home"

    function updateListing() {
        if (!_history.selectedHistory) {
            _root.statements = [];

            return;
        }
        _wrapper.height  = 0;

        const selectedHistory = _history.selectedHistory;
        const statements      = [];

        _history.selectedHistory.purchases.forEach((purchase) => {
            let foundIndex = statements.findIndex((statement) => {
                const isSameDay   = statement.date.getUTCDate() === purchase.date.getUTCDate();
                const isSameMonth = statement.date.getUTCMonth() === purchase.date.getUTCMonth();
                const isSameYear  = statement.date.getFullYear() === purchase.date.getFullYear();

                return isSameDay && isSameMonth && isSameYear;
            });

            if (foundIndex < 0) {
                statements.push({
                    date: purchase.date,
                    purchases: [],
                    dueAmount: 0
                });

                foundIndex = statements.length - 1;
            }

            statements[foundIndex].purchases.push(purchase);
            statements[foundIndex].dueAmount += purchase.getInstallmentValue();
        });

        _root.statements = statements;
    }

    Components.FinancyHistory {
        id:     _history
        width:  parent.width * 0.95
        height: parent.height * 0.4

        anchors.horizontalCenter: parent.horizontalCenter

        history: _root.history

        onSelectedHistoryUpdate: _root.updateListing
    }

    Components.SquircleContainer {
        id:     _purchases
        width:  parent.width * 0.55
        height: _root.height - _history.height - 280

        anchors.top:              _history.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin:        30

        ScrollView {
            id:     _scroll
            height: parent.height
            width:  parent.width
            clip:   true

            contentWidth:  0
            contentHeight: _wrapper.height

            ScrollBar.vertical: Components.ScrollBar {
                isVertical: true
            }

            Repeater {
                id:     _wrapper
                model:  _root.statements
                width:  parent.width
                height: 0

                delegate: Components.SquircleContainer {
                    required property int index

                    property var _data:    _root.statements[index]
                    property var _sibling: _wrapper.itemAt(index - 1)

                    id:    _statement
                    width: _scroll.width * 0.96
                    height: _header.height + _content.height

                    backgroundColor: Qt.lighter(internal.colors.background, 0.965)

                    anchors.top:       _sibling ? _sibling.bottom : parent.top
                    anchors.topMargin: 20

                    Component.onCompleted: function() {
                        _wrapper.height += height + 20;
                    }

                    Components.SquircleContainer {
                        id:     _header
                        width:  parent.width
                        height: _root.statementTitleHeight

                        backgroundColor:             internal.colors.dark
                        backgroundBottomLeftRadius:  0
                        backgroundBottomRightRadius: 0

                        anchors.top: parent.top

                        Text {
                            id:    _headerDateTitle
                            text:  "Date"
                            color: internal.colors.background

                            font.family:    "Inter"
                            font.pointSize: 9
                            font.weight:    Font.Bold

                            anchors.left:           parent.left
                            anchors.leftMargin:     10
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:  _data.date.getUTCDate() + "/" + _data.date.getUTCMonth() + "/" + _data.date.getFullYear()
                            color: internal.colors.background

                            font.family:    "Inter"
                            font.pointSize: 9
                            font.weight:    Font.Normal

                            anchors.left:           _headerDateTitle.right
                            anchors.leftMargin:     5
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id:    _headerTotalTitle
                            text:  "Total"
                            color: internal.colors.background

                            font.family:    "Inter"
                            font.pointSize: 9
                            font.weight:    Font.Bold

                            anchors.right:          _headerValueTitle.left
                            anchors.rightMargin:    5
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id:    _headerValueTitle
                            text:  _data.dueAmount.toFixed(2)
                            color: internal.colors.background

                            font.family:    "Inter"
                            font.pointSize: 9
                            font.weight:    Font.Normal

                            anchors.right:          parent.right
                            anchors.rightMargin:    10
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Repeater {
                        id:     _content
                        model:  _data.purchases
                        width:  parent.width
                        height: 0

                        anchors.top: _header.bottom

                        delegate: Item {
                            required property int index

                            property var _data:    _content.model[index]
                            property var _sibling: _content.itemAt(index - 1)

                            width:  _content.width
                            height: _data.hasDescription() ?  _root.purchaseHeight + _description.height :  _root.purchaseHeight

                            anchors.top: _sibling ? _sibling.bottom : _content.top

                            Component.onCompleted: function() {
                                _content.height += height;
                            }

                            Rectangle {
                                color:   internal.colors.dark
                                width:   parent.width
                                height:  1
                                visible: index > 0

                                anchors.top: parent.top
                            }

                            Text {
                                id:   _purchaseName
                                text: _data.name + " " + (internal.selectedAccount.getPaidInstallments(_data, _history.selectedHistory.date) + 1) + "/" + _data.installments
                                color: internal.colors.dark

                                font.family:    "Inter"
                                font.pointSize: 9
                                font.weight:    Font.Normal

                                anchors.top:            _data.hasDescription() ? parent.top : undefined
                                anchors.left:           parent.left
                                anchors.leftMargin:     20
                                anchors.topMargin:      _data.hasDescription() ? 10 : 0
                                anchors.verticalCenter: _data.hasDescription() ? undefined : parent.verticalCenter
                            }

                            Text {
                                text:  _data.getInstallmentValue().toFixed(2)
                                color: _purchaseName.color

                                font: _purchaseName.font

                                anchors.top:            _data.hasDescription() ? parent.top : undefined
                                anchors.right:          parent.right
                                anchors.rightMargin:     20
                                anchors.topMargin:      _data.hasDescription() ? 10 : 0
                                anchors.verticalCenter: _data.hasDescription() ? undefined : parent.verticalCenter
                            }

                            Components.SquircleContainer {
                                id:     _description
                                height: _text.paintedHeight + 2
                                width:  _text.paintedWidth + 10
                                visible: _data.hasDescription()

                                backgroundColor: Qt.lighter(internal.colors.dark, 2)

                                anchors.top:        _purchaseName.bottom
                                anchors.left:       parent.left
                                anchors.topMargin:  7
                                anchors.leftMargin: _purchaseName.anchors.leftMargin * 1.5

                                Text {
                                    id:    _text
                                    text:  _data.description
                                    color: internal.colors.background

                                    font.family:    "Inter"
                                    font.pointSize: 8
                                    font.weight:    Font.Bold

                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}