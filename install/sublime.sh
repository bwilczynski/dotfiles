SUBLIME_INSTALLED_PACKAGES=~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages
SUBLIME_PACKGE_CONTROL=$SUBLIME_INSTALLED_PACKAGES/Package\ Control.sublime-package

if [ ! -f "$SUBLIME_PACKGE_CONTROL" ]; then
	curl https://packagecontrol.io/Package%20Control.sublime-package > "$SUBLIME_PACKGE_CONTROL"
fi