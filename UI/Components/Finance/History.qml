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
    property var selectedHistory: undefined
    property int selectedIndex:   0

    // Vars
    property var _points: []
    property var _now:     new Date()

    id: _root

    Component.onCompleted: function() {
        if (history.length <= 0) {
            return;
        }

        _chart.width = 200 * history.length

        let maxValue = 0;

        history.forEach((statement, index) => {
            const date = statement.date;

            if (date.getUTCMonth() === _now.getUTCMonth() && date.getUTCFullYear() === _now.getUTCFullYear()) {
                selectedHistory = statement;
                selectedIndex   = index;
            }
            
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

            function centerOn(point) {
                _chart.x = ((_chartScroll.width / 2) - point.x) - ((_chart.width / history.length) / (_chart.width * 2)) - 50;
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

                    _chart.centerOn(_chart.mapToPosition(_months.model[_root.selectedIndex], _historyScatter));
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

                delegate: Item {
                    required property int index

                    readonly property var _position: _chart.mapToPosition(_months.model[index], _historyScatter)
                    readonly property var _data:     _root.history[index]

                    property bool _isSelected: _root.selectedHistory ? _data.date.toString() === _root.selectedHistory.date.toString() : false
                    property bool _isFuture:   _data.date > _root._now

                    x: _position.x
                    y: _position.y

                    height: Math.abs(_chartScroll.height - _position.y)

                    Components.Button {
                        id:           _point
                        x:            -(_historyScatter.markerSize / 2) - 1
                        y:            -(_historyScatter.markerSize / 2) - 1
                        width:        _historyScatter.markerSize
                        height:       _historyScatter.markerSize
                        radius:       _historyScatter.markerSize / 2
                        color:        _isSelected ? internal.colors.light : _isFuture ? internal.colors.background : internal.colors.dark
                        border.width: _isFuture ? _isSelected ? 0 : _historyScatter.borderWidth : 0
                        border.color: _isFuture ? internal.colors.foreground : "transparent"

                        onClick: function() {
                            if (_isSelected) {
                                return;
                            }

                            _chart.centerOn(_position);

                            _root.selectedHistory = _data;
                            _root.selectedIndex   = index;
                        }
                    }

                    Text {
                        id:    _dueAmount
                        text:  _data.dueAmount.toFixed(2)
                        color: internal.colors.dark

                        font.family:    "Inter"
                        font.pointSize: 12
                        font.weight:    Font.Bold

                        anchors.bottom:           _point.top
                        anchors.bottomMargin:     10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        id:     _line
                        width:  _isSelected ? _historyScatter.borderWidth * 2 : _historyScatter.borderWidth
                        height: Math.max(0, (_text.y - _point.y) - _historyScatter.markerSize - _text.font.pointSize)
                        color:  _isFuture ? internal.colors.light : _point.color
                        radius: _line.width / 2

                        Component.onCompleted: function() {
                            color: Qt.rgba(color.r, color.g, color.b, _isFuture ? 125 : 255);
                        }

                        anchors.top:              _point.bottom
                        anchors.topMargin:        _text.font.pointSize / 2
                        anchors.horizontalCenter: parent.horizontalCenter

                        Behavior on width {
                            PropertyAnimation {
                                easing.type: Easing.InOutQuad
                                duration:    200
                            }
                        }
                    }

                    Text {
                        id:    _text
                        text:  internal.getLongMonth(_data.date)
                        color: internal.colors.dark

                        font.family:    "Inter"
                        font.pointSize: 9
                        font.weight:    Font.DemiBold

                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: _point.horizontalCenter
                    }
                }
            }
        }
    }
}