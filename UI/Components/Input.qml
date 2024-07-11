import QtQuick
import QtQuick.Controls

// Components
import "qrc:/Components" as Components

Item {
    // Value Props
    property int minLength: 0
    property int maxLength: 0

    property bool isRequired: true
    property bool hasError: false

    property real inputHeight: 60

    property var onInput

    // Alias Props
    property alias color:     _input.color
    property alias text:      _input.text
    property alias validator: _input.validator
    property alias mask:      _input.inputMask
    property alias label:     inputLabel.text
    property alias hint:      inputHint.text

    default property alias data: _inputContainer.data

    // Out Props
    readonly property var input: _input

    // Out Methods
    function set(text) {
        _input.clear();
        _input.insert(0, text);
    }

    function clear() {
        _input.clear();
        _input._onInput();
    }

    // Vars
    readonly property real textPadding: 16
    readonly property bool hasStatus:   root.minLength > 0 || root.maxLength > 0
    readonly property bool hasHint:     inputHint.text.length > 0

    id:     root
    width:  120 + root.textPadding
    height: root.inputHeight + 20

    Component.onCompleted: function() {
        _input._onInput();
    }

    Components.SquircleContainer {
        id:     _inputContainer
        height: root.inputHeight
        width:  root.width
        clip:   true

        backgroundColor: internal.colors.foreground

        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            id:          inputLabel
            color:       _input.color
            leftPadding: textPadding
            opacity:     0.77

            font.family:    _input.font.family
            font.pointSize: _input.font.pointSize
            font.weight:    Font.Bold

            anchors.verticalCenter: parent.verticalCenter

            Component.onCompleted: function() {
                if (!root.isRequired) {
                    return;
                }

                inputLabel.text = inputLabel.text.trim() + "*";
            }

            states: [
                State {
                    when: _input.activeFocus || _input.text !== ""
                    AnchorChanges {
                        target: inputLabel

                        anchors.verticalCenter: undefined
                        anchors.top:            parent.top
                    }
                    PropertyChanges {
                        target: inputLabel

                        font.pointSize: Math.round(_input.font.pointSize * 0.65)
                        topPadding:     4
                    }
                }
            ]

            transitions: [
                Transition {
                    AnchorAnimation {
                        duration: 200
                    }

                    NumberAnimation {
                        duration: 200
                        property: "font.pointSize"
                    }

                    NumberAnimation {
                        duration: 200
                        property: "topPadding"
                    }
                }
            ]
        }

        TextInput {
            id:            _input
            height:        parent.height
            width:         parent.width - (root.textPadding * 2)
            text:          ""
            maximumLength: root.maxLength > 0 ? root.maxLength : -1

            verticalAlignment: TextInput.AlignVCenter

            font.family:    "Inter"           
            font.pointSize: Math.round(root.inputHeight * 0.2)
            font.weight:    Font.Normal

            anchors.left:           parent.left
            anchors.leftMargin:     root.textPadding
            anchors.verticalCenter: parent.verticalCenter

            function _onInput() {
                const isTextWithinSizes  = _input.text.length >= root.minLength;
                const isTextEmpty        = root.isRequired ? _input.text.trim() === "" : false;

                root.hasError = isTextEmpty || isTextWithinSizes == false || _input.acceptableInput == false;
            }

            onTextEdited: function() {
                _input._onInput();

                if (!root.onInput) {
                    return;
                }

                root.onInput();
            }
        }
    }

    Item {
        id:      _lengthStatus
        visible: root.hasStatus
        opacity: 0.7

        anchors.top:          _inputContainer.bottom
        anchors.right:        _inputContainer.right
        anchors.topMargin: 5
        anchors.rightMargin:  _lenghtMin.contentWidth + _lenghtMax.contentWidth + 5

        Components.Text {
            id:           _lenghtMin
            text:         _input.text.length > root.minLength ? _input.text.length  : _input.text.length - root.minLength
            color:        _input.color
            antialiasing: true

            font.pointSize: 8
            font.weight:    Font.Bold
        }

        Components.Text {
            id:           _lenghtMax
            text:         "/ " + root.maxLength
            color:        _lenghtMin.color
            antialiasing: true

            anchors.left:       _lenghtMin.right
            anchors.leftMargin: 2

            font.family:    _lenghtMin.font.family
            font.pointSize: _lenghtMin.font.pointSize
            font.weight:    _lenghtMin.font.weight
        }
    }

    Components.Text {
        id:      inputHint
        visible: root.hasHint
        color:   _input.color
        opacity: inputLabel.opacity

        font.family:    _input.font.family
        font.pointSize: 8
        font.weight:    Font.Bold

        anchors.top:        _inputContainer.bottom
        anchors.left:       _inputContainer.left
        anchors.topMargin:  5
        anchors.leftMargin: 5
    }
}