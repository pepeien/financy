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
        _name.clear();
        _description.clear();
        _date.clear();
        _value.clear();
        _installments.clear();

        _popup.open();
    }

    id:    _root
    title: account.name

    function updateListing() {
        _purchases.height = 0;

        if (!_history.selectedHistory) {
            _root.purchases     = [];
            _root.subscriptions = [];
    
            return;
        }

        _root.purchases     = _history.selectedHistory.dateBasedHistory;
        _root.subscriptions = _history.selectedHistory.subscriptions;
    }

    Components.FinancyHistory {
        id:      _history
        width:   parent.width * 0.95
        height:  parent.height * 0.4
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
                contentHeight: (_root.subscriptions.length > 0 ? _subscriptions.height : 0) + _purchases.height + 20

                ScrollBar.vertical: Components.ScrollBar {
                    isVertical: true
                }

                Repeater {
                    id:     _purchases
                    model:  _root.purchases
                    width:  parent.width

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

                                property bool hasDescription: _data.hasDescription()

                                width:  _purchaseContent.width
                                height: hasDescription ?  _root.purchaseHeight + _description.height :  _root.purchaseHeight

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

                                    anchors.top:            hasDescription ? parent.top : undefined
                                    anchors.left:           parent.left
                                    anchors.leftMargin:     20
                                    anchors.topMargin:      hasDescription ? 10 : 0
                                    anchors.verticalCenter: hasDescription ? undefined : parent.verticalCenter
                                }

                                Text {
                                    text:  _data.getInstallmentValue().toFixed(2)
                                    color: _purchaseName.color

                                    font: _purchaseName.font

                                    anchors.top:            hasDescription ? parent.top : undefined
                                    anchors.right:          parent.right
                                    anchors.rightMargin:     20
                                    anchors.topMargin:      hasDescription ? 10 : 0
                                    anchors.verticalCenter: hasDescription ? undefined : parent.verticalCenter
                                }

                                Components.SquircleContainer {
                                    id:     _description
                                    height: _text.paintedHeight + 2
                                    width:  _text.paintedWidth + 10
                                    visible: hasDescription

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
                    height:  _root.statementTitleHeight
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

                            property bool hasDescription: _data.hasDescription()

                            width:  _subscriptionsContent.width
                            height: hasDescription ? _root.purchaseHeight + _description.height :  _root.purchaseHeight

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

                                anchors.top:            hasDescription ? parent.top : undefined
                                anchors.left:           parent.left
                                anchors.leftMargin:     20
                                anchors.topMargin:      hasDescription ? 10 : 0
                                anchors.verticalCenter: hasDescription ? undefined : parent.verticalCenter
                            }

                            Text {
                                text:  _data.getInstallmentValue().toFixed(2)
                                color: _subscriptionName.color

                                font: _subscriptionName.font

                                anchors.top:            hasDescription ? parent.top : undefined
                                anchors.right:          parent.right
                                anchors.rightMargin:     20
                                anchors.topMargin:      hasDescription ? 10 : 0
                                anchors.verticalCenter: hasDescription ? undefined : parent.verticalCenter
                            }

                            Components.SquircleContainer {
                                id:     _description
                                height: _text.paintedHeight + 2
                                width:  _text.paintedWidth + 10
                                visible: hasDescription

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
                height: _name.height

                anchors.top:              _title.bottom
                anchors.topMargin:        10
                anchors.horizontalCenter: parent.horizontalCenter

                Components.Input {
                    id:    _name
                    width: (parent.width * 0.5) - 5

                    label:       "Name"
                    color:       internal.colors.dark
                    minLength:   1
                    maxLength:   50
                    inputHeight: 60

                    anchors.left: parent.left

                    KeyNavigation.tab: _description.input
                }

                Components.Input {
                    id:     _description
                    width:  _name.width

                    label:      "Description"
                    color:      internal.colors.dark
                    minLength:  0
                    maxLength:  50
                    inputHeight: _name.inputHeight

                    anchors.right: parent.right

                    KeyNavigation.tab: _installments.input
                }
            }

            Item {
                id:     _secondInput
                width:  _firstInput.width
                height: _installments.height

                anchors.top:              _firstInput.bottom
                anchors.topMargin:        10
                anchors.horizontalCenter: parent.horizontalCenter
    
                Components.Input {
                    id:    _installments
                    width: (parent.width * 0.5) - 5

                    label:       "Installments"
                    color:       internal.colors.dark
                    inputHeight: _name.inputHeight

                    anchors.left: parent.left

                    validator: IntValidator {
                        bottom: 1
                        top: 999
                    }

                    KeyNavigation.tab: _value.input
                }

                Components.Input {
                    id:     _value
                    width:  _installments.width

                    label:       "Value"
                    color:       internal.colors.dark
                    inputHeight: _name.inputHeight

                    anchors.right: parent.right

                    validator: DoubleValidator {
                        bottom: 0.1
                    }
                }
            }

            Item {
                id:     _thirdInput
                width:  _firstInput.width
                height: _date.height

                anchors.top:              _secondInput.bottom
                anchors.topMargin:        10
                anchors.horizontalCenter: parent.horizontalCenter

                Components.Input {
                    id:    _date
                    width: (parent.width * 0.5) - 5

                    label:       "Date"
                    hint:        "dd/mm/yyyy"
                    color:       internal.colors.dark
                    inputHeight: _name.inputHeight
                    minLength:   "00/00/0000".length

                    anchors.left: parent.left

                    validator: RegularExpressionValidator {
                        regularExpression: /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{4})$/
                    }
                }

                Components.Dropdown {
                    id:    _type
                    label: "Type"
                    model: internal.getPurchaseTypes() ?? []

                    itemWidth: (parent.width * 0.5) - 5
                    itemHeight: _value.inputHeight

                    anchors.right: parent.right
                }
            }

            Components.SquircleButton {
                id:     _submitButton
                width:  parent.width * 0.45
                height: 60

                isDisabled: _name.hasError || _description.hasError || _date.hasError || _value.hasError || _installments.hasError

                anchors.bottom:           parent.bottom
                anchors.bottomMargin:     25
                anchors.horizontalCenter: parent.horizontalCenter

                onClick: function() {
                    if (_submitButton.isDisabled) {
                        return;
                    }

                    user.selectedAccount.createPurchase(
                        _name.text,
                        _description.text,
                        _date.text,
                        _type.value,
                        _value.text,
                        _installments.text
                    );
                    user.onEdit();

                    _history.refresh();

                    _root.updateListing();

                    _popup.close();
                }

                Components.Text {
                    text:  "Create"
                    color: _submitButton.isDisabled ? internal.colors.foreground : internal.colors.background

                    font.weight:    Font.Bold
                    font.pointSize: 15

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter:   parent.verticalCenter
                }
            }
        }
    }
}