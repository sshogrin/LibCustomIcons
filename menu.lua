--{
--	type = "header",
--	name = string.format("|cFFFACD%s|r", GetString(HR_MENU_ICONS_INTEGRITY)),
--},
--{
--	type = "description",
--	text = string.format("|cFFFACD%s|r", GetString(HR_MENU_ICONS_INTEGRITY_DESCRIPTION)),
--},
--{
--	type = "button",
--	name = GetString(HR_MENU_ICONS_INTEGRITY_CHECK),
--	tooltip = GetString(HR_MENU_ICONS_INTEGRITY_DESCRIPTION),
--	func = function()
--		HodorReflexes.integrity.Check()
--	end,
--	width = 'half',
--},

local lib_name = "LibCustomIcons"
local lib = _G[lib_name]
local lib_name = lib.name
local lib_author = lib.author
local lib_version = lib.version

local LAM = LibAddonMenu2

--- Opens the in-game mail window with donation fields prefilled for supporting the library.
local function donate()
    SCENE_MANAGER:Show('mailSend')
    zo_callLater(function()
        ZO_MailSendToField:SetText(lib_author)
        ZO_MailSendSubjectField:SetText("Donation for " .. lib_name)
        ZO_MailSendBodyField:SetText("ticket-XXXX on Discord.")
        ZO_MailSendBodyField:TakeFocus()
    end, 250)
end

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