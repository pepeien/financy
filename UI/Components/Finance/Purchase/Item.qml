// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Types
import Financy.Types 1.0

// Components
import "qrc:/Components" as Components

Item {
    required property var purchase

    readonly property bool hasDescription: purchase.hasDescription()

    property var onPurchaseEdit
    property var onPurchaseDelete

    Rectangle {
        color:   internal.colors.foreground
        width:   parent.width
        height:  1
        visible: index > 0

        anchors.top: parent.top
    }

    Text {
        id:   _purchaseName
        text: purchase.name + " " + account.getPaidInstallments(purchase, _history.selectedHistory.date) + "/" + purchase.installments
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
            text:  purchase.description
            color: internal.colors.background

            font.family:    "Inter"
            font.pointSize: 8
            font.weight:    Font.Bold

            anchors.centerIn: parent
        }
    }

    Text {
        text:  purchase.getInstallmentValue().toFixed(2)
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
                            if (!onPurchaseEdit) {
                                return;
                            }

                            onPurchaseEdit();
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
                            if (!onPurchaseDelete) {
                                return;
                            }

                            onPurchaseDelete();
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