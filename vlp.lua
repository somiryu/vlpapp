-- ENGINE CALL BY API
local mime = require("mime")
local json = require("json")
local http = require("socket.http")
local ltn12 = require( "ltn12" )
local vlp = {}

vlp.baseUrl = "http://www.vivelapromo.com/api/"
--vlp.baseUrl = "http://localhost:3000/api/"

local spinnerOptions = {
	width = 30,
    height = 30,
    numFrames = 1,
    sheetContentWidth = 30,
    sheetContentHeight = 30
}

local spinnerSheet = graphics.newImageSheet( "images/spinner.png", spinnerOptions )

vlp.spinOpt = {
	width=30,
	height=30,
	sheet=spinnerSheet,
	startFrame=1,
	deltaAngle=15,
	incrementEvery=10
}


local function buildBody(parameters)
	local body = ""
	if parameters then
		for key,value in pairs(parameters) do
			if #body > 0 then
				body = body .. "&"
			end
			body = body .. key .. "=" .. require("socket.url").escape(value)
		end
	end
	return body
end

vlp.call = function(service, method, parameters)

	local url = vlp.baseUrl .. service
	local body = buildBody(parameters)

	local response = {}
	local a, b, c = http.request{
		url = url,
		method = method,
		source = ltn12.source.string(body),
		headers = {
			["Accept"] = "*/*",
			["Authorization"] = "Token token=F2pR0cks",
			["Content-Type"] = "application/x-www-form-urlencoded",
			["content-length"] = string.len(body)},
		sink = ltn12.sink.table(response)
	}
	response = json.decode(response[1])
	return response
end

vlp.async = function(service, parameters)
	local body = buildBody(parameters)
	local url = vlp.baseUrl .. service .. "?" .. body
	print("URL IS HERE")
	print(url)
	return url, {["Authorization"] = "Token token=F2pR0cks", ["Accept"] = "*/*", ["Content-type"] = "application/x-www-form-urlencoded"}
end

return vlp
