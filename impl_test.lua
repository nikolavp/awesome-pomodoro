local createPomodoro = require('impl')

local wibox = {
    widget = {
        textbox = function() 
            return {
                set_markup = function(self, s) return nil end,
                buttons = function(self, bs) return nil end,
            }
        end,
        imagebox = function()
            return {
                set_image = function(self, image_path) return nil end,
                buttons = function(self, bs) return nil end,
            }
        end
    }
}
local awful = {
    util = {
        getdir = function(str) return '/home/cooluser/.config/awesome' end,
        pread = function(cmd) return "" end,
        table = {
            join = function(elements) return nil end
        }
    },
    button = function(modifier, mouseButton, f) return nil end,
    tooltip = function(table) return nil end
}
local naughty = {
    notify = function(bg, fg, title, text, timeout)
    end
}
local beautiful = {}

local timer = function(t) 
    return {
        start = function(self) return nil end,
        stop = function(self) return nil end,
        connect_signal = function(self, f) return nil end,
    }
end

local awesome = {
    connect_signal = function(self, f) return nil end,
}

local pomodoro = createPomodoro(wibox, awful, naughty, beautiful, timer, awesome)


describe("Should set the default values properly", function()
    it('pause duration should be 5 minutes', function()
        assert.are.equal(300, pomodoro.pause_duration)
    end)
    it('work duration should be set to 25 minutes', function()
        assert.are.equal(1500, pomodoro.work_duration)
    end)
    it('default changing value for increasing and decreasing should be one minute', function()
        assert.are.equal(60, pomodoro.change)
    end)
    it('working pomodoro should be the next state', function()
        assert.are.equal(true, pomodoro.working)
    end)
end)

describe('Set time should change the textbox appropriately', function()
    local s = spy.on(pomodoro.widget, "set_markup")
    it('more than one hour pomodoro should be formatted with an hour part', function()
        pomodoro:settime(3601)
        assert.spy(s).was_called_with(pomodoro.widget, "Pomodoro: <b>01:00:01</b>")
    end)
    it('less than one hour should be set with only minutes and seconds', function()
        pomodoro:settime(1500)
        assert.spy(s).was_called_with(pomodoro.widget, "Pomodoro: <b>25:00</b>")
    end)
end)

describe('Notifications should send a naughty notification and change pomodoro object appropriately', function()
    -- TODO: For some reason I cannot mock naughty...
    it('naughty should be called properly', function()
        local s = spy.on(naughty, 'notify')
        pomodoro:notify('title', 'sometext', 10, true)
    end)
    it('should set the left to the new duration for the new state', function()
        pomodoro:notify('title', 'sometext', 10, true)
        assert.are.equal(10, pomodoro.left)
    end)
    it('should set working to false if the next timer is not for a work duration', function()
        pomodoro:notify('title', 'sometext', 10, false)
        assert.are.equal(false, pomodoro.working)
    end)
end)

describe('Starting a pomodoro', function()
    it('should start the timer', function()
        local s = spy.on(pomodoro.timer, 'start')
        pomodoro:start()
        assert.spy(s).was_called_with(pomodoro.timer)
    end)
end)


describe('Stopping a pomodoro', function()
    it('should stop the timer', function()
        local s = spy.on(pomodoro.timer, 'stop')
        pomodoro:stop()
        assert.spy(s).was_called_with(pomodoro.timer)
    end)
    it('should set the next pomodoro to be for work', function()
        pomodoro:stop()
        assert.are.equal(true, pomodoro.working)
    end)
    it('should set time left to the work duration', function()
        pomodoro:stop()
        assert.are.equal(1500, pomodoro.left)
    end)
    it('should set the textbox to the work duration', function()
        local s = spy.on(pomodoro, 'settime')
        pomodoro:stop()
        assert.spy(s).was_called_with(pomodoro, 1500)
    end)
end)

describe('Pausing a pomodoro', function()
    it('should stop the timer', function()
        local s = spy.on(pomodoro.timer, 'stop')
        pomodoro:stop()
        assert.spy(s).was_called_with(pomodoro.timer)
    end)
end)

describe('Preserve the pomodoro before restart if any', function()
    it('should find the last time in X resource DB', function()
        awful.util.pread = function(s)
            return [[
            awesome.Pomodoro.time:  716
            XTerm*faceName: consolas
            xterm*.background:      grey5
            ]]
        end
        pomodoro:init()
        assert.are.equal(716, pomodoro.left)
    end)
    it('should start the pomodoro right away if the value is found in the database after a restart and it was started', function()
        local s = spy.on(pomodoro, 'start')
        awful.util.pread = function(s)
            return [[
            awesome.Pomodoro.time:  716
            awesome.Pomodoro.started:  1
            XTerm*faceName: consolas
            xterm*.background:      grey5
            ]]
        end
        pomodoro:init()
        assert.spy(s).was_called()
    end)
    it('should use the normal duration and don\'t start a pomodoro if not found in the database', function()
        local s = spy.on(pomodoro, 'start')
        awful.util.pread = function(s)
            return [[
            awesome.pomodoro.time:  716
            XTerm*faceName: consolas
            xterm*.background:      grey5
            ]]
        end
        pomodoro:init()
        assert.spy(s).was_not_called()
        assert.are.equal(1500, pomodoro.left)
    end)

    it('should not start the timer if it was paused or stopped', function()
        local s = spy.on(pomodoro, 'start')
        awful.util.pread = function(s)
            return [[
            awesome.Pomodoro.time:  716
            awesome.Pomodoro.started:  0
            XTerm*faceName: consolas
            xterm*.background:      grey5
            ]]
        end
        pomodoro:init()
        assert.spy(s).was_not_called()
        assert.are.equal(716, pomodoro.left)
    end)
end)

describe('Should use the images properly', function()
    path_we_got = nil
    local pomodoro = createPomodoro(wibox, awful, naughty, beautiful, timer, awesome)
    pomodoro.icon_widget.set_image = function(self, image_path) 
        path_we_got = image_path
    end
    pomodoro.working = true

    it('should set the default icon to gray by default', function()
        pomodoro:init()
        assert.are.equal('/home/cooluser/.config/awesome/pomodoro/images/gray.png', path_we_got)
    end)

    it('should set the image to the locked one when we pause a pomodoro', function()
        pomodoro:pause()
        assert.are.equal('/home/cooluser/.config/awesome/pomodoro/images/locked.png', path_we_got)
    end)

    it('should set the image to the gray one when we stop a pomodoro', function()
        pomodoro:stop()
        assert.are.equal('/home/cooluser/.config/awesome/pomodoro/images/gray.png', path_we_got)
    end)

    it('should change the image depending on the time that elapsed for the pomodoro', function()
        -- there is more than 2/3 from the next break
        pomodoro.left = 26
        pomodoro.work_duration = 30
        pomodoro:ticking_time()
        assert.are.equal('/home/cooluser/.config/awesome/pomodoro/images/green.png', path_we_got)

        -- there is more than 1/3 from the next break but smaller than 2/3
        pomodoro.left = 16
        pomodoro.work_duration = 30
        pomodoro:ticking_time()
        assert.are.equal('/home/cooluser/.config/awesome/pomodoro/images/orange.png', path_we_got)

        pomodoro.left = 9
        pomodoro.work_duration = 30
        pomodoro:ticking_time()
        assert.are.equal('/home/cooluser/.config/awesome/pomodoro/images/red.png', path_we_got)
    end)

    it('should set the icon back to gray when the pomodoro finishes', function()
        pomodoro.left = 0
        pomodoro:ticking_time()
        assert.are.equal('/home/cooluser/.config/awesome/pomodoro/images/gray.png', path_we_got)
    end)
    it('shouldn\'t change the icon if we are currently not working', function()
        pomodoro.working = false
        pomodoro.work_duration = 30
        interval_elements = {26, 16, 9}
        for i, element in ipairs(interval_elements) do
            pomodoro.left = element
            pomodoro:ticking_time()
            assert.are.equal('/home/cooluser/.config/awesome/pomodoro/images/green.png', path_we_got)
        end
    end)
end)


describe('Long breaks', function()

    local pomodoro = createPomodoro(wibox, awful, naughty, beautiful, timer, awesome)
    it('should properly start a long break after 4 full pomodoros', function()
        for i=1,4,1 do
            pomodoro.working = true
            pomodoro.left = 0
            assert.are.not_equal(15 * 60, pomodoro.pause_duration)
            pomodoro:ticking_time()
        end
        assert.are.equal(15 * 60, pomodoro.pause_duration)
    end)
end)

