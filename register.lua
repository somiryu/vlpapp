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

local fields = {}
local data = {}




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

        local validUser = false
        local validEmail = false
        local validPass = false
        local registerBtn

        fields = {}
        data = {}


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

        local title = display.newText( "Regístrate", 160, 100, "Arial", 16 )
        title:setFillColor( 1  )
        scrollView:insert(title)
        sceneGroup:insert(scrollView)

        local passErrorMsg = display.newText("Las contraseñas no son iguales.", 160, 290, "Arial", 15)
        passErrorMsg:setFillColor( 1,0,0 )
        passErrorMsg.alpha = 0
        scrollView:insert(passErrorMsg)

        local mailErrorMsg = display.newText("Has ingresado un email inválido.", 160, 290, "Arial", 15)
        mailErrorMsg:setFillColor( 1,0,0 )
        mailErrorMsg.alpha = 0
        scrollView:insert(mailErrorMsg)

        local answerErrorMsg = display.newText("", 160, 290, "Arial", 15)
        answerErrorMsg:setFillColor( 1,0,0 )
        answerErrorMsg.alpha = 0
        scrollView:insert(answerErrorMsg)

        local function textListener( event )
            if event.phase == "began" and event.target.isSecure == false then
                if event.target.isPassword then
                    event.target.isSecure = true
                    native.setKeyboardFocus( event.target )
                end
            elseif ( event.phase == "ended" or event.phase == "submitted" ) then
            -- do something with defaultField text

                answerErrorMsg.alpha = 0
                local text = event.target.text
                local typeT = event.target.type
                if typeT == "Usuario" then
                    native.setKeyboardFocus( fields[2] )
                elseif typeT == "Email" then
                    native.setKeyboardFocus( fields[3] )
                elseif typeT == "Contraseña"  then
                    typeT = "password"
                    native.setKeyboardFocus( fields[4] )
                elseif typeT == "Confirma la contraseña" then
                    typeT = "confirm"
                    native.setKeyboardFocus( nil )
                end

                if typeT == "Email" then
                    if text:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") then
                        data[typeT] = text
                        validEmail = true
                        mailErrorMsg.alpha = 0
                    else
                        event.target.text = ""
                        passErrorMsg.alpha = 0
                        mailErrorMsg.alpha = 1
                    end
                elseif typeT == "Usuario" then
                    if #text > 0 then
                        data[typeT] = text
                        validUser = true
                    end
                else
                    data[typeT] = text
                end

                if data.password and data.confirm then
                    if data.password == data.confirm then
                        validPass = true
                        passErrorMsg.alpha = 0
                    else
                        mailErrorMsg.alpha = 0
                        passErrorMsg.alpha = 1
                    end
                end

                if validUser == true and validEmail == true and validPass == true then
                    registerBtn.alpha = 1

                    local submitRegister = function(e)
                        answer = vlp.call("users", "POST", data)
                        if answer.status ~= "ok" then
                            answerErrorMsg.alpha = 1
                            answerErrorMsg.text = answer.status
                        else
                            engine.player_id = engine.getPlayerId(answer.id_in_engine)
                            composer.gotoScene( self.prev )
                        end
                    end

                    registerBtn:addEventListener( "tap", submitRegister )
                end


            end
        end

        local fieldToDraw = {"Usuario", "Email", "Contraseña", "Confirma la contraseña"}
        local y = 140
        for i, field in pairs(fieldToDraw) do
            fields[i] = native.newTextField( 160, y, 250, 30 )
            fields[i]:addEventListener( "userInput", textListener )
            fields[i].type = field
            fields[i].placeholder = field

            if field == "Contraseña" or field == "Confirma la contraseña" then
                fields[i].isPassword = true
            end

            y = y + 40
            scrollView:insert(fields[i])
        end

        y = y + 28

        registerBtn = display.newRoundedRect( 160, y, 170, 35, 5 )
        registerBtn:setFillColor( 0.09, 0.4, 0.38 )
        registerBtn.alpha = 0.5
        scrollView:insert(registerBtn)
        local regText = display.newText( "Regístrate", 160, y, "Arial", 14 )
		scrollView:insert(regText)

        y = y + 40
        local haveAccount = display.newRoundedRect( 160, y, 170, 35, 5 )
        haveAccount:setFillColor( 0.09, 0.4, 0.38 )
        scrollView:insert(haveAccount)

        local haveText = display.newText( "¿YA TIENES CUENTA?", 160, y, "Arial", 14 )
        scrollView:insert(haveText)

        local showLogin = function(e)
            composer.gotoScene( "login", {params={prev = self.prev}} )
        end

        haveAccount:addEventListener( "tap", showLogin )
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
        composer.removeScene( "register" )

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
