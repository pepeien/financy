import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Components
import "qrc:/Components" as Components

ScrollView {
    readonly property real _padding:       35
    readonly property real _actionsHeight: 35

    property var user
    property int filterUserId: -1
    property bool isEditing:   false

    property var onDelete
    property var onEdit

    property alias model: _grid.model

    id:            _scroll
    width:         parent.width
    height:        parent.height - (_padding * 2)
    clip:          true
    bottomPadding: _padding

    contentHeight: (_scroll.isEditing ? (110 + _scroll._actionsHeight) : 110) * model.length / 2
    contentWidth:  -1

    ScrollBar.vertical: Components.ScrollBar {
        isVertical: true
    }

    GridView {
        id:     _grid
        width:  _scroll.width - _scroll._padding
        height: _scroll.height

        anchors.horizontalCenter: parent.horizontalCenter

        cellHeight: _scroll.isEditing ? (110 + _scroll._actionsHeight) : 110
        cellWidth:  _grid.width / 2

        delegate: Item {
            readonly property var _item:           _grid.model[index]
            readonly property real _ultilization:  _item.usedLimit / _item.limit

            function _canEdit() {
                return _scroll.isEditing && _item.isOwnedBy(_scroll.user.id);
            }

            id:     _root
            height: _grid.cellHeight
            width:  _grid.cellWidth

            Behavior on height {
                PropertyAnimation {
                    easing.type: Easing.InOutQuad
                    duration:    50
                }
            }

            Components.FinanceAccountItem {
                id:     _account
                height: _scroll.isEditing ? _root.height - (_scroll._padding / 2) - _actions.height : _root.height - (_scroll._padding / 2)
                width:  _root.width - _scroll._padding

                anchors.right:       index % 2 == 0 ? parent.right : undefined
                anchors.rightMargin: index % 2 == 0 ? (_scroll._padding / 4) : 0

                anchors.left:       index % 2 != 0 ? parent.left : undefined
                anchors.leftMargin: index % 2 != 0 ? (_scroll._padding / 4) : 0

                backgroundColor: _item.primaryColor
                textColor:       _item.secondaryColor

                title:     _item.name
                limit:     _item.limit
                usedLimit: _item.usedLimit
                dueAmount: _item.getDueAmount(filterUserId)

                backgroundBottomLeftRadius:  _scroll.isEditing ? 0 : Math.min((height * 0.25), 9)
                backgroundBottomRightRadius: _scroll.isEditing ? 0 : Math.min((height * 0.25), 9)

                Behavior on height {
                    PropertyAnimation {
                        easing.type: Easing.InOutQuad
                        duration:    50
                    }
                }
    
                onClick: function() {
                    if (_scroll.isEditing) {
                        return;
                    }

                    internal.select(_item.id);

                    stack.push("qrc:/Pages/UserAccountHome.qml");
                }

                onHover: function(inMouseArea) {
                    if (_scroll.isEditing) {
                        inMouseArea.cursorShape = Qt.ArrowCursor;

                        return;
                    }

                    opacity = 0.7;
                }

                onLeave: function(inMouseArea) {
                    if (_scroll.isEditing) {
                        inMouseArea.cursorShape = Qt.ArrowCursor;

                        return;
                    }

                    opacity = 1;
                }
            }

            Components.SquircleContainer {
                id:      _actions
                width:   _account.width
                height:  _scroll.isEditing ? _scroll._actionsHeight : 0
                visible: _scroll.isEditing
                clip:    true

                backgroundTopLeftRadius:  0
                backgroundTopRightRadius: 0
                backgroundColor:          internal.colors.dark

                anchors.top:              _account.bottom
                anchors.topMargin:        -1
                anchors.horizontalCenter: _account.horizontalCenter

                Behavior on visible {
                    PropertyAnimation {
                        easing.type: Easing.InOutQuad
                        duration:    10
                    }
                }

                Behavior on height {
                    PropertyAnimation {
                        easing.type: Easing.InOutQuad
                        duration:    50
                    }
                }

                Components.Button {
                    id:      _moreEditButton
                    width:   parent.width * 0.5
                    height:  parent.height
                    visible: _root._canEdit()

                    anchors.top:  parent.top
                    anchors.left: parent.left

                    onHover: function(inMouseArea) {
                        if (!_root._canEdit()) {
                            inMouseArea.cursorShape = Qt.ArrowCursor;

                            return;
                        }

                        opacity = 0.7;
                    }

                    onLeave: function(inMouseArea) {
                        if (!_root._canEdit()) {
                            inMouseArea.cursorShape = Qt.ArrowCursor;

                            return;
                        }

                        opacity = 1;
                    }

                    onClick: function() {
                        if (!_root._canEdit() || !_scroll.onEdit) {
                            return;
                        }

                        _scroll.onEdit(_item);
                    }

                    Image {
                        id:                _editIcon
                        source:            "qrc:/Icons/Edit.svg"
                        sourceSize.width:  parent.height * 0.5
                        sourceSize.height: parent.height * 0.5
                        antialiasing:      true
                        visible:           false

                        anchors.right:          _editText.left
                        anchors.rightMargin:    5
                        anchors.verticalCenter: _editText.verticalCenter
                    }

                    ColorOverlay {
                        anchors.fill: _editIcon
                        source:       _editIcon
                        color:        _editText.color
                        antialiasing: true
                    }

                    Components.Text {
                        id:    _editText
                        text:  "Edit"
                        color: internal.colors.background

                        font.weight: Font.DemiBold

                        anchors.right:          parent.right
                        anchors.rightMargin:    (parent.width * 0.5) - _editText.paintedWidth - 2
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    id:      _separator
                    width:   1
                    height:  parent.height
                    color:   _editText.color
                    visible: _root._canEdit()

                    anchors.left: _moreEditButton.right
                }

                Components.Button {
                    id:     _moreDeleteButton
                    width:  _root._canEdit() ? _moreEditButton.width : parent.width
                    height: parent.height

                    anchors.top:         parent.top
                    anchors.right:       parent.right

                    onHover: function(inMouseArea) {
                        if (!_scroll.isEditing) {
                            inMouseArea.cursorShape = Qt.ArrowCursor;

                            return;
                        }

                        opacity = 0.7;
                    }

                    onLeave: function(inMouseArea) {
                        if (!_scroll.isEditing) {
                            inMouseArea.cursorShape = Qt.ArrowCursor;

                            return;
                        }

                        opacity = 1;
                    }

                    onClick: function() {
                        if (!_scroll.isEditing || !_scroll.onDelete) {
                            return;
                        }

                        _scroll.onDelete(_item);
                    }

                    Image {
                        id:                _deleteIcon
                        source:            "qrc:/Icons/Trash.svg"
                        sourceSize.width:  parent.height * 0.6
                        sourceSize.height: parent.height * 0.6
                        antialiasing:      true
                        visible:           false

                        anchors.right:          _deleteText.left
                        anchors.rightMargin:    5
                        anchors.verticalCenter: _deleteText.verticalCenter
                    }

                    ColorOverlay {
                        anchors.fill: _deleteIcon
                        source:       _deleteIcon
                        color:        _editText.color
                        antialiasing: true
                    }

                    Components.Text {
                        id:    _deleteText
                        text:  "Delete"
                        color: _editText.color

                        font.weight: Font.DemiBold

                        anchors.right:           parent.right
                        anchors.rightMargin:     (parent.width * 0.5) - _deleteText.paintedWidth + 10
                        anchors.verticalCenter:  parent.verticalCenter
                    }
                }
            }
        }
    }
}