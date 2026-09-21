alias k=kubectl
alias kgp='k get pods'
alias kgpn='kgp -n'
alias kgs='k get services'
alias kgsn='kgs -n'
alias kctx='kubectx'
alias kns='kubens'

source <(kubectl completion zsh)
source <(kustomize completion zsh)