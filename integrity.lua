local lib_name = "LibCustomIcons"

local lib = _G[lib_name]
local s = lib.GetStaticTable()
local a = lib.GetAnimatedTable()
local sLength = 0
local aLength = 0

local EM = EVENT_MANAGER
local LAM = LibAddonMenu2

local WM = GetWindowManager()
local GUIControl = LibCustomIcons_IntegrityCheck

local iconSize = 32
local SCREEN_WIDTH = GuiRoot:GetWidth()
local SCREEN_HEIGHT = GuiRoot:GetHeight()
--local maxColumns = zo_floor(SCREEN_WIDTH / iconSize)
--local maxRows = zo_floor(SCREEN_HEIGHT / iconSize)

local LOAD_DELAY = 5 --5ms
local checkAfter = 0
local unloadAfter = 5000
local reportAfter = 1000

local iconPool = {}
local scannedIcons = 0
local failedList = {}

local function len(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function resetValues()
    checkAfter = 0
    iconPool = {}
    scannedIcons = 0
    failedList = {}
    sLength = 0
    aLength = 0
end

local function GetResults()
    zo_callLater(function()
        local failed = len(failedList)

        local integrityFailed = failed > 10
        local color = "00FF00"
        local status = "passed"
        local message = "all fine :-)"

        local function colorize(str)
            return "|c" .. color .. str .. "|r"
        end

        if integrityFailed then
            color = "FF0000"
            status = "failed"
            message = colorize(
                    "\nThere might be an issue with your LibCustomIcons installation.\n" ..
                            "please consider reinstalling the addon\n"
            )

            d(colorize("Missing icons:"))
            for user, icon in pairs(failedList) do
                d(colorize(user .. " (" .. icon .. ")"))
            end
            d("")
        end

        d(colorize("summary:"))
        d(colorize("icons scanned: " .. scannedIcons))
        d(colorize("icons failed: " .. failed))
        d("")

        PlaySound(SOUNDS.BOOK_COLLECTION_COMPLETED)
        if not ZO_Dialogs_IsShowingDialog() then
            LAM.util.ShowConfirmationDialog(
                    "LibCustomIcons Integrity check",
                    "Integrity check ".. colorize(status) .. "\n" ..
                            "icons scanned: " .. scannedIcons .. "\n" ..
                            "icons failed: " .. colorize(failed) .. "\n" ..
                            message,
                    nil)
        end

    end, 1000)
end

local function createTexture(iconNumber, userName, iconPath)
    --local iconColumn = iconNumber % maxColumns
    --local iconRow = (zo_floor((iconSize * iconNumber) / SCREEN_WIDTH)) % maxRows
    local iconX = zo_floor(math.random(0, SCREEN_WIDTH - iconSize))
    local iconY = zo_floor(math.random(0, SCREEN_HEIGHT - iconSize))

    local icon = WM:CreateControl( GUIControl:GetName() .. "_" .. GetGameTimeMilliseconds() .. "_Icon_" .. tostring(iconNumber), GUIControl, CT_TEXTURE)

    icon.userName = userName
    icon.iconPath = iconPath
    icon:ClearAnchors()
    --icon:SetAnchor( TOPLEFT, GUIControl, TOPLEFT, (iconColumn * iconSize), (iconRow * iconSize))
    icon:SetAnchor( TOPLEFT, GUIControl, TOPLEFT, iconX, iconY)
    icon:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
    icon:SetHidden(false)
    icon:SetTexture(iconPath)
    icon:SetDimensions(iconSize, iconSize)

    iconPool[iconNumber] = icon
    scannedIcons = scannedIcons + 1
end

local function checkTexture(iconNumber)
    local icon = iconPool[iconNumber]
    local isLoaded = icon:IsTextureLoaded()

    if isLoaded then
        iconPool[iconNumber]:SetTexture("LibCustomIcons/assets/check.dds")
    else
        --table.insert(failedList, icon.userName)
        failedList[icon.userName] = icon.iconPath
        iconPool[iconNumber]:SetTexture("LibCustomIcons/assets/cross.dds")
    end
end

local function deleteTexture(iconNumber)
    iconPool[iconNumber]:SetHidden(true)
    iconPool[iconNumber]:SetTexture("none")
    iconPool[iconNumber] = nil
end

local function calculateCheckTime()
    return (sLength + aLength) * LOAD_DELAY
end

local function integrityCheck()
    local limit = 9999999
    local iconNumber = 1

    LibCustomIcons_IntegrityCheck:SetHidden(false)

    d("loading animated icons ...")
    for userName, userData in pairs(a) do
        if iconNumber >= limit then
            break
        end

        local iconPath = userData[1]
        createTexture(iconNumber, userName, iconPath)
        iconNumber = iconNumber + 1
    end

    d("loading static icons ...")
    for userName, _ in pairs(s) do
        if iconNumber >= limit then
            break
        end

        local iconPath = s[userName]
        if iconPath then
            createTexture(iconNumber, userName, iconPath)
            iconNumber = iconNumber + 1
        end
    end

    d("loaded " .. iconNumber .. " icons")

    zo_callLater(function()
        d("checking icons...")
        for i, _ in pairs(iconPool) do
            checkTexture(i)
        end

        zo_callLater(function()
            d("unloading icons ...")
            for i, _ in pairs(iconPool) do
                deleteTexture(i)
            end

            zo_callLater(function()
                LibCustomIcons_IntegrityCheck:SetHidden(true)
                d("writing report ...")
                GetResults()
                d("done")
                end, reportAfter)
            end, unloadAfter)
        end, checkAfter)
end



function lib.IntegrityCheck()
    resetValues()

    sLength = len(s)
    aLength = len(a)

    checkAfter = calculateCheckTime()

    local calculatedTime = (reportAfter + unloadAfter + checkAfter) / 1000

    d("starting integritycheck")
    d("this will take aproximatly " .. calculatedTime .. " seconds")
    d("please wait and let it do its thing :-)")


    if not ZO_Dialogs_IsShowingDialog() then
        LAM.util.ShowConfirmationDialog(
                "LibCustomIcons Integrity check",
                "Do you want to perform an integrity check? This will take approximately ".. calculatedTime .." seconds",
                function() LAM.util.ShowConfirmationDialog(
                        "LibCustomIcons Integrity check",
                        "Please do not interrupt the check. Just let it do its thing. You will get the results after it's finished",
                        function()
                            zo_callLater(integrityCheck, 250)
                        end)
                end)
    end

end
--zo_callLater(function() integrityCheck() end, 2000)



































-----------------------------------------
--HodorReflexes.integrity = {
--    sv = nil,
--    default = {
--        timeStamp = 0,
--        failed = 0,
--        scannedIcons = 0,
--        failedList = {},
--    }
--}
--
--local EM = EVENT_MANAGER
--local HR = HodorReflexes
--local LAM = LibAddonMenu2
--local M = HodorReflexes.integrity
--
--local u = HodorReflexes.users
--local a = HodorReflexes.anim.users
--local getIconForUserId = HodorReflexes.player.GetIconForUserId
--
--local WM = GetWindowManager()
--local GUIControl = HodorReflexes_IntegrityCheck
--
--local iconSize = 32
--local SCREEN_WIDTH = GuiRoot:GetWidth()
--local SCREEN_HEIGHT = GuiRoot:GetHeight()
--local maxColumns = zo_floor(SCREEN_WIDTH / iconSize)
--local maxRows = zo_floor(SCREEN_HEIGHT / iconSize)
--
--local LOAD_DELAY = 5 --5ms
--local checkAfter = 0
--local unloadAfter = 5000
--local reportAfter = 1000
--local reloadAfter = 1000
--
--local iconPool = {}
--local failedList = {}
--
--local function createTexture(iconNumber, userName, iconPath)
--    --local iconColumn = iconNumber % maxColumns
--    --local iconRow = (zo_floor((iconSize * iconNumber) / SCREEN_WIDTH)) % maxRows
--    local iconX = zo_floor(math.random(0, SCREEN_WIDTH - iconSize))
--    local iconY = zo_floor(math.random(0, SCREEN_HEIGHT - iconSize))
--
--
--
--    local icon = WM:CreateControl( GUIControl:GetName() .. "_" .. GetGameTimeMilliseconds() .. "_Icon_" .. tostring(iconNumber), GUIControl, CT_TEXTURE)
--
--    icon.userName = userName
--    icon.iconPath = iconPath
--    icon:ClearAnchors()
--    --icon:SetAnchor( TOPLEFT, GUIControl, TOPLEFT, (iconColumn * iconSize), (iconRow * iconSize))
--    icon:SetAnchor( TOPLEFT, GUIControl, TOPLEFT, iconX, iconY)
--    icon:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
--    icon:SetHidden(false)
--    icon:SetTexture(iconPath)
--    icon:SetDimensions(iconSize, iconSize)
--
--    iconPool[iconNumber] = icon
--end
--
--local function checkTexture(iconNumber)
--    local icon = iconPool[iconNumber]
--    local isLoaded = icon:IsTextureLoaded()
--
--    if isLoaded then
--        iconPool[iconNumber]:SetTexture("HodorReflexes/assets/integrity/check.dds")
--    else
--        --table.insert(failedList, icon.userName)
--        failedList[icon.userName] = icon.iconPath
--        iconPool[iconNumber]:SetTexture("HodorReflexes/assets/integrity/cross.dds")
--    end
--end
--
--local function deleteTexture(iconNumber)
--    iconPool[iconNumber]:SetHidden(true)
--    iconPool[iconNumber]:SetTexture("none")
--    iconPool[iconNumber] = nil
--end
--
--local function calculateCheckTime()
--    local iconNumber = 0
--
--    for _, _ in pairs(a) do
--        iconNumber = iconNumber + 1
--    end
--
--    for userName, _ in pairs(u) do
--        local iconPath = getIconForUserId(userName)
--        if iconPath then
--            iconNumber = iconNumber + 1
--        end
--    end
--
--    return iconNumber * LOAD_DELAY -- for each icon to load
--end
--
--local function integrityCheck()
--    local limit = 9999999
--    local iconNumber = 1
--
--    d("loading animated icons ...")
--    for userName, userData in pairs(a) do
--        if iconNumber >= limit then
--            break
--        end
--
--        local iconPath = userData[1]
--        createTexture(iconNumber, userName, iconPath)
--        iconNumber = iconNumber + 1
--    end
--
--    d("loading static icons ...")
--    for userName, _ in pairs(u) do
--        if iconNumber >= limit then
--            break
--        end
--
--        local iconPath = getIconForUserId(userName)
--        if iconPath then
--            createTexture(iconNumber, userName, iconPath)
--            iconNumber = iconNumber + 1
--        end
--    end
--
--    d("loaded " .. iconNumber .. " icons")
--    M.sv.scannedIcons = iconNumber
--
--    zo_callLater(function()
--        d("checking icons...")
--        for i, _ in pairs(iconPool) do
--            checkTexture(i)
--        end
--
--        zo_callLater(function()
--            d("unloading icons ...")
--            for i, _ in pairs(iconPool) do
--                deleteTexture(i)
--            end
--
--            zo_callLater(function()
--                d("writing report ...")
--                -- count items in failedList
--                local failed = 0
--                for _, _ in pairs(failedList) do
--                    failed = failed +1
--                end
--
--                M.sv.failedList = failedList
--                M.sv.failed = failed
--                M.sv.timeStamp = GetGameTimeMilliseconds()
--
--                d(M.sv.failedList)
--                d(M.sv.failed)
--                d(M.sv.timeStamp)
--
--                d("done")
--                zo_callLater(function()
--                    d("reloading ...")
--                    ReloadUI()
--                end, reloadAfter)
--            end, reportAfter)
--        end, unloadAfter)
--    end, checkAfter)
--
--
--
--
--end
--
---- /script d(HodorReflexes.integrity.sv)
--
--function HodorReflexes.integrity.Check()
--    checkAfter = calculateCheckTime()
--
--    local calculatedTime = (reloadAfter + reportAfter + unloadAfter + checkAfter) / 1000
--
--    d("starting integritycheck")
--    d("this will take aproximatly " .. calculatedTime .. " seconds")
--    d("please wait and let it do its thing :-)")
--
--
--    if not ZO_Dialogs_IsShowingDialog() then
--        LAM.util.ShowConfirmationDialog(
--                "HodorReflexes Integrity check",
--                "Do you want to perform an integrity check? This will take approximately ".. calculatedTime .." seconds",
--                function() LAM.util.ShowConfirmationDialog(
--                        "HodorReflexes Integrity check",
--                        "Please do not interrupt the check. Just let it do its thing. The UI will reload after its finished and you will get the results",
--                        function()
--                            zo_callLater(integrityCheck, 250)
--                        end)
--                end)
--    end
--
--end
----zo_callLater(function() integrityCheck() end, 2000)
--
--function HodorReflexes.integrity.GetResults()
--    zo_callLater(function()
--        local integrityFailed = M.sv.failed > 10
--        local color = "00FF00"
--        local status = "passed"
--        local message = "all fine :-)"
--
--        local function colorize(str)
--            return "|c" .. color .. str .. "|r"
--        end
--
--        if integrityFailed then
--            color = "FF0000"
--            status = "failed"
--            message = colorize(
--                    "\nThere might be an issue with your HodorReflexes installation.\n" ..
--                            "please consider reinstalling the addon\n"
--            )
--
--            d(colorize("Missing icons:"))
--            for user, icon in pairs(M.sv.failedList) do
--                d(colorize(user .. " (" .. icon .. ")"))
--            end
--            d("")
--        end
--
--        d(colorize("summary:"))
--        d(colorize("icons scanned: " .. M.sv.scannedIcons))
--        d(colorize("icons failed: " .. M.sv.failed))
--        d("")
--
--        PlaySound(SOUNDS.BOOK_COLLECTION_COMPLETED)
--        if not ZO_Dialogs_IsShowingDialog() then
--            LAM.util.ShowConfirmationDialog(
--                    "HodorReflexes Integrity check",
--                    "Integrity check ".. colorize(status) .. "\n" ..
--                            "icons scanned: " .. M.sv.scannedIcons .. "\n" ..
--                            "icons failed: " .. colorize(M.sv.failed) .. "\n" ..
--                            message,
--                    nil)
--        end
--
--        M.sv.timeStamp = 0
--        M.sv.scannedIcons = 0
--        M.sv.failed = 0
--        M.sv.failedList = {}
--    end, 1000)
--end
--
--EM:RegisterForEvent("HodorReflexesIntegrityCheckSavedVariables", EVENT_ADD_ON_LOADED, function(_, name)
--    if name == HR.name then
--        EM:UnregisterForEvent("HodorReflexesIntegrityCheckSavedVariables", EVENT_ADD_ON_LOADED)
--
--        M.sv = ZO_SavedVars:NewAccountWide(HR.svName, HR.svVersion, 'integrity', M.default)
--        if M.sv.timeStamp > 0 then
--            EM:RegisterForEvent("HodorReflexesIntegrityCheckReportTrigger", EVENT_PLAYER_ACTIVATED, function()
--                EM:UnregisterForEvent("HodorReflexesIntegrityCheckReportTrigger", EVENT_PLAYER_ACTIVATED)
--
--                HodorReflexes.integrity.GetResults()
--            end)
--        end
--    end
--end)