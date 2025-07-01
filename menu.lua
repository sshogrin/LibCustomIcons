local lib_name = "LibCustomIcons"
local lib = _G[lib_name]
local lib_name = lib.name
local lib_author = lib.author
local lib_version = lib.version

local LAM = LibAddonMenu2

local function getPanel()
    return {
        type = 'panel',
        name = lib_name,
        displayName = lib_name,
        author = '|c76c3f4@m00nyONE|r',
        version = string.format('|c00FF00%s|r', lib_version),
        website = 'https://www.esoui.com/downloads/info4161-LibCustomIcons.html#info',
        donation = lib.Donate,
        registerForRefresh = true,
    }
end

local function getOptions()
    return {
        {
        	type = "header",
        	name = string.format("|cFFFACD%s|r", "INTEGRITY"),
        },
        {
        	type = "description",
        	text = string.format("|cFFFACD%s|r", "Check the integrity of LibCustomIcons"),
        },
        {
        	type = "button",
        	name = "Check",
        	tooltip = "Check the integrity of LibCustomIcons",
        	func = lib.IntegrityCheck,
        	width = 'half',
        },
    }
end

function lib.BuildMenu()
    local panel = getPanel()
    local options = getOptions()

    LAM:RegisterAddonPanel(lib_name .. "Menu", panel)
    LAM:RegisterOptionControls(lib_name .. "Menu", options)

    lib.BuildMenu = nil
end