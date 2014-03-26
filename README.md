# Pomodoro Widget

## Usage

    cd ~/.config/awesome
    git clone git://github.com/nikolavp/awesome-pomodoro.git pomodoro

### In you rc.lua:

    // insert after beautiful.init("...")
    local pomodoro = require("pomodoro")

    // customizations to the showed text or the time a pomodoro should take
    // look in init.lua for more info
    (...)

    //init the pomodoro object with the current customizations
    pomodoro.init()

At this point there are two widget you will want to use in your wibox:

*    pomodoro.widget - the main widget that will display the time of the current pomodoro.

*    pomodoro.icon_widget - the icon that you can use to display close to the text.

### Add it to your wibox

You can use:

* only the text widget:

        mywibox[s].widgets = {
            pomodoro.widget,
            mytextclock,
        }

* only the icon widget:

        mywibox[s].widgets = {
            pomodoro.icon_widget,
            mytextclock,
        }

* or you can use them both:

        mywibox[s].widgets = {
            pomodoro.widget, pomodoro.icon_widget,
            mytextclock,
        }

## Customizations

customizations are done by setting variables under the pomodoro table. Note that those should be done before calling

    pomodoro.init()

### Change the default icon
For that you can use the following which requires beautiful:

    beautiful.pomodoro_icon = '/your/path/to/pomodoro/icon'

### Check out the init.lua too.

For example if you don't want the text "Pomodoro:"

    pomodoro.format = function (t) return t end

or want time left to be show in bold:

    pomodoro.format = function (t) return "[ <b>" .. t .. "</b> ]") end

#### Execute a custom function on pomodoro finish

You can populate the tables:

*pomodoro.on_work_pomodoro_finish_callbacks* and *pomodoro.on_pause_pomodoro_finish_callbacks*

with functions to be called when the pomodoro finishes. on_pause_pomodoro_finish_callbacks functions will be called when a pause finishes and on_work_pomodoro_finish_callbacks functions are called when a pomodoro finishes.

Here is an example how I am using this to lock my screen on every pomodoro finish:

    pomodoro.on_work_pomodoro_finish_callbacks = {
        function()
            exec('slock')
        end
    }

#### Up/Down time with the mouse wheel

You can _up or down the time_ with the mouse wheel if you put your mouse on widget. By default, you
can up or down it minute by minute, but if you want you can change it. In init.lua, change the
variable _pomodoro.change_ to seconds that you want.

#### Bind different interactions to a key

If you don't want to use the mouse to interact with the widget you can easily bind custom keys to different actions/functions:

* pomodoro:start to start a pomodoro
* pomodoro:stop to stop a current pomodoro
* pomodoro:pause to pause the current pomodoro
* pomodoro:increase_time to increase the time of the pomodoro
* pomodoro:decrease_time to decrease the time of the pomodoro

so let's say you want to start a new pomodoro with *Modkey + Shift + p* then just include the following in your rc.lua file

```lua
awful.key({ modkey, "Shift" }, "p",  function() pomodoro:start() end)
```
in your global keybinding section

#### More customizations

Maybe there are more which are not documented here at the moment. Feel free to provide docs and send a pull request :)

## License

Copyright 2010-2011 François de Metz, Nikolay Sturm(nistude), Nikola Petrov(nikolavp)

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

    Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

    Everyone is permitted to copy and distribute verbatim or modified
    copies of this license document, and changing it is allowed as long
    as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

    0. You just DO WHAT THE FUCK YOU WANT TO.
