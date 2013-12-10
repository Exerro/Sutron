function getFileName( file )
  local path = game.explode( file, "/" )
  local filename = game.explode( path[#path], "." )
  table.remove( filename, #filename )
  return table.concat( filename, "." )
end

function loadImage( file )
  game.mask[getFileName( file )] = love.graphics.newImage( file )
  return game.mask[getFileName( file )]
end

function newCollisionMap( file )
  local maskname = getFileName( file )
  local imageData = love.image.newImageData( file )
  
  game.mask[maskname] = { }
  for x = 1, imageData:getWidth() do
    game.mask[maskname][x] = { }
    for y = 1, imageData:getHeight() do
      game.mask[maskname][y] = (  { imageData:getPixel(x,y) }[4] == 0 )
    end
  end
  
  return game.mask[maskname]
end
