# Pomodoro Widget

[![Build Status](https://travis-ci.org/nikolavp/awesome-pomodoro.svg?branch=master)](https://travis-ci.org/nikolavp/awesome-pomodoro)

Here are some screenshots on what you'll get if you include this module:
* <a href="http://imgur.com/ko2M5WQ"><img src="http://i.imgur.com/ko2M5WQ.png" title="Hosted by imgur.com"/></a>
* <a href="http://imgur.com/j30ZilX"><img src="http://i.imgur.com/j30ZilX.png" title="Hosted by imgur.com" /></a>
* <a href="http://imgur.com/V2IVWGO"><img src="http://i.imgur.com/V2IVWGO.png" title="Hosted by imgur.com"/></a> 
* <a href="http://imgur.com/KZdC7Qw"><img src="http://i.imgur.com/KZdC7Qw.png" title="Hosted by imgur.com"/></a>

more can be found in our [screenshots wiki page](https://github.com/nikolavp/awesome-pomodoro/wiki/Screenshots).

## Installation

    cd ~/.config/awesome
    git clone git://github.com/nikolavp/awesome-pomodoro.git pomodoro

### In you rc.lua:

    // insert after beautiful.init("...")
    local pomodoro = require("pomodoro")

    //init the pomodoro object
    pomodoro.init()

At this point there are two widget you will want to use in your wibox:

*    pomodoro.widget - the main widget that will display the time of the current pomodoro.

*    pomodoro.icon_widget - the icon that you can use to display close to the text.

### Add the widgets to your wibox

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

If you want to change something or bind pomodoro actions to keys, please look at the [custimzations](https://github.com/nikolavp/awesome-pomodoro/wiki/Advanced-customizations) page or open a feature/change request if your thing is not there.


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
