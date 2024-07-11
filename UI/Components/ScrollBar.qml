import QtQuick
import QtQuick.Controls.Basic

ScrollBar {
    // Input
    required property bool isVertical

    readonly property bool _isActive: isVertical ? parent.contentHeight > parent.height : parent.contentWidth > parent.width

    id:           _scrollBar
    height:       isVertical ? parent.height : 8
    width:        isVertical ? 8 : parent.width
    wheelEnabled: true
    hoverEnabled: true
    active:       _isActive
    policy:       _isActive ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

    // Horizontal
    horizontalPadding: isVertical ? 0 : 5

    // Vertical
    verticalPadding: isVertical ? 5 : 0

    background: Item {}
    contentItem: Rectangle {
        radius: width / 2
        color:  _scrollBar.pressed ? internal.colors.light : internal.colors.dark

        // Horizontal
        anchors.verticalCenter: isVertical ? undefined : parent.verticalCenter

        // Vertical
        anchors.horizontalCenter: isVertical ? parent.horizontalCenter : undefined

        Behavior on color {
            ColorAnimation {
                easing.type: Easing.InOutQuad
            }
        }
    }

    // Horizontal
    anchors.bottom: isVertical ? undefined : parent.bottom
    anchors.left:   isVertical ? undefined : parent.left

    // Vertical
    anchors.top:         isVertical ? parent.top   : undefined
    anchors.right:       isVertical ? parent.right : undefined
    anchors.rightMargin: isVertical ? 5 : 0
}