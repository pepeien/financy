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
    readonly property var user: internal.selectedUser
    
    property var _accountToShare

    id:    _root
    title: "Create Account"

    centerButton.isDisabled: _name.hasError || _limit.hasError || _closingDay.hasError
    centerButtonIcon: "qrc:/Icons/Check.svg"
    centerButtonOnClick: function() {
        if (centerButton.isDisabled) {
            return;
        }

        if (!user) {
            return;
        }

        if (_form.willBeShared) {
            user.addSharedAccount(_accountToShare);
        } else {
            internal.createAccount(
                _name.text,
                _closingDay.text,
                _limit.text,
                _type.value,
                _primaryColor.picker.color,
                _secondaryColor.picker.color
            );
        }

        stack.pop();
    }

    function clear() {
        _name.clear();
        _closingDay.clear();
        _limit.clear();
        _type.clear();
        _primaryColor.set(internal.colors.dark);
        _secondaryColor.set(internal.colors.background);
    }

    Item {
        id:     _form
        width:  parent.width * 0.6
        height: parent.height

        anchors.left: parent.left

        property bool willBeShared: false

        Components.SquircleContainer {
            id:     _selector
            width:  200
            height: 40

            backgroundBorder.width: 1
            backgroundBorder.color: internal.colors.foreground

            anchors.top:              parent.top
            anchors.topMargin:        25
            anchors.horizontalCenter: parent.horizontalCenter

            Components.SquircleButton {
                width:  parent.width * 0.5
                height: parent.height

                backgroundColor:             _form.willBeShared ? "transparent" : internal.colors.dark
                backgroundTopRightRadius:    0
                backgroundBottomRightRadius: 0

                anchors.left: parent.left

                onClick: function() {
                    _root.clear();

                    _form.willBeShared = false;
                }

                Components.Text {
                    text:  "New"
                    color: _form.willBeShared ? internal.colors.dark : internal.colors.background

                    font.weight:    Font.Bold
                    font.pointSize: 11

                    anchors.centerIn: parent
                }
            }

            Rectangle {
                width:  1
                height: parent.height
                color:  internal.colors.foreground

                anchors.centerIn: parent
            }

            Components.SquircleButton {
                width:  parent.width * 0.5
                height: parent.height

                backgroundColor:            _form.willBeShared ? internal.colors.dark : "transparent"
                backgroundTopLeftRadius:    0
                backgroundBottomLeftRadius: 0
    
                anchors.right: parent.right

                onClick: function() {
                    _root.clear();

                    _form.willBeShared = true;
                }

                Components.Text {
                    text:  "Shared"
                    color: _form.willBeShared ? internal.colors.background : internal.colors.dark

                    font.weight:    Font.Bold
                    font.pointSize: 11

                    anchors.centerIn: parent
                }
            }
        }

        Item {
            width:   parent.width
            height:  parent.height
            visible: !_form.willBeShared

            anchors.top:       _selector.bottom
            anchors.topMargin: 80

            Components.Input {
                id:    _name
                width: 256 * 1.25

                label:     "Name"
                color:     internal.colors.dark
                minLength: 1
                maxLength: 25

                anchors.top:              parent.top
                anchors.horizontalCenter: parent.horizontalCenter

                KeyNavigation.tab: _limit.input
            }

            Components.Input {
                id:    _limit
                width: _name.width

                label: "Limit"
                color: internal.colors.dark
                hint:  "> 1"

                validator: IntValidator {
                    bottom: 1
                }

                anchors.top:              _name.bottom
                anchors.topMargin:        10
                anchors.horizontalCenter: parent.horizontalCenter

                KeyNavigation.tab: _closingDay.input
            }

            Item {
                id:     _data
                width:  _name.width
                height: _name.height

                anchors.top:       _limit.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Components.Input {
                    property int min: internal.getMinStatementClosingDay()
                    property int max: internal.getMaxStatementClosingDay()
    
                    id:     _closingDay
                    width:  (parent.width / 2) - 10

                    label: "Closing day" 
                    color: internal.colors.dark
                    hint:  _closingDay.min + " ~ " + _closingDay.max

                    anchors.left: parent.left

                    validator: IntValidator {
                        bottom: _closingDay.min
                        top:    _closingDay.max
                    }
                }

                Components.Dropdown {
                    id:         _type
                    label:      "Type"
                    itemWidth:  _closingDay.width
                    itemHeight: _closingDay.inputHeight

                    model: internal.getAccountTypes()

                    anchors.right: parent.right
                }
            }

            Item {
                id:    _colors
                width: _name.width

                anchors.top:              _data.bottom
                anchors.topMargin:        40
                anchors.horizontalCenter: parent.horizontalCenter

                Components.ColorPicker {
                    id:     _primaryColor
                    width:  (parent.width / 2) - 15
                    height: 60
                    color:  internal.colors.dark
                    label:  "Background Color"

                    anchors.left:           parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Components.ColorPicker {
                    id:     _secondaryColor
                    width:  _primaryColor.width
                    height: _primaryColor.height
                    color:  internal.colors.background
                    label:  "Text Color"

                    anchors.left:           _primaryColor.right
                    anchors.leftMargin:     30
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Item {
            width:   parent.width
            height:  parent.height * 0.85
            visible: _form.willBeShared

            anchors.top:       _selector.bottom
            anchors.topMargin: 80

            ScrollView {
                readonly property real _padding: 35

                id:            _scroll
                height:        parent.height - (_padding * 2)
                width:         parent.width * 0.6
                bottomPadding: _padding
                clip:          true

                anchors.horizontalCenter: parent.horizontalCenter

                ScrollBar.vertical: Components.ScrollBar {
                    isVertical: true
                }

                ListView {
                    property var _accounts: internal.getAccounts(Account.Expense).filter((_) => !_.isOwnedBy(_root.user.id))

                    id:      _list
                    spacing: 25
                    model:   _accounts

                    anchors.fill: parent

                    delegate: Item {
                        property var _item: _list._accounts[index]
    
                        height: 100
                        width:  _list.width * 0.95

                        Components.Account {
                            id:     _account

                            backgroundColor: _item.primaryColor
                            textColor:       _item.secondaryColor

                            title:     _item.name
                            limit:     _item.limit
                            usedLimit: _item.usedLimit
                            dueAmount: _item.dueAmount

                            anchors.fill: parent

                            onClick: function() {
                                _root._accountToShare = _item;

                                _name.set(            _item.name)
                                _closingDay.set(      _item.closingDay);
                                _limit.set(           _item.limit);
                                _type.set(            internal.getAccountTypeName(_item.type));
                                _primaryColor.set(    _item.primaryColor);
                                _secondaryColor.set(  _item.secondaryColor);
                            }

                            onHover: function(inMouseArea) {
                                inMouseArea.cursorShape = Qt.PointingHandCursor;
                                opacity = 0.7;
                            }

                            onLeave: function(inMouseArea) {
                                inMouseArea.cursorShape = Qt.ArrowCursor;
                                opacity = 1;
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        id:     _preview
        width:  parent.width - _form.width
        height: _form.height

        anchors.left: _form.right

        Components.SquircleContainer {
            // Props
            id:               _secondPreviewButton
            width:            parent.width * 0.9
            height:           parent.height
            backgroundColor:  internal.showcaseColors.background
            hasShadow:        true

            anchors.top:              parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            Components.Text {
                id:    _secondPreviewTitle
                text:  "Preview"
                color: internal.showcaseColors.light

                font.family:    "Inter"           
                font.pointSize: 25
                font.weight:    Font.Normal

                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.topMargin:  parent.height * 0.06
                anchors.leftMargin: parent.width * 0.05
            }

            Components.Switch {
                id: _switch

                color: internal.showcaseColors.light
                fill:  internal.showcaseColors.foreground
                width: 60

                labelText:    _switch.isSwitched ? "Dark" : "Light"

                buttonHeight: 28

                isSwitched:   internal.colorsTheme == Colors.Dark

                anchors.top:         parent.top
                anchors.right:       parent.right
                anchors.topMargin:   parent.height * 0.03
                anchors.rightMargin: parent.width * 0.05

                onSwitch: function() {
                    internal.updateShowcaseTheme(
                        _switch.isSwitched ? Colors.Dark : Colors.Light
                    );
                }
            }

            Components.Account {
                height: 95
                width:  parent.width * 0.7

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter:   parent.verticalCenter

                // Props
                title:           _name.text
                backgroundColor: _primaryColor.picker.currentColor
                textColor:       _secondaryColor.picker.currentColor

                limit: _limit.text
            }
        }
    }
}