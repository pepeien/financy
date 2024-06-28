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

    property var _deletingAccount

    property bool _isOnEditMode: false

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

    onRoute: function() {
        _overviewChartPie.clear();

        const usedColors = [765, 0];

        for (const key in user.expenseMap) {
            const createdComponent = _overviewChartPie.append(
                key,
                user.expenseMap[key]
            );
            
            const red   = Math.random();
            const green = Math.random();
            const blue  = Math.random();

            while (!!usedColors[red + green + blue]) {
                red   = Math.random();
                green = Math.random();
                blue  = Math.random();
            }

            usedColors.push(red + green + blue);

            createdComponent.color = Qt.rgba(
                red,
                green,
                blue,
                1
            );
        }
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
                text:  "Expenses"
                color: internal.colors.light

                font.family:    "Inter"
                font.pointSize: 25
                font.weight:    Font.DemiBold

                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.topMargin:  15
                anchors.leftMargin: 25
            }

            Components.Button {
                id:     _moreButton
                height: 25
                width:  25

                anchors.top:         parent.top
                anchors.right:       parent.right
                anchors.topMargin:   25
                anchors.rightMargin: 16

                onClick: function() {
                    _root._isOnEditMode = !_root._isOnEditMode;
                }

                Image {
                    id:                _moreIcon
                    source:            "qrc:/Icons/More.svg"
                    sourceSize.width:  parent.height
                    sourceSize.height: parent.height
                    antialiasing:      true
                    visible:           false

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter:   parent.verticalCenter
                }

                ColorOverlay {
                    anchors.fill: _moreIcon
                    source:       _moreIcon
                    color:        _cardsTitle.color
                    antialiasing: true
                }
            }

            Components.Accounts {
                id:         _accounts
                model:      _root.expenseAccounts
                isEditing:  _root._isOnEditMode

                onEdit: function(inAccount) {
                    _root._isOnEditMode = false;

                    internal.selectedUser.selectAccount(inAccount.id);

                    stack.push("qrc:/Pages/UserAccountEdit.qml");
                }

                onDelete: function(inAccount) {
                    _root._deletingAccount = inAccount;
                    _root._isOnEditMode    = false;
    
                    _deletionPopup.open();
                }

                anchors.top:              _cardsTitle.bottom
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

                ToolTip {
                    id: _tooltip

                    contentItem: Components.Text {
                        text:  _tooltip.text
                        color: internal.colors.background

                        font.pointSize: 12
                        font.weight:    Font.DemiBold
                    }

                    background: Components.SquircleContainer {
                        backgroundColor: internal.colors.dark
                    }
                }

                MouseArea {
                    id:           _hoverArea
                    hoverEnabled: true

                    anchors.fill: parent

                    onMouseXChanged: function() {
                        _tooltip.x = _hoverArea.mouseX + 15;
                        _tooltip.y = _hoverArea.mouseY + 15;
                    }
                }

                PieSeries {
                    id:       _overviewChartPie
                    size:     1
                    holeSize: 0.5

                    property var _lastSlice

                    onHovered: function(slice, state) {
                        if (state) {
                            if (_lastSlice) {
                                _lastSlice.color = Qt.darker(_lastSlice.color, 1.25);
                            }

                            _lastSlice       = slice;
                            _lastSlice.color = Qt.lighter(_lastSlice.color, 1.25);

                            _hoverArea.cursorShape = Qt.PointingHandCursor;

                            _tooltip.show(`${slice.label} $${slice.value.toFixed(2)}`);

                            return;
                        }

                        _hoverArea.cursorShape = Qt.ArrowCursor;

                        _tooltip.hide();
                    }
                }

               Components.Text {
                    id:    _overviewInnerText
                    text:  "Total"
                    color: internal.colors.dark

                    font.pointSize: 30
                    font.weight:    Font.Bold

                    anchors.centerIn:  parent
                    anchors.topMargin: -10
                }

                Components.Text {
                    text:  user?.dueAmount.toFixed(2) ?? "0.0"
                    color: Qt.lighter(internal.colors.dark, 1.1)

                    font.pointSize: 22
                    font.weight:    Font.DemiBold

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top:              _overviewInnerText.bottom
                    anchors.topMargin:        10
                }
            }
        }
    }

    Components.Modal {
        id: _deletionPopup

        Components.SquircleContainer {
            width:  670
            height: 180

            hasShadow:       true
            backgroundColor: Qt.lighter(internal.colors.background, 0.965)

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter

            Item {
                id: _title
                width: _intialTitle.paintedWidth + _midTitle.width  + _lastTitle.paintedWidth
                height: 20

                anchors.top:              parent.top
                anchors.topMargin:        10
                anchors.horizontalCenter: parent.horizontalCenter

                Components.Text {
                    id:    _intialTitle
                    color: internal.colors.dark
                    text:  "Are you user you want to delete "

                    font.pointSize: 15
                    font.weight:    Font.Bold

                    anchors.left: parent.left
                }

                Components.SquircleContainer {
                    id: _midTitle

                    width:  _text.paintedWidth + 12.5
                    height: _text.paintedHeight + 2.5

                    backgroundColor: _root._deletingAccount?.primaryColor ?? internal.colors.dark

                    anchors.left: _intialTitle.right

                    Components.Text {
                        id:    _text
                        color: _root._deletingAccount?.secondaryColor ?? internal.colors.light
                        text:  _root._deletingAccount?.name ?? "NULL"

                        font.pointSize: 15
                        font.weight:    Font.Bold

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter:   parent.verticalCenter
                    }
                }

                Components.Text {
                    id:    _lastTitle
                    color: internal.colors.dark
                    text:  " ?"

                    font.pointSize: 15
                    font.weight:    Font.Bold

                    anchors.left: _midTitle.right
                }
            }

            Components.Text {
                id:    _disclaimer
                color: internal.colors.light
                text:  "This action cannot be reversed"

                font.pointSize: 12
                font.weight:    Font.Normal

                anchors.top:              _title.bottom
                anchors.topMargin:        15
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Components.SquircleButton {
                id:     _submitButton
                width:  parent.width * 0.45
                height: 60

                backgroundColor: internal.colors.dark

                anchors.bottom:           parent.bottom
                anchors.bottomMargin:     25
                anchors.horizontalCenter: parent.horizontalCenter

                onClick: function() {
                    if (!_root._isOnEditMode) {
                        return;
                    }

                    _accounts.model = [];

                    _root.user.deleteAccount(_root._deletingAccount.id);

                    _deletionPopup.close();

                    _root._deletingAccount = undefined;
                    _root._isOnEditMode    = false;

                    _accounts.model = _root.expenseAccounts;
                }

                Components.Text {
                    text:  "Delete"
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