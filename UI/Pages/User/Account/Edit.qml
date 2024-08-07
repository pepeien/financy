import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// Types
import Financy.Types 1.0

// Components
import "qrc:/Components" as Components

Components.Page {
    readonly property var user:    internal.selectedUser
    readonly property var account: internal.selectedAccount

    property var _accountToShare

    id:    _root
    title: account?.name ?? ""

    centerButton.isDisabled: _name.hasError || _limit.hasError || _closingDay.hasError || !account?.isOwnedBy(user.id)
    centerButtonIcon: "qrc:/Icons/Check.svg"
    centerButtonOnClick: function() {
        if (centerButton.isDisabled) {
            return;
        }

        if (!user || !account) {
            return;
        }

        if (_form.willBeShared) {
            if (!_accountToShare) {
                return;
            }

            stack.popToIndex(1);

            internal.mergeAccounts(
                account.id,
                _accountToShare.id
            );

            return;
        }

        internal.editAccount(
            account.id,
            _name.text,
            _closingDay.text,
            _limit.text,
            _type.value,
            _primaryColor.picker.color,
            _secondaryColor.picker.color
        );

        stack.pop();
    }

    Item {
        id:     _form
        width:  parent.width * 0.6
        height: parent.height

        anchors.left: parent.left

        property bool willBeShared: false

        Components.SquircleContainer {
            id:     _selector
            width:  200
            height: 40

            backgroundBorder.width: 1
            backgroundBorder.color: internal.colors.foreground

            anchors.top:              parent.top
            anchors.topMargin:        25
            anchors.horizontalCenter: parent.horizontalCenter

            Components.SquircleButton {
                width:  parent.width * 0.5
                height: parent.height

                backgroundColor:             _form.willBeShared ? "transparent" : internal.colors.dark
                backgroundTopRightRadius:    0
                backgroundBottomRightRadius: 0

                anchors.left: parent.left

                onClick: function() {
                    _form.willBeShared = false;
                }

                Components.Text {
                    text:  "Edit"
                    color: _form.willBeShared ? internal.colors.dark : internal.colors.background

                    font.weight:    Font.Bold
                    font.pointSize: 11

                    anchors.centerIn: parent
                }
            }

            Rectangle {
                width:  1
                height: parent.height
                color:  internal.colors.foreground

                anchors.centerIn: parent
            }

            Components.SquircleButton {
                width:  parent.width * 0.5
                height: parent.height

                backgroundColor:            _form.willBeShared ? internal.colors.dark : "transparent"
                backgroundTopLeftRadius:    0
                backgroundBottomLeftRadius: 0
    
                anchors.right: parent.right

                onClick: function() {
                    _form.willBeShared = true;
                }

                Components.Text {
                    text:  "Shared"
                    color: _form.willBeShared ? internal.colors.background : internal.colors.dark

                    font.weight:    Font.Bold
                    font.pointSize: 11

                    anchors.centerIn: parent
                }
            }
        }

        Item {
            width:   parent.width
            height:  parent.height
            visible: !_form.willBeShared

            anchors.top:       _selector.bottom
            anchors.topMargin: 80
    
            Components.Input {
                id:    _name
                width: 256 * 1.25
                text:  account?.name ?? ""

                label:     "Name"
                color:     internal.colors.dark
                minLength: 1
                maxLength: 25

                anchors.top:              parent.top
                anchors.horizontalCenter: parent.horizontalCenter

                KeyNavigation.tab: _limit.input
            }

            Components.Input {
                id:    _limit
                width: _name.width
                text:  account?.limit ?? 0

                label: "Limit"
                color: internal.colors.dark

                validator: IntValidator {
                    bottom: 1
                }

                anchors.top:              _name.bottom
                anchors.topMargin:        10
                anchors.horizontalCenter: parent.horizontalCenter

                KeyNavigation.tab: _closingDay.input
            }

            Item {
                id:     _data
                width:  _name.width
                height: _closingDay.height

                anchors.top:       _limit.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Components.Input {
                    property int min: internal.getMinStatementClosingDay()
                    property int max: internal.getMaxStatementClosingDay()

                    id:     _closingDay
                    width:  (parent.width / 2) - 10
                    text:   account?.closingDay ?? 1

                    label:       "Closing Day" 
                    color:       internal.colors.dark
                    inputHeight: _limit.inputHeight
                    hint:        _closingDay.min + " ~ " + _closingDay.max

                    anchors.left: parent.left

                    validator: IntValidator {
                        bottom: _closingDay.min
                        top:    _closingDay.max
                    }
                }

                Components.Dropdown {
                    id:         _type
                    label:      "Type"
                    itemWidth:  _closingDay.width
                    itemHeight: _closingDay.inputHeight

                    model: internal.getAccountTypes()

                    anchors.right:     parent.right
                }
            }

            Item {
                id:    _colors
                width: _name.width

                anchors.top:              _data.bottom
                anchors.topMargin:        30
                anchors.horizontalCenter: parent.horizontalCenter

                Components.ColorPicker {
                    id:     _primaryColor
                    width:  (parent.width / 2) - 15
                    height: 60
                    color:  account?.primaryColor ?? internal.colors.dark
                    label:  "Background Color"

                    anchors.left:           parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Components.ColorPicker {
                    id:     _secondaryColor
                    width:  _primaryColor.width
                    height: _primaryColor.height
                    color:  account?.secondaryColor ?? internal.colors.foreground
                    label:  "Text Color"

                    anchors.left:           _primaryColor.right
                    anchors.leftMargin:     30
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Item {
            width:   parent.width
            height:  parent.height * 0.85
            visible: _form.willBeShared

            anchors.top:       _selector.bottom
            anchors.topMargin: 80

            Components.FinanceAccountShareList {
                readonly property real _padding: 35

                height:        parent.height - (_padding * 2)
                width:         parent.width * 0.6
                bottomPadding: _padding

                anchors.horizontalCenter: parent.horizontalCenter

                onClick: function(inAccount) {
                    _root._accountToShare = inAccount;
                }
            }
        }
    }

    Item {
        id:     _preview
        width:  parent.width - _form.width
        height: _form.height

        anchors.left: _form.right

        Components.SquircleContainer {
            // Props
            id:               _secondPreviewButton
            width:            parent.width * 0.9
            height:           parent.height
            backgroundColor:  internal.showcaseColors.background
            hasShadow:        true

            anchors.top:              parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            Components.Text {
                id:    _secondPreviewTitle
                text:  "Preview"
                color: internal.showcaseColors.light

                font.family:    "Inter"           
                font.pointSize: 25
                font.weight:    Font.Normal

                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.topMargin:  parent.height * 0.06
                anchors.leftMargin: parent.width * 0.05
            }

            Components.Switch {
                id: _switch

                color: internal.showcaseColors.light
                fill:  internal.showcaseColors.foreground
                width: 60

                labelText: _switch.isSwitched ? "Dark" : "Light"

                buttonHeight: 28

                isSwitched:   internal.colorsTheme == Colors.Dark

                anchors.top:         parent.top
                anchors.right:       parent.right
                anchors.topMargin:   parent.height * 0.03
                anchors.rightMargin: parent.width * 0.05

                onSwitch: function() {
                    internal.updateShowcaseTheme(
                        _switch.isSwitched ? Colors.Dark : Colors.Light
                    );
                }
            }

            Components.FinanceAccountItem {
                height: 95
                width:  parent.width * 0.7

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter:   parent.verticalCenter

                // Props
                title:           _root._accountToShare?.name ?? _name.text
                backgroundColor: _root._accountToShare?.primaryColor ?? _primaryColor.picker.currentColor
                textColor:       _root._accountToShare?.secondaryColor ?? _secondaryColor.picker.currentColor
                limit:           _root._accountToShare?.limit ?? _limit.text
                usedLimit:       _root._accountToShare?.usedLimit ?? 0
            }
        }
    }
}