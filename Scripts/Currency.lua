local addonName, addon = ...
local module = addon:NewModule()

local L = addon:GetLocale()
local ScriptLoader = addon:Import("ScriptLoader")
local Tooltip = addon:Import("Tooltip")

local CURRENCY_ITEM_FORMAT = "|T%s:0|t %s"

local expansions = {}
local currentExpansionLevel = GetClampedCurrentExpansionLevel()

for i = 0, currentExpansionLevel do
    table.insert(expansions, _G["EXPANSION_NAME" .. i])
end

ScriptLoader:AddHookScript(CharacterMicroButton, "OnEnter", function()
    local latestExpansionLevelAvailableForCurrencyFound = false
    local expansionLevel = currentExpansionLevel + 1

    for i = 1, #expansions do
        for j = 1, GetCurrencyListSize() do
            local name, isHeader, _, _, _, count, icon = GetCurrencyListInfo(j)
            if latestExpansionLevelAvailableForCurrencyFound and not isHeader then
                local leftText = CURRENCY_ITEM_FORMAT:format(icon, name)
                local rightText = BreakUpLargeNumbers(count)
                if count > 0 then
                    Tooltip:AddRightHighlightDoubleLine(leftText, rightText)
                else
                    Tooltip:AddGrayDoubleLine(leftText, rightText)
                end
            elseif expansions[expansionLevel] == name then
                local nextName, nextIsHeader = GetCurrencyListInfo(j + 1)
                if nextName and not nextIsHeader then
                    latestExpansionLevelAvailableForCurrencyFound = true
                    Tooltip:AddEmptyLine()
                    Tooltip:AddHighlightLine(L["%s Currency:"]:format(name))
                end
            else
                -- If we didn't find a header for the latest expansion available
                -- then break and try to get one for the expansion before that
                break
            end
        end
        if not latestExpansionLevelAvailableForCurrencyFound then
            expansionLevel = expansionLevel - 1
        else
            -- If we got this far it means currency was found and we can bail out
            break
        end
    end

    if latestExpansionLevelAvailableForCurrencyFound then
        Tooltip:Show()
    end
end)