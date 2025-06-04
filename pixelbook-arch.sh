#!/bin/bash

sudo pacman -S wl-clipboard cliphist ttf-noto-nerd neovim tmux rg fd bat jq fish gnome-keyring libsecret seahorse git base-devel waybar tofi cmake meson cpio pkg-config gcc tree bluetui uv ruff pyright mypy

# split-monitor-workspaces plugin for hyprland worspaces
hyprpm add https://github.com/Duckonaut/split-monitor-workspaces # Add the plugin repository
hyprpm enable split-monitor-workspaces # Enable the plugin
hyprpm reload # Reload the plugins
