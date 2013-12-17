
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
			t[name] = t[name] or { }
			if ext == "png" then
				t[name].image = love.graphics.newImage( path.."/"..files[i] )
				local imageData = love.image.newImageData( path.."/"..files[i] )
			elseif ext == "txt" then
				t[name].text = love.filesystem.lines( path.."/"..files[i] )
			end
			if ext == "scm" or ext == "png" then
				local imageData = love.image.newImageData( path.."/"..files[i] )

				if not t[name].collisionMap or ext == "scm" then
					t[name].collisionMap = { left = { down = { }, up = { } }, right = { down = { }, up = { } } }
					for y = 1, imageData:getHeight( ) do
						t[name].collisionMap.left.down[y] = { }
						for x = 1, imageData:getWidth( ) do
							local pixel = { imageData:getPixel( x - 1, y - 1 ) }
							t[name].collisionMap.left.down[y][x] = pixel[4] ~= 0
						end
					end
					
					for y = 1,#t[name].collisionMap.left.down do
						t[name].collisionMap.right.down[y] = { }
						for x = 1,#t[name].collisionMap.left.down[y] do
							t[name].collisionMap.right.down[y][x] = t[name].collisionMap.left.down[y][#t[name].collisionMap.left.down[1] - x + 1]
						end
					end
					
					for k, v in pairs( t[name].collisionMap ) do
						for y = 1,#v.down do
							v.up[y] = { }
							for x = 1,#v.down[y] do
								v.up[y][x] = v.down[#v.down - y + 1][x]
							end
						end
					end
				end
			end
		end
	end
end

loadPath( "Resources/Data", game.data )
