// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Types
import Financy.Types 1.0

// Components
import "qrc:/Components" as Components

Components.Modal {
    readonly property var user:    internal.selectedUser
    readonly property var account: internal.selectedAccount

    property var onSubmit

    id: _root

    onOpened: function() {
        _name.clear();
        _description.clear();
        _date.clear();
        _value.clear();
        _installments.clear();
        _type.clear();

        _datePicker.set(new Date());
        _date.set(internal.getLongDate(_datePicker.selectedDate));
    }

    Components.SquircleContainer {
        hasShadow:       true
        backgroundColor: Qt.lighter(internal.colors.background, 0.965)

        anchors.fill: parent

        Components.Text {
            id:    _title
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
                isRequired:  false

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
                    bottom: internal.getMinInstallmentCount()
                    top:    internal.getMaxInstallmentCount()
                }

                KeyNavigation.tab: _value.input
            }

            Components.Input {
                id:     _value
                width:  _installments.width

                label:       "Total Value"
                color:       internal.colors.dark
                inputHeight: _name.inputHeight

                anchors.right: parent.right

                validator: DoubleValidator {
                    locale: "en"
                    bottom: 0.1
                    decimals: 2
                }

                KeyNavigation.tab: _date.input
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

                Components.SquircleButton {
                    id:     _dateButton
                    width:  parent.height
                    height: parent.height

                    anchors.right: parent.right

                    onClick: function() {
                        if (_datePicker.visible) {
                            return;
                        }

                        _datePicker.open();
                    }

                    Image {
                        id:           _dateIcon
                        width:        parent.height * 0.5
                        height:       parent.height * 0.5
                        source:       "qrc:/Icons/Calendar.svg"

                        anchors.centerIn: parent
                    }

                    ColorOverlay {
                        anchors.fill: _dateIcon
                        source:       _dateIcon
                        color:        _date.isDisabled ? internal.colors.foreground : internal.colors.light
                        antialiasing: true
                    }
                }

                Components.DatePicker {
                    id:     _datePicker
                    x:      _dateButton.x + _dateButton.width
                    y:      _dateButton.y + (_date.inputHeight * 0.5)
                    width:  228
                    height: 228

                    onSelect: function(date) {
                        _date.set(internal.getLongDate(date));
                    }
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

            backgroundColor: internal.colors.dark

            isDisabled: _name.hasError || _description.hasError || _date.hasError || _value.hasError || _installments.hasError

            anchors.bottom:           parent.bottom
            anchors.bottomMargin:     25
            anchors.horizontalCenter: parent.horizontalCenter

            onClick: function() {
                if (_submitButton.isDisabled) {
                    return;
                }

                _root.account.createPurchase(
                    _name.text,
                    _description.text,
                    _date.text,
                    _type.value,
                    _value.text,
                    _installments.text
                );
                user.onEdit();

                _root.close();

                if (!_root.onSubmit) {
                    return;
                }

                _root.onSubmit();
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