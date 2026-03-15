#|--/ /+-------------------------+--/ /|#
#|-/ /-| IDE Configuration File |-/ /-|#
#|/ /--+-------------------------+/ /--|#
source "/home/iris/.local/share/vyle/staterc.conf"

#  █░█ █▄█ █░░ █▀▀ 
#  ▀▄▀ ░█░ █▄▄ ██▄  

#// plLoader, sets custom placeholder for wallbash/ivy to work with .dcol and .ivy files.
#// Usage, add plLoader="example|example1|example2" as your custom placeholder.
#// Now you can use your own custom placeholder only by declaring it on your .dcol or .ivy.
#// Warning! This may not work for others if placeholder is different from the intended
plLoader="ivy|wallbash"

#// skipTemplate, specifies .ivy or .dcol template that should be excluded or skipped from procesing!
#// This allows you to selectively exclude certain template that exists in  while still processing others.
#// example:
skipTemplate=${VYLE_CONFIGURATION_SKIPTEMPLATE[@]}

#// nProcCount, lets wallbash use the maximum or limited CPU utilization to process templates!
#// You can limit the core utilization by declaring the number of cores to be utilized.
#// Defaulted is '3', but $(nproc) can be used here. e.g., nProcCount=$(nproc).
nProcCount=$(nproc)

# █░█░█ ▄▀█ █░░ █░░ █▀█ ▄▀█ █▀█ █▀▀ █▀█
# ▀▄▀▄▀ █▀█ █▄▄ █▄▄ █▀▀ █▀█ █▀▀ ██▄ █▀▄

#// set the transition FPS while changing wallpaper.
wallFramerate=60

#// set the transition duration for swww while changing wallpaper.
wallTransDuration=0.5

#// set animation for swww while changing wallpaper.
wallAnimation="grow"
wallAnimationPrevious="outer"
wallAnimationNext="grow"
wallAnimationTheme="grow"

# set transition-bezier for swww while changing wallpaper.
wallTransitionBezier=".43,1.19,.1,.4"

#// WallAddCustomPath, sets a custom user directories scanned for wallpapers.
#// add your wallpaper directories as - WallAddCustomPath=("/path/to/wall/dir1" "/path/to/wall/dir2")
#// setting a custom directory for wallDir would result in to cache wallpapers by /swwwallcache.sh!
#// example:
WallAddCustomPath=("${WALLPAPER_CONFIGURATION_CUSTOMPATH[@]}")

# █▀█ █▀█ █▀▀ █
# █▀▄ █▄█ █▀░ █

# rofiLauncher.sh configuration.
rofiLauncherFont="JetBrainsMono Nerd Font"
rofiLauncherScale=10
rofiLauncherStyle=1


# wbselecgen.sh configuration
rofiWallpaperFont="JetBrainsMono Nerd Font"
rofiWallpaperScale=10
rofiWallpaperColumn=

# themeswitch.sh configuration.
rofiThemeFont="JetBrainsMono Nerd Font"
rofiThemeScale=10
rofiThemeColumn=
rofiThemeStyle=1

# style-launcher.sh configuration.
rofiStyleScale=10

# wallbashtoggle.sh configuration
rofiWallbashFont="JetBrainsMono Nerd Font"
rofiWallbashScale=10

# █░░ █▀█ █▀▀ █▀█ █░█ ▀█▀
# █▄▄ █▄█ █▄█ █▄█ █▄█ ░█░

#// wlogoutStyle sets the style for logout menu
#// available styles - 1 (default) , 2
wlogoutStyle=1

# █▀▀ ▄▀█ █▀ ▀█▀ █▀▀ █▀▀ ▀█▀ █▀▀ █░█
# █▀░ █▀█ ▄█ ░█░ █▀░ ██▄ ░█░ █▄▄ █▀█

#// fetchIcon, sets the user directories scanned for finding fastfetch icons and randomizes. Default is to /home/iris/.config/fastfetch/icons!
fetchIcon="/home/iris/.config/fastfetch/icons"

# █▄▄ █▀█ █ █▀  █░█ ▀█▀ █▄░█ █▀▀ █▀ █▀ █▀ ▀█▀ █░░ 
# █▄█ █▀▄ █ █▄█ █▀█ ░█░ █░▀█ ██▄ ▄█ ▄█ █▄ ░█░ █▄▄

#// brightnesscontrol.sh configuration, declarable according to user preference.
#// brightnessIconDir is string-type variable that needs directory for dunst to use icons.
#// brightnessStep is integer-type variable that is determined through 0 (true) and 1 (False).
#// brightnessNotify is integer-type, determined of 0 and 1.
brightnessIconDir="/home/iris/.config/dunst/icons/vol"
brightnessStep=5
brightnessNotify=0

# █░█ █▀█ █░░ █░█ █▀▄▀█ █▀▀ █▀ ▀█▀ █░░ 
# ▀▄▀ █▄█ █▄▄ █▄█ █░▀░█ ██▄ █▄ ░█░ █▄▄

#// voluemcontrol.sh configuration, declarable according to user preference.
#// volumeStep is an integer-type variable to determine the steps. For example, volumeStep is defaultly set to 5.
#// volumeNotifyUpdateLevel & volumeNotifyMute, is an integer-type variable that suppress Notification-Popups determined through 0 (true) or {1 or greater (false)}.
volumeIconDir="/home/iris/.config/dunst/icons/vol"
volumeStep=5
volumeNotifyUpdateLevel=0
volumeNotifyMute=0

# █▄░█ █▀█ ▀█▀ █ █▀▀ █ █▀▀ ▄▀█ ▀█▀ █ █▀█ █▄░█
# █░▀█ █▄█ ░█░ █ █▀░ █ █▄▄ █▀█ ░█░ █ █▄█ █░▀█
# dunstctl configuration
notificationFont="JetBrainsMono Nerd Font"
notificationFontSize=10

# █░█ █▄█ █▀█ █▀█ █░░ ▄▀█ █▄░█ █▀▄
# █▀█ ░█░ █▀▀ █▀▄ █▄▄ █▀█ █░▀█ █▄▀

# Hyprland Configuration.
CONSOLE="kitty"
EDITOR="vscodium"
EXPLORER="dolphin"
BROWSER="firefox"
LOCKSCREEN="hyprlock"
TASKMANAGER="gnome-system-monitor"
CURSOR="Bibata-Modern-Ice"
CURSOR_SIZE=20

# █▀▀ ▀▄▀ ▀█▀ █▀█ ▄▀█
# ██▄ █░█ ░█░ █▀▄ █▀█

#// Exclusion, add exclusion to a variable that needs to be unset. Avoids conflicting variable and secures purity of globalcontrol.sh.
#// Makes the variable local only for ide.conf.
#// add the exclusions to unset the variable.
#// Do not let exclusion be defined empty. This will unload all the variable and immediately fail!
#// If an exclusion is declared, it would still be set to empty.
# exclusion="()"


