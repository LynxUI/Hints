local _, addon = ...
local module = addon:NewModule()

local L = addon:GetLocale()
local ScriptLoader = addon:Import("ScriptLoader")
local Tooltip = addon:Import("Tooltip")
local ReputationDB = addon:Import("ReputationDB")

local STANDING_FORMAT = "%s / %s"
local FACTION_NAME_FORMAT = "|cff%.2x%.2x%.2x%s|r"

local function GetFactionDisplayInfoByID(factionID)
    local factionName = GetFactionInfoByID(factionID)
    if factionName then
        local _, _, standingID, repMin, repMax, repValue = GetFactionInfoByID(factionID)
        local friendID = GetFriendshipReputation(factionID)
        local isCapped

        local gender = UnitSex("player")
        local standing = GetText("FACTION_STANDING_LABEL" .. standingID, gender)
        local standingColor = FACTION_BAR_COLORS[standingID]

        if friendID then
            local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
            if nextFriendThreshold then
                repMin, repMax, repValue = friendThreshold, nextFriendThreshold, friendRep
            else
                repMin, repMax, repValue = 0, 1, 1
                isCapped = true
            end
            standingID = 5 -- Always color friendship factions with green
            standing = friendTextLevel
        elseif C_Reputation.IsFactionParagon(factionID) then
            local currentValue, threshold, _, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
            repMin, repMax, repValue = 0, threshold, currentValue % threshold
            standingColor = LIGHTBLUE_FONT_COLOR
            factionName = not tooLowLevelForParagon and hasRewardPending and factionName .. " |TInterface\\RaidFrame\\ReadyCheck-Ready:0|t" or factionName
        else
            if (standingID == MAX_REPUTATION_REACTION) then
                isCapped = true;
            end
        end

        repMax = repMax - repMin
        repValue = repValue - repMin

        repMax = AbbreviateNumbers(repMax)
        repValue = AbbreviateNumbers(repValue)
        factionName = FACTION_NAME_FORMAT:format(standingColor.r * 255, standingColor.g * 255, standingColor.b * 255, factionName)
    
        return factionName, standing, isCapped, repValue, repMax
    end
end

ScriptLoader:AddHookScript(CharacterMicroButton, "OnEnter", function()
    if ReputationDB:HasFactionsTracked() then
        local factionName, standing, isCapped, repValue, repMax

        Tooltip:AddEmptyLine()
        Tooltip:AddHighlightLine(L["Reputation:"])

        for index = 1, GetNumFactions() do
            local factionID =  select(14, GetFactionInfo(index))
            if ReputationDB:IsSelectedFaction(factionID) then
                factionName, standing, isCapped, repValue, repMax = GetFactionDisplayInfoByID(factionID)
                if isCapped then
                    Tooltip:AddRightHighlightDoubleLine(factionName, standing)
                else
                    Tooltip:AddRightHighlightDoubleLine(factionName, STANDING_FORMAT:format(repValue, repMax))
                end
            end
        end

        Tooltip:Show()
    end
end)