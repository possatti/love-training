
function love.load()
  -- Load images.
  -- img = love.graphics.newImage('assets/foobar.png')

  -- Load music/sounds.
  -- music = love.audio.newSource("assets/foorocks.ogg")
  -- music:setVolume(0.8)
  -- music:setLooping(true)
  -- music:rewind()
  -- music:play()

  -- Load fonts.
  bigFont = love.graphics.newFont(40)

  -- Set up quads.
  -- quad = love.graphics.newQuad(0, 0, 32, 32, 128, 128)

  -- Set up mouse.
  -- love.mouse.setVisible(true)
  -- love.mouse.setGrabbed(true)
end

function love.update(dt)
  -- Quit game.
  if love.keyboard.isDown('escape', 'q') then
    love.event.push('quit')
  end
end

function love.draw()
  love.graphics.setBackgroundColor(190, 190, 190, 255)
  love.graphics.setColor(0, 145, 255, 255)
  love.graphics.setFont(bigFont)
  love.graphics.print("Hello World!", love.graphics.getWidth()/2-120, love.graphics.getHeight()/2-50)
end
