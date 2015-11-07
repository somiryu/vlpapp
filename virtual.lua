-----------------------------------------------------------------------------------------
--
-- view2.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local json = require("json")
local engine = require("engine")
local http = require("socket.http")
local ltn12 = require( "ltn12" )
local vlp = require("vlp")


local mpspinner
local overlayGroup


function scene:create( event )
	local sceneGroup = self.view
	
	-- Called when the scene's view does not exist.
	

	-- create a white background to fill screen
	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	bg.anchorX = 0
	bg.anchorY = 0
	bg:setFillColor( 1 )	-- white

	local topBar = display.newRect( 160, 90, display.contentWidth, 40 )
	topBar:setFillColor( 0.94, 0.94, 0.94 )
	
	-- create some text

	

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

		mpspinner = widget.newSpinner( vlp.spinOpt )
		mpspinner:start( )
		mpspinner.x = 160
		mpspinner.y = 240

		virtualMarket = display.newGroup( )
		sceneGroup:insert(virtualMarket)

		local title = display.newText( sceneGroup, "Mercado Virtual", 0, 0, "Arial", 16 )
		title:setFillColor( 0.30 )	-- white
		title.x = display.contentWidth * 0.5
		title.y = 90
		getMarketPromos()
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

		if mpspinner then
			mpspinner:removeSelf()
			mpspinner = nil
		end

		if self.images then
			for i, image in pairs(self.images) do
				network.cancel(image)
			end
		end

		composer.removeScene( "virtual" )
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

local function marketPromoData(event)
	print("VIRTUAL: " .. json.encode(event.response))
	if ( event.isError ) then
        print( "Network error!" )
    else
    	local promos = json.decode( event.response )
		scene:createTable(promos)
	end
end

-- CALL TO API SERVICE
function getMarketPromos (parameters)
	local url, headers = vlp.async("marketpromos")
	print(json.encode(headers))
	getting_promos = network.request( url, "GET", marketPromoData, {headers=headers} )
end


function scene:createTable(response)
	local sceneGroup = self.view

	--Call engine and assign variables to values
	local gold = 0
	local lvls_achieved = 0
	local level = {}
	self.images = {}

	if engine.player_id then
		local gameStatus = engine.call("players/game_data", "POST", {id=engine.player_id, levels="true", currencies="true"})
	
	gold = gameStatus['currencies']['oro']['quantity']
	lvls_achieved = table.getn(gameStatus['levels_completed'])
	level = gameStatus['levels']['xp']
	end
	
	local baseHeight = 173

	--Player coins
	local playerCoinIcon = display.newImageRect( sceneGroup, "coins_white.png", 15, 18 )
	playerCoinIcon.anchorX = 1
	playerCoinIcon.x = 310
	playerCoinIcon.y = 90

	local playerCoin = display.newText( sceneGroup, gold, playerCoinIcon.x - 25, 90, "Arial", 15 )
	playerCoin:setFillColor( 0.30 )
	playerCoin.anchorX = 1


	mpspinner:removeSelf()
	mpspinner = nil

	local function rowRender(event)
		local row = event.row 
		local promo = event.row.params['promo']
		local gold = event.row.params['gold']
		local level = event.row.params['level']
		local lvls_achieved = event.row.params['lvls_achieved']
		local price = promo['price']

		local function showDetails(e)
			local thisPromo = e.target.promo
			local price = e.target.price

			local function rowDetailRender(event)
				local row = event.row
				local params = event.row.params

				local function openURL( event )
					local url = event.target.text
					system.openURL( url )
				end
				
				local textOptions = {
					parent = row,
					text = "",
					x = 110,
					y = row.height / 2,
					width = 160,
					height = 0,
					font = "Arial",
					fontSize = 16,
					align = "center"
				}
			
									-- CREATE DETAIL DISPLAY
				-- BACK OF IMAGE BOX
				if params['isBox'] then
					local backBox = display.newRect( row, 0, 0, 320, 133 )
					backBox:setFillColor( 0.90 )
					backBox.anchorX = 0
					backBox.anchorY = 0
					
					--Check if there is file
					local path = system.pathForFile( thisPromo.id.."_marketpromo.png", system.TemporaryDirectory )
					print(path)
					local f=io.open(path,"r")
   					if f~=nil then 
   						io.close(f) 
   						local detailImage = display.newImage( row, thisPromo.id.."_marketpromo.png", system.TemporaryDirectory, backBox.x, backBox.y)
   						detailImage.anchorX = 0
   						detailImage.anchorY = 0
   						detailImage.width = backBox.width
   						detailImage.height = backBox.height
   					else 
   						--load Image
   						print('DOESNT EXISTS')
   					end
				end
				if params['remaining'] then
					local remainingT = "Quedan " .. params['remaining'] .. " promo(s)"
					local remaining = display.newText( row, remainingT, 160, row.height * 0.5, "Arial", 14 )
					remaining:setFillColor( 0 )
				end
				if params['short'] then
					local shortT = params['short']
					local short = display.newText( row, shortT, 160, row.height * 0.5, 300, 0, "Arial", 13 )
					short:setFillColor( 0.3 )
				end
				
				
				if params['payment'] then
					local price = display.newText( row, params.payment, 75, row.height / 2, "Arial", 14 )
					price.anchorX = 0
					price:setFillColor( 0.2 )

					local coinIcon = display.newImageRect( row, "coins.png", 16, 14 )
					coinIcon.anchorX = 1
					coinIcon.x = 65
					coinIcon.y = row.height / 2 - 4

					if engine.player_id then
						if gold >= params['payment']  then

							local function payCoins(event)
								overlayGroup = display.newGroup( )

								local overLay = display.newRoundedRect( 160, 240, 300, 120, 10 )
								overLay:setFillColor( 1 )
								overLay:setStrokeColor( 0.2 )
								overLay.strokeWidth = 2
							
								local url = G_baseUrl .. "payment/" .. event.target.id 
								local body = "id_in_engine=" .. engine.player_id .. "&gold=" .. params.payment
							
								local response = {}
								local a, b, c = http.request{
									url = url,
									method = "PUT",
									source = ltn12.source.string(body),
									headers = {
										["Accept"] = "*/*",
										["Authorization"] = "Token token=F2pR0cks", 
										["Content-Type"] = "application/x-www-form-urlencoded",
										["content-length"] = string.len(body)
									},
									sink = ltn12.sink.table(response)
								}	
								response = json.decode(response[1])

								local msgR = display.newText( response.status, overLay.x, overLay.y - 27, 250, 0, "Arial", 16 )
								msgR:setFillColor( 0.1 )

								local button = display.newRoundedRect( 160, 270, 120, 32, 5 )
								button:setFillColor(  0.27, 0.65, 0.61  )
								local btnMsg = display.newText( "Cerrar", button.x, button.y, "Arial", 15 )

								local function reload (event)
									overlayGroup:removeSelf( )
									overlayGroup = nil

									local currScene = composer.getSceneName( "current" )
									composer.gotoScene( currScene )
								end

								button:addEventListener( "tap", reload )

								overlayGroup:insert(overLay)
								overlayGroup:insert(msgR)
								overlayGroup:insert(button)
								overlayGroup:insert( btnMsg )

							
							end

							local button = widget.newButton( {
    							label="Reclama",
    							onRelease=payCoins,
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
    						button.id = params.id
    						row:insert( button )
						else 
							local getMore = display.newText( row, "Consigue más monedas", 200, row.height / 2, "Arial", 13 )
							getMore:setFillColor( 0.3 )
						end
					else 
						local function goToRegister(event)
							composer.gotoScene( "register", {params={prev="virtual"}}  )
						end

						local regBtn = display.newRoundedRect( row, 200, row.height / 2 , 100, 30, 5 )
						regBtn:setFillColor( 0.27, 0.65, 0.61  )
						local regText = display.newText( row, "Ingresa", regBtn.x, regBtn.y, "Arial", 14 )
						regBtn:addEventListener( "tap", goToRegister )
					end
				end 
				
				textOptions.x = 160
				textOptions.align = "left"
				textOptions.fontSize = 13
				textOptions.width = 290

				if params['title'] then
					textOptions.text = params['title']
					textOptions.y = row.height * 0.8
					local long_title = display.newText( textOptions )
					long_title:setFillColor( 0.2 )
				end
				if params['block'] then
					textOptions.text = params['block']
					textOptions.y = row.height * 0.5
					local longT = display.newText( textOptions )
					longT:setFillColor( 0.3 )
				end
				if params['column'] then
					local text = params['column'] .. params['cell']
					local infoText = display.newText( row, text, 160, row.height/2, "Arial", 14 )
					infoText:setFillColor( 0.27, 0.65, 0.61 )
					if params['listen'] then
						infoText:addEventListener( "tap", openURL )
					end
				end
			end

			local function tableListener(event)
				local start = event.xStart
			
				local function backToPromos(event)
					virtualMarket:remove(promosDetail)
				end

				if event.phase == "ended" then
				-- BACK TO PROMOS
					if event.x > start then
						if event.x - start > 100 then
							transition.to(virtualMarket, {time=300, x=virtualMarket.x + 320, onComplete=backToPromos})
						end
					end
				end
			end


			local optionsTable = {
    			x = 480,
    			y = 272.5,
    			width = 320,
    			height = 325,
    			onRowRender = rowDetailRender,
    			listener = tableListener,
    			noLines = true
			}
			local promosDetail = widget.newTableView( optionsTable )
			virtualMarket:insert(promosDetail)

			-- insert into ROWS
			--insert Rows
			promosDetail:insertRow({rowHeight=133, params={isBox=true}})
			promosDetail:insertRow({rowHeight=23, params={remaining=thisPromo.promo_qty}})
		
			promosDetail:insertRow({rowHeight=checkRowHeight(thisPromo.short_description, "Arial", 13, 300), params={short=thisPromo.short_description}})
			--social
			promosDetail:insertRow( {rowHeight=50, params={payment=price, id=thisPromo.id}} )
			--description
			promosDetail:insertRow( {rowHeight=25, params={title="DESCRIPCIÓN:"}} )
			promosDetail:insertRow({rowHeight=checkRowHeight(thisPromo.long_description, "Arial", 13, 300), params={block=thisPromo.long_description}})
			--conditions
			promosDetail:insertRow( {rowHeight=25, params={title="CONDICIONES:"}} )
			promosDetail:insertRow({rowHeight=checkRowHeight(thisPromo.conditions, "Arial", 13, 300), params={block=thisPromo.conditions}})
			--Associate
			promosDetail:insertRow( {rowHeight=25, params={title="NUESTRO ASOCIADO:"}} )
			local associate = thisPromo['associate']
			promosDetail:insertRow( {rowHeight=25, params={column="", cell=associate['name']}} )
			promosDetail:insertRow( {rowHeight=20, params={column="Tel: ", cell=associate['phone'], listen=associate['phone']}} )
			promosDetail:insertRow( {rowHeight=20, params={column="", cell=associate['address']}} )
			promosDetail:insertRow( {rowHeight=20, params={column="", cell=associate['website'], listen=associate['website']}} )

			transition.to(virtualMarket, {time=300, x = virtualMarket.x - 320})
		end

		bgBox = display.newRect( row, 0, 0, 320, row.height - 10)
		bgBox:setFillColor( 0.96 )
		bgBox.anchorX = 0
		bgBox.anchorY = 0
		bgBox.x = 5
		bgBox.y = 0
		bgBox.lvl_achieved = false
		bgBox.promo = promo

		if promo['level'] ~= nil then
			local perc_disc = (100 - promo['level_discount']) * price / 100
			if lvls_achieved >= promo['level'] - 1 then
				price = math.floor(perc_disc)
				bgBox.lvl_achieved = true
			end
		end

		bgBox.price = price
		bgBox:addEventListener( "tap", showDetails )

		backBox = display.newRect( row, 0, 0, 320, 133 )
		backBox:setFillColor( 0.90 )
		backBox.anchorX = 0
		backBox.anchorY = 0
		backBox.x = 5
		backBox.y = 0

		--code for IMAGES here
		print(promo.mobile_photo)
		if promo.mobile_photo ~= nil and promo.mobile_photo ~= "/images/original/missing.png" then
							
			local function displayImg(event)
				if event.phase == "ended" then
					print("DOWNLOADED")
					local image = display.newImage( row, event.response.filename, event.response.baseDirectory, 160, 1)
					image.anchorY = 0
					image.width = 320
					image.height = 133
				end
			end

			local imgFilename = promo.id.."_marketpromo.png"
			local path = system.pathForFile( imgFilename, system.TemporaryDirectory )
			print(path)
			local f=io.open(path,"r")
   			if f~=nil then 
   				io.close(f)
   				local detailImage = display.newImage( row, imgFilename, system.TemporaryDirectory, 160, 1)
   				detailImage.anchorY = 0
   				detailImage.width = 320
   				detailImage.height = 133
   			else 
   				self.images[promo.id] = network.download( promo.mobile_photo, "GET", displayImg, imgFilename, system.TemporaryDirectory )
			end 
		end
		

		local textOptions = {
				parent = row,
				text = promo['short_description'],
				x = 12,
				y = 160,
				width = 300,
				height = 20,
				font = "Arial",
				fontSize = 14,
				align = "left"
			}

		local short = display.newText( row, promo.short_description, 15, backBox.height + 10, 285, 0, "Arial", 13 )
		short:setFillColor( 0 )
		short.anchorX = 0
		short.anchorY = 0

		local priceText = display.newText( row, "Precio: "..price, 15, row.height - 20, "Arial", 14 )
		priceText.anchorX = 0
		priceText.anchorY = 1
		priceText:setFillColor( 0 )

		local coinIcon = display.newImageRect( row, "coins.png", 18, 16 )
		coinIcon.anchorY=1
		coinIcon.anchorX=0
		coinIcon.x = priceText.width + 20
		coinIcon.y = priceText.y

		local qty = display.newText( row, "Quedan: ".. promo.promo_qty, row.width - 20, row.height - 20, "Arial", 14 )
		qty:setFillColor( 0.4 )
		qty.anchorX = 1
		qty.anchorY = 1


	end

	local function tableListener(event)

	end

	local optionsTable = {
    		x = 158,
    		y = 272.5,
    		width = 320,
    		height = 325,
    		onRowRender = rowRender,
    		noLines = true
	}
	local marketPromos = widget.newTableView( optionsTable )
	virtualMarket:insert(marketPromos)
	

	-- Insert Rows
	for index, promo in pairs(response) do
		marketPromos:insertRow({rowHeight=checkRowHeight(promo.short_description .. "...", "Arial", 13, 280) + baseHeight, params={promo=promo, gold=gold, level=level, lvls_achieved=lvls_achieved}})
	end
end


---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene

