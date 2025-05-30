import QtQuick
import Qt5Compat.GraphicalEffects

// Types
import Financy.Types 1.0

// Components
import "qrc:/Components" as Components

Components.Page {
    readonly property var user: internal.selectedUser

    property var profilePicture:  ""
    
    readonly property bool _wasPictureSelected: profilePicture !== ""

    id:    _root
    title: "Edit"

    centerButton.isDisabled: firstName.hasError
    centerButtonIcon: "qrc:/Icons/Check.svg"
    centerButtonOnClick: function() {
        if (centerButton.isDisabled) {
            return;
        }

        internal.editUser(
            user.id,
            firstName.text,
            lastName.text,
            income.text,
            profilePicture,
            _primaryColor.picker.color,
            _secondaryColor.picker.color
        );

        user.onEdit();

        stack.pop();
    }

    Component.onCompleted: function() {
        if (!user) {
            return;
        }

        _root.profilePicture  = user.picture;
    }

    Item {
        id:     _formPicture
        width:  parent.width * 0.6
        height: parent.height

        anchors.left: parent.left

        Components.SquircleButton {
            id:              picture
            width:           256
            height:          256
            backgroundColor: internal.colors.foreground

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
                var result = internal.openFileDialog(
                    "Select Profile Picture",
                    "jpg;jpeg;png"
                );

                if (result === "")
                {
                    return;
                }

                _root.profilePicture = result;

                var colors = internal.getUserColorsFromImage(result);

                _primaryColor.color   = colors[0];
                _secondaryColor.color = colors[1];
            }

            Image {
                id:                icon
                source:            _root._wasPictureSelected ? profilePicture : "qrc:/Icons/Profile.svg" 
                sourceSize.width:  _root._wasPictureSelected ? picture.width : picture.width * 0.5 
                sourceSize.height: _root._wasPictureSelected ? picture.height : picture.height * 0.5 
                antialiasing:      true
                fillMode:          Image.PreserveAspectCrop

                anchors.top:              parent.top
                anchors.topMargin:        _root._wasPictureSelected ? -plusContainer.height / 2 : 40
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                id:     plusContainer
                width:  parent.width
                height: 60
                color:  internal.colors.dark

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
                    color:        internal.colors.background
                    antialiasing: true
                }
            }
        }

        Components.Input {
            id:    firstName
            width: picture.width * 1.25
            text:  user?.firstName ?? ""

            label:     "First name"
            color:     internal.colors.dark
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
            text:  user?.lastName ?? ""

            label:      "Last name"
            color:      internal.colors.dark
            minLength:  2
            maxLength:  20
            isRequired: false

            anchors.top:              firstName.bottom
            anchors.topMargin:        10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Components.Input {
            id:    income
            width: firstName.width
            text:  user?.income ? user?.income.toFixed(2) : 0

            label:      "Income"
            color:      internal.colors.dark
            isRequired: true

            validator: DoubleValidator {
                locale: "en"
                bottom: 0.1
                decimals: 2
            }

            anchors.top:              lastName.bottom
            anchors.topMargin:        10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            id:    _colors
            width: lastName.width

            anchors.top:              income.bottom
            anchors.topMargin:        40
            anchors.horizontalCenter: parent.horizontalCenter

            Components.ColorPicker {
                id:     _primaryColor
                width:  (parent.width / 2) - 15
                height: 60
                color:  user?.primaryColor ?? internal.colors.foreground
                label:  "Primary Color"

                anchors.left:           parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Components.ColorPicker {
                id:     _secondaryColor
                width:  _primaryColor.width
                height: _primaryColor.height
                color:  user?.secondaryColor ?? internal.colors.dark
                label:  "Secondary Color"

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
            backgroundColor:  internal.showcaseColors.background
            hasShadow:        true

            anchors.top:              parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            Components.Text {
                id:    _secondPreviewTitle
                text:  "Preview"
                color: internal.showcaseColors.light

                font.family:    "Inter"           
                font.pointSize: 25
                font.weight:    Font.Normal

                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.topMargin:  parent.height * 0.06
                anchors.leftMargin: parent.width * 0.05
            }

            Components.Switch {
                id: _switch

                color: internal.showcaseColors.light
                fill:  internal.showcaseColors.foreground
                width: 60

                labelText:    _switch.isSwitched ? "Dark" : "Light"

                buttonHeight: 28

                isSwitched:   internal.colorsTheme == Colors.Dark

                anchors.top:         parent.top
                anchors.right:       parent.right
                anchors.topMargin:   parent.height * 0.03
                anchors.rightMargin: parent.width * 0.05

                onSwitch: function() {
                    internal.updateShowcaseTheme(
                        _switch.isSwitched ? Colors.Dark : Colors.Light
                    );
                }
            }

            Components.ButtonUser {
                id:    _previewButton
                width: parent.width * 0.9

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter:   parent.verticalCenter

                // Props
                text:           firstName.text + "  " + lastName.text  
                picture:        profilePicture
                primaryColor:   _primaryColor.picker.currentColor
                secondaryColor: _secondaryColor.picker.currentColor
                hasShadow:      true
            }
        }
    }
}