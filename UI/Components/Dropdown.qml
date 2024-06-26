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

            hoverEnabled: true

            contentItem: Components.Text {
                text:              delegate.model[_control.textRole]
                color:             delegate.hovered ? internal.colors.background : internal.colors.dark
                font:              _control.font
                verticalAlignment: Text.AlignVCenter
                padding:           _root.textPadding
            }

            background: Components.Button {
                color: delegate.hovered ? internal.colors.light : "transparent"
                clip:  true

                anchors.fill: delegate
            }
        }

        indicator: Canvas {
            id:     canvas
            x:      _control.width - width - _control.rightPadding
            y:      _control.topPadding + (_root.itemHeight - height) / 2
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
                if (!context) {
                    return
                }

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

        background: Components.SquircleContainer {
            width:  _root.itemWidth
            height: _root.itemHeight
            clip:   true

            backgroundColor: _root.backgroundColor

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
            y:              _control.height + 10
            width:          _control.width
            padding:        0
            clip:           true

            contentItem: ListView {
                implicitHeight: contentHeight
                model:          _control.popup.visible ? _control.delegateModel : null
                currentIndex:   _control.highlightedIndex

                ScrollBar.vertical: Components.ScrollBar {
                    isVertical: true
                }
            }

            background: Components.SquircleContainer {
                backgroundColor:  internal.colors.foreground
                backgroundRadius: _root.radius
                hasShadow:        true
                clip:             true
            }

            enter: Transition {
                NumberAnimation {
                    property: "height"
                    from:     0
                    to:       Math.min(itemHeight * _control.model.length, 200)
                    duration: 100
                }
            }

            exit: Transition {
                NumberAnimation {
                    property: "height"
                    from:     Math.min(itemHeight * _control.model.length, 200)
                    to:       0
                    duration: 100
                }
            }
        }
    }
}