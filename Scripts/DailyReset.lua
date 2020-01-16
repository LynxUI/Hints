local _, addon = ...
local module = addon:NewModule("AceHook-3.0")

local L = addon:GetLocale()
local Tooltip = addon:Import("Tooltip")

local interval = 1
local lastUpdate = 0

module:SecureHook("GameTime_UpdateTooltip", function()
    Tooltip:AddEmptyLine()

    local resetTime, maxCount = GetQuestResetTime(), 1
    if resetTime < 60 then
        -- interval = 1
    elseif resetTime < 3600 then
        -- interval = 60
    elseif resetTime % 3600 < 60 then
    else
        maxCount = 2
    end
    
    Tooltip:AddHighlightDoubleLine(L["Daily Reset:"], SecondsToTime(resetTime, nil, nil, maxCount))
    Tooltip:Show()
end)