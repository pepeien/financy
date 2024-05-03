// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import Qt5Compat.GraphicalEffects

import "qrc:/Components" as Financy

Rectangle {
    color: colorScheme.background

    anchors.fill: parent

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


    Financy.SquircleContainer {
        id: addButton
        width: parent.width * 0.4
        height: 90
        backgroundColor: colorScheme.foreground

        anchors.top: title.bottom
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter

        MouseArea {
            anchors.fill: parent

            onClicked: {
                console.log(users)
            }

            HoverHandler {
                id: hover
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                cursorShape: Qt.PointingHandCursor
            }

            Image {
                source: "qrc:/Icons/Plus.svg"
                sourceSize.width: 35
                sourceSize.height: 35

                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    ListView {
        id: usersView
        model: users
        width: addButton.width
        height: 90 * 10
        spacing: 25

        anchors.top: addButton.bottom
        anchors.topMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter

        delegate: Financy.SquircleContainer {
            required property string firstName
            required property string lastName
            required property string picture
            required property string primaryColor
            required property string secondaryColor

            width: usersView.width
            height: 90
            backgroundColor: primaryColor

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    console.log(firstName, lastName)
                }

                HoverHandler {
                    id: hover
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    cursorShape: Qt.PointingHandCursor
                }

                Financy.RoundImage {
                    id: pictureComponent
                    imageSource: picture
                    imageWidth: 60
                    imageHeight: 60

                    anchors.leftMargin: 20
                    anchors.fill: parent
                }

                Text {
                    text: firstName
                    color: secondaryColor

                    font.family: "Inter"
                    font.pointSize: 20
                    font.weight: Font.Bold

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
