// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

// Components
import "qrc:/Components" as Components

Components.Page {
    id:    _root
    title: internals.selectedUser ? internals.selectedUser.getFullName() : ""

    onReturn: function() {
        internals.logout();
    }

    readonly property real padding:      100
    readonly property real innerPadding: padding / 2

    Item {
        id:     _selector
        width:  (parent.width * 0.5) - (_root.innerPadding * 0.5) - (padding * 0.5)
        height: parent.height * 0.85

        anchors.left:       parent.left
        anchors.leftMargin: _root.innerPadding

        Components.SquircleContainer {
            id:     _finances
            width:  parent.width
            height: (parent.height * 0.5) - (_root.innerPadding * 0.5)

            backgroundColor: Qt.lighter(internals.colors.background, 0.965)
            hasShadow:       true

            anchors.horizontalCenter: parent.horizontalCenter
        }

        Components.SquircleContainer {
            id:     _goals
            width:  _finances.width
            height: _finances.height

            backgroundColor: _finances.backgroundColor
            hasShadow:       true

            anchors.top:              _finances.bottom
            anchors.topMargin:        _root.innerPadding
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Item {
        id:     _general
        width:  _selector.width
        height: _selector.height

        anchors.right:       parent.right
        anchors.rightMargin: _root.innerPadding

        Components.SquircleContainer {
            backgroundColor: _finances.backgroundColor
            hasShadow:       true

            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}