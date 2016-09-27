-- -------- --
-- INVADERS --
-- -------- --

-- http://www.headchant.com/2010/12/31/love2d-tutorial-part-2-pew-pew/
-- -------------------------------------------------------------------

function shoot()
  local shot = {}
  shot.x = hero.x + hero.width/2
  shot.y = hero.y
  table.insert(hero.shots, shot) 
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function love.load()
  -- Hero
  hero = {}
  hero.x = 300
  hero.y = 450
  hero.width = 30
  hero.height = 15
  hero.speed = 100
  hero.shots = {} -- holds our fired shots

  -- Enemies
  enemies = {}
  for i = 0, 7 do
    enemy = {}
    enemy.width = 40
    enemy.height = 20
    enemy.x = i * (enemy.width + 60) + 100
    enemy.y = enemy.height + 100
    table.insert(enemies, enemy)
  end

  -- load background
  bg = love.graphics.newImage("bg.png")
end

function love.update(dt)
  -- check user input
  if love.keyboard.isDown("left") then
    hero.x = hero.x - hero.speed*dt
  elseif love.keyboard.isDown("right") then
    hero.x = hero.x + hero.speed*dt
  end

  -- move enemies
  for i, enemy in ipairs(enemies) do
    -- let them fall down slowly
    enemy.y = enemy.y + dt
    
    -- check for collision with ground
    if enemy.y > 465 then
      -- you lose
    end
  end

  -- 
  local remEnemy = {}
  local remShot = {}

  -- update the shots
  for i,shot in ipairs(hero.shots) do
    -- move them up
    shot.y = shot.y - dt * 100

    -- mark shots that are not visible for removal
    if shot.y < 0 then
      table.insert(remShot, i)
    end

    -- check for collision with enemies
    for ii,enemy in ipairs(enemies) do
      if CheckCollision(shot.x, shot.y, 2, 5, enemy.x, enemy.y, enemy.width, enemy.height) then
        -- mark that enemy for removal
        table.insert(remEnemy, ii)
        -- mark that shot for removal
        table.insert(remShot, i)
      end
    end
  end

  -- remove the marked enemies
  for i,enemy_index in ipairs(remEnemy) do
    table.remove(enemies, enemy_index)
  end

  for i,shot_index in ipairs(remShot) do
    table.remove(hero.shots, shot_index)
  end
end

function love.draw()
  -- Backround
  love.graphics.setColor(255,255,255,255)
  love.graphics.draw(bg)

  -- Ground
  love.graphics.setColor(0,255,0,255)
  love.graphics.rectangle("fill", 0, 465, 800, 150)

  -- Hero
  love.graphics.setColor(255,255,0,255)
  love.graphics.rectangle("fill", hero.x, hero.y, hero.width, hero.height)

  -- Enemies
  love.graphics.setColor(0,255,255,255)
  for i,enemy in ipairs(enemies) do
    love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
  end

  -- Shots
  love.graphics.setColor(255,255,255,255)
  for i,shot in ipairs(hero.shots) do
    love.graphics.rectangle("fill", shot.x, shot.y, 2, 5)
  end  
end

function love.keypressed(key)
   if key == 'escape' or key == 'q' then
      love.event.quit()
   end
end

function love.keyreleased(key)
  if key == " " then
    shoot()
  end
end
