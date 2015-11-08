-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local json = require("json")
local engine = require("engine")
local vlp = require("vlp")

local promo_id
local showingDetails = false

scene.categories = {}

local function openURL( event )
	local url = event.target.url
	system.openURL( url )
end


function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end



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
	bg:setFillColor( 1 )
	sceneGroup:insert(bg)

	local topBar = display.newRect( 160, 90, display.contentWidth, 40 )
	topBar:setFillColor( 0.94, 0.94, 0.94 )
	selected = display.newRect( 160, 90, 160, 40 )
	selected:setFillColor( 0.79, 0.79, 0.79 )
	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert(topBar)
	sceneGroup:insert(selected)
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
		--self.getPromos()
		local showDetails = false
		local scrolling = false
		local categoriesTable
		local categoryMenu
		local params = {}
		local headers = {}
		headers["Authorization"] = "Token token=F2pR0cks"
		headers["Accept"] = "*/*"
		headers["Content-type"] = "application/x-www-form-urlencoded"
		params.headers = headers

		self.requests = {}
		self.images = {}
		self.quedan = {}
		self.quedanDetail = {}


		local spinnerMain = widget.newSpinner( vlp.spinOpt )
		sceneGroup:insert(spinnerMain)
		spinnerMain:start()
		spinnerMain.y = 240
		spinnerMain.x = 160


		-- SHOW PROMO DETAILS

		local function showDetails(event)
			local promo = event.target.promo

			-- SOCIAL PAYMENT
			local function socialActivate(event)
				local promoToSend = event.target.promo_id

				local function socialPayment(event)
					print("socialPayment Function")
					print(event.action)

					if event.action == "sent" or event.action == "cancelled" then

						-- CALL SEND VOUCHER API
						local function voucherSent(event)
							local text = ""
							if event.isError then
								text = "Error enviando"
							else
								local response = json.decode(event.response)
								text = response.status
								if self.quedan[promoToSend] and response.new_qty then
									self.quedan[promoToSend].text = "Quedan: ".. response.new_qty
									self.quedanDetail[promoToSend].text = "Quedan: ".. response.new_qty .. " promo(s)"
								end
							end

							local overlayGroup = display.newGroup( )

							local overLay = display.newRoundedRect( 160, 240, 300, 120, 10 )
							overLay:setFillColor( 1 )
							overLay:setStrokeColor( 0.2 )
							overLay.strokeWidth = 2

							local msgR = display.newText( text, overLay.x, overLay.y - 27, 250, 0, "Arial", 16 )
							msgR:setFillColor( 0.1 )

							local button = display.newRoundedRect( 160, 270, 120, 32, 5 )
							button:setFillColor(  0.27, 0.65, 0.61  )
							local btnMsg = display.newText( "Cerrar", button.x, button.y, "Arial", 15 )

							local function reload (event)
								overlayGroup:removeSelf( )
								overlayGroup = nil

								local currScene = composer.getSceneName( "current" )
								composer.removeScene( currScene )
								composer.gotoScene( currScene )
							end

							button:addEventListener( "tap", reload )

							overlayGroup:insert(overLay)
							overlayGroup:insert(msgR)
							overlayGroup:insert(button)
							overlayGroup:insert( btnMsg )

							------------------------------- SEND ACCOMPLISHMENTS
							local category = promo.category
							category:gsub(" ", "_")
							category:gsub("á", "a")
							category:gsub("é", "e")
							category:gsub("í", "i")
							category:gsub("ó", "o")
							category:gsub("ú", "u")
							category:lower()
							if category == "salud_y_Belleza" then
								category = "salud_belleza"
							end

							engine.send_accomplishment({player_id = engine.player_id, tag = "promo_"}, true)
							engine.send_accomplishment({player_id = engine.player_id, tag = category}, true)
							engine.send_accomplishment({player_id = engine.player_id, tag = associate.name}, true)

						end

						-- CALLING

						--API BY NETWORK REQUEST
						local url, headers = vlp.async("payment", {promo_id = promoToSend, id_in_engine = engine.player_id})
						sending_voucher = network.request( url, "POST", voucherSent, {headers=headers} )

					end
				end

				-- SOCIAL POPUP
				if string.sub(system.getInfo( "model" ), 1, 2) == "iP" then
					print("The model is Apple: use individual service")

					if native.canShowPopup( "social", event.target.social ) then
						print("NATIVE CAN SHOW POPUP")

						local options = {
							service = event.target.social,
							listener = socialPayment,
							url = event.target.url
						}
						if event.target.social == "twitter" then
							options.message = event.target.twitter
						end

						if event.target.img ~= nil then
							options.image = {filename=event.target.img, baseDir=system.TemporaryDirectory }
						end

						native.showPopup( "social", options )
					end
				else
					print("model should be android")
					local serviceName = event.target
					local options = {
						service = "share",
						listener = socialPayment,
						url = event.target.url
					}

					if event.target.img ~= nil then
						options.image = {filename=event.target.img, baseDir=system.TemporaryDirectory }
					end

					native.showPopup( "social", options )
				end
			end


			-- SHOW DETAILS TABLE RENDER AND LISTENER
			if showingDetails == false then
				showingDetails = true
				local detailTable
				-- Details rendering function
				local function detailRender(event)
					local row = event.row
					local params = row.params
					local h = row.height / 2
					local imgFilename = promo.id.. "_promo.png"
					selected:setFillColor( 0.94, 0.94, 0.94 )

					if params.image then
						local imgBox = display.newRect( row, 160, 0, 320, 133 )
						imgBox.anchorY = 0
						imgBox:setFillColor( 0.9 )

						local path = system.pathForFile( imgFilename, system.TemporaryDirectory )
						local f=io.open(path,"r")
   						if f~=nil then
   							io.close(f)
   							local detailImage = display.newImage( row, imgFilename, system.TemporaryDirectory, imgBox.x, imgBox.y)
   							detailImage.anchorY = 0
   							detailImage.width = imgBox.width
   							detailImage.height = imgBox.height
   						end
					end

					if params.remaining then
						if promo.remainingPromos then
							self.quedanDetail[promo.id] = display.newText( row, "Quedan: "..promo.remainingPromos.." promo(s)", 160, h, "Arial", 14 )
							--self.quedanDetail[promo.id].qty = promo.remainingPromos
							self.quedanDetail[promo.id]:setFillColor( 0.4 )
						else
							local remaining = display.newText( row, "Promo ilimitada", 160, h, "Arial", 14 )
							remaining:setFillColor( 0.4 )
						end
					end

					if params.block then
						local short = display.newText( row, params.block, 15, 5, 285, 0, "Arial", 14 )
						short:setFillColor( 0.2 )
						short.anchorX = 0
						short.anchorY = 0
					end

					if params.social then
						if engine.player_id ~= nil then

							local url = "http://vivelapromo.com/promo/"..promo.id
							local text = "¡Compártela para Redimirla!"

							local shareText = display.newText( {parent=row, text=text, x=90, y=h-10, width=130, height=0, font="Arial", fontSize=15, align="center"} )
							shareText:setFillColor(0.4)

							local socialButton = display.newImageRect( row, "facebook_1.png", 40, 35 )
							socialButton.x = 208
							socialButton.y = h - 8
							--socialButton.message = promo.facebook_message
							socialButton.url = url
							socialButton.img = imgFilename
							socialButton.social = "facebook"
							socialButton.promo_id = promo.id
							socialButton:addEventListener( "tap", socialActivate )

							local twitterButton = display.newImageRect( row, "twitter_1.png", 40, 35 )
							twitterButton.x = 258
							twitterButton.y = h - 8
							twitterButton.message = promo.twitter_message
							twitterButton.url = url
							twitterButton.img = imgFilename
							twitterButton.social = "twitter"
							twitterButton.promo_id = promo.id
							twitterButton:addEventListener( "tap", socialActivate )
						else
							local function goToRegister(event)
								composer.gotoScene( "register", {params={prev="promos"}} )
							end
							local regBtn = display.newRoundedRect( row, 160, h - 10, 100, 30, 5 )
							regBtn:setFillColor( 0.27, 0.65, 0.61  )
							local regText = display.newText( row, "Ingresa", regBtn.x, regBtn.y, "Arial", 14 )
							regBtn:addEventListener( "tap", goToRegister )
						end
					end

					if params.title then
						local title = display.newText( row, params.title, 15, 5, 285, 0, "Arial", 14 )
						title:setFillColor( 0 )
						title.anchorX = 0
						title.anchorY = 0
					end

					if params.associate then
						local associate = display.newText( {parent=row, text=params.associate, x=160, y=h, width=280, height=0, font="Arial", fontSize=14, align="center"} )
						associate:setFillColor(0.27, 0.65, 0.61 )
						if params.openUrl then
							associate.url = params.associate
							associate:addEventListener( "tap", openURL )
						end
					end

				end

				local function detailListener(event)
					if event.phase == "ended" then
						local start = event.xStart

						local function hideDetails(event)
							showingDetails = false
							detailTable:removeSelf( )
							detailTable = nil
							scrolling = false
						end

						if event.x > start then
							if event.x - start > 100 then
								scrolling = true
								transition.to(detailTable, {time=300, x=480, onComplete=hideDetails})
								transition.to(categoryMenu, {time=300, alpha = 1})
								selected:setFillColor( 0.79, 0.79, 0.79 )
							end
						end
					end
				end

				local optionsTable = {
    				x = 480,
    				y = 265,
    				width = 320,
    				height = 340,
    				onRowRender = detailRender,
    				listener = detailListener,
    				noLines = true
				}
				detailTable = widget.newTableView( optionsTable )
				sceneGroup:insert(detailTable)

				detailTable:insertRow( {rowHeight=133, params={image = true}} )
				detailTable:insertRow( {rowHeight=30, params={remaining = true}} )
				detailTable:insertRow( {rowHeight=checkRowHeight(promo.short_description, "Arial", 14, 285), params={block = promo.short_description}} )
				detailTable:insertRow( {rowHeight=50, params={social = true}} )
				detailTable:insertRow( {rowHeight=20, params={title="DESCRIPCIÓN"}} )
				detailTable:insertRow( {rowHeight=checkRowHeight(promo.long_description, "Arial", 14, 285), params={block = promo.long_description}} )
				detailTable:insertRow( {rowHeight=20, params={title="CONDICIONES"}} )
				detailTable:insertRow( {rowHeight=checkRowHeight(promo.conditions, "Arial", 14, 285), params={block = promo.conditions}} )
				detailTable:insertRow( {rowHeight=20, params={title="ASOCIADO"}} )
				detailTable:insertRow( {rowHeight=checkRowHeight(promo.associate.name, "Arial", 14, 285) - 10, params={associate = promo.associate.name}} )
				detailTable:insertRow( {rowHeight=checkRowHeight(promo.associate.address, "Arial", 14, 285) - 10, params={associate = promo.associate.address}} )
				detailTable:insertRow( {rowHeight=checkRowHeight(promo.associate.phone, "Arial", 14, 285) - 10, params={associate = promo.associate.phone}} )
				detailTable:insertRow( {rowHeight=checkRowHeight(promo.associate.website, "Arial", 14, 285) - 10, params={associate = promo.associate.website, openUrl=true}} )

				transition.to(detailTable, {time=300, x=160, onComplete=hideDetails})
				transition.to(categoryMenu, {time=300, alpha = 0})
			end


		end

			-- SHOW CATEGORIES AND PROMO LIST

		local function getCategories(event)
			if not event.isError then
				print("NO ERROR GETTING CATEGORIES")
				spinnerMain:removeSelf( )
				spinnerMain = nil

				categoriesLuaTable = json.decode(event.response)
				print(json.encodecategoru)

				categoryMenu = display.newGroup( )
				local categoryTables = display.newGroup( )
				local currentCat = 1
				local x = 160
				local tableX = 160

				sceneGroup:insert(categoryMenu)
				sceneGroup:insert(categoryTables)


				for index, category in pairs(categoriesLuaTable) do

					-- INSERT CATEGORY INTO MENU CATEGORY SCROLL

					local menuItem = display.newText( categoryMenu, string.sub(category, 0, 5) == "Salud" and "Salud" or category, x, 90, "Roboto", 16 )
					menuItem:setFillColor( 0.30 )
					x = x + 160

					local function rowRender(event)
						local row = event.row
						local promo = row.params.promo
						local h = row.params.h

						local bgBox = display.newRect( row, 160, 0, 310, h - 10 )
						bgBox.anchorY = 0
						bgBox:setFillColor( 0.96 )
						bgBox.promo = promo
						bgBox:addEventListener( "tap", showDetails )

						local imgBg = display.newRect( row, 160, 0, 310, 133 )
						imgBg.anchorY = 0
						imgBg:setFillColor( 0.9 )

						local categoryName = display.newText( row, promo.category, 160, imgBg.height / 2, "Arial", 14 )
						categoryName:setFillColor( 0.30, 0.30, 0.30 )

						if promo.mobile_photo ~= nil and promo.mobile_photo ~= "/images/original/missing.png" then

							local function displayImg(event)
								if event.phase == "ended" then
									local image = display.newImage( row, event.response.filename, event.response.baseDirectory, 160, 1)
									image.anchorY = 0
									image.width = 320
									image.height = 133
								end
							end

							local imgFilename = promo.id.."_promo.png"
							local path = system.pathForFile( imgFilename, system.TemporaryDirectory )
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

						local printStringTitle = (string.len(promo.title) < 72) and promo.title or string.sub(promo.title, 0, 72)
						local short = display.newText( row, printStringTitle, 15, imgBg.height + 10, 285, 0, "Arial", 13 )
						short:setFillColor( 0 )
						short.anchorY = 0
						short.anchorX = 0

						if promo.remainingPromos then
							self.quedan[promo.id] = display.newText( row, "Quedan: " .. promo.remainingPromos, 15, bgBox.height - 10, "Arial", 14 )
							self.quedan[promo.id].anchorX = 0
							self.quedan[promo.id].anchorY = 1
							self.quedan[promo.id]:setFillColor( 0.3 )
							--self.quedan[promo.id].qty = promo.remainingPromos
						end

						local function getPriceTitle(id, price)
							if id == 1 then return "Por solo: $" .. comma_value(price) end
							if id == 2 then return "Desde: $" .. comma_value(price) end
							if id == 3 then return "GRATIS" end
						end

						local priceText = display.newText( row, getPriceTitle(promo.price_title_id, promo.price), 305, bgBox.height - 10, "Arial", 16 )
        				priceText:setFillColor( 0.27, 0.65, 0.61 )
        				priceText.anchorX = 1
        				priceText.anchorY = 1

					end

					local function tableListener(event)
						local start = event.xStart

						if event.phase == "ended" and scrolling == false and showingDetails == false then

							local function enableScrolling(event)
								scrolling = false
							end

							local function bounceBack()
								transition.to(categoryMenu, {time=200, x=categoryMenu.x, delay=200, onComplete=enableScrolling})
							end

							if event.x > start then
								if event.x - start > 100 then
									scrolling = true
									if categoriesLuaTable[currentCat - 1] then

										currentCat = currentCat - 1

										transition.to(categoryTables, {time=300, x=categoryTables.x + 320, onComplete=enableScrolling})
										transition.to(categoryMenu, {time=300, x=categoryMenu.x + 160})
									else
										transition.to(categoryMenu, {time=200, x=categoryMenu.x + 40, onComplete=bounceBack()})
									end
								end
							elseif event.x < start then
								if start - event.x > 100 then
									scrolling = true
									if categoriesLuaTable[currentCat + 1] then

										currentCat = currentCat + 1
										transition.to(categoryTables, {time=300, x=categoryTables.x - 320, onComplete=enableScrolling})
										transition.to(categoryMenu, {time=300, x=categoryMenu.x - 160})
									else
										transition.to(categoryMenu, {time=200, x=categoryMenu.x - 40, onComplete=bounceBack()})
									end
								end
							end
						end

					end

					local bgw = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
					bgw.anchorX = 0
					bgw.anchorY = 0
					bgw:setFillColor( 1 )
					sceneGroup:insert(bgw)
					bgw:toBack()

					categoryMenu:addEventListener( "touch", tableListener )
					bgw:addEventListener( "touch", tableListener )

					-- CREATE TABLE VIEW
					local optionsTable = {
    					x = tableX,
    					y = 272.5,
    					width = 320,
    					height = 325,
    					onRowRender = rowRender,
    					listener = tableListener,
    					noLines = true
					}
					tableX = tableX + 320
					local promosTable = widget.newTableView( optionsTable )
					categoryTables:insert(promosTable)

					local spinner = widget.newSpinner( vlp.spinOpt )
					categoryTables:insert(spinner)
					spinner:start()
					spinner.y = 240
					spinner.x = promosTable.x


					local function getPromos(event)
						if not event.isError then
							local promos = json.decode(event.response)
							local baseHeight = 173
							spinner:removeSelf( )
							spinner = nil



							-- insert ROW to TABLE VIEW
							for index, promo in pairs(promos) do
								if promo.promo_count ~= nil then
									promo.remainingPromos = promo.promo_max - promo.promo_count
								end
								local h = checkRowHeight(promo.title, "Arial", 13, 285) + baseHeight
								promosTable:insertRow({rowHeight=checkRowHeight(promo.title .. "...", "Arial", 13, 280) + baseHeight, params={promo=promo, h=h}})
							end
						end
					end


					-- CALL PROMOS FOR THIS CATEOGRY
					local url = vlp.async("promos", {category = category})
					self.requests[index] = network.request( url, "GET", getPromos, params )

				end
			end
		end

		local get_url = vlp.async("promos")
		self.getting_promos = network.request( get_url, "GET", getCategories, params )
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

		if self.getting_promos then
			network.cancel(self.getting_promos)
		end
		for index, request in pairs(self.requests) do
			network.cancel( request )
		end
		for index, image in pairs(self.images) do
			network.cancel( image )
		end
		composer.removeScene( "promos" )
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
