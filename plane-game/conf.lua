-- https://love2d.org/wiki/Config_Files

function love.conf(t)
  t.identity = nil                    -- The name of the save directory (string)
  -- t.version = "0.9.1"                -- The LÖVE version this game was made for (string)
 
  t.window.title = "Scrolling Shooter Tutorial"         -- The window title (string)
  t.window.icon = nil                 -- Filepath to an image to use as the window's icon (string)
  -- t.window.width = 480                -- The window width (number)
  -- t.window.height = 700               -- The window height (number)
  t.window.borderless = false         -- Remove all border visuals from the window (boolean)
  t.window.resizable = true          -- Let the window be user-resizable (boolean)
  t.window.minwidth = 1               -- Minimum window width if the window is resizable (number)
  t.window.minheight = 1              -- Minimum window height if the window is resizable (number)
  t.window.fullscreen = false         -- Enable fullscreen (boolean)
end
