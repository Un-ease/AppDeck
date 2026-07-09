#!/usr/bin/env bash

# AppDeck Installer
# Copies quickshell launcher configuration and script helper to local paths.

set -euo pipefail

DEST_CONFIG_DIR="$HOME/.config/quickshell/tui"
DEST_BIN_DIR="$HOME/.local/bin"

echo "=== AppDeck Installer ==="

# 1. Copy config files
echo "Installing configuration files to $DEST_CONFIG_DIR..."
mkdir -p "$DEST_CONFIG_DIR"
cp -r tui/* "$DEST_CONFIG_DIR/"

# 2. Copy launcher helper script
echo "Installing helper script to $DEST_BIN_DIR..."
mkdir -p "$DEST_BIN_DIR"
cp bin/omarchy-tui-shell "$DEST_BIN_DIR/omarchy-tui-shell"
chmod +x "$DEST_BIN_DIR/omarchy-tui-shell"

echo "Installation complete!"
echo ""
echo "To run the launcher, execute:"
echo "  omarchy-tui-shell start"
echo "  omarchy-tui-shell toggle"
echo ""
echo "For keybindings:"
echo " - Hyprland: add the following to ~/.config/hypr/bindings.conf"
echo "     bindd = SUPER, SPACE, Command surface, exec, omarchy-tui-shell toggle"
echo " - GNOME: Bind a Custom Shortcut to run 'omarchy-tui-shell toggle'"
