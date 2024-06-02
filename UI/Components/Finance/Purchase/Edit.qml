// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Types
import Financy.Types 1.0

// Components
import "qrc:/Components" as Components

Components.Popup {
    property var purchase
    property var onSubmit

    id: _root

    onOpened: function() {
        _name.input.clear();
        _name.input.insert(0, _root.purchase.name);

        _description.input.clear();
        _description.input.insert(0,_root.purchase.description);

        _date.input.clear();
        _date.input.insert(0,internal.getLongDate(_root.purchase.date));

        _value.input.clear();
        _value.input.insert(0,_root.purchase.value);

        _installments.input.clear();
        _installments.input.insert(0,_root.purchase.installments);
    }

    Components.SquircleContainer {
        width:  parent.width * 0.6
        height: parent.height * 0.5

        hasShadow:       true
        backgroundColor: Qt.lighter(internal.colors.background, 0.965)

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter:   parent.verticalCenter

        Components.Text {
            id:    _title
            color: internal.colors.dark
            text:  "Edit" + _root.purchase?.name

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
                    bottom: 1
                    top: 999
                }

                KeyNavigation.tab: _value.input
            }

            Components.Input {
                id:    _value
                width: _installments.width

                label:       "Value"
                color:       internal.colors.dark
                inputHeight: _name.inputHeight

                anchors.right: parent.right

                validator: DoubleValidator {
                    bottom: 0.1
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

                user.selectedAccount.editPurchase(
                    _root.purchase.id,
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
                text:  "Edit"
                color: _submitButton.isDisabled ? internal.colors.foreground : internal.colors.background

                font.weight:    Font.Bold
                font.pointSize: 15

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter:   parent.verticalCenter
            }
        }
    }
}