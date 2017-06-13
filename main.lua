

local layouts = {}
layouts[1] = love.filesystem.load("test_layout1.lua")()
layouts[2] = love.filesystem.load("test_layout2.lua")()

function love.load()
    currentLayoutIndex = 0
    nextLayout()
end

function love.textinput(text)
    currentLayout:keytyped(text)
end

function love.keypressed(key, isRepeat)
    currentLayout:keypressed(key, isRepeat)
    if key == "left" then
        prevLayout()
    end
    if key == "right" then
        nextLayout()
    end
end

function love.mousepressed(mx, my, key)
    currentLayout:mousepressed(mx, my, key)
end

function love.mousereleased(mx, my, key)
    currentLayout:mousereleased(mx, my, key)
end

function love.update(dt)
    local mx, my = love.mouse.getPosition()
    currentLayout:update(dt, mx, my)
end

function love.draw()
    currentLayout:draw()
    drawPips()
end

function nextLayout()
    currentLayoutIndex = currentLayoutIndex + 1
    if currentLayoutIndex > #layouts then
        currentLayoutIndex = 1
    end
    currentLayout = layouts[currentLayoutIndex]
end

function prevLayout()
    currentLayoutIndex = currentLayoutIndex - 1
    if currentLayoutIndex < 1 then
        currentLayoutIndex = #layouts
    end
    currentLayout = layouts[currentLayoutIndex]
end

function drawPips()
    local size = 4
    local padding = 12
    local n = #layouts
    local cx = love.graphics.getWidth() / 2
    local y = love.graphics.getHeight() - 16
    for i = 1, n do
        local x = cx + i * (size + padding)
        love.graphics.circle("line", x, y, size)
    end
    local x = cx + currentLayoutIndex * (size + padding)
    love.graphics.circle("fill", x, y, size)
end