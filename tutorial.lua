local composer = require( "composer" )
local widget = require("widget")
local utils = require("utils")

local scene = composer.newScene()

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  --reference to the parent scene object
    local images = event.params.images

    if ( phase == "did" ) then
    	local bg = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
    	bg:setFillColor( 0, 0.7 )

    	local function closeOverlay(e)
    		composer.hideOverlay( "fade", 400 )
    	end

    	local height = 50
    	self.closeBtn = widget.newButton{
    		left = 0, top = display.contentHeight - height,
    		height = height, width = display.contentWidth,
    		onRelease = closeOverlay,
    		label = "CERRAR", labelYOffset = -5,
    		labelColor = {default = {1}, over={0,5}},
    		font = "Roboto", fontSize = 25,
    		shape = "rect",
    		fillColor = {default = {0.27, 0.65, 0.61}, over = {0.27, 0.65, 0.61, 0.5}}
    	}


    	--- SLIDER
    	local group = display.newGroup( )
    	group.scrolling = false
    	local activeCircle = 1

    	local initX = display.contentWidth/2
    	for i = 1, #images do
    		local bg = display.newRect( group, 0, display.contentCenterY - (height/2), display.contentWidth, display.contentHeight - height )	
    		bg.x = initX
    		local image = display.newImageRect( group, images[i], 320, 350 )
    		image.y = bg.y + 40
    		image.x = initX
    		initX = initX + display.contentWidth
    		bg:setFillColor( 1 )
    	end

    	local function slideCarrousel(e)
			if e.phase == "ended" then
				if not group.scrolling then
						
					local function activateScroll(event)
						group.scrolling = false
					end

					if e.x < e.xStart - 50 then
						if activeCircle < #images  then
							group.scrolling = true
							transition.to(group, {time = 300, x = group.x - display.contentWidth, onComplete=activateScroll, transition=easing.outBack})
						
							--transition.to(circles[activeCircle].active, {time = 200, alpha = 0})
							activeCircle = activeCircle + 1
							--transition.to(circles[activeCircle].active, {time = 200, alpha = 1})
						end
					end

					if e.x > e.xStart + 50 then
						if activeCircle > 1 then
							group.scrolling = true
							transition.to(group, {time = 300, x = group.x + display.contentWidth, onComplete=activateScroll, transition=easing.outBack})
						
							--transition.to(circles[activeCircle].active, {time = 200, alpha = 0})
							activeCircle = activeCircle - 1
							--transition.to(circles[activeCircle].active, {time = 200, alpha = 1})
						end
					end
				end
			end
		end

		group:addEventListener( "touch", slideCarrousel )


    	sceneGroup:insert(group)
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  --reference to the parent scene object

    if ( phase == "will" ) then
        self.closeBtn:removeSelf( )
        self.closeBtn = nil
    end
end



scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
return scene