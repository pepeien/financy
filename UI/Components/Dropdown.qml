// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls.Basic

// Components
import "qrc:/Components" as Components

ComboBox {
    // Props
    property real itemWidth:  120
    property real itemHeight: 40

    id: control

    delegate: ItemDelegate {
        required property var model
        required property int index

        id:     delegate
        height: control.itemHeight
        width:  control.itemWidth

        highlighted: control.highlightedIndex === index

        contentItem: Components.Text {
            text:              delegate.model[control.textRole]
            color:             internals.colors.dark
            font:              control.font
            verticalAlignment: Text.AlignVCenter
        }

        background: Components.SquircleButton {
            topLeftRadius:  index === 0 ? 4 : 0
            topRightRadius: index === 0 ? 4 : 0

            bottomLeftRadius:  index === (control.model.length - 1) ? 4 : 0
            bottomRightRadius: index === (control.model.length - 1) ? 4 : 0
        }
    }

    indicator: Canvas {
        id:     canvas
        x:      control.itemWidth - width - control.rightPadding
        y:      control.topPadding + (control.availableHeight - height) / 2
        width:  12
        height: 8

        contextType: "2d"

        Connections {
            target: control
            function onPressedChanged() {
                canvas.requestPaint();
            }
        }

        onPaint: {
            context.reset();

            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);

            context.closePath();
    
            context.fillStyle = internals.colors.dark

            context.fill();
        }
    }

    contentItem: Components.Text {
        leftPadding:  control.indicator.width + control.spacing
        rightPadding: control.indicator.width + control.spacing

        text:              control.displayText
        font:              control.font
        color:             internals.colors.dark
        verticalAlignment: Text.AlignVCenter
        elide:             Text.ElideRight
    }

    background: Rectangle {
        color:          internals.colors.background
        implicitWidth:  control.itemWidth
        implicitHeight: control.itemHeight
        border.color:   "transparent"
        border.width:   0

        topLeftRadius:     4
        topRightRadius:    4
        bottomLeftRadius:  control.popup.visible ? 0 : 4
        bottomRightRadius: control.popup.visible ? 0 : 4
    }

    popup: Popup {
        y:              control.height + 1
        width:          control.itemWidth
        implicitHeight: contentItem.implicitHeight
        padding:        0

        contentItem: ListView {
            implicitHeight: contentHeight
            model:          control.popup.visible ? control.delegateModel : null
            currentIndex:   control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        enter: Transition {
            NumberAnimation {
                property: "height"
                from: 0
                to: control.itemHeight * control.model.length
                duration: 100
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "height"
                from: control.itemHeight * control.model.length
                to: 0
                duration: 100
            }
        }

        background: Components.SquircleContainer {
            backgroundColor: internals.colors.background
            backgroundRadius: 0
            hasShadow: true

            backgroundBottomLeftRadius:  4
            backgroundBottomRightRadius: 4
        }
    }
}