local strings = {
    LCI_MENU = "LibCustomIcons",
    LCI_MENU_README = "Readme (Klicken zum Öffnen)",
    LCI_MENU_README1 = "Verwende die untenstehenden Einstellungen, um den LUA-Code für dein benutzerdefiniertes Icon zu erzeugen. Sende diesen Code zusammen mit deinem Icon an den Addon-Autor.",
    LCI_MENU_README2 = "Klicke oben in diesem Menü auf „%s“, um eine detaillierte Anleitung zu erhalten, wie du den Autor kontaktieren und ein benutzerdefiniertes Icon erhalten kannst. Bitte verwende das Ingame-Postsystem nur für Goldspenden. Anfragen zu Icons werden dort nicht beantwortet!",
    LCI_MENU_HEADER = "mein benutzerdefiniertes Icon",
    LCI_MENU_GEN_STATIC = "LUA-Code für statisches Icon erzeugen",
    LCI_MENU_GEN_ANIMATED = "LUA-Code für animiertes Icon erzeugen",
    LCI_MENU_LUA = "LUA-Code:",
    LCI_MENU_LUA_TT = "Sende diesen Code an den Addon-Autor.",
    LCI_MENU_INTEGRITY = "INTEGRITÄT",
    LCI_MENU_INTEGRITY_DESCRIPTION = "Überprüft die Integrität von LibCustomIcons",
}

for id, val in pairs(strings) do
    ZO_CreateStringId(id, val)
    SafeAddVersion(id, 1)
end
