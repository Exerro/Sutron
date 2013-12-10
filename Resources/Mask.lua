function getFileName( file )
  local path = game.explode( file, "/" )
  local filename = game.explode( path[#path], "." )
  table.remove( filename, #filename )
  return table.concat( filename, "." )
end

function loadImage( file )
  game.mask.image[getFileName( file )] = love.graphics.newImage( file )
  return game.mask.image[getFileName( file )]
end

function newCollisionMap( file )
  local maskname = getFileName( file )
  local imageData = love.image.newImageData( file )
  
  game.mask.data.collision[maskname] = { }
  for x = 1, imageData:getWidth() do
    game.mask.data.collision[maskname][x] = { }
    for y = 1, imageData:getHeight() do
      game.mask.data.collision[maskname][x][y] = (  { imageData:getPixel(x,y) }[4] == 0 )
    end
  end
  
  return game.mask.data.collision[maskname]
end
