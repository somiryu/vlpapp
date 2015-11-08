-----------------------------------------------------------------------------------------
--
-- view2.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local engine = require("engine")
local json = require("json")
local widget = require("widget")
local vlp = require("vlp")

local data = {}
local fields = {}


function scene:create( event )
	local sceneGroup = self.view

    self.prev = event.params.prev


	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- create a white background to fill screen
	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	bg.anchorX = 0
	bg.anchorY = 0
	bg:setFillColor( 1 )	-- white

    local topBar = display.newRect( 160, 30, display.contentWidth, 65 )
    topBar:setFillColor( 0.27, 0.65, 0.61 )



	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( bg )
    sceneGroup:insert(topBar)

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
        transition.to(G_logo, {time=300, y=50})

        local loginBtn
        data = {}
        fields = {}

        local function scrollListener(e)
            native.setKeyboardFocus( nil )
        end


        local scrollOptions = {
            top = 0,
            left = 0,
            width = 320,
            height = 480,
            scrollWidth = 320,
            scrollHeight = 340,
            listener = scrollListener,
            horizontalScrollDisabled = true,
            backgroundColor = { 0.94 }
        }

        local scrollView = widget.newScrollView(scrollOptions)

        local title = display.newText( "Ingresa", 160, 100, "Roboto", 14 )
        title:setFillColor( 0.3  )
        scrollView:insert(title)
        sceneGroup:insert(scrollView)

        local errorMsg = display.newText("", 160, 210, "Gotham Light", 13)
        errorMsg:setFillColor( 1,0,0 )
        errorMsg.alpha = 0
        scrollView:insert(errorMsg)


        local function textListener( event )
            if event.phase == "began" then
                if event.target.isPassword  and event.target.isSecure == false then
                    event.target.isSecure = true
                    native.setKeyboardFocus( event.target )
                end
            elseif event.phase == "ended" or event.phase == "submitted" then
                errorMsg.alpha = 0
                local text = event.target.text
                local typeT = event.target.type
                if typeT == "Contraseña" then
                     typeT = "password"
                     native.setKeyboardFocus( nil )
                 elseif typeT == "Usuario" then
                     typeT = "username"
                     native.setKeyboardFocus( fields[2] )
                 end

                data[typeT] = text
            end
        end

        local fieldToDraw = {"Usuario", "Contraseña"}
        local y = 140
        for i, field in pairs(fieldToDraw) do
            fields[i] = native.newTextField( 160, y, 250, 30 )
            fields[i]:addEventListener( "userInput", textListener )
            fields[i].type = field
            fields[i].font = native.newFont("Gotham Light", 13)
            fields[i].placeholder = field

            local secure = false
            if field == "Contraseña" then fields[i].isPassword = true end
            y = y + 40
            scrollView:insert(fields[i])
        end

        y = y + 28

        loginBtn = display.newRoundedRect( 160, y, 170, 35, 5 )
        loginBtn:setFillColor( 0.09, 0.4, 0.38 )
        scrollView:insert(loginBtn)

        local logText = display.newText( "Ingresa", 160, y-3, "Roboto", 14 )
        scrollView:insert(logText)

        local submitLogin = function(e)
            loginBtn.alpha = 0

            local function go(e)
                answer = vlp.call("users/login", "POST", data)
                if answer.status ~= "ok" then
                    loginBtn.alpha = 1
                    errorMsg.alpha = 1
                    errorMsg.text = answer.status
                else
                    engine.player_id = engine.getPlayerId(answer.id_in_engine)
                    composer.gotoScene( self.prev )
                end
            end
            timer.performWithDelay( 50, go, 1 )
        end

        loginBtn:addEventListener( "tap", submitLogin )

        y = y + 40

        local dontHaveAccount = display.newRoundedRect( 160, y, 170, 35, 5 )
        dontHaveAccount:setFillColor( 0.09, 0.4, 0.38 )
        scrollView:insert(dontHaveAccount)

        local dontHaveText = display.newText( "¿NO TIENES CUENTA?", 160, y-3, "Roboto", 14 )
        scrollView:insert(dontHaveText)

        local returnToRegister = function(e)
            composer.gotoScene( "register", {params={ prev = self.prev }} )
        end

        dontHaveAccount:addEventListener( "tap", returnToRegister )
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
        print(json.encode(fields))
        for i, obj in pairs(fields) do
            obj:removeSelf()
            obj = nil
        end
        fields = nil


	elseif phase == "did" then
		-- Called when the scene is now off screen
		transition.to(G_logo, {time=300, y=45})
        composer.removeScene( "login" )

	end
end

function scene:destroy( event )
	local sceneGroup = self.view

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
