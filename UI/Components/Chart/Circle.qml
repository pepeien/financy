// ByteBau (Jörn Buchholz) @bytebau.com
// PATCH [Pepeien]:
//     - Added rounded ends;
//     - Campled lines start & and angles [0, 360];

import QtQuick 2.0
import QtQml 2.2

Item {
    id: root

    width: size
    height: size

    property int size:               200             
    property real arcBegin:          0          
    property real arcEnd:            270          
    property real arcOffset:         0         
    property bool isPie:             false         
    property bool showBackground:    false
    property real lineWidth:         20        
    property string colorCircle:     internal.colors.background
    property string colorBackground: internal.colors.foreground

    property alias beginAnimation: animationArcBegin.enabled
    property alias endAnimation:   animationArcEnd.enabled

    property int animationDuration: 200

    onArcBeginChanged:        canvas.requestPaint()
    onArcEndChanged:          canvas.requestPaint()
    onColorCircleChanged:     canvas.requestPaint()
    onColorBackgroundChanged: canvas.requestPaint()

    Behavior on arcBegin {
       id: animationArcBegin
       enabled: true
       NumberAnimation {
           duration:    root.animationDuration
           easing.type: Easing.InOutCubic
       }
    }

    Behavior on arcEnd {
       id: animationArcEnd
       enabled: true
       NumberAnimation {
           duration:    root.animationDuration
           easing.type: Easing.InOutCubic
       }
    }

    Canvas {
        id:           canvas
        anchors.fill: parent
        rotation:     -90 + parent.arcOffset
        antialiasing: true

        onPaint: function() {
            const ctx   = getContext("2d");
            const x     = width / 2;
            const y     = height / 2;
            const start = Math.PI * (Math.min(Math.max(parent.arcBegin, 0), 360) / 180);
            const end   = Math.PI * (Math.min(Math.max(parent.arcEnd,   0), 360) / 180);

            ctx.reset();

            if (root.isPie) {
                if (root.showBackground) {
                    ctx.beginPath();

                    ctx.fillStyle = root.colorBackground;

                    ctx.moveTo(x, y);
                    ctx.arc(x, y, width / 2, 0, Math.PI * 2, false);
                    ctx.lineTo(x, y);
                    ctx.fill();
                }

                ctx.beginPath();

                ctx.fillStyle = root.colorCircle;

                ctx.moveTo(x, y);
                ctx.arc(x, y, width / 2, start, end, false);
                ctx.lineTo(x, y);
                ctx.fill();
            } else {
                if (root.showBackground) {
                    ctx.beginPath();

                    ctx.arc(x, y, (width / 2) - (parent.lineWidth / 2), 0, Math.PI * 2, false);

                    ctx.lineWidth   = root.lineWidth * 0.6;
                    ctx.strokeStyle = root.colorBackground;

                    ctx.stroke();
                }

                ctx.beginPath();

                ctx.arc(x, y, (width / 2) - (parent.lineWidth / 2), start, end, false);

                ctx.lineWidth   = root.lineWidth;
                ctx.strokeStyle = root.colorCircle;
                ctx.lineCap     = "round";

                ctx.stroke();
            }
        }
    }
}