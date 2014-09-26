local image     = image
local os        = os
local string    = string
local ipairs    = ipairs
local setmetatable = setmetatable
local print     = print
local tonumber = tonumber
local math = require("math")

module("pomodoro.impl")

return function(wibox, awful, naughty, beautiful, timer, awesome)
    -- pomodoro timer widget
    pomodoro = {}
    -- tweak these values in seconds to your liking
    pomodoro.short_pause_duration = 5 * 60
    pomodoro.long_pause_duration = 15 * 60
    pomodoro.work_duration = 25 * 60
    pomodoro.npomodoros = 0
    pomodoro.pause_duration = pomodoro.short_pause_duration
    pomodoro.change = 60


    pomodoro.format = function (t) return "Pomodoro: <b>" .. t .. "</b>" end
    pomodoro.pause_title = "Pause finished."
    pomodoro.pause_text = "Get back to work!"
    pomodoro.work_title = "Pomodoro finished."
    pomodoro.work_text = "Time for a pause!"
    pomodoro.working = true
    pomodoro.widget = wibox.widget.textbox()
    pomodoro.icon_widget = wibox.widget.imagebox()
    pomodoro.timer = timer { timeout = 1 }

    -- Callbacks to be called when the pomodoro finishes or the rest time finishes
    pomodoro.on_work_pomodoro_finish_callbacks = {}
    pomodoro.on_pause_pomodoro_finish_callbacks = {}

    last_icon_used = nil

    function set_pomodoro_icon(icon_name)
        local pomodoro_image_path = awful.util.getdir("config") .."/pomodoro/images/" .. icon_name .. ".png"
        if last_icon_used == pomodoro_image_path then
            return
        end
        last_icon_used = pomodoro_image_path
        pomodoro.icon_widget:set_image(pomodoro_image_path)
    end

    function pomodoro:settime(t)
        if t >= 3600 then -- more than one hour!
            t = os.date("!%X", t)
        else
            t = os.date("%M:%S", t)
        end
        self.widget:set_markup(pomodoro.format(t))
    end

    function pomodoro:notify(title, text, duration, working)
        naughty.notify {
            bg = beautiful.bg_urgent,
            fg = beautiful.fg_urgent,
            title = title,
            text  = text,
            timeout = 10
        }

        pomodoro.left = duration
        pomodoro:settime(duration)
        pomodoro.working = working
    end

    function pomodoro:start()
        pomodoro.last_time = os.time()
        pomodoro.timer:start()
    end

    function pomodoro:pause()
        -- TODO: Fix the showed remaining text
        pomodoro.timer:stop()
        set_pomodoro_icon('locked')
    end

    function pomodoro:stop()
        pomodoro.timer:stop()
        pomodoro.working = true
        pomodoro.left = pomodoro.work_duration
        pomodoro:settime(pomodoro.work_duration)
        set_pomodoro_icon('gray')
    end

    function pomodoro:increase_time()
        pomodoro.timer:stop()
        pomodoro:settime(pomodoro.work_duration+pomodoro.change)
        pomodoro.work_duration = pomodoro.work_duration+pomodoro.change
        pomodoro.left = pomodoro.work_duration
    end

    function pomodoro:decrease_time()
        pomodoro.timer:stop()
        if pomodoro.work_duration > pomodoro.change then
            pomodoro:settime(pomodoro.work_duration-pomodoro.change)
            pomodoro.work_duration = pomodoro.work_duration-pomodoro.change
            pomodoro.left = pomodoro.work_duration
        end
    end

    function get_buttons()
        return awful.util.table.join(
        awful.button({ }, 1, function()
            pomodoro:start()
        end),
        awful.button({ }, 2, function()
            pomodoro:pause()
        end),
        awful.button({ }, 3, function()
            pomodoro:stop()
        end),
        awful.button({ }, 4, function()
            pomodoro:increase_time()
        end),
        awful.button({ }, 5, function()
            pomodoro:decrease_time()
        end)
        )
    end

    function pomodoro:ticking_time()
        if pomodoro.left > 0 then
            if pomodoro.working then
                local pomodoro_portion = pomodoro.work_duration / 3
                if pomodoro.left > (2 * pomodoro_portion) then
                    set_pomodoro_icon('green')
                elseif pomodoro.left > pomodoro_portion then
                    set_pomodoro_icon('orange')
                else
                    set_pomodoro_icon('red')
                end
            else
                set_pomodoro_icon('green')
            end
            pomodoro:settime(pomodoro.left)
        else
            set_pomodoro_icon('gray')
            if pomodoro.working then
                pomodoro.npomodoros = pomodoro.npomodoros + 1
                if pomodoro.npomodoros % 4 == 0 then
                    pomodoro.pause_duration = pomodoro.long_pause_duration
                else
                    pomodoro.pause_duration = pomodoro.short_pause_duration
                end
                pomodoro:notify(pomodoro.work_title, pomodoro.work_text,
                pomodoro.pause_duration, false)
                for _, value in ipairs(pomodoro.on_work_pomodoro_finish_callbacks) do
                    value()
                end
            else
                pomodoro:notify(pomodoro.pause_title, pomodoro.pause_text,
                pomodoro.work_duration, true)
                for _, value in ipairs(pomodoro.on_pause_pomodoro_finish_callbacks) do
                    value()
                end
            end
            pomodoro.timer:stop()
        end
    end

    -- Function that keeps the logic for ticking
    function pomodoro:ticking()
        local now = os.time()
        pomodoro.left = pomodoro.left - (now - pomodoro.last_time)
        pomodoro.last_time = now
        pomodoro:ticking_time()
    end

    function pomodoro:init()
        local xresources = awful.util.pread("xrdb -query")
        local time_from_last_run = xresources:match('awesome.Pomodoro.time:%s+%d+')
        local started_from_last_run = xresources:match('awesome.Pomodoro.started:%s+%w+')
        local working_from_last_run = xresources:match('awesome.Pomodoro.working:%s+%w+')
        local npomodoros_from_last_run = xresources:match('awesome.Pomodoro.npomodoros:%s+%d+')

        set_pomodoro_icon('gray')

        -- Timer configuration
        --
        pomodoro.timer:connect_signal("timeout", pomodoro.ticking)

        awesome.connect_signal("exit", function(restarting)
            -- Save current state in xrdb.
            -- run this synchronously cause otherwise it is not saved properly -.-
            if restarting then
                started_as_number = pomodoro.timer.started and 1 or 0
                working_as_number = pomodoro.working and 1 or 0
                awful.util.pread('echo "awesome.Pomodoro.time: ' .. pomodoro.left
                .. '\nawesome.Pomodoro.started: ' .. started_as_number
                .. '\nawesome.Pomodoro.working: ' .. working_as_number
                .. '\nawesome.Pomodoro.npomodoros: ' .. pomodoro.npomodoros
                .. '" | xrdb -merge')
            end
        end)

        pomodoro.widget:buttons(get_buttons())
        pomodoro.icon_widget:buttons(get_buttons())

        if time_from_last_run then
            time_from_last_run = tonumber(time_from_last_run:match('%d+'))
            if working_from_last_run then
                pomodoro.working = (tonumber(working_from_last_run:match('%d+')) == 1)
            end
            -- Use `math.min` to get the lower value for `pomodoro.left`, in
            -- case the config/setting has been changed.
            if pomodoro.working then
                pomodoro.left = math.min(time_from_last_run, pomodoro.work_duration)
            else
                pomodoro.left = math.min(time_from_last_run, pomodoro.pause_duration)
            end

            if npomodoros_from_last_run then
                pomodoro.npomodoros = tonumber(npomodoros_from_last_run:match('%d+'))
            end

            if started_from_last_run then
                started_from_last_run = tonumber(started_from_last_run:match('%d+'))
                if started_from_last_run == 1 then
                    pomodoro:start()
                end
            end
        else
            -- Initial value depends on the one set by the user
            pomodoro.left = pomodoro.work_duration
        end
        pomodoro:settime(pomodoro.left)

        awful.tooltip({
            objects = { pomodoro.widget, pomodoro.icon_widget},
            timer_function = function()
                local collected = 'Collected ' .. pomodoro.npomodoros .. ' pomodoros so far.\n'
                if pomodoro.timer.started then
                    if pomodoro.working then
                        return collected .. 'Work ending in ' .. os.date("%M:%S", pomodoro.left)
                    else
                        return collected .. 'Rest ending in ' .. os.date("%M:%S", pomodoro.left)
                    end
                else
                    return collected .. 'Pomodoro not started'
                end
                return 'Bad tooltip'
            end,
        })

    end

    return pomodoro
end
