-- ENGINE CALL BY API
local mime = require("mime")
local json = require("json")
local http = require("socket.http")
local ltn12 = require( "ltn12" )
local utils = require("utils")
local multiform = require "libs.multiform"
local engine = {}
print("ENGINE module loaded")


local function buildUrl(service, parameters)
	local body = "?"
	if parameters then
		for key,value in pairs(parameters) do
			if #body > 0 then 
				body = body .. "&"
			end
			body = body .. key .. "=" .. require("socket.url").escape(value)
		end
	end
	return "http://playngage.io/api/" .. service .. body
end

engine.upload = function(service, player_id, filename)
	--local player_id = 1 -- FOR TEST
	print("UPLOAD")
	local boundary = "MPFD-"..crypto.digest( crypto.sha1, "MultipartFormData"..tostring(object)..tostring(os.time())..tostring(os.clock()), false )
	--local url =  "http://localhost:4003/api/" .. service -- FOR TEST
	local url =  "http://playngage.io/api/" .. service

	local pre = "--"..boundary.."\r\n"
	local pos = "--"..boundary.."--\r\n"

	local file = io.open( system.pathForFile( filename, system.DocumentsDirectory ), "rb" )
	local content = file:read("*all")
	file:close()

	local body = pre.."Content-Disposition: form-data; name=\"avatar\"; filename=\"".. filename..  "\"\r\n" ..
		"Content-Transfer-Encoding: binary\r\n" ..
		"Content-Type: image/png\r\n" ..
		"\r\n" .. content ..
		"\r\n"

	body = body .. pre .. "Content-Disposition: form-data; name=\"player_id\"\r\n" ..
		"\r\n" .. player_id ..
		"\r\n" 

	body = body .. pos

	local response = {}
	local a, b, c = http.request{
		url = url,
		method = "POST",
		source = ltn12.source.string(body), 
		headers = {
			["Accept"] = "*/*",
			["Authorization"] = "Token token=37b431bd6b9e9f5883b95e3d6d9e5cab", 
			--["Authorization"] = "Token token=5b97ecdcccad92fac0f85383d3858d9b", -- FOR TEST
			["Content-Type"] = "multipart/form-data; boundary="..boundary,
			["content-length"] = string.len(body)},
		sink = ltn12.sink.table(response)
	}
	print("RESPONSE IN LIB: ")
	local joined = ""
	if #response > 0 then
		for i = 1, #response do
			joined = joined .. response[i]
		end
	end
	local data = json.decode(joined)
	utils.print_r(data)
	return data
end

engine.call = function(service, method, parameters)
	print("CALL")
	local url = buildUrl(service, parameters)

	local response = {}
	local a, b, c = http.request{
		url = url,
		method = method,
		headers = {
			["Accept"] = "*/*",
			["Authorization"] = "Token token=37b431bd6b9e9f5883b95e3d6d9e5cab", 
			["Content-Type"] = "application/json"},
		sink = ltn12.sink.table(response)
	}
	response = json.decode(response[1])
	print("RESPONSE CALL")
	return response
end

engine.async = function(service, parameters)
	print("ASYNC ".. service)
	return buildUrl(service, parameters), {["Authorization"] = "Token token=37b431bd6b9e9f5883b95e3d6d9e5cab", ["Accept"] = "*/*", ["Content-type"] = "application/x-www-form-urlencoded"}
end

local function async(service, parameters)
	return buildUrl(service, parameters), {["Authorization"] = "Token token=37b431bd6b9e9f5883b95e3d6d9e5cab", ["Accept"] = "*/*", ["Content-type"] = "application/x-www-form-urlencoded"}
end

engine.send_accomplishment = function(parameters, tag_type)
	local service = "accomplishments" 
	if tag_type then
		sevice = service .. "/tag_type"
	end
	local url, headers = async(service, parameters)

	local accomplishmentSent = function(e)
		utils.print_r(e)
		if not e.isError then
			print("ACCOMPLISHMENT SENT")
		end
	end

	local request = network.request( url, "POST", accomplishmentSent, {headers=headers} )
end


engine.getPlayerId = function(id)
	local file

	local path = system.pathForFile( "player.txt", system.DocumentsDirectory )

	local function checkId()
		file = io.open(path, "r")

		if file then
			local savedData = file:read( "*a" )
			io.close(file)
			file = nil

			print("Saved Data: "..savedData)
			if savedData == "No content" then
				return nil 
			else
				if id then
					if tostring(id) ~= savedData then
						print("CHECKING NEW ID")
						return nil
					else
						return savedData
					end
				else
					return savedData
				end
				
			end
		end
	end

	local checked = checkId()
	
	if not checked then
		file = io.open(path, "w")
		if id then
			file:write(tostring(id))
		else
			file:write("No content")
		end

		io.close(file)

		return checkId()
	else
		return checked
	end

	return nil
end

engine.player_id = engine.getPlayerId()


return engine