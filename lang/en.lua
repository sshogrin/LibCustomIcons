local strings = {
    LCI_MENU = "LibCustomIcons",
    LCI_MENU_README = "Readme (Click to open)",
    LCI_MENU_README1 = "Use the settings below to generate a LUA for your custom icon. Then send the code along with your icon to the addons author.",
    LCI_MENU_README2 = "Click \"%s\" at the top of this menu for more detailed instructions on how to contact the author and get a custom icon. Please use the in-game mail system for gold donations only. You won't get any replies there regarding icon requests!",
    LCI_MENU_HEADER = "my custom icon",
    LCI_MENU_GEN_STATIC = "generate static icon LUA code",
    LCI_MENU_GEN_ANIMATED = "generate animated icon LUA code",
    LCI_MENU_LUA = "LUA code:",
    LCI_MENU_LUA_TT = "Send this code to the addon author.",
    LCI_MENU_INTEGRITY = "INTEGRITY",
    LCI_MENU_INTEGRITY_DESCRIPTION = "Check the integrity of LibCustomIcons",
}

for id, val in pairs(strings) do
    ZO_CreateStringId(id, val)
    SafeAddVersion(id, 1)
end