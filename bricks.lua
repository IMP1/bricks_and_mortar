local bricks = {
    _VERSION     = 'v0.0.1',
    _DESCRIPTION = 'A Lua UI library for LÖVE games',
    _URL         = '',
    _LICENSE     = [[
        MIT License

        Copyright (c) 2017 Huw Taylor

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
    ]]
}

local default_global_styles = {
    ["*"] = {
        backgroundColor = nil,
        borderColor     = nil,
        textColor       = {224, 224, 224},
        borderRadius    = {0, 0},
        margin          = {0, 0, 0, 0},
        padding         = {4, 4, 4, 4},
    },
}

local default_element_styles = {
    ["group"] = {
        margin          = {0, 0, 0, 0},
        padding         = {0, 0, 0, 0},
    },
    ["layout"] = {
        margin          = {0, 0, 0, 0},
        padding         = {0, 0, 0, 0},
    },
    ["button"] = {
        backgroundColorFocus  = {32, 32, 32},
        backgroundColorActive = {64, 64, 64},
        backgroundColor       = {32, 32, 32},
        borderRadius          = {8, 8},
        borderColor           = {192, 192, 192},
        borderColorFocus      = {128, 128, 255},
        borderColorActive     = {192, 192, 192},
        padding               = {8, 8, 4, 4}
    },
    ["checkbox"] = {
        borderColor           = {192, 192, 192},
        borderColorFocus      = {128, 128, 255},
        backgroundColor       = {32, 32, 32},
        backgroundColorFocus  = {32, 32, 32},
    },
    ["dropdown_group"] = {
        borderColor           = {192, 192, 192},
        borderColorFocus      = {128, 128, 255},
        backgroundColor       = {32, 32, 32},
        backgroundColorFocus  = {32, 32, 32},
        padding               = {0, 0, 0, 0},
        placeholder = {
            padding           = {4, 4, 4, 4},
        }
    },
    ["dropdown_option"] = {
        borderColor           = {192, 192, 192},
        borderColorFocus      = {128, 128, 255},
        backgroundColor       = {32, 32, 32},
        backgroundColorFocus  = {32, 32, 32},
    },
    ["radio_option"] = {
        borderColor           = {192, 192, 192},
        borderColorFocus      = {128, 128, 255},
        backgroundColor       = {32, 32, 32},
        backgroundColorFocus  = {32, 32, 32},
        borderRadius          = {8, 8},
    },
    ["text_input"] = {
        borderColor        = {192, 192, 192},
        borderColorFocus   = {128, 128, 255},
        borderColorInvalid = {192, 128, 128},
        placeholderColor   = {128, 128, 128},
        textColor          = {255, 255, 255},
        textColorInvalid   = {255, 255, 255},
        cursorColor        = {255, 255, 255},
    },
}

local selectedElement = nil

--------------------------------------------------------------------------------
-- # Element
--------------
-- A generic UI element, with common properties and actions.
--------------------------------------------------------------------------------
local Element = {}
Element.__index = Element
function Element:__tostring()
    return "<Element:" .. (self.id or "") .. ">"
end

function Element.new(elementName, id, pos, options)
    local obj = {}
    obj._name = elementName

    obj.id      = id
    obj.pos     = pos or {"0", "0", "100", "100", "top", "left"}
    obj.tags    = options.tags or {}
    obj.hover   = false
    obj.focus   = false
    obj.style   = options.style or {}
    obj.loaded  = false
    obj.onload  = options.onload or nil
    obj.visible = options.visible
    if obj.visible == nil then obj.visible = true end
    
    return obj
end

function Element:load()
    if self.onload then
        self:onload()
    end
    -- setup styles
    -- if default_style[self._name] then
    --     for k, v in pairs(default_style[self._name]) do
    --         if self.style[k] == nil then
    --             self.style[k] = v
    --         end
    --     end
    -- end
    -- setmetatable(self.style, {__index = default_style.common})
    -- load style from style declarations
    self:layout():refreshStyles()

    -- load children
    if self.elements then
        for _, e in pairs(self.elements) do
            e:load()
        end
    end
    if self.placeholder then
        self.placeholder:load()
    end
    self.loaded = true
end

function Element:setStyle(styleRules)
    for key, value in pairs(styleRules) do
        self.style[key] = value
    end
end

function Element:getScreenBounds()
    local parentBounds
    if self.parent == nil then
        parentBounds = { 
            0, 
            0, 
            love.graphics.getWidth(),
            love.graphics.getHeight(),
        }
    else
        parentBounds = self.parent:getScreenBounds()
    end
    local x, y, w, h = unpack(self.pos)
    if type(x) == "string" then x = parentBounds[3] * tonumber(x) / 100 end
    if type(y) == "string" then y = parentBounds[4] * tonumber(y) / 100 end
    if type(w) == "string" then w = parentBounds[3] * tonumber(w) / 100 end
    if type(h) == "string" then h = parentBounds[4] * tonumber(h) / 100 end
    if x < 0 then x = x + parentBounds[3] end
    if y < 0 then y = y + parentBounds[4] end
    return {
        parentBounds[1] + x,
        parentBounds[2] + y,
        w,
        h
    }
end

function Element:getRelativePosition()
    local parentSize
    if self.parent == nil then
        parentSize = { love.graphics.getWidth(), love.graphics.getHeight() }
    else
        parentSize = self.parent:getSize()
    end
    local x, y = unpack(self.pos)
    if type(x) == "string" then x = x * parentSize[1] / 100 end
    if type(y) == "string" then y = y * parentSize[2] / 100 end
    if x < 0 then x = x + parentSize[1] end
    if y < 0 then y = y + parentSize[2] end
    return {
        x,
        y
    }
end

function Element:getSize()
    local parentSize
    if self.parent == nil then
        parentSize = { love.graphics.getWidth(), love.graphics.getHeight() }
    else
        parentSize = self.parent:getSize()
    end
    local _, _, w, h = unpack(self.pos)
    if type(w) == "string" then w = tonumber(w) * parentSize[1] / 100 end
    if type(h) == "string" then h = tonumber(h) * parentSize[2] / 100 end
    return {
        w,
        h,
    }
end

function Element:getRelativeBounds()
    local x, y = unpack(self:getRelativePosition())
    local w, h = unpack(self:getSize())
    return { x, y, w, h }
end

function Element:isMouseOver(mx, my)
    local bounds = self:getScreenBounds()
    local x, y, w, h = unpack(bounds)
    return (mx >= x and 
            my >= y and 
            mx <= x + w and 
            my <= y + h)
end

function Element:layout()
    local top = self
    while top.parent do
        top = top.parent
    end
    if top._name == "layout" then
        return top
    else
        return nil
    end
end

function Element:findFirst(selectors)
    if selectors == nil or selectors == "" then
        return nil
    end

    local directDescendant = false
    local i = selectors:find("%s") or #selectors + 1
    local j = selectors:find("%S", i) or #selectors + 1
    local s = selectors:sub(1, i - 1)
    local nextSelectors = selectors:sub(j)
    local final = #nextSelectors == 0

    if s == ">" and final then
        return nil
    elseif s == ">" then
        directDescendant = true
        selectors = nextSelectors
        i = selectors:find("%s") or #selectors + 1
        j = selectors:find("%S", i) or #selectors + 1
        s = selectors:sub(1, i - 1)
        nextSelectors = selectors:sub(j)
        final = #nextSelectors == 0
    end
    -- print("----")
    -- print(self, "'" .. selectors .. "'")

    local match = self:matches(s)
    -- print(match)

    if match and final then
        return self
    end

    if not match and self.elements and not directDescendant then
        -- print("checking children...")
        for _, child in pairs(self.elements) do
            local result = child:findFirst(selectors)
            if result then
                return result
            end
        end
        return nil
    end

    if match and self.elements and not final then
        -- print("continuing on...")
        local matches = {}
        for _, child in pairs(self.elements) do
            local result = child:findFirst(nextSelectors)
            if result then
                return result
            end
        end
        return matches
    end

    return nil
end

function Element:find(selectors)
    if selectors == nil or selectors == "" then
        return {}
    end

    local directDescendant = false
    local i = selectors:find("%s") or #selectors + 1
    local j = selectors:find("%S", i) or #selectors + 1
    local s = selectors:sub(1, i - 1)
    local nextSelectors = selectors:sub(j)
    local final = #nextSelectors == 0

    local matches = {}

    if selectors == "*" then
        -- TODO: have this also include selectors like "*#lol"
        -- TODO: does this need to double the results and return
        --       all children, with the * passed, and then again
        --       with the rest of the selector passed?
        --       for a selector like "* > .title"
        final = false
        nextSelectors = "*"
        table.insert(matches, self)
    end

    if s == ">" and final then
        return {}
    elseif s == ">" then
        directDescendant = true
        selectors = nextSelectors
        i = selectors:find("%s") or #selectors + 1
        j = selectors:find("%S", i) or #selectors + 1
        s = selectors:sub(1, i - 1)
        nextSelectors = selectors:sub(j)
        final = #nextSelectors == 0
    end
    -- print("----")
    -- print(self, "'" .. selectors .. "'")

    local match = self:matches(s)
    -- print(match)

    if match and final then
        return { self }
    end

    if not match and self.elements and not directDescendant then
        -- print("checking children...")
        for _, child in pairs(self.elements) do
            local results = child:find(selectors)
            if #results > 0 then
                for _, r in ipairs(results) do
                    table.insert(matches, r)
                end
            end
        end
        return matches
    end

    if match and self.elements and not final then
        -- print("continuing on...")
        for _, child in pairs(self.elements) do
            local results = child:find(nextSelectors)
            if #results > 0 then
                for _, r in ipairs(results) do
                    table.insert(matches, r)
                end
            end
        end
        return matches
    end

    return matches
end

function Element:matches(selector)
    -- print("Matching " .. tostring(self) .. " to '" .. tostring(selector) .. "' selector.")
    if not selector:find("%S") then
        return false
    end
    -- element
    local element = selector:match("^([%w_]+)")
    element = element or selector:match("%*")
    if element and element ~= "*" and element ~= self._name then
        return false
    end
    -- print("Matching " .. tostring(self) .. " to <" .. tostring(element) .. "> element.")
    --- id
    local id = selector:match("#(%w+)")
    if id and id ~= self.id then
        return false
    end
    -- print("Matching " .. tostring(self) .. " to #" .. tostring(id) .. " id.")
    -- tags
    for tag in selector:gmatch("%.(%w+)") do
        if tag then
            local none = true
            for _, t in pairs(self.tags) do
                if t == tag then
                    none = false
                end
            end
            if none then
                return false
            end
        end
    end
    -- attributes
    local attribute, value = selector:match("%[(%w+)=(.-)%]")
    if attribute and tostring(self[attribute]) ~= value then
        return false
    end
    -- print("Matched!")
    return true
end

function Element:select()
    if selectedElement then
        selectedElement:deselect()
    end

    self.focus = true
    selectedElement = self
end

function Element:deselect()
    self.focus = false
end

function Element:draw()
    if not self.visible then
        return
    end
    bricks.graphics.push()
    local x, y, w, h = unpack(self:getRelativeBounds())
    x, y, w, h = self:applyMargin(x, y, w, h)
    self:drawShape(x, y, w, h)
    x, y, w, h = self:applyPadding(x, y, w, h)
    if self.drawContent then
        love.graphics.push()
        love.graphics.translate(x, y)
        self:drawContent(w, h)
        love.graphics.pop()
    end
    bricks.graphics.pop()
end

function Element:applyMargin(x, y, w, h)
    if not self.style.margin then
        return x, y, w, h
    end
    x = x + self.style.margin[1]
    y = y + self.style.margin[2]
    w = w - self.style.margin[1] - self.style.margin[3]
    h = h - self.style.margin[2] - self.style.margin[4]
    return x, y, w, h
end

function Element:applyPadding(x, y, w, h)
    if not self.style.padding then
        return x, y, w, h
    end
    x = x + self.style.padding[1]
    y = y + self.style.padding[2]
    w = w - (self.style.padding[1] + self.style.padding[3])
    h = h - (self.style.padding[2] + self.style.padding[4])
    return x, y, w, h
end

function Element:drawShape(x, y, w, h)
    local rx, ry = 0, 0
    if self.style.borderRadius then
        rx, ry = unpack(self.style.borderRadius)
    end

    -- draw shape
    local drawBackground = true
    if not self.valid and self.style.backgroundColorInvalid then
        bricks.graphics.setColor(unpack(self.style.backgroundColorInvalid))
    elseif self.isActive and self:isActive() and self.style.backgroundColorActive then
        bricks.graphics.setColor(unpack(self.style.backgroundColorActive))
    elseif self.focus and self.style.backgroundColorFocus then
        bricks.graphics.setColor(unpack(self.style.backgroundColorFocus))
    elseif self.style.backgroundColor then
        bricks.graphics.setColor(unpack(self.style.backgroundColor))
    else
        drawBackground = false
    end
    if drawBackground then
        love.graphics.rectangle("fill", x, y, w, h, rx, ry)
    end

    -- draw border
    local drawBorder = true
    if not self.valid and self.style.borderColorInvalid then
        bricks.graphics.setColor(unpack(self.style.borderColorInvalid))
    elseif self.isActive and self:isActive() and self.style.borderColorActive then
        bricks.graphics.setColor(unpack(self.style.borderColorActive))
    elseif self.focus and self.style.borderColorFocus then
        bricks.graphics.setColor(unpack(self.style.borderColorFocus))
    elseif self.style.borderColor then
        bricks.graphics.setColor(unpack(self.style.borderColor))
    else
        drawBorder = false
    end
    if drawBorder then
        love.graphics.rectangle("line", x, y, w, h, rx, ry)
    end
end

--------------------------------------------------------------------------------
-- # Group
--------------
-- A group of other elements.
--------------------------------------------------------------------------------
local Group = {}
setmetatable(Group, { __index = Element})
Group.__index = Group
function Group:__tostring()
    return "<Group:" .. (self.id or "") .. ">"
end

function Group.new(id, position, options)
    local this = Element.new("group", id, position, options)
    setmetatable(this, Group)
    this.elements = options.elements or {}
    for _, e in pairs(this.elements) do
        e.parent = this
    end
    this.cannotTarget = true
    return this
end

function Group:mousepressed(mx, my, key)
    for _, e in pairs(self.elements) do
        if e.mousepressed then
            e:mousepressed(mx, my, key)
        end
    end
end

function Group:mousereleased(mx, my, key)
    for _, e in pairs(self.elements) do
        if e.mousereleased then
            e:mousereleased(mx, my, key)
        end
    end
end

function Group:update(dt, mx, my)
    for _, e in pairs(self.elements) do
        if e.update then
            e:update(dt, mx, my)
        end
    end
end

function Group:keytyped(text)
    for _, e in pairs(self.elements) do
        if e.keytyped then
            e:keytyped(text)
        end
    end
end

function Group:keypressed(key, isRepeat)
    local stopped
    for _, e in pairs(self.elements) do
        if e.keypressed then
            stopped = e:keypressed(key, isRepeat)
        end
    end
end

function Group:selectNextElement(current, takeNext)
    if current == nil then takeNext = true end
    for _, e in pairs(self.elements) do
        if takeNext and not e.cannotTarget then 
            e:select()
            return e
        end
        if not takeNext and e == current then
            e:deselect()
            takeNext = true
        end
        if e.selectNextElement then
            local finished
            finished, takeNext = e:selectNextElement(current, takeNext)
            if finished then return finished end
        end
    end
    return nil, takeNext
end

function Group:selectPreviousElement(current, previous)
    for _, e in pairs(self.elements) do
        if e.selectPreviousElement then
            previous = e:selectPreviousElement(current, previous)
        end
        if e == current then
            e:deselect()
            if previous then 
                previous:select()
            end
            return previous
        elseif not e.cannotTarget then
            previous = e
        end
    end
    if previous and not previous.cannotTarget then 
        previous:select()
    end
    return previous
end

function Group:elementsWith(f, ...)
    local results = {}
    for _, e in pairs(self.elements) do
        if f(e, ...) then
            table.insert(results, e)
        end
        if e.elementsWith then
            local subresults = e:elementsWith(f, ...)
            if #subresults > 0 then
                for _, r in pairs(subresults) do
                    table.insert(results, r)
                end
            end
        end
    end
    return results
end

function Group:elementWith(f, ...)
    for _, e in pairs(self.elements) do
        if f(e, ...) then
            return e
        end
        if e.elementWith then
            local element = e:elementWith(f, ...)
            if element then
                return element
            end
        end
    end
    return nil
end

function Group:elementWithId(id)
    local f = function(element, id)
        return element.id == id
    end
    return self:elementWith(f, id)
end

function Group:addElement(element)
    table.insert(self.elements, element)
    self:layout():refreshStyles()
end

function Group:removeElement(element)
    for i = #self.elements, 1, -1 do
        if self.elements[i] == element then
            print("removing " .. tostring(self.elements[i]) .. " from " .. tostring(self))
            table.remove(self.elements, i)
            return
        end
    end
    self:layout():refreshStyles()
end

function Group:removeElements(selector)
    local elements = self:find(selector)
    for i = #self.elements, 1, -1 do
        local remove = false
        for _, e in pairs(elements) do
            if e == self.elements[i] then
                remove = true
            end
        end
        if remove then
            table.remove(self.elements, i)
        end
    end
end

function Group:drawContent(w, h)
    self:drawChildren()
end

function Group:drawChildren()
    for _, element in pairs(self.elements) do
        if element.draw then
            element:draw()
        end
    end
end

--------------------------------------------------------------------------------
-- # Button
--------------
-- A simple text button class. It is connected to an action which will fire when
-- the button is clicked.
--------------------------------------------------------------------------------
local Button = {}
setmetatable(Button, { __index = Group })
Button.__index = Button
function Button:__tostring()
    return "<Button:" .. (self.id or "") .. ">"
end

function Button.new(id, position, options)
    local this = Element.new("button", id, position, options)
    setmetatable(this, Button)
    this.elements = options.elements or {}
    for _, e in pairs(this.elements) do
        e.parent = this
    end
    this.onclick   = options.onclick or nil
    this.hover     = false
    this.focusKeys = options.focusKeys or {}
    this.focus     = false
    this.active    = false
    this.cannotTarget = false
    return this
end

function Button:update(dt, mx, my)
    self.hover = self:isMouseOver(mx, my)
end

function Button:isActive()
    return self.active and self.hover
end

function Button:keypressed(key, isRepeat)
    if self.focus and key == "space" then
        self:fire()
    end
    if not self.focus and self.focusKeys and key == self.focusKeys[1] then
        self:select()
    end
end

function Button:mousepressed(mx, my, key)
    self.active = self:isMouseOver(mx, my)
    if self:isMouseOver(mx, my) then
        self:select()
    else
        self:deselect()
    end
end

function Button:mousereleased(mx, my, key)
    if self:isActive() and key == 1 then
        self:fire()
    end
    self.active = false
end

function Button:fire()
    self.active = true
    if self.onclick then
        self:onclick()
    end
    self.active = false
    self:deselect()
end

--------------------------------------------------------------------------------
-- # Checkbox
--------------
-- A class for allowing a user to toggle options on and off.
--------------------------------------------------------------------------------
local Checkbox = {}
setmetatable(Checkbox, { __index = Element})
Checkbox.__index = Checkbox
function Checkbox:__tostring()
    return "<Checkbox:" .. (self.id or "") .. ">"
end

function Checkbox.new(id, position, options)
    local this = Element.new("checkbox", id, position, options)
    setmetatable(this, Checkbox)
    this.focus    = false
    this.selected = options.selected or false
    this.onchange = options.onchange or nil
    this.width    = options.width    or 16
    this.height   = options.height   or 16
    return this
end

function Checkbox:keypressed(key, isRepeat)
    if self.focus and key == "space" then
        self:toggle()
    end
end

function Checkbox:mousepressed(mx, my, key)
    self.active = self:isMouseOver(mx, my)
    self.focus  = self:isMouseOver(mx, my)
end

function Checkbox:mousereleased(mx, my, key)
    if self:isMouseOver(mx, my) then
        self:toggle()
        self:select()
    end
end

function Checkbox:toggle()
    local stop = false
    local newValue = not self.selected
    if self.onchange then
        stop = self:onchange(newValue)
    end
    if not stop then
        self.selected = newValue
    end
end

function Checkbox:draw()
    if self.style.customDraw then 
        self.style.customDraw(self)
        return
    end
    if not self.visible then
        return
    end
    bricks.graphics.push()
    -- get positions
    local x, y, w, h = unpack(self:getRelativeBounds())
    x, y = self:applyMargin(x, y, w, h)
    w = self.width
    h = self.height
    self:drawShape(x, y, w, h)
    -- draw content
    bricks.graphics.setColor(unpack(self.style.textColor))
    if self.selected then
        love.graphics.printf("X", x, y, w, "center")
    end
    bricks.graphics.pop()
end

--------------------------------------------------------------------------------
-- # DropdownGroup
--------------
-- A group for a dropdown list of options.
--------------------------------------------------------------------------------
local DropdownGroup = {}
setmetatable(DropdownGroup, {__index=Button})
DropdownGroup.__index = DropdownGroup
function DropdownGroup:__tostring()
    return "<DropdownGroup:" .. (self.id or "") .. ">"
end

function DropdownGroup.new(id, position, options)
    local this = Element.new("dropdown_group", id, position, options)
    setmetatable(this, DropdownGroup)
    this.placeholder     = options.placeholder or nil
    if this.placeholder then
        this.placeholder.parent = this
    end
    this.elements = options.elements or {}
    for _, e in pairs(this.elements) do
        e.parent = this
    end
    this.options = this:elementsWith(function(e)
        return e._name == "dropdown_option"
    end)
    -- apply list layout
    local prevElement = this.placeholder
    local offset = 0
    for i, o in ipairs(this.options) do
        o._groupElement = this
        if o.autoLayout and prevElement then
            offset = offset + prevElement:getSize()[2]
        end
        o.pos[2] = offset
        prevElement = o
    end
    this.selectedOptions = {}
    this.onchange        = options.onchange or nil
    this.multipleSelect  = options.multiple or false
    this.cannotTarget    = false
    this.open            = false
    return this
end

-- Override: 
function DropdownGroup:mousepressed(...)
    if self.open then 
        Group.mousepressed(self, ...)
    end
    Button.mousepressed(self, ...)
end

-- Override: 
function DropdownGroup:mousereleased(...)
    if self.open then 
        Group.mousereleased(self, ...)
    end
    Button.mousereleased(self, ...)
    if not self.hover then
        self.open = false
    end
end

-- Override: 
function DropdownGroup:update(...)
    if self.open then 
        Group.update(self, ...)
    end
    Button.update(self, ...)
end

-- Override: 
function DropdownGroup:fire()
    self.open = not self.open
end

function DropdownGroup:choose(option)
    if self.multipleSelect then

    else
        local stop = false
        local oldOption = self.selectedOptions[1]
        self.selectedOptions[1] = option
        if self.onchange then
            stop = self:onchange(option)
        end
        if stop then
            self.selectedOptions[1] = oldOption
        end
        for _, o in pairs(self.options) do
            if o ~= option then
                o.selected = false
            end
        end
    end
end

-- Override: 
function DropdownGroup:value()
    if self.multipleSelect then

    else
        if self.selectedOptions[1] then return
            self.selectedOptions[1].value
        end
    end
    return nil
end

-- Override: 
function DropdownGroup:drawContent(w, h)
    if self.open then
        love.graphics.polygon("fill", w-16, h-12, w-4, h-12, w-10, 8)
    else
        love.graphics.polygon("fill", w-16, 8, w-4, 8, w-10, h - 12)
    end
    
    love.graphics.push()
    love.graphics.translate(unpack(self.style.placeholder.padding))
    if #self.selectedOptions > 0 then
        self:drawSelection()
    elseif self.placeholder then
        self.placeholder.focus = self.focus
        self.placeholder:draw()
    end
    love.graphics.pop()

    if self.open then
        self:drawChildren()
    end
end

function DropdownGroup:drawSelection()
    self.selectedOptions[1]:drawChildren()
end

-- Override: 
function DropdownGroup:drawChildren()
    for _, element in pairs(self.elements) do
        if element.draw then
            element:draw()
        end
    end
end

function DropdownGroup:selectNextElement(current, takeNext)
    if self.open then
        return Group.selectNextElement(self, current, takeNext)
    else
        return nil, takeNext
    end
end

--------------------------------------------------------------------------------
-- # DropdownOption
--------------
-- An item in a dropdown list, one of which can be selected.
--------------------------------------------------------------------------------
local DropdownOption = {}
setmetatable(DropdownOption, { __index = Button })
DropdownOption.__index = DropdownOption
function DropdownOption:__tostring()
    return "<DropdownOption:" .. (self.id or "") .. ">"
end 

function DropdownOption.new(id, position, options)
    local this = Element.new("dropdown_option", id, position, options)
    setmetatable(this, DropdownOption)
    this.elements = options.elements or {}
    for _, e in pairs(this.elements) do
        e.parent = this
        e.cannotTarget = true
    end
    this.autoLayout   = (position == nil)
    this.focus        = false
    this.value        = options.value
    if this.value == nil then
        error("The value of a dropdown option cannot be nil.")
    end
    this.hover        = false
    this.focusKeys    = options.focusKeys or {}
    this.focus        = false
    this.active       = false
    this.cannotTarget = false
    return this
end

function DropdownOption:fire()
    if not self._groupElement.open then return end
    self._groupElement:choose(self)
end

--------------------------------------------------------------------------------
-- # Hidden
--------------
-- A hidden value.
--------------------------------------------------------------------------------
local Hidden = {}
setmetatable(Hidden, { __index = Element})
Hidden.__index = Hidden
function Hidden:__tostring()
    return "<Hidden:" .. (self.id or "") .. ">"
end

function Hidden.new(id, position, options)
    local this = Element.new("hidden", id, position, options)
    setmetatable(this, Hidden)
    self.value = options.value or nil
    return this
end

function Hidden:draw()
    -- hidden.
end

--------------------------------------------------------------------------------
-- # Layout
--------------
-- The top-level container.
--------------------------------------------------------------------------------
local Layout = {}
setmetatable(Layout, { __index = Group })
Layout.__index = Layout
function Layout:__tostring()
    return "<Layout:" .. (self.id or "") .. ">"
end

function Layout.new(id, position, options)
    local this = Element.new("layout", id, position, options)
    setmetatable(this, Layout)
    this.elements = options.elements or {}
    for _, e in pairs(this.elements) do
        e.parent = this
    end
    this.cannotTarget = true
    this.styleRules   = {}
    this:addStyle(default_global_styles)
    this:addStyle(default_element_styles)
    this:load()
    return this
end

function Layout:keypressed(key, isRepeat)
    local stopped = Group.keypressed(self, key, isRepeat)
    if key == "tab" and not stopped then
        local selectedElement = self:elementWith(function(e) return e.focus end)
        if love.keyboard.isDown("lshift", "rshift") then
            self:selectPreviousElement(selectedElement)
        else
            self:selectNextElement(selectedElement)
        end
    end
end

function Layout:update(...)
    Group.update(self, ...)
    self:refreshStyles(true)
end

function Layout:draw()
    self:refreshStyles() -- TODO: check that this doesn't kill performance.
    if not self.visible then
        return
    end
    bricks.graphics.push()
    bricks.graphics.setLineStyle("rough")
    Group.draw(self)
    bricks.graphics.pop()
end

function Layout:addStyle(styleRules)
    -- TODO: use style rules for created elements (in :load())
    for k, v in pairs(styleRules) do
        self.styleRules[k] = v
    end
end

function Layout:load()
    Element.load(self)
    self:refreshStyles()
    bricks.style(self, self.styleRules)
end

function Layout:refreshStyles(hardRefresh)
    if not self.loaded then return end
    if hardRefresh then
        -- TODO: remove existing styles from all elements and reapply them.
    end
    bricks.style(self, self.styleRules)
end

--------------------------------------------------------------------------------
-- # RadioGroup
--------------
-- A group for radio options.
--------------------------------------------------------------------------------

local RadioGroup = {}
setmetatable(RadioGroup, { __index = Group })
RadioGroup.__index = RadioGroup
function RadioGroup:__tostring()
    return "<RadioGroup:" .. (self.id or "") .. ">"
end

function RadioGroup.new(id, position, options)
    local this = Element.new("radio_group", id, position, options)
    setmetatable(this, RadioGroup)
    this.onchange = options.onchange or nil
    this.elements = options.elements or {}
    for _, e in pairs(this.elements) do
        e.parent = this
    end
    this.options = this:elementsWith(function(e)
        return e._name == "radio_option" and e.group == this.id
    end)
    for _, o in pairs(this.options) do
        o._groupElement = this
    end
    this.selectedOption = nil
    this.cannotTarget   = true
    return this
end

function RadioGroup:choose(option)
    local stop = false
    local oldOption = self.selectedOption
    self.selectedOption = option
    if self.onchange then
        stop = self:onchange()
    end
    if stop then
        self.selectedOption = oldOption
    end
    for _, o in pairs(self.options) do
        if o ~= option then
            o.selected = false
        end
    end
end

function RadioGroup:value()
    if self.selectedOption then return
        self.selectedOption.value
    end
    return nil
end

--------------------------------------------------------------------------------
-- # RadioOption
--------------
-- An element similar to a checkbox, excpet that is mutually exclusive with 
-- others in the same group.
--------------------------------------------------------------------------------

local RadioOption = {}
setmetatable(RadioOption, { __index = Element})
RadioOption.__index = RadioOption
function RadioOption:__tostring()
    return "<RadioOption:" .. (self.id or "") .. ">"
end 

function RadioOption.new(id, position, options)
    local this = Element.new("radio_option", id, position, options)
    setmetatable(this, RadioOption)
    this.focus    = false
    this.group    = options.group    or nil
    this.selected = options.selected or false
    this.onchange = options.onchange or nil
    this.size     = options.size     or 16
    this.value    = options.value
    if this.value == nil then
        error("The value of a radio option cannot be nil.")
    end
    return this
end

function RadioOption:keypressed(key, isRepeat)
    if self.focus and key == "space" then
        self:toggle()
    end
end

function RadioOption:mousepressed(mx, my, key)
    self.active = self:isMouseOver(mx, my)
    self.focus  = self:isMouseOver(mx, my)
end

function RadioOption:mousereleased(mx, my, key)
    if self:isMouseOver(mx, my) then
        self:toggle()
        self:select()
    end
end

function RadioOption:toggle()
    local stop = false
    local oldValue = self.selected
    self.selected = not self.selected
    if self.onchange then
        stop = self:onchange(newValue)
    end
    if stop then
        self.selected = oldValue
    end
    if self.selected then
        self._groupElement:choose(self)
    else
        self._groupElement:choose(nil)
    end
end

function RadioOption:draw()
    if self.style.customDraw then 
        self.style.customDraw(self)
        return
    end
    if not self.visible then
        return
    end
    bricks.graphics.push()
    -- get positions
    local x, y, w, h = unpack(self:getRelativeBounds())
    r = self.size / 2
    x = x + self.style.margin[1] + r
    y = y + self.style.margin[2] + r
    -- draw shape
    if self.focus and self.style.backgroundColorFocus then
        bricks.graphics.setColor(unpack(self.style.backgroundColorFocus))
        love.graphics.circle("fill", x, y, r)
    elseif self.style.backgroundColor then
        bricks.graphics.setColor(unpack(self.style.backgroundColor))
        love.graphics.circle("fill", x, y, r)
    end
    -- draw border
    if self.focus and self.style.borderColorFocus then
        bricks.graphics.setColor(unpack(self.style.borderColorFocus))
        love.graphics.circle("line", x, y, r)
    elseif self.style.borderColor then
        bricks.graphics.setColor(unpack(self.style.borderColor))
        love.graphics.circle("line", x, y, r)
    end
    -- draw content
    bricks.graphics.setColor(unpack(self.style.textColor))
    if self.selected then
        love.graphics.circle("fill", x, y, r / 3)
    end
    bricks.graphics.pop()
end


--------------------------------------------------------------------------------
-- # Spinner
--------------
-- A class for showing to the user that a process happenning.
--------------------------------------------------------------------------------

-- Lua Coroutines: https://www.lua.org/pil/9.1.html
-- Async Coroutines?: http://leafo.net/posts/itchio-and-coroutines.html
-- Non-blocking `select` on a lua socket? And then periodically check for completion and fire a callback? Not sure if this is possible...

local Spinner = {}
setmetatable(Spinner, { __index = Element})
Spinner.__index = Spinner
function Spinner:__tostring()
    return "<Spinner:" .. (self.id or "") .. ">"
end

function Spinner.new(id, position, options)
    local this = Element.new("spinner", id, position, options)
    setmetatable(this, Spinner)
    this.spin = {
        speed    = options.speed or 2 * math.pi,
        position = 0,
        pips     = {},
    }
    local pipCount = options.pips or 8
    for i = 1, pipCount do
        table.insert(this.spin.pips, 0)
    end
    this.cannotTarget = true
    return this
end

function Spinner:update(dt)
    self.spin.position = self.spin.position + self.spin.speed * dt
    for i, pip in pairs(self.spin.pips) do
        local distance    = self.spin.position - (i-1)
        if distance < 0 then distance = distance + #self.spin.pips end
        local opacity     = math.max(0, math.min(255, 255 * distance / #self.spin.pips))
        self.spin.pips[i] = opacity
    end
    if self.spin.position >= #self.spin.pips then
        self.spin.position = self.spin.position - #self.spin.pips
    end
end

function Spinner:draw()
    if self.style.customDraw then 
        self.style.customDraw(self)
        return
    end
    if not self.visible then
        return
    end
    bricks.graphics.push()
    local ox, oy, w, h = unpack(self:getRelativeBounds())
    ox = ox + w / 2
    oy = oy + h / 2
    for i, opacity in pairs(self.spin.pips) do
        local r = 2 * math.pi * i / #self.spin.pips
        local x = ox + w/2 * math.cos(r)
        local y = oy + h/2 * math.sin(r)
        bricks.graphics.setColor(255, 255, 255, 255 - opacity)
        local n = 4
        local size = n - opacity / 128
        love.graphics.circle("fill", x, y, size)
    end
    bricks.graphics.pop()
end

--------------------------------------------------------------------------------
-- # Text
--------------
-- A simple class for displaying text. 
--------------------------------------------------------------------------------
local Text = {}
setmetatable(Text, { __index = Element})
Text.__index = Text
function Text:__tostring()
    return "<Text:" .. tostring(self.id) .. ">"
end

function Text.new(id, position, options)
    local this = Element.new("text", id, position, options)
    setmetatable(this, Text)
    this:setText(options.text)
    this.cannotTarget = true
    return this
end

function Text:setText(text)
    if text == nil then
        self.text = function () return "" end
    elseif type(text) == "string" then
        self.text = function() return text end
    elseif type(text) == "function" then
        self.text = text
    else
        error("[Mortar] Invalid text value: '" .. tostring(text) .. "' for Text.")
    end
end

function Text:draw()
    if self.style.customDraw then 
        self.style.customDraw(self)
        return
    end
    if not self.visible then
        return
    end
    bricks.graphics.push()
    local x, y, w, h = unpack(self:getRelativeBounds())
    x, y, w, h = self:applyMargin(x, y, w, h)
    self:drawShape(x, y, w, h)
    x, y, w, h = self:applyPadding(x, y, w, h)
    if self.style.font then
        bricks.graphics.setFont(self.style.font)
    end
    if self.style.textColor then
        bricks.graphics.setColor(unpack(self.style.textColor))
    end
    local align = self.pos[6]
    love.graphics.printf(self.text(), x, y, w, align)
    bricks.graphics.pop()
end

--------------------------------------------------------------------------------
-- # TextInput
--------------
-- A class for allowing a user to input text. 
--------------------------------------------------------------------------------
local TextInput = {}
setmetatable(TextInput, { __index = Element})
TextInput.__index = TextInput
function TextInput:__tostring()
    return "<TextInput:" .. (self.id or "") .. ">"
end

function TextInput.new(id, position, options)
    local this = Element.new("text_input", id, position, options)
    setmetatable(this, TextInput)
    this.placeholder    = options.placeholder or nil
    if this.placeholder then
        this.placeholder.parent = this
    end
    this.pattern        = options.pattern or nil
    local initialText   = {}
    if options.text then
        options.text:gsub(".",function(c) 
            table.insert(initialText,c) 
        end)
    end
    this.text           = initialText
    this.index          = #this.text
    this.validation     = options.validation or {}
    this.oninvalid      = options.oninvalid or nil
    this.onchange       = options.onchange or nil
    this.focus          = false
    this.flashSpeed     = 0.5
    this.flashTimer     = 0
    this.cursorVisible  = true
    this.valid          = true
    this:validate()
    return this
end

function TextInput:change()
    if self.onchange then
        self:onchange()
    end
    self:validate()
end

function TextInput:validate(force)
    if not self.validation then
        self.valid = true
        return
    end
    if #self.text == 0 and not force then
        self.valid = true
        return
    end
    local text = self:value()
    for _, check in ipairs(self.validation) do
        if check.custom then
            if not check.custom(self, text) then
                self.valid = false
                if check.oninvalid then
                    check.oninvalid(self)
                end
                -- TODO: show validation message element
                return
            end
        elseif check.pattern then
            if text:match(check.pattern) ~= text then
                self.valid = false
                if check.oninvalid then
                    check.oninvalid(self)
                end
                -- TODO: show validation message element
                return
            end
        end
    end
    self.valid = true
end

function TextInput:update(dt, mx, my)
    self.hover = self:isMouseOver(mx, my)
    if self.focus then
        self.flashTimer = self.flashTimer + dt
        if self.flashTimer > self.flashSpeed then
            self.cursorVisible = not self.cursorVisible
            self.flashTimer = self.flashTimer - self.flashSpeed
        end
    end
end

function TextInput:mousereleased(mx, my, key)
    if self:isMouseOver(mx, my) then
        self:select()
    else
        self:deselect()
    end
end

function TextInput:keypressed(key, isRepeat)
    -- SEE: https://love2d.org/wiki/love.textinput
    if not self.focus then return end
    if key == "backspace" then
        if self.index > 0 and #self.text > 0 then
            table.remove(self.text, self.index)
            self.index = self.index - 1
            self:change()
        end
    end
    if key == "delete" then
        if #self.text > 0 and self.text[self.index + 1] then
            table.remove(self.text, self.index + 1)
            self:change()
        end
    end
    if key == "left" and self.index > 0 then
        self.index = self.index - 1
    end
    if key == "right" and self.index < #self.text then
        self.index = self.index + 1
    end
    if (key == "v" and love.keyboard.isDown("lctrl", "rctrl")) or
        (key == "insert" and love.keyboard.isDown("lshift", "rshift")) then
        self:keytyped(love.system.getClipboardText())
        self:change()
    end
end

function TextInput:value()
    local text = ""
    for i, char in ipairs(self.text) do
        text = text .. char
    end
    return text
end

function TextInput:keytyped(text)
    if not self.focus then return end
    for c in text:gmatch(".") do
        table.insert(self.text, self.index + 1, c)
        self.index = self.index + 1
    end
    self:change()
end

function TextInput:drawContent(w, h)
    love.graphics.line(0, h, w, h)
    local font = love.graphics.getFont()
    local text = self:value()
    if text:len() == 0 and self.placeholder then
        self.placeholder:draw()
    end

    if not self.valid and self.style.textColorInvalid then
        bricks.graphics.setColor(unpack(self.style.textColorInvalid))
    else
        bricks.graphics.setColor(unpack(self.style.textColor))
    end


    local x = default_global_styles["*"].padding[1]
    local y = default_global_styles["*"].padding[2]

    love.graphics.printf(text, x, y, w, self.pos[6])

    if self.focus and self.cursorVisible then
        local ox = 0
        for i = 1, self.index do
            ox = ox + font:getWidth(self.text[i])
        end
        local ch = font:getHeight()
        bricks.graphics.setColor(unpack(self.style.cursorColor))
        love.graphics.line(x + ox, y, x + ox, y + ch)
    end
end

--------------------------------------------------------------------------------
-- # Mortar.Graphics (Internal)
--------------
-- This holds a stack of graphical parameters (font, colour, backgroundColour, 
-- line style, etc.). This stack can be pushed to and popped from to isolate
-- individual elements' draw methods without manually keeping track of the old
-- state of these values. The current state is still represented by using
-- love.graphics.get* methods.

-- TODO: test this with an actual stack test.

--------------------------------------------------------------------------------
bricks.graphics = {stack={}}
setmetatable(bricks.graphics, {
    __index = function(table, key)
        if key:find("set") and love.graphics[key] then

            local getter = key:gsub("set", "get", 1)
            local currentValue = { love.graphics[getter]() }
            local topLevel = bricks.graphics.stack[#bricks.graphics.stack]
            if not topLevel[getter] then
                topLevel[getter] = currentValue
            end
            return love.graphics[key]

        elseif key:find("get") and love.graphics[key] then

            local i = #bricks.graphics.stack
            local topLevel = bricks.graphics.stack[i]
            while topLevel[key] == nil and i > 0 do
                i = i - 1
                topLevel = bricks.graphics.stack[i]
            end
            return topLevel[key]

        elseif key:find("pop") and love.graphics[key:gsub("pop", "get", 1)] then

            -- TODO: pop just a single element

        else
            return rawget(table, key)
        end
    end
})

-- Pushing creates a new 'scope' on top of the stack.
function bricks.graphics.push()
    table.insert(bricks.graphics.stack, {})
end

-- Popping removed the top 'scope' from the stack, and uses its values (which
-- are the previous values for that property) to set the love.graphics values
-- to again.
function bricks.graphics.pop()
    local topLevel = table.remove(bricks.graphics.stack)
    for key, value in pairs(topLevel) do
        local setter = key:gsub("get", "set", 1)
        love.graphics[setter](unpack(value))
    end
end

-- Internal function as elements have common constructors.
local function default_constructor_for(ObjectClass)
    return function(...)
        local params = {...}
        if #params == 3 then
            return ObjectClass.new(unpack(params))
        elseif #params == 2 then
            if type(params[1]) == "string" then
                return ObjectClass.new(params[1], nil, params[2])
            elseif type(params[1]) == "table" then
                return ObjectClass.new(nil, params[1], params[2])
            end
        elseif #params == 1 then
            if params[1][1] then
                return ObjectClass.new(nil, params[1], {})
            else
                return ObjectClass.new(nil, nil, params[1])
            end
        elseif #params == 0 then
            return ObjectClass.new(nil, nil, {})
        else
            local errorString = "[Mortar] Invalid parameters:\n"
            errorString = errorString .. "Attempted to create a " .. tostring(ObjectClass)
            errorString = errorString .. " with " .. tostring(#params) .. " parameters\n"
            for k, v in pairs(params) do
                errorString = errorString .. "\t" .. tostring(v) .. ",\n"
            end
            error(errorString)
        end
    end
end

local function default_group_constructor_for(ObjectClass)
    return function(...)
        local params = {...}
        if #params == 4 then
            params[3].elements = params[4]
            table.remove(params, 4)
            return ObjectClass.new(unpack(params))
        elseif #params == 3 and type(params[1]) == "string" then
            if params[2][1] then -- location
                return ObjectClass.new(params[1], params[2], {elements = params[3]})
            else
                params[2].elements = params[3]
                return ObjectClass.new(params[1], nil, params[2])
            end
        elseif #params == 3 and type(params[1]) == "table" then
            params[2].elements = params[3]
            return ObjectClass.new(nil, params[1], params[2])
        elseif #params == 2 and type(params[1]) == "string" then
            return ObjectClass.new(params[1], nil, {elements = params[2]})
        elseif #params == 2 and type(params[1]) == "table" then
            if params[1][1] then
                return ObjectClass.new(nil, params[1], {elements = params[2]})
            else
                params[1].elements = params[2]
                return ObjectClass.new(nil, nil, params[1])
            end
        elseif #params == 1 then
            return ObjectClass.new(nil, nil, {elements = params[1]})
        elseif #params == 0 then
            return ObjectClass.new(nil, nil, {})
        else
            local errorString = "[Mortar] Invalid parameters:\n"
            errorString = errorString .. "Attempted to create a " .. tostring(ObjectClass)
            errorString = errorString .. " with " .. tostring(#params) .. "parameters\n"
            for k, v in pairs(params) do
                errorString = errorString .. "\t" .. v .. ",\n"
            end
            error(errorString)
        end
    end
end

local function special_text_constructor()
    local ObjectClass = Text
    return function(...)
        local params = {...}
        if #params == 3 then
            return ObjectClass.new(unpack(params))
        elseif #params == 2 then
            if type(params[1]) == "string" then
                return ObjectClass.new(params[1], nil, params[2])
            elseif type(params[1]) == "table" then
                return ObjectClass.new(nil, params[1], params[2])
            end
        elseif #params == 1 then
            if params[1][1] then
                return ObjectClass.new(nil, params[1], {})
            elseif type(params[1]) == "string" then
                return ObjectClass.new(nil, nil, {text = params[1]})
            else
                return ObjectClass.new(nil, nil, params[1])
            end
        elseif #params == 0 then
            return ObjectClass.new(nil, nil, {})
        else
            local errorString = "[Mortar] Invalid parameters:\n"
            errorString = errorString .. "Attempted to create a " .. tostring(ObjectClass)
            errorString = errorString .. " with " .. tostring(#params) .. " parameters\n"
            for k, v in pairs(params) do
                errorString = errorString .. "\t" .. tostring(v) .. ",\n"
            end
            error(errorString)
        end
    end
end

-- Public methods for creation of elements.
bricks.checkbox     = default_constructor_for(Checkbox)
bricks.hidden       = default_constructor_for(Hidden)
bricks.radio_option = default_constructor_for(RadioOption)
bricks.spinner      = default_constructor_for(Spinner)
bricks.text_input   = default_constructor_for(TextInput)

bricks.text         = special_text_constructor()

bricks.button          = default_group_constructor_for(Button)
bricks.radio_group     = default_group_constructor_for(RadioGroup)
bricks.dropdown_group  = default_group_constructor_for(DropdownGroup)
bricks.dropdown_option = default_group_constructor_for(DropdownOption)
bricks.group           = default_group_constructor_for(Group)
bricks.layout          = default_group_constructor_for(Layout)

-- Private tables for customisation purposes.
bricks._classes = {
    Element     = Element,
    Button      = Button,
    Checkbox    = Checkbox,
    Group       = Group,
    Hidden      = Hidden,
    Layout      = Layout,
    RadioOption = RadioOption,
    RadioGroup  = RadioGroup,
    Spinner     = Spinner,
    Text        = Text,
    TextInput   = TextInput,
}
bricks._functions = {
    default_constructor_for       = default_constructor_for,
    default_group_constructor_for = default_group_constructor_for,
}

--------------------------------------------------------------------------------
-- # Mortar.Style
--------------
-- 
--------------------------------------------------------------------------------

function bricks.style(object, styleRules)
    for selector, rules in pairs(styleRules) do
        local elements = object:find(selector)
        if elements then
            for _, element in pairs(elements) do
                element:setStyle(rules)
            end
        end
    end
end

return bricks