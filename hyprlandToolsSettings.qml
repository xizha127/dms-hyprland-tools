import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "hyprlandTools"

    StyledText {
        width: parent.width
        text: "Hyprland Tools"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Configure where Hyprland config files live so future generated DMS plugin config can be written into the right place. The plugin will not edit hyprland.lua automatically yet."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StringSetting {
        settingKey: "configSourceDir"
        label: "Hyprland config source directory"
        description: "Defaults to ~/.config/hypr/. Future generated config will live under dms/plugins/hyprlandtools.lua inside this directory."
        placeholder: "~/.config/hypr/"
        defaultValue: "~/.config/hypr/"
    }
}
