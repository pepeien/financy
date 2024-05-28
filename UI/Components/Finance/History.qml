// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtCharts
import QtQuick
import QtQuick.Controls.Basic

// Components
import "qrc:/Components" as Components

Item {
    id: _root

    // Input
    property var history: []

    property var onSelectedHistoryUpdate

    // Output
    property var selectedHistory: undefined
    property int selectedIndex:   0

    // Vars
    property var _points: []
    property var _now:     internal.addMonths(new Date(), 1)

    readonly property var _xAxis: ValueAxis {
        labelsVisible: false
        gridVisible:   false
        lineVisible:   false
    }
    readonly property var _yAxis: ValueAxis {
        labelsVisible: false
        gridVisible:   false
        lineVisible:   false
    }

    property var _historyLine
    property var _historyScatter

    function select(index) {
        _root.selectedHistory = _root.history[index];
        _root.selectedIndex   = index;

        _chart.centerOn(
            _chart.mapToPosition(
                _months.model[_root.selectedIndex],
                _historyScatter
            )
        );

        if (!_root.onSelectedHistoryUpdate) {
            return;
        }

        _root.onSelectedHistoryUpdate();
    }

    function refresh() {
        if (_root.history.length <= 0) {
            return;
        }

        _root._createChart();

        let x = (_chart.width / _root.history.length) / (_chart.width * 2);
        let y = 0;

        const maxValue = _root.history.sort((a, b) => b.dueAmount - a.dueAmount)[0].dueAmount;
        _root.history.forEach((statement, index) => {
            y = statement.dueAmount / (maxValue * 1.45);

            _historyLine.append(   x, y);
            _historyScatter.append(x, y);

            _months.model.push(_historyLine.at(index));

            x += (_chart.width / _root.history.length) / _chart.width;
        });

        this._centerOnCurrentStatement();
    }

    function _createChart() {
        _months.model = [];
        _root._points = [];

        if (_root.history.length <= 0) {
            return;
        }

        _root.selectedIndex   = 0;
        _root.selectedHistory = _root.history[0];

        _chart.removeAllSeries();
        _chart.width = 200 * _root.history.length;

        // Line
        _historyLine = _chart.createSeries(
            ChartView.SeriesTypeSpline,
            "Line",
            _root._xAxis,
            _root._yAxis
        );
        _historyLine.color = internal.colors.foreground;
        _historyLine.width = 2;

        // Scatter
        _historyScatter = _chart.createSeries(
            ChartView.SeriesTypeScatter,
            "Scatter",
            _root._xAxis,
            _root._yAxis
        );
        _historyScatter.markerSize  = 30;
        _historyScatter.color       = "transparent";
        _historyScatter.borderWidth = 2;
        _historyScatter.borderColor = "transparent";
    }

    function _centerOnCurrentStatement() {
        const currentIndex = _root.history.findIndex((statement) => {
            const date = statement.date;

            return date.getUTCMonth() === _root._now.getUTCMonth() && date.getUTCFullYear() === _root._now.getUTCFullYear();
        });

        _root.select(currentIndex);
    }

    Component.onCompleted: function() {
        _root.refresh();
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

                            _root.select(index);
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
                        color:  _isFuture ? _isSelected ? _point.color : _point.border.color : _point.color
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