# Hyprland Workspace Renamer

A small [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) bar widget that shows the focused Hyprland workspace name and lets you rename it with a right-click.

## Features

- Displays the current focused Hyprland workspace name in the bar.
- Right-click opens a rename popup.
- Renames the active workspace through the existing DMS Hyprland IPC path.

## Install

Clone this repo into your DMS plugins folder:

```sh
git clone https://github.com/xizha127/hyprland-workspace-renamer.git \
  ~/.config/DankMaterialShell/plugins/hyprlandWorkspaceRenamer
```

Then enable it in **DMS Settings → Plugins** and add it to your bar.

## Notes

- The widget strips the numeric Hyprland workspace prefix when showing the display name.
- If the workspace has no custom name, it falls back to the workspace id.

## License

MIT
