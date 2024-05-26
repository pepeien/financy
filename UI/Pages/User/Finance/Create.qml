// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import Qt5Compat.GraphicalEffects

// Types
import Financy.Types 1.0

// Components
import "qrc:/Components" as Components

Components.Page {
    id: _root
    title: "Create Account"

    centerButtonIcon: "qrc:/Icons/Check.svg"
    centerButtonOnClick: function() {
        if (!internal.selectedUser) {
            return;
        }

        internal.selectedUser.createAccount(
            _name.text,
            _closingDay.text,
            _limit.text,
            _type.currentValue,
            _primaryColor.picker.color,
            _secondaryColor.picker.color
        );

        stack.pop();
    }

    Item {
        id:     _form
        width:  parent.width * 0.6
        height: parent.height

        anchors.left: parent.left

        Components.Input {
            id:    _name
            width: 256 * 1.25

            label:     "Name"
            color:     internal.colors.dark
            minLength: 1
            maxLength: 25

            anchors.top:              parent.top
            anchors.topMargin:        parent.height * 0.25
            anchors.horizontalCenter: parent.horizontalCenter

            KeyNavigation.tab: _limit.input
        }

        Components.Input {
            id:    _limit
            width: _name.width

            label: "Limit"
            color: internal.colors.dark

            anchors.top:              _name.bottom
            anchors.topMargin:        30
            anchors.horizontalCenter: parent.horizontalCenter

            validator: IntValidator {
                bottom: 1
            }
        }

        Item {
            id:    _data
            width: _name.width

            anchors.top:       _limit.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            Components.Input {
                id:     _closingDay
                width:  (parent.width / 2) - 10
                height: _limit.height

                label: "Closing Date" 
                color: internal.colors.dark

                anchors.top:       parent.top
                anchors.topMargin: 10
                anchors.left:      parent.left

                validator: IntValidator {
                    bottom: 1
                    top: 20
                }
            }

            Components.Dropdown {
                id:         _type
                label:      "Type"
                itemWidth:  _closingDay.width
                itemHeight: _closingDay.height

                model: [ "Expense", "Saving" ]

                anchors.top:       parent.top
                anchors.topMargin: _closingDay.anchors.topMargin
                anchors.right:     parent.right
            }
        }

        Item {
            id:    _colors
            width: _name.width

            anchors.top:              _data.bottom
            anchors.topMargin:        120
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