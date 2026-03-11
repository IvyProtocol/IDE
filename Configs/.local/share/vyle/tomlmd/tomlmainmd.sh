#!/usr/bin/env bash

# Vyle Configuration
grpTmp="Vyle.Configuration"
tomlPath="${ideDir}/vyle.toml"

ideTheme="$(tomlq "${tomlPath}" "${grpTmp}" "Theme")"
plLoader="$(tomlq "${tomlPath}" "${grpTmp}" "PlaceHolder")"
enableWallIde="$(tomlq "${tomlPath}" "${grpTmp}" "ColMode")"
eval skipTemplate="($(tomlq "${tomlPath}" "${grpTmp}" "SkipTemplate"))"
nProcCount="$(tomlq "${tomlPath}" "${grpTmp}" "ProcCount")"

# Wallpaper Configuration: wbselecgen.sh
unset grpTmp
grpTmp="Wallpaper.Configuration"

eval wallSet="$(tomlq "${tomlPath}" "${grpTmp}" "Set")"
eval wallDir="$(tomlq "${tomlPath}" "${grpTmp}" "Directory")"
eval WallAddCustomPath="($(tomlq "${tomlPath}" "${grpTmp}" "CustomPath"))"

unset grpTmp
grpTmp="Wallpaper.Swww"
wallFramerate="$(tomlq "${tomlPath}" "${grpTmp}" "Framerate")"
wallTransDuration="$(tomlq "${tomlPath}" "${grpTmp}" "TransitionDuration")"
wallAnimation="$(tomlq "${tomlPath}" "${grpTmp}" "Animation")"
wallTransitionBezier="$(tomlq "${tomlPath}" "${grpTmp}" "TransitionBezier")"

eval wallTransitionStep="$(tomlq "${tomlPath}" "${grpTmp}" "TransitionStep")"
wallAnimationPrevious="$(tomlq "${tomlPath}" "${grpTmp}" "AnimationPrevious")"
wallAnimationNext="$(tomlq "${tomlPath}" "${grpTmp}" "AnimationNext")"
wallAnimationTheme="$(tomlq "${tomlPath}" "${grpTmp}" "AnimationTheme")"

# Rofi Configuration: rofilauncher.sh
unset grpTmp
grpTmp="Rofi.Launch"

rofiLauncherScale="$(tomlq "${tomlPath}" "${grpTmp}" "Scale")"
rofiLauncherStyle="$(tomlq "${tomlPath}" "${grpTmp}" "Style")"

# Rofi Configuration: wbselecgen.sh
unset grpTmp
grpTmp="Rofi.Wallpaper"
    
rofiWallpaperScale="$(tomlq "${tomlPath}" "${grpTmp}" "Scale")"
rofiWallpaperColumn="$(tomlq "${tomlPath}" "${grpTmp}" "ColumnCount")"

# Rofi Configuration: themeswitch.sh
unset grpTmp
grpTmp="Rofi.Theme"

rofiThemeScale="$(tomlq "${tomlPath}" "${grpTmp}" "Scale")"
rofiThemeColumn="$(tomlq "${tomlPath}" "${grpTmp}" "ColumnCount")"
rofiThemeStyle="$(tomlq "${tomlPath}" "${grpTmp}" "Style")"
  
# Rofi Configuration: wallbashtoggle.sh
unset grpTmp
grpTmp="Rofi.Wallbash"

rofiWallbashScale="$(tomlq "${tomlPath}" "${grpTmp}" "Scale")"

# Rofi Configuration: style-launcher.sh
unset grpTmp
grpTmp="Rofi.Switch"

rofiStyleScale="$(tomlq "${tomlPath}" "${grpTmp}" "Scale")"

# Logout Configuration: logoutlaunch.sh
unset grpTmp
grpTmp="Wlogout"

wlogoutStyle="$(tomlq "${tomlPath}" "${grpTmp}" "Style")"

# Fastfetch Configuration: fastfetch.sh
unset grpTmp
grpTmp="Fastfetch"

eval fetchIcon="$(tomlq "${tomlPath}" "${grpTmp}" "FetchIcon")"

# Brightness Configuration: brightnesscontrol.sh
unset grpTmp
grpTmp="Brightness.Configuration"

eval brightnessIconDir="$(tomlq "${tomlPath}" "${grpTmp}" "FetchIcon")"
brightnessStep="$(tomlq "${tomlPath}" "${grpTmp}" "Steps")"
brightnessNotify="$(tomlq "${tomlPath}" "${grpTmp}" "NotifyMute")"

# Volume Configuration: volumecontrol.sh
unset grpTmp
grpTmp="Volume.Configuration"

eval volumeIconDir="$(tomlq "${tomlPath}" "${grpTmp}" "FetchIcon")"
volumeStep="$(tomlq "${tomlPath}"  "${grpTmp}" "Steps")"
volumeNotifyUpdateLevel="$(tomlq "${tomlPath}" "${grpTmp}" "StepsMute")"
volumeNotifyMute="$(tomlq "${tomlPath}" "${grpTmp}" "NotifyMute")"

# Hyprland Configuration.
unset grpTmp
grpTmp="Hyprland.Configuration"

TERMINAL="$(tomlq "${tomlPath}" "${grpTmp}" "Terminal")"
EDITOR="$(tomlq "${tomlPath}" "${grpTmp}" "Editor")"
EXPLORER="$(tomlq "${tomlPath}" "${grpTmp}" "Explorer")"
BROWSER="$(tomlq "${tomlPath}" "${grpTmp}" "Browser")"
LOCKSCREEN="$(tomlq "${tomlPath}" "${grpTmp}" "LockScreen")"
TASKMANAGER="$(tomlq "${tomlPath}" "${grpTmp}" "TaskManager")"
