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
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Math as Math;
using Toybox.ActivityMonitor as ActMonitor;
using Toybox.SensorHistory as SensHistory;

class BinaryEleganceHRView extends Ui.WatchFace {
	const ICON_HEART = "0";
	const ICON_ALARM = "1";
	const ICON_BLUETOOTH = "2";
	const ICON_NOTIFICATION = "3";
	const ICON_MOON = "4";
	const ICON_BATTERY = "5";
	const ICON_OFFSET = 25;
    const JUSTIFICATION = Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER;

  	hidden var dayOffset;
  	hidden var centerX, centerY, screenH, screenW;
  	hidden var colors = {};
  	hidden var iconFont;
  	hidden var is24Hour = false;
  	hidden var shapeOffset;
  	hidden var squareSize;
  	hidden var squareSpace;
  	hidden var drawingcontext;
	hidden var hasHR = false;
	hidden var batteryOffset;
	hidden var lowBatteryThreshold;
	hidden var isAwake;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));

    	var app = App.getApp();
	    colors.put("bg", app.getProperty("background"));
	    colors.put("hbg", app.getProperty("hoursInactive"));
	    colors.put("hfg", app.getProperty("hoursActive"));
	    colors.put("mbg", app.getProperty("minutesInactive"));
	    colors.put("mfg", app.getProperty("minutesActive"));
	    colors.put("dbg", app.getProperty("dayInactive"));
	    colors.put("dfg", app.getProperty("dayActive"));
	    colors.put(ICON_ALARM, app.getProperty("alarmColor"));
	    colors.put(ICON_HEART, app.getProperty("heartColor"));
	    colors.put(ICON_NOTIFICATION, app.getProperty("notificationsColor"));
	    colors.put(ICON_BLUETOOTH, app.getProperty("bluetoothColor"));
	    colors.put(ICON_MOON, app.getProperty("moonColor"));
	    colors.put(ICON_BATTERY, app.getProperty("batteryColor"));

    	squareSize = app.getProperty("squareSize");    	
        squareSpace = app.getProperty("squareSpace") ? 1.7 : 1.5;
	    dayOffset = app.getProperty("showDay") ? 0 : 1;
	    lowBatteryThreshold = app.getProperty("lowBatteryThreshold");
	    
        drawingcontext = dc;    
    	screenH = dc.getHeight();
    	screenW = dc.getWidth();
    	centerX = screenW/2;
    	centerY = screenH/2;

    	var settings = Sys.getDeviceSettings();
    	is24Hour = settings.is24Hour;

    	var shape = settings.screenShape;
	
      	batteryOffset = shape == Sys.SCREEN_SHAPE_RECTANGLE ? 3 : 40;
    	
    	if (shape == Sys.SCREEN_SHAPE_RECTANGLE) {
      		centerY -= 5;
      		shapeOffset = 15;
		    if (app.getProperty("showDay")) {
		        squareSpace = app.getProperty("squareSpace") ? 1.7 : 1.5;
	    	} else {
		        squareSpace = app.getProperty("squareSpace") ? 2 : 1.5;    	
	    	}    
		} else {
	        squareSpace = app.getProperty("squareSpace") ? 2 : 1.5;    	
      		shapeOffset = shape == Sys.SCREEN_SHAPE_ROUND ? 30 : 20;
    	}

		if (Toybox has :SensorHistory) {
			if (SensHistory has :getHeartRateHistory) {
				hasHR = true;
			}
		}
      
    
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
	    iconFont = Ui.loadResource(Rez.Fonts.id_font);

    
    }

    // Update the view
    function onUpdate(dc) {
	    setForeground(Gfx.COLOR_TRANSPARENT);
	    dc.clear();
	    
        // Get the current time and format it correctly        
	    var clockTime = Sys.getClockTime();
	    var currentDate = Time.today();
		var currentDayOfMonth = Time.Gregorian.info(currentDate,Time.FORMAT_SHORT).day;
		var currentDayOfWeek = Time.Gregorian.info(currentDate,Time.FORMAT_MEDIUM).day_of_week;
	    drawHours(clockTime.hour);
	    drawMinutes(clockTime.min);
	    if (dayOffset == 0) {
	  		drawDay(currentDayOfMonth,currentDayOfWeek);
    	}
                          
        var activity = ActMonitor.getInfo();
        
    	drawIcons();
        
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
//	    colors = null;
//	    iconFont = null;    
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        isAwake = true;    
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        isAwake = false;
        Ui.requestUpdate();
    }


	hidden function drawHours(hours) {
		var x, y, digit;
	    var bounds = 2;
	    if (!is24Hour) {
	        bounds = 1;
	        if (hours > 12) {
	          hours -= 12;
	        }
	    }
	
	    x = centerX - (3-dayOffset)*squareSpace*squareSize + ((squareSpace - 1) * squareSize / 2);
	    y = centerY + 1.5*squareSize;
	    digit = hours/10;
	    
	    for (var i = 0; i < bounds; ++i) {
	      setForeground(colors.get(digit & (1 << i) > 0 ? "hfg" : "hbg"));
	      drawSquare(x, y - squareSpace*i*squareSize);
	    }
	
	    x = centerX - (2-dayOffset)*squareSpace*squareSize + ((squareSpace - 1) * squareSize / 2);
	    y = centerY + 1.5*squareSize;
	    digit = hours%10;
	
	    for (var i = 0; i < 4; ++i) {
	      setForeground(colors.get(digit & (1 << i) > 0 ? "hfg" : "hbg"));
	      drawSquare(x, y - squareSpace*i*squareSize);
	    }
	  }
	

	  hidden function drawMinutes(minutes) {
	    var x, y, digit;
	
	    x = centerX - (1-dayOffset)*squareSpace*squareSize + ((squareSpace - 1) * squareSize / 2);
	    y = centerY + 1.5*squareSize;
	    digit = minutes/10;
	
	    for (var i = 0; i < 3; ++i) {
	      setForeground(colors.get(digit & (1 << i) > 0 ? "mfg" : "mbg"));
	      drawSquare(x, y - squareSpace*i*squareSize);
	    }
	
	    x = centerX + (0+dayOffset)*squareSpace*squareSize + ((squareSpace - 1) * squareSize / 2);
	    y = centerY + 1.5*squareSize;
	    digit = minutes%10;
	
	    for (var i = 0; i < 4; ++i) {
	      setForeground(colors.get(digit & (1 << i) > 0 ? "mfg" : "mbg"));
	      drawSquare(x, y - squareSpace*i*squareSize);
	    }
	  }
	
	  hidden function drawDay(day,dow) {
	    var x, y, digit;
	
		x = centerX + 1*squareSpace*squareSize + ((squareSpace - 1) * squareSize / 2);	    
	    y = centerY + 1.5*squareSize;
	    digit = day/10;
	
	    for (var i = 0; i < 2; ++i) {
	      setForeground(colors.get(digit & (1 << i) > 0 ? "dfg" : "dbg"));
	      drawSquare(x, y - squareSpace*i*squareSize);
	    }

	    x = centerX + 2*squareSpace*squareSize + ((squareSpace - 1) * squareSize / 2);
	    y = centerY + 1.5*squareSize;
	    digit = day%10;
	
	    for (var i = 0; i < 4; ++i) {
	      setForeground(colors.get(digit & (1 << i) > 0 ? "dfg" : "dbg"));
	      drawSquare(x, y - squareSpace*i*squareSize);
	    }


	    y = centerY + 3.5*squareSize;
	    x = x - ((squareSpace - 1) * squareSize / 2);
        drawingcontext.setColor(0xFFFFFF, colors.get("bg"));
        drawingcontext.drawText(x, y, Gfx.FONT_SMALL, dow, JUSTIFICATION);

	    y = centerY + 2.8*squareSize;        
		x = centerX + 1*squareSpace*squareSize + ((squareSpace - 1) * squareSize / 2);	    
		drawingcontext.drawLine(x, y, x + squareSpace*squareSize + squareSize, y);

	    
	    
	  }
	  
	  hidden function drawIcons() {
	    var icons = {};
	    var settings = Sys.getDeviceSettings();
	    
	    var stats = Sys.getSystemStats();
        if (stats.battery <= lowBatteryThreshold) {
	        drawingcontext.setColor(colors.get(ICON_BATTERY), colors.get("bg"));
	        drawingcontext.drawText(screenW - batteryOffset, 2, iconFont, "5", Gfx.TEXT_JUSTIFY_RIGHT);
		}
		        
	    var hr_sample = null;
	    if (hasHR) {
			var HRiterator = SensHistory.getHeartRateHistory({ :period=>1 });
			var HRSample = HRiterator.next();
	        hr_sample = HRSample.data;
		}
		 
	    if (settings.alarmCount > 0) {
	      icons.put("0", ICON_ALARM);
	    }
	    
	    if (hr_sample != null) {
	      icons.put("1",ICON_HEART);
	    }
	    
	    if (settings.phoneConnected) {
	      icons.put("2", ICON_BLUETOOTH);
	    }
	
	    if (settings.notificationCount > 0) {
	      icons.put("3", ICON_NOTIFICATION);
	    }

	    if (settings.doNotDisturb) {
	      icons.put("4", ICON_MOON);
	    }
	
	    var size = icons.size();
	    if (size > 0) {
	      var values = icons.values();
	      var shape = settings.screenShape;
	      var x = centerX - (size == 1 ? 0 : (size == 2 ? ICON_OFFSET/2 : (size == 3 ? ICON_OFFSET : (size == 4 ? ICON_OFFSET*1.5 : ICON_OFFSET*2))));
	      var y = screenH - shapeOffset;
	      for (var i = 0; i < size; ++i) {
	        drawingcontext.setColor(colors.get(values[i]), colors.get("bg"));
	        drawingcontext.drawText(x, y, iconFont, values[i], JUSTIFICATION);
	        x += ICON_OFFSET;
	      }
	    }
	    	    	    
	  }
	
	  hidden function drawSquare(x, y) {
	    drawingcontext.fillRectangle(x, y, squareSize, squareSize);
	  }

	  hidden function drawMiddle() {
		setForeground(0xFFFFFF);	    
	    drawingcontext.drawLine(screenW/2, 0, screenW/2, screenH);
	  }
	
	  hidden function setForeground(color) {
	    drawingcontext.setColor(color, colors.get("bg"));
	  }

}
