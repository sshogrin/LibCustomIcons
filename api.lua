local lib_name = "LibCustomIcons"

local lib = _G[lib_name]
local s = lib.GetStaticTable()
local a = lib.GetAnimatedTable()

-- internal function that created a deep copy of a table
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
    return lib:HasStatic(username) or lib:HasAnimated(username)
end


--- Retrieves the texturePath of the static icon for the user or nil if none exists.
--- @param username string The player's account name (e.g., "@m00nyONE").
--- @return string|nil texturePath or `nil` if no static icon exists
function lib.GetStatic(username)
    return s[username]
end
--- Retrieves the texturePath and animation parameters of the animated icon for the user or nil if none exists.
--- @param username string The player's account name (e.g., "@m00nyONE").
--- @return table<string,sizeX,sizeY,fps>|nil {texturePath, sizeX, sizeY, fps} or `nil` if no static icon exists
function lib.GetAnimated(username)
    return a[username]
end

--- Retrieves the texturePath and animation parameters of the animated icon for the user if it exists or the texturePath of the static icon for the user or nil if none exists.
--- @param username string The player's account name (e.g., "@m00nyONE").
--- @return table<string,sizeX,sizeY,fps>|string|nil {texturePath, sizeX, sizeY, fps} or texturePath or `nil` if no static icon exists
function lib.GetIcon(username)
    local anim = lib.GetAnimated(username)
    if anim then return anim end

    local static = lib.GetStatic(username)
    if static then return static end

    return nil
end

--- Retrieves all registered static icons
---@return table<string, string> table mapping `@accountname` to `texturePath` for all static icons
function lib.GetAllStaticIcons()
    return clone(s)
end
--- Retrieves all registered static icons
---@return table<string, string[]> table mapping `@accountname` to `{texturePath, sizeX, sizeY, fps}` for all animated icons
function lib.GetAllAnimatedIcons()
    return clone(a)
end

