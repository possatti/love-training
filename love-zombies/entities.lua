
-- Set up entities.

hero = {
  x = love.graphics.getWidth()/2,
  y = love.graphics.getHeight()/2,
  w = 50,
  h = 50,
  r = math.pi/4,
  hp = 0,
  hpMax = 3,
  speed = 125,
  heat = 0,
  heatMax = 0.2,
  score = 0
}
function hero:isAlive()
  return self.hp > 0
end

mouse = {x = 0, y = 0, w = 40, h = 40}

bullets = {}
function createBullet(x, y, r)
  local newBullet = {
    x = x,
    y = y,
    r = r,
    speed = 400
  }
  table.insert(bullets, newBullet)
end

zombies = {}
function createZombie(x, y)
  local newZombie = {
    x = x,
    y = y,
    w = 30,
    h = 30,
    r = 0,
    speed = 100
  }
  table.insert(zombies, newZombie)
end
