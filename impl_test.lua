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
        getdir = function(str) return '/home/cooluser/.config' end,
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
    it('should start the pomodoro right away if the value is found in the database after a restart', function()
        local s = spy.on(pomodoro, 'start')
        awful.util.pread = function(s)
            return [[
            awesome.Pomodoro.time:  716
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
end)

