-- Tutorial: http://osmstudios.com/tutorials/your-first-love2d-game-in-200-lines-part-1-of-3

debug = false

-- Speeds
enemySpeed = 200
bulletSpeed = 400
playerSpeed = 250
groundSpeed = 600

-- Player data
startX = 200
startY = 600
player = { x = startX, y = startY, speed = playerSpeed, img = nil }

-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated
enemies = {} -- array of current enemies on screen
bgTiles = {}

-- math.randomseed( os.time() )

isAlive = true
score = 0

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function love.load(arg)
  -- Images
  player.img = love.graphics.newImage('assets/Aircraft_03.png')
  bulletImg = love.graphics.newImage('assets/bullet_2_orange.png')
  enemyImg = love.graphics.newImage('assets/Aircraft_02.png')
  groundImg = love.graphics.newImage('assets/ground.png')

  -- Sound
  shotSound = love.audio.newSource("assets/gun-sound.wav", "static")
  shotSound:setVolume(0.2)
  shotSound:setPitch(1.5)

  explosionSound = love.audio.newSource("assets/explosion.wav", "static")
  explosionSound:setVolume(0.2)

  bgMusic = love.audio.newSource("assets/bgm_action_4.mp3")
  bgMusic:setVolume(0.8)
  bgMusic:setLooping(true)
  bgMusic:play()

  -- Ground
  local x = 0
  local y = 0
  while y < love.graphics.getHeight() do
    while x < love.graphics.getWidth() do

      newTile = {x = x, y = y, img = groundImg}
      table.insert(bgTiles, newTile)
      x = x + groundImg:getWidth()
    end
    x = 0
    y = y + groundImg:getHeight()
  end
end -- love.load

function love.update(dt)
  -- I always start with an easy way to exit the game
  if love.keyboard.isDown('escape', 'q') then
    love.event.push('quit')
  end

  if love.keyboard.isDown('left','a') then
    if player.x > 0 then -- binds us to the map
      player.x = player.x - (player.speed*dt)
    end
  elseif love.keyboard.isDown('right','d') then
    if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
      player.x = player.x + (player.speed*dt)
    end
  end
  if love.keyboard.isDown('up','w') then
    if player.y > 0 then -- binds us to the map
      player.y = player.y - (player.speed*dt)
    end
  elseif love.keyboard.isDown('down','s') then
    if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
      player.y = player.y + (player.speed*dt)
    end
  end
  if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot and isAlive then
    -- Create some bullets
    newBullet = { x = player.x + (player.img:getWidth()/2) - (bulletImg:getWidth()/2), y = player.y, img = bulletImg }
    table.insert(bullets, newBullet)
    canShoot = false
    canShootTimer = canShootTimerMax
    shotSound:play()
  end
  if love.keyboard.isDown('r') and not isAlive  then
    -- remove all our bullets and enemies from screen
    bullets = {}
    enemies = {}

    -- reset timers
    canShootTimer = canShootTimerMax
    createEnemyTimer = createEnemyTimerMax

    -- move player back to default position
    player.x = startX
    player.y = startY

    -- reset our game state
    score = 0
    isAlive = true
  end

  -- Time out how far apart our shots can be.
  canShootTimer = canShootTimer - (1 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end

  -- Time out enemy creation
  createEnemyTimer = createEnemyTimer - (1 * dt)
  if createEnemyTimer < 0 then
    createEnemyTimer = createEnemyTimerMax

    -- Create an enemy
    randomNumber = math.random(10, love.graphics.getWidth() - 10 - enemyImg:getWidth())
    newEnemy = { x = randomNumber, y = -enemyImg:getHeight(), img = enemyImg }
    table.insert(enemies, newEnemy)
  end

  -- update the positions of bullets
  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (bulletSpeed * dt)

      if bullet.y < 0 then -- remove bullets when they pass off the screen
      table.remove(bullets, i)
    end
  end

  -- update the positions of enemies
  for i, enemy in ipairs(enemies) do
    enemy.y = enemy.y + (enemySpeed * dt)

    if enemy.y > 850 then -- remove enemies when they pass off the screen
      table.remove(enemies, i)
    end
  end

  smallestY = love.graphics.getHeight()
  for i, tile in ipairs(bgTiles) do
    -- update the positons of ground tiles
    tile.y = tile.y + groundSpeed*dt

    -- remove those which are off screen
    if tile.y > love.graphics.getHeight() then
      table.remove(bgTiles, i)
    end

    -- verify if more tiles are needed
    if tile.y < smallestY then
      smallestY = tile.y
    end
  end

  -- create more tiles if necessary
  gambiarra = true -- corrects the sliding tile problem
  if smallestY > -groundImg:getHeight() then
    for x = 0, love.graphics.getWidth(), groundImg:getWidth() do
      -- create an additional tile over the first one created here
      if gambiarra then
        newTile = {x = x, y = smallestY - groundImg:getHeight(), img = groundImg}
        table.insert(bgTiles, newTile)
        gambiarra = false
      end

      -- create new tile
      newTile = {x = x, y = smallestY - groundImg:getHeight(), img = groundImg}
      table.insert(bgTiles, newTile)
    end
  end

  -- run our collision detection
  -- Since there will be fewer enemies on screen than bullets we'll loop them first
  -- Also, we need to see if the enemies hit our player
  for i, enemy in ipairs(enemies) do
    for j, bullet in ipairs(bullets) do
      if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
        table.remove(bullets, j)
        table.remove(enemies, i)
        score = score + 1
        explosionSound:rewind()
        explosionSound:play()
      end
    end

    if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) 
    and isAlive then
      table.remove(enemies, i)
      isAlive = false
      explosionSound:rewind()
      explosionSound:play()
    end
  end
end -- love.update

function love.draw(dt)
  love.graphics.setColor(255, 255, 255, 255)
  for i, tile in ipairs(bgTiles) do
    love.graphics.draw(tile.img, tile.x, tile.y)
  end
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end
  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end
  if isAlive then
    love.graphics.draw(player.img, player.x, player.y)
  else
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end
  love.graphics.print("Score: "..score, 10, 10)
  if debug then
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.print("smallestY: "..smallestY, 10, 30)
  end
end -- love.draw
