DEVBOX_DOCKER_IMAGE=ghcr.io/bwilczynski/devbox:main
DEVBOX_HOME=/root
TZ=Europe/Warsaw

devbox() {
  cmd=$*

  TMP_DIR=$(mktemp -d)
  cleanup() {
    rm -rf "$TMP_DIR"
  }
  trap cleanup EXIT

  mkdir -p $TMP_DIR/{.kube,.config/git}
  cp ~/.kube/config $TMP_DIR/.kube/config
  cp ~/.config/git/config $TMP_DIR/.config/git/config

  docker run --pull always \
    -it --rm \
    -e TZ=$TZ \
    -v $HOME/.devbox_history:$DEVBOX_HOME/.zsh_history \
    -v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock \
    -e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $TMP_DIR/.kube:$DEVBOX_HOME/.kube \
    -v $TMP_DIR/.config/git:$DEVBOX_HOME/.config/git \
    -v $PWD:$DEVBOX_HOME/shared \
    -w $DEVBOX_HOME/shared \
    $DEVBOX_DOCKER_IMAGE ${cmd}
}
