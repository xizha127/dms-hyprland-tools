# Hyprland Tools

A small [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) bar widget for Hyprland workspace management.

## Features

- Shows the current focused Hyprland workspace name in the bar.
- Left click starts inline rename directly on the bar.
- Right click opens a placeholder dropdown menu for future tools.
- Uses DMS's Hyprland IPC path to rename the active workspace.

## Install

Clone this repo into your DMS plugins folder:

```sh
git clone https://github.com/xizha127/dms-hyprland-tools.git \
  ~/.config/DankMaterialShell/plugins/hyprlandTools
```

Then enable it in **DMS Settings → Plugins** and add it to your bar.

## Settings

- `Hyprland config source directory` defaults to `~/.config/hypr/`.
- This path is stored for later config-generation work.
- DMS will not auto-edit `hyprland.lua` yet.

## Notes

- The widget strips the numeric Hyprland workspace prefix when showing the display name.
- If the workspace has no custom name, it falls back to the workspace id.
- Right-click currently opens a placeholder menu only. The later plan is to host extra Hyprland tools there.

## License

MIT
