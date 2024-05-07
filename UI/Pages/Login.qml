// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

// Animations
import "qrc:/Animations" as Animations

Components.Page {
    title: "Login"

    Components.SquircleButton {
        id: addButton
        height: 90
        width: parent.width * 0.6
        backgroundColor: internals.colors.foreground

        anchors.horizontalCenter: parent.horizontalCenter

        onClick: function() {
            stack.push("qrc:/Pages/UserCreate.qml")
        }

        Image {
            id: icon
            source: "qrc:/Icons/Plus.svg"
            sourceSize.width: 35
            sourceSize.height: 35
            antialiasing: true
            visible: false

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColorOverlay {
            anchors.fill: icon
            source: icon
            color: internals.colors.light
            antialiasing: true
        }
    }

    ListView {
        id: usersView
        model: internals.users
        width: addButton.width
        height: 90 * 10
        spacing: 25

        anchors.top: addButton.bottom
        anchors.topMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter

        delegate: Components.SquircleButton {
            required property string firstName
            required property string lastName
            required property string picture
            required property string primaryColor
            required property string secondaryColor

            width: usersView.width
            height: 90
            backgroundColor: primaryColor

            onClick: function() {
                console.log(firstName, lastName)
            }

            Components.RoundImage {
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
