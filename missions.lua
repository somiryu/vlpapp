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

local timer_surprise
local timer_1
local timer_2
local timer_3
local timer_4



function scene:create( event )
	local sceneGroup = self.view
	
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
		if not engine.player_id then
            composer.gotoScene( "register", {params={prev="missions"}}  )
        else

        local mainSpinner = widget.newSpinner( vlp.spinOpt )
        mainSpinner:start()
        mainSpinner.x = 160
        mainSpinner.y = 240
        sceneGroup:insert( mainSpinner )

		local function missionsResponse(event)
			 if ( event.isError ) then
        		print( "Network error!" )
    		else
                mainSpinner:removeSelf( )
                mainSpinner = nil

    			response = json.decode(event.response)
    			local quests = response['quests']
    			local mina = quests['mina']
    			local tutorial = {}
    			if quests['tutorial'] then
    				tutorial = quests['tutorial']
    			end
    			local gold = response['currencies']['oro']['quantity']

    			--Player coins
				local playerCoinIcon = display.newImageRect( sceneGroup, "coins_white.png", 15, 18 )
				playerCoinIcon.anchorX = 1
				playerCoinIcon.x = 310
				playerCoinIcon.y = 40

				local playerCoin = display.newText( sceneGroup, gold, playerCoinIcon.x - 25, 40, "Arial", 15 )
				playerCoin.anchorX = 1


    			local function missionRowRender(event)
    				local row = event.row 
    				local params = event.row.params


    				local function onTimer(event)
    					local this = event.source
    					local seconds = this.remaining
    					local total = this.total
    					local remaining = total - seconds

    					local hours = math.floor(seconds / 3600)
    					local minutes = math.floor((seconds / 60) % 60)
    					local remainingSeconds = seconds % 60

    					if remainingSeconds < 10 then
    						remainingSeconds = "0" ..remainingSeconds
    					end

    					if minutes < 10 then
    						minutes = "0"..minutes
    					end

    					local to_show = hours .. ":" .. minutes .. ":" .. remainingSeconds
						

    					if row.numChildren then
						for i=1, row.numChildren do
							if row[i] then
								if row[i].fg then 
									row[i].width = remaining * 100 / total
								elseif row[i].textShow then 
									row[i].text = to_show
								end
							end
						end
						end
						
						if seconds == 0 then
    						timer.cancel(event.source)
    						local currScene = composer.getSceneName( "current" )
							composer.gotoScene( currScene )
    					else
							event.source.remaining = event.source.remaining - 1
						end
					end

    				if params['title'] then
        				local title = display.newText( row, params['title'], 160, row.height / 2, "Arial", 16 )
        				title:setFillColor( 0.2 )
        			end

    				if params['mina'] then    					
    					local coinImage = display.newImageRect( row, params.mineType .. ".png", 16, 19 )
    					coinImage.x = 50
    					coinImage.y = row.height / 2

    					if params.mina.mission.cooldown_active == false then
    						
    						local function sendAccomplishment(event)
    							local acc = event.target
    							local tag = acc.tag

    							acc:removeSelf( )
    							acc = nil
								
    							local response = engine.call(
    								"accomplishments", "POST", 
    								{tag=tag, 
    								note="completed_from_app", 
    								player_id=engine.player_id}
    							)

								local currScene = composer.getSceneName( "current" )
								composer.gotoScene( currScene )
    						end

    						local button = widget.newButton( {
    							label="Reclama",
    							onRelease=sendAccomplishment,
    							emboss=false,
    							shape="roundedRect",
    							width = 160,
    							height = 28,
    							cornerRadius = 2,
    							fillColor = { default={ 0.27, 0.65, 0.61, 1 }, over={ 0.27, 0.65, 0.61, 0.7 } },
    							strokeColor = { default={ 0.27, 0.65, 0.611 }, over={ 0.27, 0.65, 0.61, 0.7 } },
    							strokeWidth = 2,
    							labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 1 } }
    						} )	
    						button.x = 200
    						button.y = row.height / 2
    						local actionTag = params.mina.actions
    						for tag, action in pairs(actionTag) do
    							button.tag = tag
    						end
    						row:insert(button)

    					else 
    						local barBg = display.newRect( row, 120, row.height / 2, 160, 7 )
        					barBg.anchorX = 0
        					barBg:setFillColor( 0.78, 0.78, 0.78 )

        					-- TIME TEXT
							local text = display.newText( row, "Cargando...", 280, (row.height / 2) + 15, "Arial", 12 )
    						text:setFillColor( 0.4 )
    						text.anchorX = 1
    						text.textShow = true

    						-- PROGRESS BAR
    						local timeLeft = params.mina.mission.time_left
    						local totalTime = params.mina.mission.cooldown
    						local remainingTime = totalTime - timeLeft

    						local percentage = (remainingTime * 100 / totalTime)
    						print(percentage)
							local barFg = display.newRect( row, 120, row.height / 2, percentage, 7 )
        					barFg.anchorX = 0
        					barFg:setFillColor( 0.3, 0.3, 0.3 )
        					barFg.fg = true
        					
    						
    						if params.mineType == "mina_oro_1" then
    							timer_1 = timer.performWithDelay( 1000, onTimer, -1 )
    							timer_1.remaining = timeLeft
    							timer_1.total = totalTime
    						elseif params.mineType == "mina_oro_2" then
    							timer_2 = timer.performWithDelay( 1000, onTimer, -1 )
    							timer_2.remaining = timeLeft
    							timer_2.total = totalTime
    						elseif params.mineType == "mina_oro_3" then
    							timer_3 = timer.performWithDelay( 1000, onTimer, -1 )
    							timer_3.remaining = timeLeft
    							timer_3.total = totalTime
    						elseif params.mineType == "caja_sorpresa" then
    							timer_4 = timer.performWithDelay( 1000, onTimer, -1 )
    							timer_4.remaining = timeLeft
    							timer_4.total = totalTime
    						end

    					end
    					
    				end

    				if params.description then
    					print("TUTORIAL MISSION")
    					local name = display.newText( row, params.name, 15, 19, 280, 0, "Arial", 17 )
    					name:setFillColor( 0 )
    					name.anchorX = 0

						local description = display.newText( row, params.description, 18, row.height / 2, 280, 0, "Arial", 15 )
    					description:setFillColor( 0.2 )
    					description.anchorX = 0

    					local rightMargin = 280
    					for tag, curr in pairs(params.rewards.currencies) do
    						print(json.encode(curr))
    						local thisCurr = display.newText( row, curr.quantity, rightMargin, row.height -22, "Arial", 16 )
    						thisCurr:setFillColor( 0.1 )
    						thisCurr.anchorX = 1
    						rightMargin = rightMargin - 10 - thisCurr.width

    						local img
    						if curr.name == "oro" then
    							img = display.newImageRect( row, "coins.png", 16, 14 )
    						elseif curr.name == "xp" then
    							img = display.newImageRect( row, "xp.png", 25, 12 )
    						elseif curr.name == "Ruleta" then
    							img = display.newImageRect( row, "caja_sorpresa.png", 21, 18 )
    						end
    						img.anchorX = 1
    						img.x = rightMargin
    						img.y = thisCurr.y
    						rightMargin = rightMargin - 15 - img.width
    					end


    				end

    			end

    			local function missionListener(event)
    			end

    			local optionsMissionTable = {
    				x = 160,
    				y = 275,
    				width = 320,
    				height = 320,
    				onRowRender = missionRowRender,
    				listener = missionListener,
    				noLines = true
				}
				
				missionTable = widget.newTableView( optionsMissionTable )
				sceneGroup:insert( missionTable )
				

				print("START TABLE")
				missionTable:insertRow( {rowHeight=50, isCategory=true, params={title="MINA DE ORO"}} )
				
				for mineType, mine in pairs(mina['missions']) do
					missionTable:insertRow({rowHeight=50, params={mina=mine, mineType=mineType}})
				end

				missionTable:insertRow( {rowHeight=50, isCategory=true, params={title="MISIONES"}} )
				
				if tutorial['missions'] then
					for tag, mission in pairs(tutorial['missions']) do
						mission = mission.mission
						missionTable:insertRow( {rowHeight=checkRowHeight(mission.description, "Arial", 15, 280) + 60, params={name=mission.name, description=mission.description, rewards=mission.rewards}} )
					end
				end
				print("END TABLE")

    			


    		end
		end



		local url, headers = engine.async("players/game_data", {id=engine.player_id, missions="true", currencies="true"})
		print(url)
		getting_missions = network.request(url, "POST", missionsResponse, {headers=headers})

        end --END IF NO G_PLAYER
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

		if timer_surprise then
			timer.cancel(timer_surprise)
		end
		if timer_1 then
			timer.cancel(timer_1)
		end
		if timer_2 then
			timer.cancel(timer_2)
		end
		if timer_3 then
			timer.cancel(timer_3)
		end
		if timer_4 then
			timer.cancel(timer_4)
		end

        composer.removeScene( "missions" )

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
