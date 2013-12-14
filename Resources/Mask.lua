game.imageData = { }

local function getFileName( file )
	local path = game.split( file, "/" )
	local filename = game.split( path[#path], "." )
	if #filename > 1 then
		table.remove( filename, #filename )
	end
	return table.concat( filename, "." )
end

local loadPath
loadPath = function( path, t )
	local files = love.filesystem.enumerate( path )
	for i = 1,#files do
		if love.filesystem.isDirectory( path.."/"..files[i] ) then
			t[files[i]] = { }
			loadPath( path.."/"..files[i], t[files[i]] )
		else
			local name = getFileName( files[i] )
			t[name] = { }
			t[name].image = love.graphics.newImage( path.."/"..files[i] )
			t[name].collisionMap = { }
			local imageData = love.image.newImageData( path.."/"..files[i] )
 
			for y = 1, imageData:getHeight( ) do
				t[name].collisionMap[y] = { }
				for x = 1, imageData:getWidth( ) do
					local pixel = { imageData:getPixel( x - 1, y - 1 ) }
					t[name].collisionMap[y][x] = pixel[4] ~= 0
				end
			end
		end
	end
end

function getBlockGroupMask(group) 
	-- generate a collision map based on a block group
end

loadPath( "Resources/Textures", game.imageData )
