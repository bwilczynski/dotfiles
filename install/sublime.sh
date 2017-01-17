SUBLIME_INSTALLED_PACKAGES=~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages
SUBLIME_PACKAGE_CONTROL=$SUBLIME_INSTALLED_PACKAGES/Package\ Control.sublime-package

if [ ! -f "$SUBLIME_PACKAGE_CONTROL" ]; then
	curl https://packagecontrol.io/Package%20Control.sublime-package > "$SUBLIME_PACKAGE_CONTROL"
fi