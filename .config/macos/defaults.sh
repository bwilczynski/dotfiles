#!/usr/bin/env bash
# macOS system settings, as applied on a fresh machine.
#
# Run by hand after `stow .`:
#   ~/.config/macos/defaults.sh
#
# Idempotent — running it twice is a no-op. Keyboard remapping lives in
# keyremap.sh alongside this file, driven by the LaunchAgent.

set -euo pipefail

# System Settings caches the preference domains it owns and writes them back on
# quit, which would clobber the symbolic hotkey changes below.
if pgrep -xq "System Settings"; then
  echo "Quit System Settings first — it overwrites these preferences on exit." >&2
  exit 1
fi

# Symbolic hotkey ids, from com.apple.symbolichotkeys. Opaque by nature; these
# are the ones this config touches.
HOTKEY_DESKTOP_1=118
HOTKEY_DESKTOP_2=119
HOTKEY_DESKTOP_3=120
HOTKEY_DESKTOP_4=121
HOTKEY_DESKTOP_5=122
HOTKEY_SPACE_LEFT=79
HOTKEY_SPACE_RIGHT=81

# Modifier bitmask as stored in symbolic hotkey parameters.
CONTROL=262144
CONTROL_FN=8650752

# set_hotkey <id> <enabled> <ascii> <keycode> <modifiers>
# Parameters are [ascii character, virtual keycode, modifier mask]; 65535 means
# the key has no ascii representation (arrows and friends).
set_hotkey() {
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$1" "
    <dict>
      <key>enabled</key><$2/>
      <key>value</key><dict>
        <key>type</key><string>standard</string>
        <key>parameters</key>
        <array>
          <integer>$3</integer>
          <integer>$4</integer>
          <integer>$5</integer>
        </array>
      </dict>
    </dict>"
}

### Keyboard

# F1-F12 send function keys; media controls need fn.
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# Full keyboard access: Tab moves focus to every control, not just text fields.
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

### Keyboard shortcuts

# Ctrl+1 through Ctrl+5 switch to Desktop 1-5.
set_hotkey "$HOTKEY_DESKTOP_1" true 49 18 "$CONTROL"
set_hotkey "$HOTKEY_DESKTOP_2" true 50 19 "$CONTROL"
set_hotkey "$HOTKEY_DESKTOP_3" true 51 20 "$CONTROL"
set_hotkey "$HOTKEY_DESKTOP_4" true 52 21 "$CONTROL"
set_hotkey "$HOTKEY_DESKTOP_5" true 53 23 "$CONTROL"

# Free plain Ctrl+arrow by disabling "move one space left/right". The
# Ctrl+Shift+arrow variants (80/82) are left alone.
set_hotkey "$HOTKEY_SPACE_LEFT" false 65535 123 "$CONTROL_FN"
set_hotkey "$HOTKEY_SPACE_RIGHT" false 65535 124 "$CONTROL_FN"

### Trackpad and mouse

# Traditional scroll direction, not "natural".
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

### Dock and Spaces

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 64
defaults write com.apple.dock magnification -bool false

# Keep desktops in a fixed order so the Ctrl+number shortcuts stay stable.
defaults write com.apple.dock mru-spaces -bool false

### Finder

defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder ShowPathbar -bool false
defaults write com.apple.finder ShowStatusBar -bool false
defaults write com.apple.finder NewWindowTarget -string "PfHm"

### Appearance and text

defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAllowContinuousSpellChecking -bool false
defaults write com.apple.Siri ContinuousSpellCheckingEnabled -bool false
defaults write com.apple.Siri GrammarCheckingEnabled -bool false
defaults write com.apple.Siri SuggestionsEnabled -bool false

### Apply

# Symbolic hotkeys are read once at login; this reloads them in place.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

killall Dock Finder 2>/dev/null || true

echo "Done. Log out and back in for keyboard and appearance changes to fully apply."
