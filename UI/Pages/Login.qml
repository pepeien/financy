// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Components.Page {
    property bool _isDeleting: false

    title: "Login"

    leftButtonIcon: _isDeleting ? "qrc:/Icons/Close.svg" : "qrc:/Icons/Trash.svg" 
    leftButtonOnClick: function() {
        _isDeleting = !_isDeleting;
    }

    centerButtonIcon: "qrc:/Icons/Plus.svg"
    centerButtonOnClick: function() {
        stack.push("qrc:/Pages/UserCreate.qml");
    }

    ScrollView {
        width:  parent.width * 0.7
        height: parent.height

        anchors.top:              parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        ScrollBar.vertical: Components.ScrollBar {
            isVertical: true
        }

        ListView {
            id:      usersView
            spacing: 25

            anchors.fill: parent

            model:    internal.users
            delegate: Components.ButtonUser {
                width:        parent.width * 0.8
                contentWidth: (parent.width * 0.87) - _delete.width

                property var user: internal.users[index]

                onClick: function() {
                    internal.login(user);
    
                    stack.push("qrc:/Pages/UserHome.qml")
                }

                text:           user.getFullName()
                picture:        user.picture
                primaryColor:   user.primaryColor
                secondaryColor: user.secondaryColor

                Components.Button {
                    id:     _delete
                    height: parent.height
                    width:  0

                    states: State {
                        when: _isDeleting
                        PropertyChanges {
                            target: _delete
                            width: 70
                        }
                    }
                    transitions: Transition {
                        NumberAnimation {
                            properties: "width"
                            easing.type: Easing.InOutQuad
                        }
                    }

                    anchors.right: parent.right

                    backgroundColor: "#F2665A"
                    onClick: function() {
                        internal.removeUser(user.id);
                    }

                    Image {
                        id:                _icon
                        source:            "qrc:/Icons/Close.svg"
                        sourceSize.width:  parent.width * 0.4
                        sourceSize.height: parent.width * 0.4
                        antialiasing:      true
                        visible:           false

                        anchors.verticalCenter:   parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    ColorOverlay {
                        anchors.fill: _icon
                        source:       _icon
                        color:        "white"
                        antialiasing: true
                        visible:      _isDeleting
                    }
                }
            }
        }
    }
}
