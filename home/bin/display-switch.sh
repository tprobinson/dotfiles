#!/bin/bash
isSingleMonitor="$(xrandr | grep -P 'eDP connected .*\d')"
if [[ -z "$isSingleMonitor" ]]; then
  xrandr \
    --output DisplayPort-0 --auto --off \
    --output HDMI-0 --auto --off \
    --output eDP --auto --pos 0x0
else
  xrandr \
    --output DisplayPort-0 --auto --rotate left --pos 0x0 \
    --output HDMI-0 --auto --rotate right --pos 1440x0 \
    --output eDP --auto --off
fi

if [ "$(ps -ef | grep xfce4-panel | grep -v grep | wc -l)" -gt 0 ]; then
  sleep 1
  xfce4-panel -r
fi
