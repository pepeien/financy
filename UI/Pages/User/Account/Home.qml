// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

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
        stack.push("qrc:/Pages/UserAccountEdit.qml");
    }

    centerButtonIcon: "qrc:/Icons/Plus.svg" 
    centerButtonOnClick: function() {
        _purchaseCreation.open();
    }

    id:    _root
    title: account.name

    Component.onCompleted: function() {
        _history.refresh(_root.account.history);
    }

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

    function deletePurchase(id) {
        _purchases.model = [];

        _history.refresh([]);

        _root.account.deletePurchase(id);
        _root.account.onEdit();
        _root.user.onEdit();

        _history.refresh(_root.account.history);

        _root.updateListing();

        _purchases.model = _root.purchases;
    }

    Components.FinanceHistory {
        id:      _history
        width:   parent.width * 0.95
        height:  parent.height * 0.4

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

                        backgroundColor: Qt.lighter(internal.colors.foreground, 1.1)

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

                                Text {
                                    text:  _data.getInstallmentValue().toFixed(2)
                                    color: _purchaseName.color

                                    font: _purchaseName.font

                                    anchors.right:          _actions.left
                                    anchors.rightMargin:    20
                                    anchors.verticalCenter:  parent.verticalCenter
                                }

                                Item {
                                    id: _actions
                                    height: parent.height

                                    anchors.top:            hasDescription ? parent.top : undefined
                                    anchors.right:          parent.right
                                    anchors.rightMargin:    20

                                    Components.Button {
                                        id:     _actionButton
                                        height: 25
                                        width:  25

                                        anchors.verticalCenter:   parent.verticalCenter
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        onClick: function() {
                                            if (popup.isClosed == false) {
                                                return;
                                            }

                                            popup.open();
                                        }

                                        Image {
                                            id:                _leftButtonIcon
                                            source:            "qrc:/Icons/More.svg"
                                            sourceSize.width:  parent.height
                                            sourceSize.height: parent.height
                                            antialiasing:      true
                                            visible:           false

                                            anchors.verticalCenter:   parent.verticalCenter
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        ColorOverlay {
                                            anchors.fill: _leftButtonIcon
                                            source:       _leftButtonIcon
                                            color:        internal.colors.dark
                                            antialiasing: true
                                        }

                                        Popup {
                                            property bool isClosed: true
     
                                            id:          popup
                                            width:       100
                                            height:      80
                                            focus:       true
                                            closePolicy: Popup.CloseOnPressOutsideParent
                                            padding:     0

                                            x: _actionButton.x + 20
                                            y: _actionButton.y + 10

                                            background: Components.SquircleContainer {
                                                hasShadow:       true
                                                backgroundColor: internal.colors.background
                                            }

                                            Timer {
                                                id: timer
                                            }

                                            function setTimeout(cb, delayTime) {
                                                timer.interval = delayTime;
                                                timer.repeat = false;
                                                timer.triggered.connect(cb);
                                                timer.start();
                                            }

                                            onOpened: function() {
                                                popup.isClosed = false;
                                            }

                                            onClosed: function() {
                                                setTimeout(() => {
                                                    popup.isClosed = true;
                                                }, 200);
                                            }

                                            Item {
                                                anchors.fill: parent

                                                Components.Button {
                                                    id:     _editButton
                                                    width:  parent.width
                                                    height: 40

                                                    anchors.top: parent.top

                                                    topLeftRadius:  popup.background.backgroundRadius
                                                    topRightRadius: popup.background.backgroundRadius

                                                    onClick: function() {
                                                        _purchaseEdition.purchase = _data;

                                                        _purchaseEdition.open();
                                                    }

                                                    onHover: function() {
                                                        _editButton.color         = internal.colors.dark;
                                                        _editButtonIconFill.color = internal.colors.background;
                                                        _editButtonText.color     = internal.colors.background;
                                                    }

                                                    onLeave: function() {
                                                        _editButton.color         = internal.colors.background;
                                                        _editButtonIconFill.color = internal.colors.dark;
                                                        _editButtonText.color     = internal.colors.dark;
                                                    }

                                                    Image {
                                                        id:                _editButtonIcon
                                                        source:            "qrc:/Icons/Edit.svg"
                                                        sourceSize.width:  parent.height * 0.35
                                                        sourceSize.height: parent.height * 0.35
                                                        antialiasing:      true
                                                        visible:           false

                                                        anchors.left:           parent.left
                                                        anchors.leftMargin:     15
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }

                                                    ColorOverlay {
                                                        id:           _editButtonIconFill
                                                        anchors.fill: _editButtonIcon
                                                        source:       _editButtonIcon
                                                        color:        internal.colors.dark
                                                        antialiasing: true
                                                    }

                                                    Components.Text {
                                                        id:    _editButtonText
                                                        text:  "Edit"
                                                        color: internal.colors.dark

                                                        anchors.left:           _editButtonIcon.right
                                                        anchors.leftMargin:     5
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }

                                                Components.Button {
                                                    id:     _deleteButton
                                                    width:  parent.width
                                                    height: 40

                                                    anchors.top: _editButton.bottom

                                                    bottomLeftRadius:  popup.background.backgroundRadius
                                                    bottomRightRadius: popup.background.backgroundRadius

                                                    onClick: function() {
                                                        _root.deletePurchase(_data.id);
                                                    }

                                                    onHover: function() {
                                                        _deleteButton.color         = internal.colors.dark;
                                                        _deleteButtonIconFill.color = internal.colors.background;
                                                        _deleteButtonText.color     = internal.colors.background;
                                                    }

                                                    onLeave: function() {
                                                        _deleteButton.color         = internal.colors.background;
                                                        _deleteButtonIconFill.color = internal.colors.dark;
                                                        _deleteButtonText.color     = internal.colors.dark;
                                                    }

                                                    Image {
                                                        id:                _deleteButtonIcon
                                                        source:            "qrc:/Icons/Trash.svg"
                                                        sourceSize.width:  parent.height * 0.4
                                                        sourceSize.height: parent.height * 0.4
                                                        antialiasing:      true
                                                        visible:           false

                                                        anchors.left:           parent.left
                                                        anchors.leftMargin:     13
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }

                                                    ColorOverlay {
                                                        id:           _deleteButtonIconFill
                                                        anchors.fill: _deleteButtonIcon
                                                        source:       _deleteButtonIcon
                                                        color:        internal.colors.dark
                                                        antialiasing: true
                                                    }

                                                    Components.Text {
                                                        id:    _deleteButtonText
                                                        text:  "Delete"
                                                        color: internal.colors.dark

                                                        anchors.left:           _deleteButtonIcon.right
                                                        anchors.leftMargin:     5
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }
                                            }
                                        }
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

                    backgroundColor: Qt.lighter(internal.colors.foreground, 1.1)

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

    Components.FinancePurchaseCreate {
        id: _purchaseCreation

        onSubmit: function() {
            _history.refresh(_root.account.history);

            _root.updateListing();
        }
    }

    Components.FinancePurchaseEdit {
        id: _purchaseEdition

        onSubmit: function() {
            _purchases.model = [];

            _history.refresh(_root.account.history);

            _root.updateListing();

            _purchases.model = _root.purchases;
        }
    }
}