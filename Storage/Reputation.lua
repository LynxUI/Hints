local _, addon = ...
local module = addon:NewModule()

local ScriptLoader = addon:Import("ScriptLoader")
local Character = addon:Import("Character")

local ReputationDB, factions = addon:NewObject("ReputationDB")

ScriptLoader:RegisterScript(function()
    local db = addon.Db:NewGlobalTable("Reputation", {})
    local charFullName = Character:GetFullName()
    db[charFullName] = db[charFullName] or {}
    factions = db[charFullName]
end)

function ReputationDB:IsSelectedFaction(factionID)
    return factionID and select(14, GetFactionInfoByID(factionID)) and factions[factionID] ~= nil
end

function ReputationDB:ToggleFaction(factionID)
    if factionID and select(14, GetFactionInfoByID(factionID)) then
        if factions[factionID] then
            factions[factionID] = nil
        else
            factions[factionID] = true
        end
    end
end

function ReputationDB:HasFactionsTracked()
	return factions and next(factions) and true or false
end

