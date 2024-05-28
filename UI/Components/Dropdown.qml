// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls.Basic

// Components
import "qrc:/Components" as Components

Item {
    id: _root

    property real itemWidth:  100
    property real itemHeight: 40
    property real radius:     Math.min((itemHeight * 0.25), 9)

    property string backgroundColor: internal.colors.foreground

    property alias model: _control.model
    property alias label: _label.text

    // Output
    readonly property alias value: _control.currentValue

    // Vars
    readonly property real textPadding: 16

    width: _root.itemWidth

    ComboBox {
        id:     _control
        width:  _root.itemWidth

        font.family:    "Inter"
        font.pointSize: _root.itemHeight * 0.2
        font.weight:    Font.Normal

        delegate: ItemDelegate {
            required property var model
            required property int index

            id:     delegate
            height: _root.itemHeight
            width:  _root.itemWidth

            highlighted: _control.highlightedIndex === index

            contentItem: Components.Text {
                text:              delegate.model[_control.textRole]
                color:             internal.colors.dark
                font:              _control.font
                verticalAlignment: Text.AlignVCenter
                padding:           _root.textPadding
            }

            background: Components.SquircleButton {
                topLeftRadius:  index === 0 ? _root.radius : 0
                topRightRadius: index === 0 ? _root.radius : 0

                bottomLeftRadius:  index === (_control.model.length - 1) ? _root.radius : 0
                bottomRightRadius: index === (_control.model.length - 1) ? _root.radius : 0
            }
        }

        indicator: Canvas {
            id:     canvas
            x:      _control.width - width - _control.rightPadding
            y:      _control.topPadding + (_control.availableHeight - height) / 2
            width:  12
            height: 8

            contextType: "2d"

            Connections {
                target: _control
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

                context.fillStyle = internal.colors.dark

                context.fill();
            }
        }

        contentItem: Components.Text {
            padding:           _root.textPadding
            text:              _control.displayText
            font:              _control.font
            color:             internal.colors.dark
            elide:             Text.ElideRight

            anchors.top:       parent.top
            anchors.topMargin: _root.itemHeight * 0.1
        }

        background: Rectangle {
            color:          _root.backgroundColor
            implicitWidth:  _root.itemWidth
            implicitHeight: _root.itemHeight
            border.color:   "transparent"
            border.width:   0

            topLeftRadius:     _root.radius
            topRightRadius:    _root.radius
            bottomLeftRadius:  _control.popup.visible ? 0 : _root.radius
            bottomRightRadius: _control.popup.visible ? 0 : _root.radius

            Components.Text {
                id:     _label
                color:  internal.colors.dark
                text:   "Label"
                opacity: 0.77

                font.weight:    Font.Bold
                font.pointSize: Math.round(_control.font.pointSize * 0.65)

                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.topMargin:  _root.itemHeight * 0.1
                anchors.leftMargin: _root.textPadding
            }
        }

        popup: Popup {
            y:              _control.height + 1
            width:          _control.width
            implicitHeight: contentItem.implicitHeight
            padding:        0

            contentItem: ListView {
                implicitHeight: contentHeight
                model:          _control.popup.visible ? _control.delegateModel : null
                currentIndex:   _control.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator { }
            }

            enter: Transition {
                NumberAnimation {
                    property: "height"
                    from: 0
                    to: itemHeight * _control.model.length
                    duration: 100
                }
            }

            exit: Transition {
                NumberAnimation {
                    property: "height"
                    from: itemHeight * _control.model.length
                    to: 0
                    duration: 100
                }
            }

            background: Components.SquircleContainer {
                backgroundColor: internal.colors.background
                backgroundRadius: 0
                hasShadow: true

                backgroundBottomLeftRadius:  _root.radius
                backgroundBottomRightRadius: _root.radius
            }
        }
    }
}