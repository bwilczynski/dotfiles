#!/usr/bin/env bash
# Disable hibernation on this Apple T2 Mac.
#
# Run by hand after `stow omarchy`:
#   sudo ~/.config/omarchy/no-hibernate.sh install
#
# Stow only targets $HOME, so it can carry the companion menu entry in
# .config/omarchy/extensions/omarchy-menu.jsonc but not this file. The menu
# entry only hides the Hibernate row; this is what actually blocks S4, so a
# machine rebuilt from this repository needs both. The reasoning is kept in the
# installed file itself, where anyone debugging suspend will find it.
#
# Idempotent — running it twice is a no-op.

set -euo pipefail

CONF=/etc/systemd/sleep.conf.d/99-no-hibernate-t2.conf

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Needs root: sudo $0 ${1:-install}" >&2
    exit 1
  fi
}

install() {
  require_root install
  mkdir -p "$(dirname "$CONF")"
  cat >"$CONF" <<'CONF_EOF'
# Disable hibernation on this Apple T2 Mac (Macmini8,1).
#
# The out-of-tree t2bce staging driver stack (t2bce_dma / t2bce_core /
# t2bce_vhci / t2bce_audio) does not survive resume from S4. On resume its
# DMA command queues desync:
#
#   t2bce_vhci: Possible desync, cmd cancel timed out
#   t2bce_dma:  command queue timeout (slot 7)
#   t2bce_dma:  SQ unregister failed
#
# The T2 then keeps DMA-writing into physical pages that no longer belong to
# it once the hibernation image has been restored, corrupting kernel slab
# memory. Observed fallout, in order, on 2026-09-19:
#
#   21:27:31  Oops #1  GPF in do_epoll_ctl_file   (6s after resume)
#   22:01:48  Oops #2  GPF in rb_insert_color <- do_epoll_ctl_file
#   22:28:59  suspend aborts: "Freezing user space processes failed after
#             20.000 seconds (1 tasks refusing to freeze)" - sd-resolve
#             wedged forever on the global epoll mutex
#   22:35:18  Oops #3  NULL deref in ep_poll_callback <- __wake_up, during
#             logout. The greeter's epoll wait queues are now corrupt, so
#             libinput events never wake it => frozen keyboard at the login
#             screen, recoverable only by a hard power-cycle.
#
# Plain S3 suspend (mem_sleep_default=deep, already on the kernel cmdline)
# does not go through the t2bce resume path that breaks, so it stays enabled.
#
# To re-enable hibernation, delete this file.

[Sleep]
AllowHibernation=no
AllowHybridSleep=no
AllowSuspendThenHibernate=no
CONF_EOF
  echo "Installed $CONF"
  echo "Verify with: systemd-analyze cat-config systemd/sleep.conf"
}

uninstall() {
  require_root uninstall
  rm -f "$CONF"
  echo "Removed $CONF — hibernation is governed by systemd defaults again."
}

case "${1:-}" in
  install) install ;;
  uninstall) uninstall ;;
  *)
    echo "Usage: $(basename "$0") install|uninstall" >&2
    exit 1
    ;;
esac
