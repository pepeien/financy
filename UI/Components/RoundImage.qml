import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Item {
    property alias imageSource: _image.source
    property alias imageWidth:  _image.sourceSize.width
    property alias imageHeight: _image.sourceSize.height
    property alias imageColor:  _mask.color
    property alias hasColor:    _mask.visible

    width:  _image.sourceSize.width
    height: _image.sourceSize.height

    Image {
        id:           _image
        width:        imageWidth
        height:       imageHeight
        fillMode:     Image.PreserveAspectCrop
        antialiasing: true

        anchors.verticalCenter: parent.verticalCenter

        layer.enabled: true
        layer.effect:  OpacityMask {
            maskSource: _mask
        }
    }

    Rectangle {
        id:      _mask
        width:   _image.sourceSize.width
        height:  _image.sourceSize.height
        radius:  _image.sourceSize.width / 2
        visible: false

        anchors.verticalCenter: parent.verticalCenter
    }
}