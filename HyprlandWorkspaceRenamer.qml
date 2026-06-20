pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

PluginComponent {
    id: root

    property real popupX: 0
    property real popupY: 0
    property string pendingName: ""
    property string workspaceName: ""

    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property string workspaceId: String(focusedWorkspace?.id ?? "")

    Component.onCompleted: root.syncWorkspaceLabel()

    Connections {
        target: Hyprland

        function onFocusedWorkspaceChanged() {
            root.syncWorkspaceLabel()
        }

        function onRawEvent(event) {
            if (!event || !event.name)
                return
            if (event.name === "workspace" || event.name === "renameworkspace" || event.name === "focusedmon")
                root.syncWorkspaceLabel()
        }
    }

    function _displayNameForWorkspace(workspace) {
        if (!workspace)
            return "Workspace"

        const idText = String(workspace.id ?? "")
        const rawName = String(workspace.name ?? "")

        if (!rawName)
            return idText || "Workspace"

        if (idText && rawName.startsWith(idText + " "))
            return rawName.slice(idText.length + 1)

        return rawName
    }

    function syncWorkspaceLabel() {
        root.workspaceName = root._displayNameForWorkspace(root.focusedWorkspace)
    }

    function _renameValue() {
        return String(renameField.text ?? "").trim()
    }

    function openRenamePopup(x, y) {
        root.popupX = Math.max(0, x)
        root.popupY = Math.max(0, y)
        root.pendingName = root.workspaceName
        renamePopup.open()
    }

    function closeRenamePopup() {
        renamePopup.close()
    }

    function applyRename() {
        const value = root._renameValue()
        if (!value)
            return
        if (HyprlandService && HyprlandService.renameWorkspace)
            HyprlandService.renameWorkspace(value)
        renamePopup.close()
    }

    horizontalBarPill: Component {
        BasePill {
            enableCursor: true
            content: Component {
                Row {
                    spacing: Theme.spacingS

                    StyledText {
                        text: root.workspaceName
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    verticalBarPill: Component {
        BasePill {
            enableCursor: true
            content: Component {
                Column {
                    spacing: Theme.spacingXS

                    StyledText {
                        text: root.workspaceName
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        wrapMode: Text.NoWrap
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    pillClickAction: function() {}
    pillRightClickAction: function(x, y) {
        root.openRenamePopup(x, y)
    }

    Popup {
        id: renamePopup

        parent: Overlay.overlay
        x: root.popupX
        y: root.popupY
        modal: false
        focus: true
        dim: false
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            radius: Theme.cornerRadius
            color: Theme.withAlpha(Theme.surfaceContainerHigh, Theme.popupTransparency)
            border.color: Theme.outlineMedium
            border.width: 1
        }

        onOpened: Qt.callLater(() => {
            renameField.forceActiveFocus()
            renameField.selectAll()
        })

        contentItem: StyledRect {
            width: 340
            implicitHeight: popupColumn.implicitHeight + Theme.spacingL * 2
            color: "transparent"
            radius: Theme.cornerRadius

            ColumnLayout {
                id: popupColumn
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                ColumnLayout {
                    spacing: Theme.spacingXS
                    Layout.fillWidth: true

                    StyledText {
                        text: "Rename current workspace"
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Bold
                        color: Theme.surfaceText
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: root.workspaceId.length > 0 ? ("Workspace " + root.workspaceId) : "Focused workspace"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                DankTextField {
                    id: renameField
                    text: root.pendingName
                    placeholderText: "Workspace name"
                    Layout.fillWidth: true
                    onAccepted: root.applyRename()
                }

                RowLayout {
                    spacing: Theme.spacingS
                    Layout.fillWidth: true

                    Item { Layout.fillWidth: true }

                    DankButton {
                        text: "Cancel"
                        onClicked: root.closeRenamePopup()
                    }

                    DankButton {
                        text: "Rename"
                        backgroundColor: Theme.primary
                        textColor: Theme.onPrimary
                        onClicked: root.applyRename()
                    }
                }
            }
        }
    }
}
