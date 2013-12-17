

game.physics = { }
game.physics.collisionRR = function( r1, r2 )
	local x, y, w, h = r1.x, r1.y, r1.w, r1.h
	local x2, y2, w2, h2 = r2.x, r2.y, r2.w, r2.h
	local t, b
	if y2 > y then
		t, b = y2, y + h - 1
	else
		t, b = y, y2 + h2 - 1
	end
	if t > b then return false end
	local l, r
	if x2 > x then
		r, l = x2, x + w - 1
	else
		r, l = x, x2 + w2 - 1
	end
	if l < r then return false end
	return true, l, r, b, t
end

game.physics.collisionBERR = function( entity, blockx, blocky )
	local b = { x = blockx * game.blockSize, y = blocky * game.blockSize, w = game.blockSize, h = game.blockSize }
	return game.physics.collisionRR( entity, b )
end

game.physics.collisionPM = function( x, y, xo, yo, m )
	return m[y-yo] and m[y-yo][x-xo]
end

game.physics.collisionMM = function( m1, m2, xo, yo, xs, ys, xl, yl )
	local xo, yo = xo or 0, yo or 0
	local xs, ys = xs or 1, ys or 1
	local xl, yl = xl or #m1[1], yl or #m1
	for y = ys, yl do
		for x = xs, xl do
			if m1[y] and m1[y][x] then
				if game.physics.collisionPM( x, y, xo, yo, m2 ) then
					return true, x, y
				end
			end
		end
	end
	return false
end

game.physics.collisionY = function( amount, entity1, entity2 )
	local e1x, e1y, e1w, e1h, e2x, e2y, e2w, e2h
	if entity1.majorType == "Block" then
		if not entity1.solid then return false, "None" end
		e1x, e1y = entity1:getRealXY( )
		e1w, e1h = game.blockSize, game.blockSize
	else
		e1x, e1y = entity1.x, entity1.y
		e1w, e1h = entity1.w, entity1.h
	end
	if entity2.majorType == "Block" then
		if not entity2.solid then return false, "None" end
		e2x, e2y = entity2:getRealXY( )
		e2w, e2h = game.blockSize, game.blockSize
	else
		e2x, e2y = entity2.x, entity2.y
		e2w, e2h = entity2.w, entity2.h
	end
	e2y = e2y + amount
	e1m = entity1:getCollisionMap( )
	e2m = entity2:getCollisionMap( )
	local col, l, r, t, b = game.physics.collisionRR( { x = e1x, y = e1y, w = e1w, h = e1h }, { x = e2x, y = e2y, w = e2w, h = e2h } )
	if not col then return false, "None" end
	local xo, yo = e2x - e1x, e2y - e1y
	local col, x, y = game.physics.collisionMM( e1m, e2m, xo, yo )
	if not col then return false, "Rectangle" end
	return true, x, y
end

