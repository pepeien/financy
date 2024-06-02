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
    property var user:    internal.selectedUser
    property var account: user.selectedAccount

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
        _purchases.clear();

        if (!_history.selectedHistory) {
            return;
        }

        _purchases.add(
            _history.selectedHistory.dateBasedHistory,
            _history.selectedHistory.subscriptions
        );
    }

    function clearListing() {
        _purchases.clear();

        _history.refresh([]);
        _root.updateListing();
    }

    function refreshListing() {
        _history.refresh(_root.account.history);
        _root.updateListing();

        _purchases.add(_root.purchases, _root.subscriptions);
    }

    Components.Text {
        id:      _historyYear
        text:    _history.selectedHistory?.date.getFullYear() ?? ""
        color:   internal.colors.dark
        visible: !!_history.selectedHistory

        font.pointSize: 20
        font.weight:    Font.Bold

        anchors.top:              parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Components.FinanceHistory {
        id:      _history
        width:   parent.width * 0.95
        height:  parent.height * 0.4

        anchors.top:              _historyYear.bottom
        anchors.topMargin:        10
        anchors.horizontalCenter: parent.horizontalCenter

        onSelectedHistoryUpdate: _root.updateListing
    }

    Item {
        width:  parent.width * 0.55
        height: _root.height - _history.height - 320

        anchors.top:              _history.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin:        30

        Components.FinancePurchaseList {
            id: _purchases

            anchors.fill: parent

            onEdit: function(purchase) {
                _purchaseEdition.purchase = purchase;

                _purchaseEdition.open();
            }

            onDelete: function(purchase) {
                _purchaseDeletion.purchase = purchase;

                _purchaseDeletion.open();
            }
        }
    }

    Components.FinancePurchaseCreate {
        id: _purchaseCreation

        onSubmit: function() {
            _root.clearListing();

            _history.refresh(_root.account.history);

            _root.refreshListing();
        }
    }

    Components.FinancePurchaseEdit {
        id: _purchaseEdition

        onSubmit: function() {
            _root.clearListing();

            _history.refresh(_root.account.history);

            _root.refreshListing();
        }
    }

    Components.FinancePurchaseDelete {
        id: _purchaseDeletion

        onSubmit: function() {
            _root.clearListing();

            _root.account.deletePurchase(purchase.id);
            _root.account.onEdit();
            _root.user.onEdit();

            _root.refreshListing();
        }
    }
}