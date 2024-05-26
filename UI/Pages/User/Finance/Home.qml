// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Components.Page {
    readonly property var history: internal.selectedAccount.getHistory()

    property var purchases:     []
    property var subscriptions: []

    property int purchaseHeight:       45
    property int statementTitleHeight: 40
    property int statementHeight:      purchaseHeight + statementTitleHeight

    id:    _root
    title: "Account Home"

    function updateListing() {
        _purchases.height     = 0;
        _subscriptions.height = _root.statementTitleHeight;

        if (!_history.selectedHistory) {
            _root.purchases     = [];
            _root.subscriptions = [];
    
            return;
        }

        _root.purchases     = _history.selectedHistory.getDateBasedHistory();
        _root.subscriptions = _history.selectedHistory.subscriptions;
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
            contentHeight: (_root.subscriptions.length > 0 ? (_purchases.height + _subscriptions.height) : _purchases.height)  + 20

            ScrollBar.vertical: Components.ScrollBar {
                isVertical: true
            }

            Repeater {
                id:     _purchases
                model:  _root.purchases
                width:  parent.width
                height: 0

                delegate: Components.SquircleContainer {
                    required property int index

                    property var _data:    _purchases.model[index]
                    property var _sibling: _purchases.itemAt(index - 1)

                    id:    _statement
                    width: _scroll.width * 0.96
                    height: _purchaseHeader.height + _purchaseContent.height

                    backgroundColor: Qt.lighter(internal.colors.background, 0.965)

                    anchors.top:       _sibling ? _sibling.bottom : parent.top
                    anchors.topMargin: 20

                    Component.onCompleted: function() {
                        _purchases.height += height + 20;
                    }

                    Components.SquircleContainer {
                        id:     _purchaseHeader
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
                            anchors.leftMargin:     20
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:  internal.getLongDate(_data.date)
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
                            anchors.rightMargin:    _headerDateTitle.anchors.leftMargin
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Repeater {
                        id:     _purchaseContent
                        model:  _data.purchases
                        width:  parent.width
                        height: 0

                        anchors.top: _purchaseHeader.bottom

                        delegate: Item {
                            required property int index

                            property var _data:    _purchaseContent.model[index]
                            property var _sibling: _purchaseContent.itemAt(index - 1)

                            width:  _purchaseContent.width
                            height: _data.hasDescription() ?  _root.purchaseHeight + _description.height :  _root.purchaseHeight

                            anchors.top: _sibling ? _sibling.bottom : _purchaseContent.top

                            Component.onCompleted: function() {
                                _purchaseContent.height += height;
                            }

                            Rectangle {
                                color:   internal.colors.foreground
                                width:   parent.width
                                height:  1
                                visible: index > 0

                                anchors.top: parent.top
                            }

                            Text {
                                id:   _purchaseName
                                text: _data.name + " " + internal.selectedAccount.getPaidInstallments(_data, _history.selectedHistory.date) + "/" + _data.installments
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

            Components.SquircleContainer {
                id:      _subscriptions
                width:   _scroll.width * 0.96
                height: 0
                visible: _root.subscriptions.length > 0

                backgroundColor: Qt.lighter(internal.colors.background, 0.965)

                anchors.top:       _purchases.bottom    
                anchors.topMargin: 20

                Components.SquircleContainer {
                    id:     _subscriptionsHeader
                    width:  parent.width
                    height: _root.statementTitleHeight

                    backgroundColor:             internal.colors.dark
                    backgroundBottomLeftRadius:  0
                    backgroundBottomRightRadius: 0

                    anchors.top: parent.top

                    Text {
                        id:    _headerTitle
                        text:  "Subscriptions"
                        color: internal.colors.background

                        font.family:    "Inter"
                        font.pointSize: 9
                        font.weight:    Font.Bold

                        anchors.left:          parent.left
                        anchors.leftMargin:    15
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
                        text:  internal.getDueAmount(_root.subscriptions).toFixed(2)
                        color: internal.colors.background

                        font.family:    "Inter"
                        font.pointSize: 9
                        font.weight:    Font.Normal

                        anchors.right:          parent.right
                        anchors.rightMargin:    _headerTitle.anchors.leftMargin
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Repeater {
                    id:     _subscriptionsContent
                    model:  _root.subscriptions
                    width:  parent.width
                    height: 0

                    anchors.top: _subscriptionsHeader.bottom

                    delegate: Item {
                        required property int index

                        property var _data:    _subscriptionsContent.model[index]
                        property var _sibling: _subscriptionsContent.itemAt(index - 1)

                        width:  _subscriptionsContent.width
                        height: _data.hasDescription() ?  _root.purchaseHeight + _description.height :  _root.purchaseHeight

                        anchors.top: _sibling ? _sibling.bottom : _subscriptionsContent.top

                        Component.onCompleted: function() {
                            _subscriptionsContent.height += height;
                            _subscriptions.height        += height;
                        }

                        Rectangle {
                            color:   internal.colors.foreground
                            width:   parent.width
                            height:  1
                            visible: index > 0

                            anchors.top: parent.top
                        }

                        Text {
                            id:   _subscriptionName
                            text: _data.name
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
                            color: _subscriptionName.color

                            font: _subscriptionName.font

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

                            anchors.top:        _subscriptionName.bottom
                            anchors.left:       parent.left
                            anchors.topMargin:  7
                            anchors.leftMargin: _subscriptionName.anchors.leftMargin * 1.5

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