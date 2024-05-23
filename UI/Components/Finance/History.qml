// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtCharts
import QtQuick
import QtQuick.Controls.Basic

// Components
import "qrc:/Components" as Components

Item {
    // Input
    property var history: []

    // Output
    property var selectedHistory: history.length > 0 ? history[0] : undefined

    // Vars
    property var _points: []

    id: _root

    Component.onCompleted: function() {
        if (history.length <= 0) {
            return;
        }

        _chart.width = 200 * history.length

        let maxValue = 0;

        history.forEach((statement) => {
            if (statement.dueAmount <= maxValue) {
                return;
            }

            maxValue = statement.dueAmount;
        });

        let x = (_chart.width / history.length) / (_chart.width * 2)

        history.forEach((statement) => {
            const y = statement.dueAmount / (maxValue * 1.45);

            _historyLine.append(   x, y);
            _historyScatter.append(x, y);

            x += (_chart.width / history.length) / _chart.width;
        });
    }
  
    Item {
        id: _chartScroll

        width:  _root.width
        height: _root.height

        anchors.fill: parent

        ChartView {
            id:     _chart
            height: _root.height

            antialiasing:    true
            backgroundColor: "transparent"
            plotAreaColor:   "transparent"
            animationOptions: ChartView.SeriesAnimations

            legend.visible: false

            Behavior on x {
                PropertyAnimation {
                    easing.type: Easing.InOutQuad
                    duration:    200
                }
            }

            SplineSeries {
                id:    _historyLine
                color: internal.colors.foreground
                width: 2

                axisX: ValueAxis {
                    labelsVisible: false
                    gridVisible:   false
                    lineVisible:   false
                }
                axisY: ValueAxis {
                    labelsVisible: false
                    gridVisible:   false
                    lineVisible:   false
                }
            }

            ScatterSeries {
                id: _historyScatter

                markerSize:  30
                color:       "transparent"
                borderWidth: 2
                borderColor: "transparent"

                Component.onCompleted: function() {
                    for (let i = 0; i < history.length; i++) {
                        _months.model.push(_historyScatter.at(i));
                    }
                }

                axisX: ValueAxis {
                    labelsVisible: false
                    gridVisible:   false
                    lineVisible:   false
                }
                axisY: ValueAxis {
                    labelsVisible: false
                    gridVisible:   false
                    lineVisible:   false
                }
            }

            Repeater {
                id:    _months
                model: []

                delegate: Item  {
                    required property int index

                    readonly property var position: _chart.mapToPosition(_months.model[index], _historyScatter)

                    x: position.x
                    y: _chart.height - (_historyScatter.markerSize + 10)

                    Text {
                        id:    _text
                        text:  internal.getLongMonth(_root.history[index].date)
                        color: internal.colors.dark
                        
                        font.family:    "Inter"
                        font.pointSize: 9
                        font.weight:    Font.DemiBold

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter:   parent.verticalCenter
                    }

                    Rectangle {
                        width: _historyScatter.borderWidth
                        height: parent.y - position.y - (_historyScatter.markerSize / 2) - (_text.font.pointSize + 2)
                        color:  internal.colors.light
                        radius: width / 2

                        anchors.top: parent.top
                        anchors.topMargin: -height - _text.font.pointSize
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Repeater {
                id:    _values
                model: _months.model

                delegate: Item  {
                    required property int index

                    readonly property var position: _chart.mapToPosition(_values.model[index], _historyScatter)

                    x: position.x
                    y: position.y - _historyScatter.markerSize - 5

                    Text {
                        text:  _root.history[index].dueAmount.toFixed(2)
                        color: internal.colors.dark
                        
                        font.family:    "Inter"
                        font.pointSize: 12
                        font.weight:    Font.Bold

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter:   parent.verticalCenter
                    }
                }
            }

            Repeater {
                property int _selectedIndex: 0

                id:    _button
                model: _months.model

                delegate: Item  {
                    required property int index

                    readonly property var position: _chart.mapToPosition(_button.model[index], _historyScatter)

                    x: position.x - 15 - 1
                    y: position.y - 15 - 1

                    Components.Button {
                        readonly property var _data: _root.history[index]

                        width:  30
                        height: 30
                        radius: 15
                        color:  _data.date.toString() === _root.selectedHistory.date.toString() ? internal.colors.light : internal.colors.dark

                        onClick: function() {
                            if (index == _button._selectedIndex) {
                                return;
                            }

                            _chart.x += (_button._selectedIndex - index) * 100;

                            _root.selectedHistory = _data;
                            _button._selectedIndex = index;
                        }
                    }
                }
            }
        }
    }
}