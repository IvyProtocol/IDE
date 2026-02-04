#!/usr/bin/env bash

if pgrep -x "waybar" > /dev/null; then
    {
        pkill waybar &&
        swaync-client -R &&
        waybar & disown 
    } >/dev/null 2>&1
else
    {
        waybar
        swaync-client -R
    } >/dev/null 2>&1
fi
