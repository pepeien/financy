// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Types
import Financy.Types 1.0

// Components
import "qrc:/Components" as Components

Components.SquircleContainer {
    property var purchases:     []
    property var subscriptions: []

    property int purchaseHeight:       45
    property int statementTitleHeight: 40
    property int statementHeight:      purchaseHeight + statementTitleHeight

    Behavior on width {
        PropertyAnimation {
            easing.type: Easing.InOutQuad
        }
    }

    property var onEdit
    property var onDelete

    ScrollView {
        id:     _scroll
        height: parent.height
        width:  parent.width
        clip:   true

        contentWidth:  0
        contentHeight: (subscriptions.length > 0 ? _subscriptions.height : 0) + _purchases.height + 20

        ScrollBar.vertical: Components.ScrollBar {
            isVertical: true
        }

        Repeater {
            id:     _purchases
            model:  purchases
            width:  parent.width

            delegate: Components.SquircleContainer {
                required property int index

                property var _data:    purchases[index]
                property var _sibling: _purchases.itemAt(index - 1)

                id:    _statement
                width: _scroll.width * 0.96
                height: _purchaseHeader.height + _purchaseContent.height

                backgroundColor: Qt.lighter(internal.colors.foreground, 1.1)

                anchors.top:       _sibling ? _sibling.bottom : parent.top
                anchors.topMargin: 20

                Component.onCompleted: function() {
                    _purchases.height += height + 20;
                }

                Components.SquircleContainer {
                    id:     _purchaseHeader
                    width:  parent.width
                    height: statementTitleHeight

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

                    delegate: Components.FinancePurchaseItem {
                        required property int index

                        property var _sibling: _purchaseContent.itemAt(index - 1)

                        purchase: _data.purchases[index]

                        width:  _purchaseContent.width
                        height: purchase.hasDescription() ? purchaseHeight + 20 :  purchaseHeight

                        anchors.top: _sibling ? _sibling.bottom : _purchaseContent.top

                        Component.onCompleted: function() {
                            _purchaseContent.height += height;
                        }

                        onPurchaseEdit: function() {
                            if (!onEdit) {
                                return;
                            }

                            onEdit(purchase);
                        }

                        onPurchaseDelete: function() {
                            if (!onDelete) {
                                return;
                            }

                            onDelete(purchase);
                        }
                    }
                }
            }
        }

        Components.SquircleContainer {
            id:      _subscriptions
            width:   _scroll.width * 0.96
            height:  statementTitleHeight
            visible: subscriptions.length > 0

            backgroundColor: Qt.lighter(internal.colors.foreground, 1.1)

            anchors.top:       _purchases.bottom    
            anchors.topMargin: 20

            Components.SquircleContainer {
                id:     _subscriptionsHeader
                width:  parent.width
                height: statementTitleHeight

                backgroundColor:             internal.colors.dark
                backgroundBottomLeftRadius:  0
                backgroundBottomRightRadius: 0

                anchors.top: parent.top

                Text {
                    id:    _headerTitle
                    text:  "Recurring"
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
                    text:  internal.getDueAmount(subscriptions).toFixed(2)
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
                model:  subscriptions
                width:  parent.width
                height: 0

                anchors.top: _subscriptionsHeader.bottom

                delegate: Components.FinancePurchaseItem  {
                    required property int index

                    property var _sibling: _subscriptionsContent.itemAt(index - 1)

                    purchase: subscriptions[index]

                    width:  _subscriptionsContent.width
                    height: purchase.hasDescription() ?  purchaseHeight + 20 :  purchaseHeight

                    anchors.top: _sibling ? _sibling.bottom : _subscriptionsContent.top

                    Component.onCompleted: function() {
                        _subscriptionsContent.height += height;
                        _subscriptions.height        += height;
                    }

                    onPurchaseEdit: function() {
                        if (!onEdit) {
                            return;
                        }

                        onEdit(purchase);
                    }

                    onPurchaseDelete: function() {
                        if (!onDelete) {
                            return;
                        }

                        onDelete(purchase);
                    }
                }
            }
        }
    }
}