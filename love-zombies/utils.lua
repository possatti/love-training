
-- Check if the circles colidded.
function checkCollisionCircles(x1, y1, r1, x2, y2, r2)
  return (x2-x1)^2 + (y1-y2)^2 <= (r1+r2)^2
end

-- Return an angle for which 'one' will be looking at 'two'.
function calculateDirection(one, two)
  return math.atan2(two.y - one.y, two.x - one.x)
end

-- Moves the 'entity' in the direction of 'entity.r' by 'entity.speed'
function moveEntity(entity, dt)
  entity.y = entity.y + math.sin(entity.r) * entity.speed * dt
  entity.x = entity.x + math.cos(entity.r) * entity.speed * dt
end

-- Check if entity is offscreen.
function isOffscreen(entity)
  local threshold = 50
  if (entity.x < -threshold)
    or (entity.x > love.graphics.getWidth() + threshold)
    or (entity.y < -threshold)
    or (entity.y > love.graphics.getHeight() + threshold) then
      return true
  else
    return false
  end
end
