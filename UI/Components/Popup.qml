// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Popup {
    default property alias data: content.data

    id:     _root
    width:  parent.width
    height: parent.height + headerComponent.height + footerComponent.height
    modal:  true
    y:      -headerComponent.height

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from:     0.0
            to:       1.0
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from:     1.0
            to:       0.0
        }
    }

    background: Components.SquircleContainer {
        backgroundColor:  Qt.rgba(0, 0, 0, 0.4)
        backgroundRadius: 0
    }

    Item {
        id: content

        anchors.fill: parent
    }

    Components.SquircleButton {
        width:  60
        height: 60

        backgroundColor: internal.colors.background

        anchors.bottom:           parent.bottom
        anchors.bottomMargin:     25
        anchors.horizontalCenter: parent.horizontalCenter

        onClick: function() {
            _root.close();
        }

        Image {
            id:                _icon
            source:           "qrc:/Icons/Close.svg"
            sourceSize.width:  parent.width * 0.5
            sourceSize.height: parent.height * 0.5
            antialiasing:      true
            visible:           false

            anchors.verticalCenter:   parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColorOverlay {
            anchors.fill: _icon
            source:       _icon
            color:        internal.colors.light
            antialiasing: true
        }
    }
}