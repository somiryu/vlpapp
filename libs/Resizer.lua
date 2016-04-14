---------
-- Resizer.Lua
-- Author: Felipe Botero Londoño
---------
local Resizer = {}

Resizer.resize = function(image, width, height, resizeType, filename, baseDirectory)
	--Original Properties
	local originalParent = image.parent
	local originalWidth = image.width
	local originalHeight = image.height
	local originalPositionX = image.x
	local originalPositionY = image.y

	--Reset position
	image.x = 0
	image.y = 0
	
	baseDirectory = baseDirectory or system.DocumentsDirectory
	resizeType = resizeType or "crop"
	
	print("Generando imagen de "..width.."x"..height)
	
	local containerWidth = width * display.contentScaleX
	local containerHeight = height * display.contentScaleY
	print("El container mide "..containerWidth.."x"..containerHeight)
	
	local container = display.newContainer(containerWidth, containerHeight)
	container.x = display.contentCenterX
	container.y = display.contentCenterY
	container:insert(image)
	
	local originalAspectRatio = originalWidth/originalHeight
	local newAspectRatio = width/height
	print("OriginalAspectRatio "..originalAspectRatio)
	print("NewAspectRatio "..newAspectRatio)
	
	if(resizeType == "crop") then		
		if(newAspectRatio > originalAspectRatio) then	--Adjust width and cut top/bottom
			print("New aspect ratio is bigger, adjusting image to "..containerWidth)
			image.width  = containerWidth
			image.height = containerWidth/originalAspectRatio
		else
			print("Original aspect ratio is equal/bigger, adjusting image to "..containerHeight)
			image.height = containerHeight
			image.width = containerHeight*originalAspectRatio
		end
	end
	print("new image size "..image.width.."x"..image.height)
	display.save(container, {
		filename = filename,	
		baseDir = baseDirectory, 
		backgroundColor = {1,1}, --Background color
		isFullResolution = true	--save all displayObject and not only visible part inside scene
	})
	
	--Restore image properties
	originalParent:insert(image)
	image.width = originalWidth
	image.height = originalHeight
	image.x = originalPositionX
	image.y= originalPositionY
	
	container:removeSelf();
	print("termino el proceso")
end

Resizer.resize_no_save_or_restore = function(image, width, height, resizeType)
	--Reset position
	image.x = 0
	image.y = 0
	
	baseDirectory = baseDirectory or system.DocumentsDirectory
	resizeType = resizeType or "crop"
	
	
	local containerWidth = width
	local containerHeight = height
	print("El container mide "..containerWidth.."x"..containerHeight)
	
	local container = display.newContainer(containerWidth, containerHeight)
	container.x = display.contentCenterX 
	container.y = display.contentCenterY
	container:insert(image)
	
	local originalAspectRatio = image.width/image.height
	local newAspectRatio = width/height
	print("OriginalAspectRatio "..originalAspectRatio)
	print("NewAspectRatio "..newAspectRatio)
	
	if(resizeType == "crop") then		
		if(newAspectRatio > originalAspectRatio) then	--Adjust width and cut top/bottom
			print("New aspect ratio is bigger, adjusting image to "..containerWidth)
			image.width  = containerWidth
			image.height = containerWidth/originalAspectRatio
		else
			print("Original aspect ratio is equal/bigger, adjusting image to "..containerHeight)
			image.height = containerHeight
			image.width = containerHeight*originalAspectRatio
		end
	end
	print("new image size "..image.width.."x"..image.height)


	print("termino el proceso")
	return container
end

return Resizer