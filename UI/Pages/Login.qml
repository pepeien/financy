// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtCharts

import "qrc:/Components" as Financy

Rectangle {
    width: 1600
    height: 900
    color: colorScheme.background

    Text {
        id: title
        text: "Login"
        color: colorScheme.dark

        font.family: "Inter"
        font.pointSize: 40
        font.weight: Font.DemiBold

        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: addButton
        width: parent.width * 0.18
        height: 90
        color: colorScheme.foreground
        radius: 15

        anchors.top: title.bottom
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter

        MouseArea {
            anchors.fill: parent

            onClicked: {
                console.log(users)
            }
        }
    }

    ListView {
        id: usersView
        model: users

        width: parent.width * 0.18
        height: 90 * 10

        spacing: 25

        anchors.top: addButton.bottom
        anchors.topMargin: 80
        anchors.horizontalCenter: parent.horizontalCenter

        delegate: Rectangle {
            required property string firstName
            required property string lastName
            required property string picture

            width: usersView.width
            height: 90
            color: colorScheme.foreground
            radius: 15

            Financy.RoundImage {
                imageSource: picture
                imageWidth: 60
                imageHeight: 60

                anchors.leftMargin: 10
                anchors.fill: parent
            }
        }
    }
}
