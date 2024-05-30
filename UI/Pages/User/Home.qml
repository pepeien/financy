// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtCharts
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Types
import Financy.Types 1.0

// Components
import "qrc:/Components" as Components

Components.Page {
    readonly property var user: internal.selectedUser

    id:    _root
    title: user ? user.getFullName() : ""

    leftButtonIcon:   "qrc:/Icons/Edit.svg"
    leftButtonOnClick: function() {
        stack.push("qrc:/Pages/UserEdit.qml");
    }

    centerButtonIcon: "qrc:/Icons/Plus.svg"
    centerButtonOnClick: function() {
        stack.push("qrc:/Pages/UserAccountCreate.qml");
    }

    onReturn: function() {
        internal.logout();
    }

    readonly property real padding:      80
    readonly property real innerPadding: padding / 2

    readonly property var expenseAccounts: user ? user.accounts.filter((account) => account.type == Account.Expense) : []
    readonly property var savingAccounts:  user ? user.accounts.filter((account) => account.type == Account.Saving) : []

    Item {
        id:     _selector
        width:  (parent.width * 0.5) - (_root.innerPadding * 0.5) - (padding * 0.5)
        height: parent.height

        anchors.left:       parent.left
        anchors.leftMargin: _root.innerPadding

        Components.SquircleContainer {
            id:     _cards
            width:  parent.width
            height: (parent.height * 0.5) - (_root.innerPadding * 0.5)

            backgroundColor: Qt.lighter(internal.colors.background, 0.965)
            hasShadow:       true

            anchors.horizontalCenter: parent.horizontalCenter

            Components.Text {
                id:    _cardsTitle
                text:  "Cards"
                color: internal.colors.light

                font.family:    "Inter"
                font.pointSize: 25
                font.weight:    Font.DemiBold

                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.topMargin:  15
                anchors.leftMargin: 25
            }

            Components.Accounts {
                model: _root.expenseAccounts

                anchors.top:              _cardsTitle.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Components.SquircleContainer {
            id:     _goals
            width:  _cards.width
            height: _cards.height

            backgroundColor: _cards.backgroundColor
            hasShadow:       true

            anchors.top:              _cards.bottom
            anchors.topMargin:        _root.innerPadding
            anchors.horizontalCenter: parent.horizontalCenter

            Components.Text {
                id:    _goalTitle
                text:  "Goals"
                color: internal.colors.light

                font.family:    "Inter"
                font.pointSize: 25
                font.weight:    Font.DemiBold

                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.topMargin:  15
                anchors.leftMargin: 25
            }

            Components.Accounts {
                model: _root.savingAccounts

                anchors.top:              _goalTitle.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Item {
        id:     _overview
        width:  _selector.width
        height: _selector.height

        anchors.right:       parent.right
        anchors.rightMargin: _root.innerPadding

        Components.SquircleContainer {
            backgroundColor: _cards.backgroundColor
            hasShadow:       true

            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter

            Components.Text {
                id:    _overviewTitle
                text:  "Overview"
                color: internal.colors.light

                font.family:    "Inter"
                font.pointSize: 25
                font.weight:    Font.DemiBold

                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.topMargin:  15
                anchors.leftMargin: 25
            }

            ChartView {
                id:           _overviewChart
                height:       parent.height - _overviewTitle.height
                width:        parent.width - _overviewTitle.height
                antialiasing: true
                visible:      _root.expenseAccounts.length > 0

                backgroundColor:  "transparent"
                plotAreaColor:    "transparent"
                animationOptions: ChartView.SeriesAnimations

                legend.visible:        true
                legend.markerShape:    Legend.MarkerShapeCircle
                legend.color:          internal.colors.foreground
                legend.font.family:    "Inter"
                legend.font.pointSize: 13
                legend.font.weight:    Font.Bold

                anchors.top:              _overviewTitle.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin:        -10

                Component.onCompleted: function() {
                    const expensesMap = {};

                    _root.expenseAccounts.forEach((card) => {
                        card.purchases.forEach((purchase) => {
                            if (card.hasFullyPaid(purchase)) {
                                return;
                            }

                            const key = purchase.getTypeName();

                            if (expensesMap[key]) {

                                expensesMap[key] += purchase.getInstallmentValue();

                                return;
                            }

                            expensesMap[key] = purchase.getInstallmentValue();
                        });
                    });

                    for (const [key, value] of Object.entries(expensesMap)) {
                        _overviewChartPie.append(
                            key,
                            value
                        );
                    }
                }

                PieSeries {
                    id:       _overviewChartPie
                    size:     1
                    holeSize: 0.7
                }

                Text {
                    id:    _overviewInnerText
                    text:  "Total"
                    color: internal.colors.dark

                    font.family:    "Inter"
                    font.pointSize: 30
                    font.weight:    Font.Bold

                    anchors.centerIn:  parent
                    anchors.topMargin: -10
                }

                Text {
                    text:  user?.dueAmount.toFixed(2) ?? "0.0"
                    color: Qt.lighter(internal.colors.dark, 1.1)

                    font.family:    "Inter"
                    font.pointSize: 22
                    font.weight:    Font.DemiBold

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top:              _overviewInnerText.bottom
                    anchors.topMargin:        10
                }
            }
        }
    }
}