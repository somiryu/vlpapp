-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local engine = require("engine")
local ga = require("GoogleAnalytics.ga")

ga.init({
    isLive = false, 
    testTrackingID = "UA-32094152-2",  -- Replace with your tracking code. If code is wrong it fails silently.
    productionTrackingID = "UA-32094152-2",
    debug = false,
})
-- show default status bar (iOS)
display.setStatusBar( display.DefaultStatusBar )

-- include Corona's "widget" library
local widget = require "widget"
local composer = require "composer"
G_baseUrl = "http://vivelapromo.herokuapp.com/api/"

function checkRowHeight(text, font, fontSize, width)
	local tempText = display.newText( text, 0, 0, width, 0, font, fontSize )
	local rowHeight = tempText.height + 20
	tempText:removeSelf()
	tempText = nil
	return rowHeight
end


function comma_value(amount)
  	local formatted = amount
  	while true do  
    	formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    	if (k==0) then
      		break
    	end
  	end
  	return formatted
end

-- event listeners for tab buttons:
local function promosView( event )
	composer.gotoScene( "promos" )
end

local function virtualView( event )
	composer.gotoScene( "virtual")
end

local function missionsView( event )
	composer.gotoScene( "missions" )
end

local function accountView( event )
	composer.gotoScene( "account" )
end

-- LOGO
G_logo = display.newImageRect( "logo.png", 200, 42)
G_logo.x = 160
G_logo.y = 45


-- create a tabBar widget with two buttons at the bottom of the screen

-- table to setup buttons
local tabButtons = {
	{ label="", labelYOffset = -8, defaultFile="promos.png", overFile="promos-down.png", width = 32, height = 30, onPress=promosView, selected=true },
	{ label="", labelYOffset = -8, defaultFile="virtual.png", overFile="virtual-down.png", width = 30, height = 27, onPress=virtualView },
	{ label="", labelYOffset = -8, defaultFile="missions.png", overFile="missions-down.png", width = 32, height = 30, onPress=missionsView },
	{ label="", labelYOffset = 0, defaultFile="account.png", overFile="account-down.png", width = 32, height = 28, onPress=accountView },
}

-- create the actual tabBar widget
local tabBar = widget.newTabBar{
	top = display.contentHeight - 45,	-- 50 is default height for tabBar widget
	buttons = tabButtons,
	backgroundFile = "tabBarBG.png",
    tabSelectedLeftFile = "tabBarSelectedBG.png",
    tabSelectedRightFile = "tabBarSelectedBG.png",
    tabSelectedMiddleFile = "tabBarSelectedBG.png",
    tabSelectedFrameWidth = 32,
    tabSelectedFrameHeight = 45,
}



promosView()	-- invoke first tab button's onPress event manually