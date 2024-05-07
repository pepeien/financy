// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import Qt5Compat.GraphicalEffects

// Types
import Financy.Colors 1.0

// Components
import "qrc:/Components" as Components

Components.Page {
    // Vars
    property bool wasPictureSelected

    property string profileFirstName: ""
    property string profileLastName: ""
    property url profilePicture: "qrc:/Icons/Profile.svg"

    id: root
    title: "Create User"

    Components.SquircleButton {
        id: picture
        width: 256
        height: 256
        backgroundColor: internals.colors.foreground

        anchors.horizontalCenter: parent.horizontalCenter

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: picture.width
                height: picture.height
                radius: 15
                visible: true
            }
        }

        onClick: function() {
            var result = internals.openFileDialog(
                "Select Profile Picture",
                "jpg;jpeg;png"
            );

            if (result === "")
            {
                return;
            }

            root.wasPictureSelected = true;
            root.profilePicture = result;
        }

        Image {
            id: icon
            source: profilePicture
            sourceSize.width:  wasPictureSelected ? picture.width : picture.width * 0.5
            sourceSize.height: wasPictureSelected ? picture.height : picture.height * 0.5
            antialiasing: true
            fillMode: Image.PreserveAspectCrop

            anchors.top: parent.top
            anchors.topMargin: wasPictureSelected ? -plusContainer.height / 2 : 40
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColorOverlay {
            id: iconMask
            anchors.fill: icon
            source: icon
            color: internals.colors.light
            antialiasing: true
            visible: !wasPictureSelected
        }

        Rectangle {
            id: plusContainer
            width: parent.width
            height: 60
            color: internals.colors.light

            bottomLeftRadius: 15
            bottomRightRadius: 15

            anchors.bottom: parent.bottom

            Image {
                id: plusIcon
                source: "qrc:/Icons/Plus.svg"
                sourceSize.width: 25
                sourceSize.height: 25
                antialiasing: true
                visible: false

                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ColorOverlay {
                anchors.fill: plusIcon
                source: plusIcon
                color: internals.colors.background
                antialiasing: true
            }
        }
    }

    Components.Input {
        id: firstName
        width: picture.width + 80
        
        label: "First name"
        color: internals.colors.dark

        KeyNavigation.tab: lastName.input

        anchors.top: picture.bottom
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Components.Input {
        id: lastName
        label: "Last name"
        width: firstName.width
        color: internals.colors.dark

        anchors.top: firstName.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Components.Button {
        id: confirmButton
        width: picture.width
        height: 70

        anchors.top: lastName.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter

        onClick: function() {
            console.log(firstName.inputComponent)
            var user = internals.addUser(
                firstName.text,
                lastName.text,
                profilePicture
            );

            if (!user) {
                return;
            }

            stack.pop();
        }

        Components.SquircleContainer {
            backgroundColor: internals.colors.light

            anchors.fill: parent

            Text {
                text: "Register"
                color: internals.colors.background

                font.family: "Inter"           
                font.pointSize: 15
                font.weight: Font.DemiBold

                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}