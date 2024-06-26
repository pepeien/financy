// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Components
import "qrc:/Components" as Components

Components.Popup {
    id: _date

    property alias title: _grid.title
    property alias month: _grid.month
    property alias year:  _grid.year

    property var selectedDate: new Date()

    background: Components.SquircleContainer {
        backgroundColor: Qt.lighter(internal.colors.foreground, 1.25)

        MouseArea {
            anchors.fill: parent

            onClicked: function() {
                _date.close();
            }
        }
    }

    GridLayout {
        id:      _gridRoot
        width:   parent.width * 0.9
        height:  parent.height * 0.9
        columns: 1

        anchors.centerIn: parent

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

                backgroundColor: isSelected ? internal.colors.light : "transparent"

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
                }
            }
        }
    }
}