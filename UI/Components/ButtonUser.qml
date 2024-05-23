// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Components.SquircleButton {
    // Props
    property alias text: _name.text

    property url picture: "qrc:/Icons/Profile.svg"

    property string primaryColor:   internal.colors.dark
    property string secondaryColor: internal.colors.foreground

    property real contentWidth: parent.width

    id:     _root
    width:  parent.width
    height: 90
    clip:   true

    backgroundColor: primaryColor

    anchors.horizontalCenter: parent.horizontalCenter

    layer.enabled: true
    layer.effect:  OpacityMask {
        maskSource: Rectangle {
            width:   _root.width
            height:  _root.height
            radius:  15
            visible: true
        }
    }

    onHover: function() {
        opacity = 0.7;
    }

    onLeave: function() {
        opacity = 1;
    }

    Components.RoundImage {
        id: _picture
        imageSource: picture
        imageWidth:  60
        imageHeight: 60

        anchors.leftMargin: 20
        anchors.fill: parent
    }

    Components.Text {
        id:                  _name
        color:               _root.secondaryColor
        height:              _root.height
        width:               _root.contentWidth - 170
        leftPadding:         -60
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:   Text.AlignVCenter
        clip: true

        font.pointSize: 20
        font.weight:    Font.Bold

        anchors.left:       parent.left
        anchors.leftMargin: 90
        anchors.rightMargin: 30
    }
}