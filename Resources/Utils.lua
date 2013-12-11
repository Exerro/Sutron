
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
