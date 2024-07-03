// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

Components.Popup {
    id: _date

    property alias title: _grid.title
    property alias month: _grid.month
    property alias year:  _grid.year

    property var selectedDate: new Date()

    property var onSelect

    function set(date) {
        selectedDate = date;

        _grid.month = date.getMonth();
        _grid.year  = date.getFullYear();
    }

    background: Components.SquircleContainer {
        backgroundColor: Qt.lighter(internal.colors.foreground, 1.1)
        hasShadow:       true
    }

    GridLayout {
        id:      _gridRoot
        width:   parent.width * 0.9
        height:  parent.height * 0.9
        columns: 1

        anchors.centerIn: parent

        Components.SquircleContainer {
            height: 30

            backgroundColor: internal.colors.dark

            Layout.fillWidth: true

            Components.SquircleButton {
                width:  parent.height
                height: parent.height

                anchors.left: parent.left

                onClick: function() {
                    const date = new Date();
                    date.setMonth(   _grid.month);
                    date.setFullYear(_grid.year);

                    const newDate = internal.addMonths(date, -1);

                    _grid.month = newDate.getMonth();
                    _grid.year  = newDate.getFullYear();
                }

                Image {
                    id:                _backIcon
                    source:            "qrc:/Icons/Back.svg"
                    sourceSize.width:  parent.height * 0.4
                    sourceSize.height: parent.height * 0.4
                    antialiasing:      true

                    anchors.verticalCenter:   parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    ColorOverlay {
                        anchors.fill: _backIcon
                        source:       _backIcon
                        color:        _dateText.color
                        antialiasing: true
                    }
                }
            }

            Components.Text {
                id:    _dateText
                color: internal.colors.background
                text:  `${_grid.locale.monthName(_grid.month)} ${_grid.year}`

                font.pointSize: 10
                font.weight:    Font.Bold

                anchors.centerIn: parent
            }
            
            Components.SquircleButton {
                width:  parent.height
                height: parent.height

                anchors.right: parent.right

                onClick: function() {
                    const date = new Date();
                    date.setMonth(   _grid.month);
                    date.setFullYear(_grid.year);

                    const newDate = internal.addMonths(date, 1);

                    _grid.month = newDate.getMonth();
                    _grid.year  = newDate.getFullYear();
                }

                Image {
                    id:                _forwardIcon
                    source:            "qrc:/Icons/Back.svg"
                    sourceSize.width:  parent.height * 0.4
                    sourceSize.height: parent.height * 0.4
                    antialiasing:      true
                    transformOrigin:   Item.Center
                    rotation:          180

                    anchors.verticalCenter:   parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    ColorOverlay {
                        anchors.fill: _forwardIcon
                        source:       _forwardIcon
                        color:        _dateText.color
                        antialiasing: true
                    }
                }
            }
        }

        DayOfWeekRow {
            locale: _grid.locale

            Layout.fillWidth: true

            delegate: Components.Text {
                required property string shortName

                text:  shortName
                color: internal.colors.dark

                font.weight: Font.DemiBold

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
            }
        }

        MonthGrid {
            id:     _grid
            locale: Qt.locale("en_US")

            Layout.fillWidth:  true
            Layout.fillHeight: true

            delegate: Components.SquircleButton {
                required property var model

                property bool isSelected: internal.isSameDate(model.date, _date.selectedDate)

                width:  _gridRoot.width * 0.14
                height: _gridRoot.width * 0.14

                isDisabled:           model.month !== _grid.month
                disableWillOverwrite: false
                backgroundColor:      isSelected ? internal.colors.light : "transparent"

                Components.Text {
                    color:   internal.colors.dark
                    opacity: model.month === _grid.month ? 1 : 0.25
                    text:    model.day

                    anchors.centerIn: parent
                }

                onClick: function() {
                    if (model.month !== _grid.month) {
                        return;
                    }
 
                    _date.selectedDate = model.date;

                    _date.close();

                    if (!_date.onSelect) {
                        return;
                    }

                    _date.onSelect(model.date);
                }
            }
        }
    }
}