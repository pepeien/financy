// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

// Types
import Financy.Types 1.0

// Components
import "qrc:/Components" as Components

Components.Page {
    property var user:          internal.selectedUser
    property var account:       user.selectedAccount
    property var purchases:     []
    property var subscriptions: []

    property int purchaseHeight:       45
    property int statementTitleHeight: 40
    property int statementHeight:      purchaseHeight + statementTitleHeight

    leftButtonIcon: "qrc:/Icons/Edit.svg" 
    leftButtonOnClick: function() {
        stack.push("qrc:/Pages/UserFinanceEdit.qml");
    }

    centerButtonIcon: "qrc:/Icons/Plus.svg" 
    centerButtonOnClick: function() {
        _popup.open();
    }

    id:    _root
    title: account.name

    function updateListing() {
        _purchases.height     = 0;
        _subscriptions.height = _root.statementTitleHeight;

        if (!_history.selectedHistory) {
            _root.purchases     = [];
            _root.subscriptions = [];
    
            return;
        }

        _root.purchases     = _history.selectedHistory.dateBasedHistory;
        _root.subscriptions = _history.selectedHistory.subscriptions;
    }

    Components.FinancyHistory {
        id:     _history
        width:  parent.width * 0.95
        height: parent.height * 0.4
        history: account.history

        anchors.horizontalCenter: parent.horizontalCenter

        onSelectedHistoryUpdate: _root.updateListing
    }

    Item {
        width:  parent.width * 0.55
        height: _root.height - _history.height - 280

        anchors.top:              _history.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin:        30

        Behavior on width {
            PropertyAnimation {
                easing.type: Easing.InOutQuad
            }
        }

        Components.SquircleContainer {
            id:     _purchasesWrapper
            width:  parent.width
            height: parent.height

            anchors.left: parent.left
            anchors.top:  parent.top

            Behavior on width {
                PropertyAnimation {
                    easing.type: Easing.InOutQuad
                }
            }

            ScrollView {
                id:     _scroll
                height: parent.height
                width:  parent.width
                clip:   true

                contentWidth:  0
                contentHeight: (_root.subscriptions.length > 0 ? (_purchases.height + _subscriptions.height) : _purchases.height) + 20

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
                                    text: _data.name + " " + account.getPaidInstallments(_data, _history.selectedHistory.date) + "/" + _data.installments
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

    Components.Popup {
        id: _popup

        Components.SquircleContainer {
            width:  parent.width * 0.6
            height: parent.height * 0.5

            hasShadow:       true
            backgroundColor: Qt.lighter(internal.colors.background, 0.965)

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter

            Components.Text {
                id:   _title
                color: internal.colors.dark
                text:  "New Purchase"

                font.pointSize: 30
                font.weight:    Font.Bold

                anchors.top:              parent.top
                anchors.topMargin:        10
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item {
                id: _firstInput

                width: parent.width * 0.8

                anchors.top:              _title.top
                anchors.topMargin:        70
                anchors.horizontalCenter: parent.horizontalCenter

                Components.Input {
                    id:    _name
                    width: (parent.width * 0.5) - 5

                    label:     "Name"
                    color:     internal.colors.dark
                    minLength: 1
                    maxLength: 50

                    anchors.left: parent.left

                    KeyNavigation.tab: _description.input
                }

                Components.Input {
                    id:    _description
                    width: _name.width

                    label:     "Description"
                    color:     internal.colors.dark
                    minLength: 0
                    maxLength: 50

                    anchors.right: parent.right

                    KeyNavigation.tab: _installments.input
                }
            }

            Item {
                id:    _secondInput
                width: _firstInput.width

                anchors.top:              _firstInput.bottom
                anchors.topMargin:        90
                anchors.horizontalCenter: parent.horizontalCenter
    
                Components.Input {
                    id:    _installments
                    width: (parent.width * 0.5) - 5

                    label:     "Installments"
                    color:     internal.colors.dark

                    anchors.left: parent.left

                    validator: IntValidator {
                        bottom: 1
                    }

                    KeyNavigation.tab: _value.input
                }

                Components.Input {
                    id:    _value
                    width: (parent.width * 0.5) - 5

                    label: "Value"
                    color: internal.colors.dark

                    anchors.right: parent.right

                    validator: IntValidator {
                        bottom: 1
                    }
                }
            }

            Item {
                id:    _thirdInput
                width: _firstInput.width

                anchors.top:              _secondInput.bottom
                anchors.topMargin:        90
                anchors.horizontalCenter: parent.horizontalCenter
    
                Components.Dropdown {
                    id:    _type
                    label: "Type"
                    model: internal.getPurchaseTypes() ?? []

                    itemWidth: (parent.width * 0.5) - 5
                    itemHeight: _value.height

                    anchors.left: parent.left
                }
            }

            Components.SquircleButton {
                width:  parent.width * 0.45
                height: 60

                backgroundColor: internal.colors.dark

                anchors.bottom:           parent.bottom
                anchors.bottomMargin:     25
                anchors.horizontalCenter: parent.horizontalCenter

                onClick: function() {
                    user.selectedAccount.createPurchase(
                        _name.text,
                        _description.text,
                        new Date(),
                        Purchase.Other,
                        _value.text,
                        _installments.text
                    );
                    user.onEdit();

                    _history.refresh();
                    _history.select(_history.selectedIndex);

                    _root.updateListing();

                    _popup.close();
                }

                Components.Text {
                    text:  "Create"
                    color: internal.colors.background

                    font.weight:    Font.Bold
                    font.pointSize: 15

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter:   parent.verticalCenter
                }
            }
        }
    }
}