// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

// Components
import "qrc:/Components" as Components

Components.SquircleButton {
    // Props
    property string firstName: ""
    property string lastName:  ""

    property url picture: "qrc:/Icons/Profile.svg"

    property string primaryColor:   internals.colors.dark
    property string secondaryColor: internals.colors.foreground

    id: _root
    width: parent.width
    height: 90

    backgroundColor: primaryColor

    anchors.horizontalCenter: parent.horizontalCenter

    Components.RoundImage {
        imageSource: picture
        imageWidth:  60
        imageHeight: 60

        anchors.leftMargin: 20
        anchors.fill: parent
    }

    Text {
        text: firstName + " " + lastName
        color: secondaryColor

        font.family: "Inter"
        font.pointSize: 20
        font.weight: Font.Bold

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}