
game.explode = function(d,p)
	local t, ll
	t={}
	ll=0
	if(#p == 1) then return {p} end
	while true do
		l=string.find(p,d,ll,true) -- find the next d in the string
		if l~=nil then -- if not "not found" then..
			table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
			ll=l+1 -- save just after where we found it for searching next time.
		else
			table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
			break -- Break at end, as it should be, according to the lua manual.
		end
	end
	return t
end

game.split = function( str, pat )
	if type( str ) ~= "string" then error( "Failed to split "..type( str ).." with "..pat, 2 ) end
	local parts = { }
	local last = 1
	for i = 1,str:len( ) do
		if str:sub( i, i + #pat - 1 ) == pat and last ~= i then
			table.insert( parts, str:sub( last, i-1 ) )
			last = i + 1
		end
	end
	if last <= #str then
		table.insert( parts, str:sub( last, #str ) )
	end
	return parts
end

math.round = function( n )
	return math.floor( n + 0.5 )
end

game.data = { }

local function getFileName( file )
	local path = game.split( file, "/" )
	local filename = game.split( path[#path], "." )
	if #filename > 1 then
		table.remove( filename, #filename )
	end
	return table.concat( filename, "." )
end

local function getFilePath( file )
	local name = game.split( file, "/" )
	name = name[#name]
	local parts = game.split( name, "." )
	if #parts > 1 then
		return parts[#parts]
	end
	return false
end

local loadPath
loadPath = function( path, t )
	local files = love.filesystem.enumerate( path )
	for i = 1,#files do
		if love.filesystem.isDirectory( path.."/"..files[i] ) then
			t[files[i]] = { }
			loadPath( path.."/"..files[i], t[files[i]] )
		else
			local ext = getFilePath( files[i] )
			local name = getFileName( files[i] )
			t[name] = { }
			if ext == "png" then
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
			elseif ext == "txt" then
				t[name].text = love.filesystem.lines( path.."/"..files[i] )
			end
		end
	end
end

loadPath( "Resources/Data", game.data )
