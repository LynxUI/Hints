local _, addon = ...
local module = addon:NewModule("AceEvent-3.0")

local L = addon:GetLocale()
local ScriptLoader = addon:Import("ScriptLoader")
local Tooltip = addon:Import("Tooltip")
local Character = addon:Import("Character")
local Realm = addon:Import("Realm")
local GoldDB = addon:Import("GoldDB")

local REALM_PATTERN = "% - (.+)"
local CHARACTER_CLASS_COLOR_FORMAT = "|cff%.2x%.2x%.2x%s|r"

local function UpdateGold()
    local money = GetMoney()
    GoldDB:UpdateGold(Character:GetFullName(), money)
end

local function IsCharacterOnConnectedRealm(character, includeOwn)
    return Realm:IsRealmConnectedRealm(character:match(REALM_PATTERN), includeOwn)
end

local function SortCharacterNamesAlphabetically(a, b)
    return a[1]:lower() < b[1]:lower() 
end

module:RegisterEvent("PLAYER_MONEY", UpdateGold)

ScriptLoader:AddScript(MainMenuBarBackpackButton, function()
    UpdateGold()

    local sum, goldInfo = 0, {}
    for character, money in GoldDB:GetGoldInfo() do
        local isCharacterOnCurrentRealm = character:find(Character:GetRealm())
        if money > 0 and (IsCharacterOnConnectedRealm(character, true) or isCharacterOnCurrentRealm) then
            local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
            local isCharacterCurrentPlayer = character == Character:GetFullName()
            if gold > GoldDB:GetMinGoldAmount() or isCharacterCurrentPlayer then
                if IsCharacterOnConnectedRealm(character, false) and GoldDB:IsConnectedRealmsNamesHidden() then
                    character = character:gsub(REALM_PATTERN, "*")
                elseif isCharacterOnCurrentRealm then
                    character = character:gsub(REALM_PATTERN, "")
                end
                table.insert(goldInfo, {character, money})
            end
            sum = sum + money
        end
    end

    table.sort(goldInfo, SortCharacterNamesAlphabetically)

    MainMenuBarBackpackButton:HookScript("OnEnter", function(self)
        Tooltip:AddEmptyLine()
        Tooltip:AddHighlightLine(L["Gold:"])

        if #goldInfo > 0 then 
            for _, data in ipairs(goldInfo) do
                local character = Ambiguate(data[1], "none")
                local money = GetMoneyString(data[2], true)
                local isCharacterCurrentPlayer = character == Character:GetName()
                if isCharacterCurrentPlayer then
                    local _, englishClass = UnitClass("player")
                    local classColor = englishClass and RAID_CLASS_COLORS[englishClass] or NORMAL_FONT_COLOR
                    character = CHARACTER_CLASS_COLOR_FORMAT:format(classColor.r * 255, classColor.g * 255, classColor.b * 255, character)
                end
                Tooltip:AddRightHighlightDoubleLine(character, money)
            end
            Tooltip:AddEmptyLine()
        end
        
        Tooltip:AddRightHighlightDoubleLine(L["Total"], GetMoneyString(sum, true))
        Tooltip:AddEmptyLine()

        Tooltip:Show()
    end)
end)
