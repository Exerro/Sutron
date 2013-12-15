

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

