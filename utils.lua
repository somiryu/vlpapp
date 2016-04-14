local json = require("json")

utils = {
        ----------------------------------------------------------
        printTable = function(t)
                if nil == t then return end
                for k, v in pairs(t) do
                        if "table" == type(v) then
                                local s = ""
                                for k2, v2 in pairs(v) do
                                        s = s .. ("table" ~= type(v2) and tostring(v2) or "{..}") .. " "
                                end
                                print(k, s)
                        else
                                print(k, v)
                        end
                end
        end,

        ----------------------------------------------------------
        printDisplayObject = function(obj)
                print("x="..obj.x, "y="..obj.y, "xOr="..obj.xOrigin, "yOr="..obj.yOrigin, "xRef="..obj.xReference, "yRef="..obj.yReference, "w="..obj.width, "h="..obj.height)
        end,

        ----------------------------------------------------------
        printMemoryUsed = function()
           collectgarbage( "collect" )
           local memUsage = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )
           print( memUsage, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
        end,

        ----------------------------------------------------------
        saveTable = function(t, filename)
                local path = system.pathForFile(filename, system.DocumentsDirectory)
                local file = io.open(path, "w")
                if file then
                        local contents = json.encode(t)
                        file:write(contents)
                        io.close( file )
                        return true
                else
                        return false
                end
        end,

        ----------------------------------------------------------
        loadTable = function(filename)
                local path = system.pathForFile( filename, system.DocumentsDirectory)
                local contents = ""
                local myTable = {}
                local file = io.open( path, "r" )
                if file then
                        -- read all contents of file into a string
                        local contents = file:read( "*a" )
                        myTable = json.decode(contents);
                        io.close( file )
                        return myTable 
                end
                return nil
        end,

        ----------------------------------------------------------
        copyTable = function(t)
          local t2 = {}
          for k,v in pairs(t) do
            t2[k] = v
          end
          return t2
        end,

        ----------------------------------------------------------
        distance = function(a, b)
                return ((a.x - b.x)^2 + (a.y - b.y)^2)^0.5
        end,

        ----------------------------------------------------------
        getPhysicsData = function(shapesPath, sheetPath, scale)
                print("getPhysicsData")
                local scale = scale or 1
                local physicsData = (require(shapesPath)).physicsData(scale)
                local sheetInfo = require(sheetPath)
                local visualInfo

                for k, _ in pairs(physicsData.data) do
                        visualInfo = sheetInfo:getSheet().frames[sheetInfo:getFrameIndex(k)]
                        for i = 1, #physicsData.data[k] do
--                                _utils.printTable(physicsData.data[k])
                                for j = 1, #physicsData.data[k][i].shape do
                                        if 1 == j % 2 then        -- x coordinate
                                                physicsData.data[k][i].shape[j] = physicsData.data[k][i].shape[j] + sheetInfo:getSheet().sheetContentWidth / 2 - (visualInfo.x + visualInfo.width / 2)
                                        else        -- y coordinate
                                                physicsData.data[k][i].shape[j] = physicsData.data[k][i].shape[j] + sheetInfo:getSheet().sheetContentHeight / 2 - (visualInfo.y + visualInfo.height / 2)
                                        end
                                end
                        end
                end
                
                return physicsData
        end,
		
		PointInsideBounds = function(x,y, bounds)
			local isInside = x >= bounds.xMin and x<=bounds.xMax and y >= bounds.yMin and y<=bounds.yMax 
			if(isInside)then
				--print (x,y,"esta dentro de", bounds.xMin, bounds.yMin, bounds.xMax, bounds.yMax)
			end
			return(isInside)
		end,
		
		print_r = function( t )  
			local print_r_cache={}
			local function sub_print_r(t,indent)
				if (print_r_cache[tostring(t)]) then
					print(indent.."*"..tostring(t))
				else
					print_r_cache[tostring(t)]=true
					if (type(t)=="table") then
						for pos,val in pairs(t) do
							if (type(val)=="table") then
								print(indent.."["..pos.."] => "..tostring(t).." {")
								sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
								print(indent..string.rep(" ",string.len(pos)+6).."}")
							elseif (type(val)=="string") then
								print(indent.."["..pos..'] => "'..val..'"')
							else
								print(indent.."["..pos.."] => "..tostring(val))
							end
						end
					else
						print(indent..tostring(t))
					end
				end
			end
			if (type(t)=="table") then
				print(tostring(t).." {")
				sub_print_r(t,"  ")
				print("}")
			else
				sub_print_r(t,"  ")
			end
			print()
		end,
}

return utils