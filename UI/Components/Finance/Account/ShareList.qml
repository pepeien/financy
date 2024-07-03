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
    readonly property var user: internal.selectedUser
    readonly property var accounts: internal.getAccounts(Account.Expense).filter((_) => !_.isOwnedBy(user.id) && !_.isSharingWith(user.id))

    property alias topPadding:    _scroll.topPadding
    property alias bottomPadding: _scroll.bottomPadding

    id: _root

    property var onClick

    Components.Text {
        text:    "No expense accounts available"
        color:   Qt.darker(internal.colors.foreground, 1.1)
        visible: _root.accounts.length == 0

        font.weight:    Font.Bold
        font.pointSize: 16

        anchors.centerIn: parent
    }

    ScrollView {
        id:      _scroll
        width:   parent.width
        height:  parent.height
        clip:    true
        visible: _root.accounts.length > 0

        ScrollBar.vertical: Components.ScrollBar {
            isVertical: true
        }

        ListView {
            id:           _list
            spacing:      25
            model:        _root.accounts
            anchors.fill: parent

            delegate: Item {
                readonly property var _item:  _list.model[index]
                readonly property var _owner: internal.getUser(_item.userId)

                height: 100
                width:  _list.width * 0.95

                Components.SquircleContainer {

                    id:     _accountOnwer
                    width:  parent.height
                    height: parent.height

                    backgroundColor: _owner.primaryColor

                    Components.RoundImage {
                        id: _picture

                        imageSource: _owner.picture ?? ""
                        imageWidth:  parent.height * 0.5
                        imageHeight: parent.height * 0.5
                        imageColor:  internal.colors.foreground
                        hasColor:    imageSource == ""

                        anchors.top:              parent.top
                        anchors.topMargin:        10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Components.Text {
                        readonly property string _name: _owner.firstName;

                        text:  _name.length > 8 ? `${_name.substring(0, 8)}...` : _name
                        color: _owner.secondaryColor

                        font.pointSize: 12
                        font.weight:    Font.DemiBold

                        anchors.top:              _picture.bottom
                        anchors.topMargin:        10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Components.FinanceAccountItem {
                    id:     _account
                    height: parent.height
                    width:  parent.width - _accountOnwer.width - _account.anchors.leftMargin

                    backgroundColor: _item.primaryColor
                    textColor:       _item.secondaryColor

                    title:     _item.name
                    limit:     _item.limit
                    usedLimit: _item.usedLimit
                    dueAmount: _item.dueAmount

                    anchors.left:       _accountOnwer.right
                    anchors.leftMargin: _list.spacing

                    onClick: function() {
                        if (!_root.onClick)
                        {
                            return;
                        }

                        _root.onClick(_item);
                    }

                    onHover: function(inMouseArea) {
                        inMouseArea.cursorShape = Qt.PointingHandCursor;
                        opacity                 = 0.7;
                    }

                    onLeave: function(inMouseArea) {
                        inMouseArea.cursorShape = Qt.ArrowCursor;
                        opacity                 = 1;
                    }
                }
            }
        }
    }
}