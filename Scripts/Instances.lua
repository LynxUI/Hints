local addonName, addon = ...
local module = addon:NewModule()

local L = addon:GetLocale()
local ScriptLoader = addon:Import("ScriptLoader")
local Tooltip = addon:Import("Tooltip")

local INSTANCE_INFO_LABEL_FORMAT = "%s (%s)"
local INSTANCE_INFO_STATS_FORMAT = "|cffff0000%d|r / |cff00ff00%d|r"

local instances = {}
local worldBosses = {}

do
    EJ_SelectTier(EJ_GetNumTiers())

    local index = 1
    local instanceID = EJ_GetInstanceByIndex(index, false)

    while instanceID do
        EJ_SelectInstance(instanceID)
        instances[instanceID] = true
        index = index + 1
        instanceID = EJ_GetInstanceByIndex(index, false)
    end

    index = 1
    instanceID = EJ_GetInstanceByIndex(index, true)

    while instanceID do
        EJ_SelectInstance(instanceID)
        instances[instanceID] = true

        if index == 1 then
            local bossIndex = 1
            local _, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex, instanceID)
            
            while bossID do
                EJ_SelectEncounter(bossID)
                worldBosses[bossID] = true
                bossIndex = bossIndex + 1
                _, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex, instanceID)
            end
        end

        index = index + 1
        instanceID = EJ_GetInstanceByIndex(index, true)
    end
end

ScriptLoader:AddHookScript(LFDMicroButton, "OnEnter", function()
    RequestRaidInfo()

    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(L["Dungeons & Raids:"])

    local isSaved

    for index = 1, GetNumSavedInstances() do
        local instanceName, instanceID, _, instanceDifficulty, locked, extended, _, _, _, _, maxBosses, defeatedBosses = GetSavedInstanceInfo(index)
        if instances[instanceID] and (locked or extended) then
            local label = INSTANCE_INFO_LABEL_FORMAT:format(instanceName, GetDifficultyInfo(instanceDifficulty))
            if defeatedBosses < maxBosses then
                Tooltip:AddRightHighlightDoubleLine(label, INSTANCE_INFO_STATS_FORMAT:format(defeatedBosses, maxBosses))
            else
                Tooltip:AddDoubleLine(label, L["Cleared"], nil, nil, nil, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
            end
            isSaved = true
        end
    end

    for index = 1, GetNumSavedWorldBosses() do
        local bossName, worldBossID = GetSavedWorldBossInfo(index)
        if worldBosses[worldBossID] then
            Tooltip:AddDoubleLine(bossName, BOSS_DEAD, nil, nil, nil, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
            isSaved = true
        end
    end

    if not isSaved then
        Tooltip:AddLine(NO_RAID_INSTANCES_SAVED)
    end
    
    Tooltip:Show()
end)