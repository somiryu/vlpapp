-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local engine = require("engine")
local json = require("json")
local widget = require("widget")
local vlp = require("vlp")

local avatarBg
local getting_lb
scene.avatars = {}

local leaderboardTag = display.newText( "Tabla de Líderes  >", 310, 40, "Arial", 15 )
leaderboardTag.anchorX = 1



function scene:create( event )
	local sceneGroup = self.view

	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	bg.anchorX = 0
	bg.anchorY = 0
	bg:setFillColor( 1 )	-- white

	local topBar = display.newRect( 0, 30, display.contentWidth * 2, 65 )
	topBar.anchorX = 0
	topBar:setFillColor( 0.2627451, 0.6627, 0.6196 )

	local function slide(event)
		local start = event.xStart
		if event.phase == "ended" then
			if event.x < start then
				if start - event.x > 100 then
					leaderboardTag.alpha = 0
					transition.to(sceneGroup, {time=300, x=sceneGroup.x - 320})
				end
			end
		end
	end

	bg:addEventListener( "touch", slide )
	
	avatarBg = display.newImageRect( "avatar_bg.png", 320, 250 )
	avatarBg.anchorX = 0.5
	avatarBg.anchorY = 0
	avatarBg.x = display.contentCenterX 
	avatarBg.y = 45


	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( bg )
	sceneGroup:insert(topBar)
	sceneGroup:insert(avatarBg)

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		if not engine.player_id then
			composer.gotoScene( "register", {params={prev="account"}} )
		else

		local mainSpinner = widget.newSpinner( vlp.spinOpt )
		mainSpinner:start()
		mainSpinner.x = 160
		mainSpinner.y = 350
		sceneGroup:insert( mainSpinner )

		leaderboardTag.alpha = 1
		self.avatars = {}
		
		G_logo.alpha = 0

		local function accountInfo(event)
			if not event.isError then
				mainSpinner:removeSelf( )
				mainSpinner = nil

				local gameStatus = json.decode(event.response)
				local player_info = gameStatus['player_info']
				local level = gameStatus['levels']['xp']
				local gold = gameStatus['currencies']['oro']['quantity']
				local avatar = player_info['avatars']['selected']['avatar_url']


				local function avatarLoader(e)
					if e.phase == "ended" then
						local img = display.newImage( sceneGroup, e.response.filename, e.response.baseDirectory, 164, 170)
						img.height = 240
						img.width = 240
						avatarBg:toFront()
					end
				end

				self.avatar_img = network.download( avatar, "GET", avatarLoader, player_info.name.."_avatar.png", system.TemporaryDirectory )
				
				local player_name = display.newText( sceneGroup, string.upper(player_info['name']), 160, 310, "Arial", 17 )
				player_name:setFillColor(0)
				local level_name = display.newText( sceneGroup, level['level_name'], 160, 330, "Arial", 15 )
				level_name:setFillColor( 0.3 )

				local barBg = display.newRect( sceneGroup, 70, 350, 180, 7 )
        		local percentage = level['percentage'] * 180 / 100
        		local barFg = display.newRect( sceneGroup, 70, 350, percentage, 7 )
        		barBg.anchorX = 0
        		barFg.anchorX = 0
        		barBg:setFillColor( 0.78, 0.78, 0.78 )
        		barFg:setFillColor( 0.3, 0.3, 0.3 )

        		local goldText = display.newText( sceneGroup, gold, 140, 380, "Arial", 17 )
        		goldText:setFillColor( 0.3 )
        		local goldImg = display.newImageRect( sceneGroup, "coins.png", 24, 20 )
        		goldImg.x = 180
        		goldImg.y = 380

        		local logoff = display.newText( sceneGroup, "Cerrar Sesión", 160, 410, "Arial", 16 )
        		logoff:setFillColor( 0.27, 0.65, 0.61 )

        		local function logOff(event)
        			engine.player_id = engine.getPlayerId("No content")
        			if self.avatar_img then
						network.cancel(self.avatar_img)
						self.avatar_img = nil
					end
        			composer.gotoScene( "promos" )
        		end

        		logoff:addEventListener( "tap", logOff )
        		
        	end
    	end

    	local urlA, headers = engine.async("players/game_data", {id=engine.player_id, player="true", levels="true", currencies="true"})
    	self.callingAccount = network.request(urlA, "POST", accountInfo, {headers=headers})

        -- Show Leaderboard
    	local function lbRowRender(event)
        	local row = event.row 
        	local params = event.row.params

		    if params['title'] then
        		local title = display.newText( row, params['title'], 160, row.height / 2, "Arial", 16 )
        		title:setFillColor( 0.2 )
		    end

 			if params['spinner'] then
        		spinner = widget.newSpinner( vlp.spinOpt )
				spinner:start( )
				spinner.x=160
				spinner.y = row.height / 2
				row:insert(spinner)
        	end

        	if params['player'] then
        		local player = params['player']
        		local position = display.newText( row, player['position']..".", 35, row.height / 2, "Arial", 15 )
        		position:setFillColor( 0 )
        		position.anchorX = 1
        		
        		-- Avatar
        		local function modifyAvatar(event)
					if ( event.phase == "ended" ) then
						local image = display.newImage( row, event.response.filename, event.response.baseDirectory, 50, row.height / 2)
    					image.width = 50
    					image.height = 50
    					image.anchorX = 0
    				end
				end

        		self.avatars[player['position']] = network.download( player['player']['avatar'], "GET", modifyAvatar, player['position'].."_leaderboard.png", system.TemporaryDirectory )

        		-- Player Info
        		local playerName = display.newText( row, player['player']['name'], 120, 20, "Arial", 15 )
        		playerName:setFillColor( 0.1 )
        		playerName.anchorX = 0

        		local playerLevel = display.newText( row, player['player']['levels']['xp']['name'], 120, 40, "Arial", 15 )
        		playerLevel:setFillColor( 0.3 )
        		playerLevel.anchorX = 0

        		-- Progress Bar
        		local barBg = display.newRect( row, 120, 55, 175, 7 )
        		local percentage = player['player']['levels']['xp']['percentage'] * 175 / 100
        		local barFg = display.newRect( row, 120, 55, percentage, 7 )
        		barBg.anchorX = 0
        		barFg.anchorX = 0
        		barBg:setFillColor( 0.78, 0.78, 0.78 )
        		barFg:setFillColor( 0.3, 0.3, 0.3 )
        	end
    	end

    	-- MOVE SCENE GROUP BACK TO ACCOUNT
		local function lbListener(event)
    		local start = event.xStart
			if event.phase == "ended" then
				if event.x > start then
					if event.x - start > 100 then
						leaderboardTag.alpha = 1
						transition.to(sceneGroup, {time=300, x=sceneGroup.x + 320})
					end
				end
			end
    	end

        local optionsLbTable = {
    		x = 480,
    		y = 245,
    		width = 320,
    		height = 390,
    		onRowRender = lbRowRender,
    		listener = lbListener,
    		noLines = true
		}
		local lbTable = widget.newTableView( optionsLbTable )
		sceneGroup:insert( lbTable )

		lbTable:insertRow( {rowHeight=50, isCategory=true, params={title="TABLA DE LÍDERES"}} )
		lbTable:insertRow( {rowHeight=50, params={spinner=true}} )

		local function lbResponse(event)
			if ( event.isError ) then
        		print( "Network error!" )
    		else
        		lbTable:deleteRow( 2 )
        		print(event.response)

        		local leaderboard = json.decode( event.response )
        		local top = leaderboard['top']
        		local contextual = leaderboard['contextual']

        		for index, player in pairs(top) do
        			lbTable:insertRow({rowHeight=75, params={player=player}})
        		end

        		lbTable:insertRow( {rowHeight=50, isCategory=true, params={title="TU POSICIÓN"}} )

        		for index, player in pairs(contextual) do
        			lbTable:insertRow({rowHeight=75, params={player=player}})
        		end
    		end
		end

		local urlB, headers = engine.async("leaderboards/currencies/xp", {type="top,contextual", limit=2, player_id=engine.player_id, above=2, include_info="avatar,levels"})
		getting_lb = network.request(urlB, "GET", lbResponse, {headers=headers})


		end -- ENF IF PLAYER

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
		
	elseif phase == "did" then
		-- Called when the scene is now off screen
		G_logo.alpha = 1

		if spinner then
			spinner:removeSelf( )
			spinner=nil
		end

		if getting_lb then
			network.cancel(getting_lb)
		end

		leaderboardTag.alpha = 0

		for i, obj in pairs(self.avatars) do
			if obj then
				print("CANCEL IMAGE")
				network.cancel(obj)
			end
		end

		if self.avatar_img then
			network.cancel(self.avatar_img)
		end

		composer.removeScene( "account" )
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