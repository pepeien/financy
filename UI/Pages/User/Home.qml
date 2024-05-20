// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtCharts
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Components.Page {
    id:    _root
    title: internal.selectedUser ? internal.selectedUser.getFullName() : ""

    leftButtonIcon:   "qrc:/Icons/Profile.svg"
    leftButtonOnClick: function() {
        stack.push("qrc:/Pages/UserEdit.qml");
    }

    centerButtonIcon: "qrc:/Icons/Plus.svg"
    centerButtonOnClick: function() {
        console.log("center")
    }

    onReturn: function() {
        internal.logout();
    }

    readonly property real padding:      80
    readonly property real innerPadding: padding / 2

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
                model: internal.selectedUser?.cards ?? []

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
                model: internal.selectedUser?.goals ?? []

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
                visible:      internal.selectedUser?.cards.length > 0

                backgroundColor:  "transparent"
                plotAreaColor:    _cards.backgroundColor
                animationOptions: ChartView.SeriesAnimations

                legend.visible:        true
                legend.markerShape:    Legend.MarkerShapeCircle
                legend.color:          internal.colors.dark
                legend.font.family:    "Inter"
                legend.font.pointSize: 12
                legend.font.weight:    Font.Normal

                anchors.top:              _overviewTitle.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                Component.onCompleted: function() {
                    const expensesMap = {};

                    internal.selectedUser.cards.forEach((card) => {
                        card.purchases.forEach((purchase) => {
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
            }
        }
    }
}