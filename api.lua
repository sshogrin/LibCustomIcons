local lib_name = "LibCustomIcons"
local lib = _G[lib_name]
local s = lib.GetStaticTable()
local a = lib.GetAnimatedTable()

--- function that creates a deep copy of a table
local function clone(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

--- Checks whether a static icon exists for the given username.
--- @param username string The player's account name (e.g., "@m00nyONE").
--- @return boolean hasStaticIcon `true` if a custom static icons exists, `false` otherwise.
function lib.HasStatic(username)
    return s[username] ~= nil
end
--- Checks whether an animated icon exists for the given username.
--- @param username string The player's account name (e.g., "@m00nyONE").
--- @return boolean hasAnimatedIcon `true` if a custom animated icons exists, `false` otherwise.
function lib.HasAnimated(username)
    return a[username] ~= nil
end
--- Checks if a custom icon (either static or animated) exists for the given username.
--- @param username string The player's account name (e.g., "@m00nyONE").
--- @return boolean hasStaticIcon `true` if a custom static icons exists, `false` otherwise.
function lib.HasIcon(username)
    return lib.HasStatic(username) or lib.HasAnimated(username)
end


--- Retrieves the texturePath of the static icon for the user or nil if none exists.
--- @param username string The player's account name (e.g., "@m00nyONE").
--- @return string|nil texturePath or `nil` if no static icon exists
function lib.GetStatic(username)
    return s[username]
end
--- Retrieves the texturePath and animation parameters of the animated icon for the user or nil if none exists.
--- @param username string The player's account name (e.g., "@m00nyONE").
--- @return table<string,animEntry>|nil `{texturePath, width, height, fps}` or `nil` if no static icon exists
function lib.GetAnimated(username)
    return a[username]
end

--- Retrieves the texturePath and animation parameters of the animated icon for the user if it exists or the texturePath of the static icon for the user or nil if none exists.
--- @param username string The player's account name (e.g., "@m00nyONE").
--- @return table<string,animEntry>|string|nil `{texturePath, width, height, fps}` or `texturePath` or `nil` if no static icon exists
function lib.GetIcon(username)
    local anim = lib.GetAnimated(username)
    if anim then return anim end

    local static = lib.GetStatic(username)
    if static then return static end

    return nil
end

--- Retrieves all registered static icons
---@return table<string,string> table mapping `@accountname` to `texturePath` for all static icons
function lib.GetAllStatic()
    return clone(s)
end
--- Retrieves all registered static icons
---@return table<string,animEntry> table mapping `@accountname` to `{texturePath, width, height, fps}` for all animated icons
function lib.GetAllAnimated()
    return clone(a)
end

--[[
    Icon count caching:
    The number of static and animated icons is fixed at runtime (icons are registered once and not modified later).
    To optimize performance, counts are calculated only once when first requested and then cached for future calls.
]]

local staticIconCount = 0
local animatedIconCount = 0
local totalIconCount = 0

--- Returns the number of registered static icons.
--- The result is cached after the first computation.
--- @return number count The number of static icons
function lib.GetStaticCount()
    if staticIconCount == 0 then
        for _ in pairs(s) do
            staticIconCount = staticIconCount + 1
        end
    end
    return staticIconCount
end

--- Returns the number of registered animated icons.
--- The result is cached after the first computation.
--- @return number count The number of animated icons
function lib.GetAnimatedCount()
    if animatedIconCount == 0 then
        for _ in pairs(a) do
            animatedIconCount = animatedIconCount + 1
        end
    end
    return animatedIconCount
end

--- Returns the total number of registered icons (static + animated).
--- The result is cached after the first computation.
--- @return number count The total number of icons
function lib.GetIconCount()
    if totalIconCount == 0 then
        totalIconCount = lib.GetStaticIconCount() + lib.GetAnimatedIconCount()
    end
    return totalIconCount
end
