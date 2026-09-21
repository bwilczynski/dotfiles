#!/usr/bin/env bash
# Keyboard remapping for the built-in keyboard only.
#
# External keyboards are deliberately excluded: they are remapped in firmware,
# and `hidutil --set` replaces a device's entire UserKeyMapping, so touching
# them here would revert the firmware layout.
#
# The matcher selects Apple Silicon's built-in keyboard by its SPI transport
# (externals arrive over USB or Bluetooth) restricted to keyboard usage
# (usage page 1, usage 6). On Intel Macs the built-in keyboard reports USB
# instead, so use '{"VendorID":0x5ac,"ProductID":0x281}' there.
#
# Verify what a matcher selects before trusting it:
#   hidutil list --matching '{"Transport":"SPI","PrimaryUsagePage":1,"PrimaryUsage":6}'

set -euo pipefail

MATCHING='{"Transport":"SPI","PrimaryUsagePage":1,"PrimaryUsage":6}'

# HID usage codes (0x700000000 + usage id), as decimal — hidutil wants numbers.
CAPS_LOCK=30064771129    # 0x700000039
ESCAPE=30064771113       # 0x700000029
RIGHT_COMMAND=30064771303 # 0x7000000E7
RIGHT_OPTION=30064771302  # 0x7000000E6

# Every mapping goes in one --set: the call replaces the whole UserKeyMapping
# array, so a second call would silently drop the first one's mappings.
install() {
  hidutil property --matching "$MATCHING" --set "{\"UserKeyMapping\":[
    {\"HIDKeyboardModifierMappingSrc\":$CAPS_LOCK,\"HIDKeyboardModifierMappingDst\":$ESCAPE},
    {\"HIDKeyboardModifierMappingSrc\":$RIGHT_COMMAND,\"HIDKeyboardModifierMappingDst\":$RIGHT_OPTION}
  ]}" >/dev/null
}

uninstall() {
  hidutil property --matching "$MATCHING" --set '{"UserKeyMapping":[]}' >/dev/null
}

case "${1:-}" in
  install) install ;;
  uninstall) uninstall ;;
  *)
    echo "Usage: $(basename "$0") install|uninstall" >&2
    exit 1
    ;;
esac
