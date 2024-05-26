// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Components.SquircleButton {
    id: _root

    property alias textColor: _title.color

    property alias title:    _title.text
    property real limit:     0
    property real usedLimit: 0
    property real dueAmount: 0

    readonly property real _ultilization: _root.usedLimit === 0 && _root.limit === 0 ? 0 : _root.usedLimit / _root.limit

    anchors.verticalCenter: parent.verticalCenter

    onHover: function() {
        opacity = 0.7;
    }

    onLeave: function() {
        opacity = 1;
    }

    Components.Text {
        id: _title

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
            color:        _title.color
            antialiasing: true
        }

        Components.Text {
            id:    _limitText
            text:  _root.usedLimit.toFixed(2) + " | " + _root.limit
            color: _title.color

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
            color:        _title.color
            antialiasing: true
        }

        Components.Text {
            text:  _root.dueAmount.toFixed(2)
            color: _title.color

            font: _limitText.font

            anchors.left:           _dueAmountIcon.right
            anchors.leftMargin:     _limitText.anchors.leftMargin
            anchors.verticalCenter: parent.verticalCenter   
        }
    }

    Components.ChartCircle {
        id:              _chart
        size:            60
        colorCircle:     _title.color
        colorBackground: internal.colors.foreground
        arcBegin:        0
        arcEnd:          360 * _root._ultilization
        lineWidth:       6
        showBackground:  true

        anchors.verticalCenter: parent.verticalCenter
        anchors.right:          parent.right
        anchors.rightMargin:    10
    }

    Components.Text {
        text:  Math.round(_root._ultilization * 100) + "%"
        color: _title.color

        font.pointSize: 9
        font.weight:    Font.Bold

        anchors.centerIn: _chart
    }
}