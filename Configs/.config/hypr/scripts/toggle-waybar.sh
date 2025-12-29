#!/usr/bin/env bash

if pgrep -x "waybar" > /dev/null; then
    {
        pkill waybar
        swaync-client -rs &
        waybar & disown 
    } >/dev/null 2>&1
else
    {
        waybar
        swaync-client -rs
    } >/dev/null 2>&1
    notify-send "Waybar launched"
fi
