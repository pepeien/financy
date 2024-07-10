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
    readonly property var user:    internal.selectedUser
    readonly property var account: internal.selectedAccount

    property int purchaseHeight:       45
    property int statementTitleHeight: 40
    property int statementHeight:      purchaseHeight + statementTitleHeight

    // Filter
    property int _userToFilter: -1

    id:    _root
    title: account?.name ?? ""

    leftButton.isDisabled: !account?.isOwnedBy(user.id) ?? true
    leftButtonIcon: "qrc:/Icons/Edit.svg" 
    leftButtonOnClick: function() {
        if (leftButton.isDisabled) {
            return;
        }

        if (!user || !account) {
            return;
        }

        stack.push("qrc:/Pages/UserAccountEdit.qml");
    }

    centerButtonIcon: "qrc:/Icons/Plus.svg" 
    centerButtonOnClick: function() {
        _purchaseCreation.open();
    }

    onReturn: function() {
        _history.visible = false;

        clearListing();

        internal.deselect();
    }

    onUserChanged: function () {
        _userFilter.clear();

        if (!user || !account || !account.isOwnedBy(user.id)) {
            _userFilter.model = [];

            return;
        }

        _updateFilter(-1);

        const userIds = [];

        account.sharedUserIds.forEach((sharedUser) => {
            if (userIds.find((user) => user == sharedUser)) {
                return;
            }

            userIds.push(sharedUser);
        });

        const sharedUsers = userIds.map((_) => internal.getUser(_));
        sharedUsers.push(user);

        if (userIds.length > 0) {
            sharedUsers.push(user);
        }

        sharedUsers.sort((userA, userB) => userA.id - userB.id);

        _userFilter.model = sharedUsers;
    }

    function clearListing() {
        _history.refresh([]);
        _purchases.clear();
    }

    function _refreshListing() {
        _root.clearListing();

        _history.refresh(_root.account.history);
    }

    function _updateFilter(inId) {
        _root._userToFilter = inId;
    }

    Component.onCompleted: function() {
        _root._refreshListing();
    }

    Components.Dropdown {
        id:      _userFilter
        visible: account?.isOwnedBy(user.id) ?? false

        label: "Users"

        itemWidth:  250
        itemHeight: 50

        getOptionDisplay: function(option, index) {
            if (!option) {
                return "";
            }

            return index === 0 ? "All" : option.getFullName().trim();
        }

        onSelect: function(option, index) {
            if (!account.isOwnedBy(user.id)) {
                return;
            }

            const nextId = index === 0 ? -1 : option.id;

            if (_root._userToFilter === nextId) {
                return;
            }

            _root.account.refreshHistory(nextId);

            _root._updateFilter(nextId);
            _root._refreshListing();
        }

        anchors.top:         parent.top
        anchors.right:       parent.right
        anchors.topMargin:   -90
        anchors.rightMargin: 25
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

        onSelectedHistoryUpdate: function() {
            if (!_history.selectedHistory) {
                _root.clearListing();

                return;
            }

            _purchases.update(
                _history.selectedHistory,
                account.getStatementPurchases(    _history.selectedHistory.date, _root._userToFilter),
                account.getStatementSubscriptions(_history.selectedHistory.date, _root._userToFilter)
            );
        }
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

            onCancel: function(purchase) {
                _purchaseCancelation.purchase = purchase;

                _purchaseCancelation.open();
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
            _root._refreshListing();
        }
    }

    Components.FinancePurchaseEdit {
        id: _purchaseEdition

        onSubmit: function() {
            _root._refreshListing();
        }
    }

    Components.FinancePurchaseCancel {
        id: _purchaseCancelation

        onSubmit: function() {
            _root.clearListing();

            account.cancelPurchase(purchase.id);

            _root.account.onEdit();
            _root.user.onEdit();

            _root._refreshListing();
        }
    }

    Components.FinancePurchaseDelete {
        id: _purchaseDeletion

        onSubmit: function() {
            _root.clearListing();

            account.deletePurchase(purchase.id);

            _root.account.onEdit();
            _root.user.onEdit();

            _root._refreshListing();
        }
    }
}