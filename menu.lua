local lib_name = "LibCustomIcons"
local lib = _G[lib_name]
local lib_author = lib.author
local lib_version = lib.version

-- needs to be changed if we create a new folder for icons - usually after a folder reaches 1k icons or the year has changed
local currentFolder = "misc7"
local sv = {}
local svVersion = 1
local svDefaults = {
    genStatic = false,
    genAnimated = false,
}

local LAM = LibAddonMenu2
local strfmt = string.format

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
    local _escapeName = function(displayName)
        local name = displayName:gsub("^@", "")
        name = name:gsub("[^%w%-_]", "")
        return name
    end

    local _generateStaticCode = function(displayName)

        local s = strfmt('s["%s"] = "LibCustomIcons/icons/%s/%s.dds"', displayName, currentFolder, _escapeName(displayName))
        return s
    end
    local _generateAnimatedCode = function(displayName)
        local s = strfmt('a["%s"] = {"LibCustomIcons/icons/%s/%s_anim.dds", 0, 0, 0}', displayName, currentFolder, _escapeName(displayName))
        return s
    end

    local _generateCode = function()
        local displayName = GetDisplayName('player')

        local code = "```\n"
        if sv.genStatic then
            code = code .. _generateStaticCode(displayName)
            code = code .. "\n"
        end
        if sv.genAnimated then
            code = code .. _generateAnimatedCode(displayName)
            code = code .. "\n"
        end
        code = code .. "```"

        return code
    end

    return {
        {
            type = "submenu",
            name = strfmt("|cFF8800%s|r", GetString(LCI_MENU_README)),
            controls = {
                {
                    type = "description",
                    text = strfmt("|c00FF001.|r %s", GetString(LCI_MENU_README1))
                },
                {
                    type = "description",
                    text = strfmt("|c00FF002.|r %s", strfmt(GetString(LCI_MENU_README2), LAM.util.L.WEBSITE))
                ,}
            },
        },
        {
            type = "header",
            name = strfmt("|cFFFACD%s|r", GetString(LCI_MENU_HEADER))
        },
        {
            type = "checkbox",
            name = GetString(LCI_MENU_GEN_STATIC),
            tooltip = GetString(LCI_MENU_GEN_STATIC_TT),
            default = false,
            getFunc = function() return sv.genStatic end,
            setFunc = function(value)
                sv.genStatic = value
            end,
        },
        {
            type = "checkbox",
            name = GetString(LCI_MENU_GEN_ANIMATED),
            tooltip = GetString(LCI_MENU_GEN_ANIMATED_TT),
            default = false,
            getFunc = function() return sv.genAnimated end,
            setFunc = function(value)
                sv.genAnimated = value
            end,
        },
        {
            type = "editbox",
            name = GetString(LCI_MENU_LUA),
            tooltip = GetString(LCI_MENU_LUA_TT),
            default = _generateCode(),
            getFunc = function() return _generateCode() end,
            setFunc = function(value) end,
            isMultiline = true,
            isExtraWide = true,
        },
        {
            type = "submenu",
            name = string.format("|cFFFACD%s|r", GetString(LCI_MENU_INTEGRITY)),
            controls = {
                {
                    type = "description",
                    text = string.format("|cFFFACD%s|r", GetString(LCI_MENU_INTEGRITY_DESCRIPTION)),
                },
                {
                    type = "button",
                    name = "Check",
                    tooltip = "Check the integrity of LibCustomIcons",
                    func = lib.IntegrityCheck,
                    width = 'half',
                },
            },
        },
    }
end

function lib.BuildMenu()
    sv = ZO_SavedVars:NewAccountWide(lib_name .. "SV", svVersion, nil, svDefaults)

    local panel = getPanel()
    local options = getOptions()

    LAM:RegisterAddonPanel(lib_name .. "Menu", panel)
    LAM:RegisterOptionControls(lib_name .. "Menu", options)

    lib.BuildMenu = nil
end