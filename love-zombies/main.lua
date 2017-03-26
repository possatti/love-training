
require 'entities'
require 'utils'

debug = false

function start()
  -- remove all our bullets and enemies from screen
  bullets = {}
  zombies = {}

  -- move player back to default position
  hero.hp = hero.hpMax
  hero.x = love.graphics.getWidth()/2
  hero.y = love.graphics.getHeight()/2
  hero.score = 0
end

function love.load()
  -- Load images.
  TankImg = love.graphics.newImage('assets/tank_alpha.png')
  TankGunImg = love.graphics.newImage('assets/tank_gun.png')
  TankBodyImg = love.graphics.newImage('assets/tank_body.png')
  TankWheelsImg = love.graphics.newImage('assets/tank_wheels.png')
  ZombieImg = love.graphics.newImage('assets/zombie/skeleton-idle_0.png')
  crosshairImg = love.graphics.newImage('/assets/crosshairs/triangle/triangle-06.png')
  crosshairHitImg = love.graphics.newImage('/assets/crosshairs/triangle/triangle-06-whole.png')
  grassImg = love.graphics.newImage('/assets/grass.png')

  -- Quads.
  tileW, tileH = 32, 32
  tilesetW, tilesetH = grassImg:getDimensions()
  grassQuad = love.graphics.newQuad(0, 0, tileW, tileH, tilesetW, tilesetH)

  -- Load music.
  bgMusic = love.audio.newSource("assets/stone_fortress.ogg")
  bgMusic:setVolume(0.8)
  bgMusic:setLooping(true)
  bgMusic:play()
  zombieDeathSound = love.audio.newSource("assets/monster-sounds/piggrunt1.wav", "static")
  zombieDeathSound:setVolume(0.7)
  shotSound = love.audio.newSource("assets/shots/cg1.wav", "static")
  shotSound:setVolume(0.2)
  heroHitSound = love.audio.newSource("assets/shots/cg1.wav", "static")
  heroHitSound:setVolume(0.5)

  -- Other variables.
  zombieSpawnInterval = 0
  zombieSpawnIntervalMax = 0.5
  -- bigFont = love.graphics.newFont(40)
  love.mouse.setVisible(false)
  love.mouse.setGrabbed(true)

  -- Start game.
  start()
end

function love.update(dt)
  -- Quit game.
  if love.keyboard.isDown('escape', 'q') then
    love.event.push('quit')
  end

  -- Restart the game, if the player wants.
  if love.keyboard.isDown('r') and not hero:isAlive() then
    start()
  end

  -- Updates mouse position.
  mouse.x, mouse.y = love.mouse.getPosition()

  -- Hero movement.
  facing = 'nowhere'
  if hero:isAlive() then
    if love.keyboard.isDown('up', 'w') then
      hero.y = math.max(hero.w/2, hero.y - hero.speed*dt)
      facing = 'up'
      hero.bodyR = 0
    elseif love.keyboard.isDown('down', 's') then
      hero.y = math.min(love.graphics.getHeight()-hero.h/2, hero.y + hero.speed*dt)
      facing = 'down'
      hero.bodyR = math.pi
    end
    if love.keyboard.isDown('left', 'a') then
      hero.x = math.max(hero.w/2, hero.x - hero.speed*dt)
      if facing == 'up' then
        facing = 'upleft'
        hero.bodyR = math.pi + math.pi*3/4
      elseif facing == 'down' then
        facing = 'downleft'
        hero.bodyR = math.pi + math.pi/4
      else
        facing = 'left'
        hero.bodyR = math.pi*3/2
      end
    elseif love.keyboard.isDown('right', 'd') then
      hero.x = math.min(love.graphics.getWidth()-hero.w/2, hero.x + hero.speed*dt)
      if facing == 'up' then
        facing = 'upright'
        hero.bodyR = math.pi/4
      elseif facing == 'down' then
        facing = 'downright'
        hero.bodyR = math.pi*3/4
      else
        facing = 'right'
        hero.bodyR = math.pi/2
      end
    end

    -- Adjust hero direction.
    hero.r = math.atan2(mouse.y - hero.y, mouse.x - hero.x)

    -- Fire!!
    fire = love.mouse.isDown(1,2)
    if fire and hero.heat <= 0 then
      shotSound:rewind()
      shotSound:play()
      -- local newBullet = {x=hero.x, y=hero.y, r=hero.r, speed=400}
      -- table.insert(bullets, newBullet)
      createBullet(hero.x, hero.y, hero.r)
      hero.heat = hero.heatMax
    end
    hero.heat = math.max(0, hero.heat - dt)

    -- Create zombies.
    if zombieSpawnInterval <= 0 then
      edge = math.random(1, 4)
      local x, y
      if edge == 1 then -- Up there.
        y = -50
        x = math.random(0, love.graphics.getWidth())
      elseif edge == 2 then -- On the right.
        y = math.random(0, love.graphics.getHeight())
        x = love.graphics.getWidth() + 50
      elseif edge == 3 then -- Down there.
        y = love.graphics.getHeight() + 50
        x = math.random(0, love.graphics.getWidth())
      elseif edge == 4 then -- On the left.
        y = math.random(0, love.graphics.getHeight())
        x = - 50
      end
      createZombie(x, y)
      zombieSpawnInterval = zombieSpawnIntervalMax
    end
    zombieSpawnInterval = math.max(0, zombieSpawnInterval - dt)

  end

  -- Update zombies.
  for i, zombie in ipairs(zombies) do
    zombie.r = calculateDirection(zombie, hero)
    moveEntity(zombie, dt)
  end

  -- Update bullets.
  for i, bullet in ipairs(bullets) do
    moveEntity(bullet, dt)
    if (bullet.x < -10) or (bullet.x > love.graphics.getWidth() + 10)
    or (bullet.y < -10) or (bullet.y > love.graphics.getHeight() + 10) then
      table.remove(bullets, i)
    end
  end
  
  -- Check collision of bullets against zombies.
  for i, zombie in ipairs(zombies) do
    for j, bullet in ipairs(bullets) do
      if checkCollisionCircles(zombie.x, zombie.y, zombie.w/2-5, bullet.x, bullet.y, 2) then
        hero.score = hero.score + 1
        table.remove(zombies, i)
        table.remove(bullets, j)
        zombieDeathSound:rewind()
        zombieDeathSound:play()
      end
    end
  end

  -- Check collision of hero against zombies.
  for i, zombie in ipairs(zombies) do
    if checkCollisionCircles(zombie.x, zombie.y, zombie.w/2-5, hero.x, hero.y, hero.w/2-5) then
      heroHitSound:rewind()
      heroHitSound:play()
      table.remove(zombies, i)
      hero.hp = math.max(0, hero.hp - 1)
    end
  end
end

function love.draw()
  if debug then
    objectiveW, objectiveH = 700, 500
    currentW, currentH = love.graphics.getWidth(), love.graphics.getHeight()
    scaleW = objectiveW / currentW
    scaleH = objectiveH / currentH
    love.graphics.scale(scaleW, scaleH)
    love.graphics.translate((currentW-objectiveW)/2, (currentH-objectiveH)/2)
  end

  -- Draw the Background.
  love.graphics.setColor(200,200,200,255)
  for y = 0, love.graphics.getHeight(), tileH do
    for x = 0, love.graphics.getWidth(), tileW do
      love.graphics.draw(grassImg, grassQuad, x, y)
    end
  end

  -- Draw bullets.
  love.graphics.setColor(120,0,0,255)
  for i, bullet in ipairs(bullets) do
    love.graphics.circle("fill", bullet.x-2, bullet.y-2, 2, 10)
  end

  -- Draw hero.
  love.graphics.setColor(200,200,200,255)
  w, h = TankBodyImg:getDimensions()
  love.graphics.draw(TankWheelsImg, hero.x, hero.y, hero.bodyR, hero.w/w, hero.h/h, w/2, h/2)
  love.graphics.draw(TankBodyImg, hero.x, hero.y, hero.bodyR, hero.w/w, hero.h/h, w/2, h/2)
  love.graphics.draw(TankGunImg, hero.x, hero.y, hero.r+math.pi/2, hero.w/w, hero.h/h, w/2, h/2)

  -- Draw zombies.
  for i, zombie in ipairs(zombies) do
    -- love.graphics.circle("fill", zombie.x-10, zombie.y-10, 10, 10)
    w, h = ZombieImg:getDimensions()
    love.graphics.draw(ZombieImg, zombie.x, zombie.y, zombie.r, zombie.w/w, zombie.h/h, ZombieImg:getWidth()/2, ZombieImg:getHeight()/2)
  end

  -- Draw Hero's HP.
  love.graphics.setColor(0,0,0,255)
  local offset = 1
  love.graphics.rectangle("fill", 10-offset, 10-offset, 20 * hero.hpMax + offset*2, 13 + offset*2)
  love.graphics.setColor(200,0,0,255)
  love.graphics.rectangle("fill", 10, 10, 20 * hero.hp, 13)
  love.graphics.setColor(255,255,255,255)
  love.graphics.print("HP", 12, 10)

  -- Draw Hero's Score.
  love.graphics.setColor(0,0,0,255)
  local offset = 1
  love.graphics.rectangle("fill", 10-offset, 30-offset, 80, 13 + offset*2)
  love.graphics.setColor(255,255,255,255)
  love.graphics.print("Score: "..hero.score, 12, 30)

  -- Draw game over.
  if not hero:isAlive() then
    -- love.graphics.setFont(bigFont)
    local x, y
    y = love.graphics.getHeight()/2 - 100
    x = love.graphics.getWidth()/2 - 40
    love.graphics.print("GAME OVER", x, y)
    y = y + 20
    x = x - 20
    love.graphics.print("Press 'R' to restart.", x, y)
  end

  -- Draw crosshair.
  love.graphics.setColor(255,255,255,255)
  if fire then
    w, h = crosshairHitImg:getDimensions()
    love.graphics.draw(crosshairHitImg, mouse.x, mouse.y, 0, mouse.w/w, mouse.h/h, w/2, w/2)
  else
    w, h = crosshairImg:getDimensions()
    love.graphics.draw(crosshairImg, mouse.x, mouse.y, 0, mouse.w/w, mouse.h/h, w/2, w/2)
  end

  -- Debugging information.
  if debug then
    love.graphics.print("mouse: x="..mouse.x..",y="..mouse.y, 10, 10)
    if fire then
      love.graphics.print("shoot? Fire!", 10, 30)
    else
      love.graphics.print("shoot?", 10, 30)
    end
    offset = 0
    love.graphics.setColor(255,0,0,255)
    love.graphics.rectangle("line", -offset, -offset, currentW+offset*2,currentH+offset*2)
  end
end
