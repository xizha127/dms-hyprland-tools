
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import Quickshell.Hyprland
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

PluginComponent {
    id: root

    property string workspaceName: ""
    property string renameDraft: ""
    property bool renamePopoutOpen: false
    property real renamePopupMinWidth: 20
    readonly property real renameInfoButtonSize: Math.max(Theme.iconSize, Theme.fontSizeMedium + Theme.spacingS * 2)
    readonly property real renamePopupHorizontalPadding: 8
    readonly property real renamePopupVerticalPadding: 4
    readonly property real renameInputWidth: {
        const textWidth = renameMetrics.width || 0
        const desiredWidth = Math.ceil(textWidth) + root.renamePopupHorizontalPadding * 2
        return Math.max(root.renamePopupMinWidth, desiredWidth)
    }
    readonly property real renamePopupContentWidth: renameInfoButtonSize + Theme.spacingXS + renameInputWidth
    popoutWidth: renamePopupContentWidth + Theme.spacingS * 2

    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property string hyprConfigSourceDir: String(pluginData.configSourceDir ?? "~/.config/hypr/")

    Component.onCompleted: {
        refreshRenameUiSettings()
        syncWorkspaceLabel()
    }

    onPluginServiceChanged: refreshRenameUiSettings()

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

    Connections {
        target: pluginService
        ignoreUnknownSignals: true

        function onPluginDataChanged(changedPluginId) {
            if (!(String(changedPluginId) === String(root.pluginId)))
                return
            root.refreshRenameUiSettings()
        }
    }

    TextMetrics {
        id: renameMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeMedium
        text: root.renameDraft.length > 0 ? root.renameDraft : "New workspace name"
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
        if (!root.renamePopoutOpen)
            root.renameDraft = root.workspaceName
    }

    function refreshRenameUiSettings() {
        root.renamePopupMinWidth = Number(pluginService?.loadPluginData ? pluginService.loadPluginData(pluginId, "renamePopupMinWidth", 20) : 20)
    }

    function _luaString(value) {
        return JSON.stringify(String(value ?? ""))
    }

    function _luaValue(value) {
        const text = String(value ?? "")
        return /^[-+]?\d+$/.test(text) ? text : root._luaString(text)
    }

    function renameWorkspace(newName) {
        if (!root.focusedWorkspace || !Hyprland || !Hyprland.dispatch)
            return

        const wsId = String(root.focusedWorkspace.id ?? "").trim()
        const trimmedName = String(newName ?? "").trim()
        if (!wsId || !trimmedName)
            return

        if (Hyprland.usingLua === true) {
            Hyprland.dispatch(`hl.dsp.workspace.rename({ workspace = ${root._luaValue(wsId)}, name = ${root._luaString(trimmedName)} })`)
        } else {
            Hyprland.dispatch(`renameworkspace ${wsId} ${trimmedName}`)
        }
    }

    function applyRename() {
        const value = String(root.renameDraft ?? "").trim()
        if (!value) {
            root.closePopout()
            return
        }
        root.renameWorkspace(value)
        root.closePopout()
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout
            property QtObject parentPopout: null
            showCloseButton: false

            Connections {
                target: popout.parentPopout
                ignoreUnknownSignals: true
                function onOpened() {
                    root.refreshRenameUiSettings()
                    root.renamePopoutOpen = true
                    root.renameDraft = root.workspaceName
                    Qt.callLater(() => {
                        renameInput.forceActiveFocus()
                        renameInput.selectAll()
                    })
                }
                function onClosed() {
                    root.renamePopoutOpen = false
                    root.renameDraft = root.workspaceName
                }
            }

            Row {
                spacing: Theme.spacingXS

                TextField {
                    id: renameInput
                    width: root.renameInputWidth
                    text: root.renameDraft
                    placeholderText: qsTr("Workspace name")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceText
                    selectionColor: Theme.primaryContainer
                    selectedTextColor: Theme.primary
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    leftPadding: root.renamePopupHorizontalPadding
                    rightPadding: root.renamePopupHorizontalPadding
                    topPadding: root.renamePopupVerticalPadding
                    bottomPadding: root.renamePopupVerticalPadding
                    background: Item {}
                    onTextChanged: root.renameDraft = text
                    onAccepted: root.applyRename()
                    Keys.onEscapePressed: event => {
                        root.closePopout()
                        event.accepted = true
                    }
                }

                DankActionButton {
                    width: root.renameInfoButtonSize
                    height: root.renameInfoButtonSize
                    buttonSize: root.renameInfoButtonSize
                    iconName: "info"
                    iconSize: Theme.iconSize - 4
                    iconColor: Theme.surfaceVariantText
                    backgroundColor: "transparent"
                    opacity: 0.9
                    tooltipText: qsTr("Enter saves. Esc closes.")
                    tooltipSide: "top"
                }
            }
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

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

    verticalBarPill: Component {
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
