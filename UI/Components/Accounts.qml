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
    clip: true

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
            readonly property real _ultilization: _item.getUsedLimit() / _item.limit

            id:     _root
            height: _grid.cellHeight
            width:  _grid.cellWidth

            Components.SquircleButton {
                height: _root.height - (_scroll._padding / 2)
                width:  _root.width - _scroll._padding

                backgroundColor: _item.primaryColor

                anchors.right:       index % 2 == 0 ? parent.right : undefined
                anchors.rightMargin: index % 2 == 0 ? (_scroll._padding / 4) : 0

                anchors.left:       index % 2 != 0 ? parent.left : undefined
                anchors.leftMargin: index % 2 != 0 ? (_scroll._padding / 4) : 0

                anchors.verticalCenter: parent.verticalCenter

                onClick: function() {
                    internal.accountLogin(_item);

                    stack.push("qrc:/Pages/UserFinanceHome.qml");
                }

                Components.Text {
                    id:    _title
                    text:  _item.name
                    color: _item.secondaryColor

                    font.pointSize: 13
                    font.weight:    Font.Bold

                    anchors.top:        parent.top
                    anchors.left:       parent.left
                    anchors.topMargin:  10
                    anchors.leftMargin: 15
                }

                Item {
                    id:     _limit
                    width:  65
                    height: 15

                    anchors.left:       parent.left
                    anchors.top:        _title.bottom
                    anchors.topMargin:  15
                    anchors.leftMargin: 15

                    Image {
                        id:     _limitIcon
                        width:  15
                        height: 10

                        source:            "qrc:/Icons/Limit.svg"
                        sourceSize.width:  15
                        sourceSize.height: 10
                        antialiasing:      true
                        visible:           false

                        anchors.left:           parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ColorOverlay {
                        anchors.fill: _limitIcon
                        source:       _limitIcon
                        color:        _item.secondaryColor
                        antialiasing: true
                    }

                    Components.Text {
                        id:    _limitText
                        text:  _item.getUsedLimit().toFixed(0) + " | " + _item.limit
                        color: _item.secondaryColor

                        font.pointSize: 9
                        font.weight:    Font.DemiBold

                        anchors.left:           _limitIcon.right
                        anchors.leftMargin:     5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item {
                    width:  _limit.width
                    height: _limit.height

                    anchors.left:       parent.left
                    anchors.top:        _limit.bottom
                    anchors.topMargin:  5
                    anchors.leftMargin: 15

                    Image {
                        id:     _dueAmountIcon
                        width:  15
                        height: 10

                        source:            "qrc:/Icons/Cash.svg"
                        sourceSize.width:  15
                        sourceSize.height: 10
                        antialiasing:      _limitIcon.antialiasing
                        visible:           _limitIcon.visible

                        anchors.left:           parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ColorOverlay {
                        anchors.fill: _dueAmountIcon
                        source:       _dueAmountIcon
                        color:        _item.secondaryColor
                        antialiasing: true
                    }

                    Components.Text {
                        text:  _item.getDueAmount().toFixed(2)
                        color: _item.secondaryColor

                        font: _limitText.font

                        anchors.left:           _dueAmountIcon.right
                        anchors.leftMargin:     _limitText.anchors.leftMargin
                        anchors.verticalCenter: parent.verticalCenter   
                    }
                }

                Components.ChartCircle {
                    id:              _chart
                    size:            60
                    colorCircle:     _item.secondaryColor
                    colorBackground: internal.colors.foreground
                    arcBegin:        0
                    arcEnd:          360 * _ultilization
                    lineWidth:       6
                    showBackground:  true

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right:          parent.right
                    anchors.rightMargin:    10
                }

                Components.Text {
                    text: Math.round(_ultilization * 100) + "%"
                    color: _item.secondaryColor

                    font.pointSize: 9
                    font.weight:    Font.Bold

                    anchors.centerIn: _chart
                }
            }
        }
    }
}