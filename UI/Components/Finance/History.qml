// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtCharts
import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Item {
    property var account

    property var _points: []

    id: _root

    ScrollView {
        id:           _chartScroll
        anchors.fill: parent

        contentWidth:  _chart.width
        contentHeight: -1

        ChartView {
            id:     _chart
            height: _root.height

            antialiasing:    true
            backgroundColor: "transparent"
            plotAreaColor:   "transparent"
            animationOptions: ChartView.SeriesAnimations

            legend.visible: false

            Component.onCompleted: function() {
                if (!account) {
                    return;
                }

                const statements     = account.getHistory();
                const statementCount = statements.length;

                _chart.width = (_root.width / 3) * statementCount;

                let maxValue = 0;

                statements.forEach((statement) => {
                    if (statement.dueAmount <= maxValue) {
                        return;
                    }

                    maxValue = statement.dueAmount;
                });

                let x = 0.025;

                statements.forEach((statement) => {
                    const y = statement.dueAmount / (maxValue * 1.75);

                    _historyLine.append(   x, y);
                    _historyScatter.append(x, y);

                    x += 0.33 / (statementCount / 3.3);
                });
            }

            SplineSeries {
                id: _historyLine

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
                color:       internal.colors.light
                borderWidth: 0
                borderColor: "transparent"

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
        }
    }
}