// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

// Components
import "qrc:/Components" as Components

Item {
    default property alias data: content.data

    // Header
    property alias title:    header.title
    property alias onReturn: header.onReturn

    // Footer
    property alias leftButtonOnClick: footer.leftButtonOnClick
    property alias leftButtonIcon:    footer.leftButtonIcon

    property alias centerButtonOnClick: footer.centerButtonOnClick
    property alias centerButtonIcon:    footer.centerButtonIcon

    property alias rightButtonOnClick: footer.rightButtonOnClick
    property alias rightButtonIcon:   footer.rightButtonIcon

    Components.Header {
        id: header

        anchors.top:  parent.top
        anchors.left: parent.left
    }

    Item {
        id:     content
        height: parent.height - header.height - footer.height
        width:  parent.width

        anchors.top:       header.bottom
        anchors.left:      parent.left
    }

    Components.Footer {
        id: footer
    }
}