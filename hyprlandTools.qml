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
    property string workspaceName: ""
    property string inlineDraft: ""
    property bool inlineEditing: false
    property Item renameField: null

    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property string workspaceId: String(focusedWorkspace?.id ?? "")
    readonly property string hyprConfigSourceDir: String(pluginData.configSourceDir ?? "~/.config/hypr/")

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
        if (!root.inlineEditing)
            root.inlineDraft = root.workspaceName
    }

    function beginInlineRename() {
        if (!root.focusedWorkspace)
            return

        root.inlineDraft = root.workspaceName
        root.inlineEditing = true
        Qt.callLater(() => {
            if (root.renameField) {
                root.renameField.forceActiveFocus()
                root.renameField.selectAll()
            }
        })
    }

    function cancelInlineRename() {
        root.inlineEditing = false
        root.inlineDraft = root.workspaceName
    }

    function _setRenameField(field) {
        root.renameField = field
    }

    function applyInlineRename() {
        const value = String(root.inlineDraft ?? "").trim()
        root.inlineEditing = false
        if (!value)
            return
        if (HyprlandService && HyprlandService.renameWorkspace)
            HyprlandService.renameWorkspace(value)
    }

    function openPlaceholderMenu(x, y) {
        root.popupX = Math.max(0, x)
        root.popupY = Math.max(0, y)
        placeholderPopup.open()
    }

    function closePlaceholderMenu() {
        placeholderPopup.close()
    }

    function _popupBodyText() {
        return "Hyprland Tools menu placeholder\n\nConfig source: " + root.hyprConfigSourceDir + "\nPlanned actions will live here later."
    }

    horizontalBarPill: Component {
        BasePill {
            enableCursor: true
            content: Component {
                Row {
                    spacing: Theme.spacingXS

                    StyledText {
                        visible: !root.inlineEditing
                        text: root.workspaceName
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        visible: root.inlineEditing
                        width: 220
                        height: inlineRenameField.implicitHeight + Theme.spacingS
                        radius: Theme.cornerRadius
                        color: Theme.surfaceHover
                        border.color: inlineRenameField.activeFocus ? Theme.primary : Theme.outlineStrong
                        border.width: inlineRenameField.activeFocus ? 2 : 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.IBeamCursor
                            onClicked: inlineRenameField.forceActiveFocus()
                        }

                        DankTextField {
                            id: inlineRenameField
                            anchors.fill: parent
                            anchors.margins: Theme.spacingXS
                            font.pixelSize: Theme.fontSizeMedium
                            textColor: Theme.surfaceText
                            backgroundColor: "transparent"
                            placeholderText: "Rename workspace"
                            enabled: root.inlineEditing
                            text: root.inlineDraft
                            Component.onCompleted: root._setRenameField(inlineRenameField)
                            Component.onDestruction: {
                                if (root.renameField === inlineRenameField)
                                    root._setRenameField(null)
                            }
                            onTextChanged: root.inlineDraft = text
                            onAccepted: root.applyInlineRename()
                            onActiveFocusChanged: {
                                if (!activeFocus && root.inlineEditing)
                                    root.applyInlineRename()
                            }
                            Keys.onEscapePressed: event => {
                                root.cancelInlineRename()
                                event.accepted = true
                            }
                        }
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
                        visible: !root.inlineEditing
                        text: root.workspaceName
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        wrapMode: Text.NoWrap
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        visible: root.inlineEditing
                        width: 180
                        height: inlineRenameField.implicitHeight + Theme.spacingS
                        radius: Theme.cornerRadius
                        color: Theme.surfaceHover
                        border.color: inlineRenameField.activeFocus ? Theme.primary : Theme.outlineStrong
                        border.width: inlineRenameField.activeFocus ? 2 : 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.IBeamCursor
                            onClicked: inlineRenameField.forceActiveFocus()
                        }

                        DankTextField {
                            id: inlineRenameField
                            anchors.fill: parent
                            anchors.margins: Theme.spacingXS
                            font.pixelSize: Theme.fontSizeSmall
                            textColor: Theme.surfaceText
                            backgroundColor: "transparent"
                            placeholderText: "Rename workspace"
                            enabled: root.inlineEditing
                            text: root.inlineDraft
                            Component.onCompleted: root._setRenameField(inlineRenameField)
                            Component.onDestruction: {
                                if (root.renameField === inlineRenameField)
                                    root._setRenameField(null)
                            }
                            onTextChanged: root.inlineDraft = text
                            onAccepted: root.applyInlineRename()
                            onActiveFocusChanged: {
                                if (!activeFocus && root.inlineEditing)
                                    root.applyInlineRename()
                            }
                            Keys.onEscapePressed: event => {
                                root.cancelInlineRename()
                                event.accepted = true
                            }
                        }
                    }

                }
            }
        }
    }

    pillClickAction: function() {
        root.beginInlineRename()
    }

    pillRightClickAction: function(x, y) {
        root.openPlaceholderMenu(x, y)
    }

    Popup {
        id: placeholderPopup

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

        contentItem: StyledRect {
            width: 300
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
                        text: "Hyprland Tools"
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Bold
                        color: Theme.surfaceText
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: root._popupBodyText()
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: Theme.spacingS
                    Layout.fillWidth: true

                    Item { Layout.fillWidth: true }

                    DankButton {
                        text: "Close"
                        onClicked: root.closePlaceholderMenu()
                    }
                }
            }
        }
    }
}
