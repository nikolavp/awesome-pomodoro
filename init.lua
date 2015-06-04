local wibox     = require("wibox")
local awful     = require("awful")
local naughty   = require("naughty")
local beautiful = require("beautiful")
local module_path = (...):match ("(.+/)[^/]+$") or ""
local createPomodoro  = require(module_path..'impl')
local timer     = (type(timer) == 'table' and timer or require("gears.timer"))
local awesome   = awesome


module("pomodoro")

return createPomodoro(wibox, awful, naughty, beautiful, timer, awesome)
