import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Components.Page {
    property bool _isDeleting: false
    property var _deletingUser

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
        height: parent.height * 0.9
        clip:   true

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
                    internal.login(user.id);
    
                    stack.push("qrc:/Pages/UserHome.qml")
                }

                onHover: function(inMouseArea) {
                    if (_isDeleting) {
                        inMouseArea.cursorShape = Qt.ArrowCursor;

                        return;
                    }

                    inMouseArea.cursorShape = Qt.PointingHandCursor;
                    opacity = 0.7;
                }

                onLeave: function(inMouseArea) {
                    if (_isDeleting) {
                        inMouseArea.cursorShape = Qt.ArrowCursor;

                        return;
                    }

                    inMouseArea.cursorShape = Qt.ArrowCursor;
                    opacity = 1;
                }

                text:           user?.getFullName() ?? ""
                picture:        user?.picture ?? ""
                primaryColor:   user?.primaryColor ?? ""
                secondaryColor: user?.secondaryColor ?? ""

                Components.Button {
                    id:     _delete
                    height: parent.height
                    width:  0

                    onHover: function(inMouseArea) {
                        if (!_isDeleting) {
                            return;
                        }

                        inMouseArea.cursorShape = Qt.PointingHandCursor;
                        opacity = 0.7;
                    }

                    onLeave: function(inMouseArea) {
                        if (!_isDeleting) {
                            return;
                        }

                        inMouseArea.cursorShape = Qt.ArrowCursor;
                        opacity = 1;
                    }

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
                        _isDeleting   = false;
                        _deletingUser = user;

                        _deletionPopup.open();
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

    Components.Modal {
        id: _deletionPopup

        Components.SquircleContainer {
            width:  670
            height: 180

            hasShadow:       true
            backgroundColor: Qt.lighter(internal.colors.background, 0.965)

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter

            Components.Text {
                id:    _title
                color: internal.colors.dark
                text:  "You're about to delete the user " + _deletingUser?.getFullName().trim() ?? "NULL" + " , are you sure?"

                font.pointSize: 15
                font.weight:    Font.Bold

                anchors.top:              parent.top
                anchors.topMargin:        10
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Components.Text {
                id:    _disclaimer
                color: internal.colors.light
                text:  "This action cannot be reversed"

                font.pointSize: 12
                font.weight:    Font.Normal

                anchors.top:              _title.bottom
                anchors.topMargin:        15
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Components.SquircleButton {
                id:     _submitButton
                width:  parent.width * 0.45
                height: 60

                backgroundColor: internal.colors.dark

                anchors.bottom:           parent.bottom
                anchors.bottomMargin:     25
                anchors.horizontalCenter: parent.horizontalCenter

                onClick: function() {
                    internal.deleteUser(_deletingUser.id);

                    _deletionPopup.close();

                    _deletingUser = undefined;
                }

                Components.Text {
                    text:  "Delete"
                    color: internal.colors.background

                    font.weight:    Font.Bold
                    font.pointSize: 15

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter:   parent.verticalCenter
                }
            }
        }
    }
}
