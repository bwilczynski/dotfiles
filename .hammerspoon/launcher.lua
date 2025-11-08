hs.loadSpoon("AppLauncher")

spoon.AppLauncher.modifiers = { "ctrl", "alt", "cmd", "shift" }
spoon.AppLauncher:bindHotkeys({
	c = "Calendar",
	d = "2Do",
	f = "Finder",
	k = "Firefox",
	m = "Spotify",
	n = "Notes",
	p = "Bitwarden",
	s = "Slack",
	t = "iTerm",
	v = "Visual Studio Code",
	y = "YouTube",
})

