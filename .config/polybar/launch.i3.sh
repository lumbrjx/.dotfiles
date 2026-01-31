#!/usr/bin/env sh

#: Terminate all the running polybar instances
killall -q polybar
sleep 0.2

#: Launch all the Bars
polybar -c $HOME/.config/polybar/config.ini bar1

