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
    property url profilePicture: "qrc:/Icons/Profile.svg"

    id: _root
    title: "Create User"

    Item {
        id:     _formPicture
        width:  parent.width * 0.6
        height: parent.height * 0.7

        anchors.left: parent.left

        Components.SquircleButton {
            id:              picture
            width:           256
            height:          256
            backgroundColor: internals.colors.foreground

            anchors.horizontalCenter: parent.horizontalCenter

            layer.enabled: true
            layer.effect:  OpacityMask {
                maskSource: Rectangle {
                    width:   picture.width
                    height:  picture.height
                    radius:  15
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

                _root.wasPictureSelected = true;
                _root.profilePicture     = result;

                var colors = internals.getUserColorsFromImage(result);

                _primaryColor.selectedColor   = colors[0];
                _secondaryColor.selectedColor = colors[1];
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
                id:     plusContainer
                width:  parent.width
                height: 60
                color:  internals.colors.light

                bottomLeftRadius:  15
                bottomRightRadius: 15

                anchors.bottom: parent.bottom

                Image {
                    id:                plusIcon
                    source:            "qrc:/Icons/Plus.svg"
                    sourceSize.width:  25
                    sourceSize.height: 25
                    antialiasing:      true
                    visible:           false

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                ColorOverlay {
                    anchors.fill: plusIcon
                    source:       plusIcon
                    color:        internals.colors.background
                    antialiasing: true
                }
            }
        }

        Components.Input {
            id:    firstName
            width: picture.width * 1.25

            label:     "First name"
            color:     internals.colors.dark
            minLength: 2
            maxLength: 20

            KeyNavigation.tab: lastName.input

            anchors.top:              picture.bottom
            anchors.topMargin:        30
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Components.Input {
            id:    lastName
            width: firstName.width

            label:     "Last name"
            color:     internals.colors.dark
            minLength: 2
            maxLength: 20

            anchors.top:              firstName.bottom
            anchors.topMargin:        30
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            id:    _colors
            width: lastName.width

            anchors.top:              lastName.bottom
            anchors.topMargin:        60
            anchors.horizontalCenter: parent.horizontalCenter

            Components.ColorPicker {
                id:              _primaryColor
                width:           (parent.width / 2) - 15
                height:          60
                selectedColor:   internals.colors.foreground
                label:           "Primary Color"

                anchors.left:           parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Components.ColorPicker {
                id:              _secondaryColor
                width:           _primaryColor.width
                height:          _primaryColor.height
                selectedColor:   internals.colors.light
                label:           "Secondary Color"

                anchors.left:           _primaryColor.right
                anchors.leftMargin:     30
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Item {
        id:     _preview
        width:  parent.width - _formPicture.width
        height: _formPicture.height

        anchors.left: _formPicture.right

        Components.SquircleContainer {
            // Props
            id:               _secondPreviewButton
            width:            parent.width * 0.9
            height:           parent.height
            backgroundColor:  internals.showcaseColors.background
            hasShadow:        true

            anchors.top:              parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id:    _secondPreviewTitle
                text:  "Preview"
                color: internals.showcaseColors.light

                font.family:    "Inter"           
                font.pointSize: 25
                font.weight:    Font.Normal

                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.topMargin:  parent.height * 0.05
                anchors.leftMargin: parent.width * 0.05
            }

            Components.Switch {
                id: _switch

                color:      internals.showcaseColors.light
                fill:       internals.showcaseColors.foreground
                isSwitched: internals.colorsTheme == Colors.Dark

                text: _switch.isSwitched ? "Dark" : "Light"
                width: 60

                anchors.top:         parent.top
                anchors.right:       parent.right
                anchors.topMargin:   parent.height * 0.05
                anchors.rightMargin: parent.width * 0.05

                onSwitch: function() {
                    internals.updateShowcaseTheme(
                        _switch.isSwitched ? Colors.Dark : Colors.Light
                    );
                }
            }

            Components.ButtonUser {
                width:  parent.width * 0.9

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter:   parent.verticalCenter

                // Props
                text:           firstName.text + "  " + lastName.text  
                picture:        profilePicture
                primaryColor:   _primaryColor.selectedColor
                secondaryColor: _secondaryColor.selectedColor
                hasShadow: true
            }
        }
    }

    Components.SquircleButton {
        width: parent.width / 1.5
        height: 70

        anchors.bottom:           parent.bottom
        anchors.bottomMargin:     parent.height * 0.065
        anchors.horizontalCenter: parent.horizontalCenter

        // Props
        backgroundColor: internals.colors.light

        onClick: function() {
            var user = internals.addUser(
                firstName.text,
                lastName.text,
                profilePicture,
                _primaryColor.selectedColor,
                _secondaryColor.selectedColor
            );

            if (!user) {
                return;
            }

            stack.pop();
        }

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