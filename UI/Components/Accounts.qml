// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

ScrollView {
    readonly property real _padding: 35

    property alias model: _grid.model

    id:     _scroll
    width:  parent.width
    height: parent.height - (_padding * 2)
    clip:   true

    contentHeight: 110 * model.length / 2
    contentWidth:  -1

    property bool isDeleting: false
    property var onDeleting

    ScrollBar.vertical: Components.ScrollBar {
        isVertical: true
    }

    GridView {
        id:     _grid
        width:  _scroll.width - _scroll._padding
        height: _scroll.height

        anchors.horizontalCenter: parent.horizontalCenter

        cellHeight: 110
        cellWidth:  _grid.width / 2

        delegate: Item {
            readonly property var _item:          _grid.model[index]
            readonly property real _ultilization: _item.usedLimit / _item.limit

            id:     _root
            height: _grid.cellHeight
            width:  _grid.cellWidth

            Components.Account {
                height: _root.height - (_scroll._padding / 2)
                width:  _root.width - _scroll._padding

                anchors.right:       index % 2 == 0 ? parent.right : undefined
                anchors.rightMargin: index % 2 == 0 ? (_scroll._padding / 4) : 0

                anchors.left:       index % 2 != 0 ? parent.left : undefined
                anchors.leftMargin: index % 2 != 0 ? (_scroll._padding / 4) : 0

                backgroundColor: _item.primaryColor
                textColor:       _item.secondaryColor

                title:     _item.name
                limit:     _item.limit
                usedLimit: _item.usedLimit
                dueAmount: _item.dueAmount

                onClick: function() {
                    if (_scroll.isDeleting) {
                        return;
                    }

                    internal.selectedUser.selectAccount(_item.id);

                    stack.push("qrc:/Pages/UserAccountHome.qml");
                }

                onHover: function(inMouseArea) {
                    if (_scroll.isDeleting) {
                        inMouseArea.cursorShape = Qt.ArrowCursor;

                        return;
                    }

                    opacity = 0.7;
                }

                onLeave: function(inMouseArea) {
                    if (_scroll.isDeleting) {
                        inMouseArea.cursorShape = Qt.ArrowCursor;

                        return;
                    }

                    opacity = 1;
                }

                Components.Button {
                    id:     _delete
                    height: parent.height
                    width:  0

                    topRightRadius:    Math.min((height * 0.25), 9)
                    bottomRightRadius: Math.min((height * 0.25), 9)

                    backgroundColor: "#F2665A"

                    anchors.right: parent.right

                    onHover: function(inMouseArea) {
                        if (!_scroll.isDeleting) {
                            return;
                        }

                        inMouseArea.cursorShape = Qt.PointingHandCursor;
                    }

                    onLeave: function(inMouseArea) {
                        if (!_scroll.isDeleting) {
                            inMouseArea.cursorShape = Qt.ArrowCursor;

                            return;
                        }

                        inMouseArea.cursorShape = Qt.ArrowCursor;
                    }

                    onClick: function() {
                        if (!_scroll.isDeleting) {
                            return;
                        }

                        onDeleting(_item);
                    }

                    states: State {
                        when: _scroll.isDeleting
                        PropertyChanges {
                            target: _delete
                            width: 70
                        }
                    }

                    transitions: Transition {
                        NumberAnimation {
                            properties: "width"
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Image {
                        id:                _icon
                        source:            "qrc:/Icons/Close.svg"
                        sourceSize.width:  parent.width * 0.4
                        sourceSize.height: parent.width * 0.4
                        antialiasing:      true
                        visible:           false

                        anchors.verticalCenter:   parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    ColorOverlay {
                        anchors.fill: _icon
                        source:       _icon
                        color:        "white"
                        antialiasing: true
                        visible:      _scroll.isDeleting
                    }
                }
            }
        }
    }
}