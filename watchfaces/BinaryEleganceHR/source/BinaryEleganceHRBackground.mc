//! Copyright (C) 2016 Simone Torelli <simone.torelli@gmail.com>
//! Copyright (C) 2016 Sven Meyer <meyer@modell-aachen.de> (for reused code from Binary Elegance watch face)
//!
//! This program is free software: you can redistribute it and/or modify it
//! under the terms of the GNU General Public License as published by the Free
//! Software Foundation, either version 3 of the License, or (at your option)
//! any later version.
//!
//! This program is distributed in the hope that it will be useful, but WITHOUT
//! ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//! FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//! more details.
//!
//! You should have received a copy of the GNU General Public License along
//! with this program.  If not, see <http://www.gnu.org/licenses/>.

using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class Background extends Ui.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
        // Set the background color then call to clear the screen
        dc.setColor(Gfx.COLOR_TRANSPARENT, App.getApp().getProperty("BackgroundColor"));
        dc.clear();
    }

}
