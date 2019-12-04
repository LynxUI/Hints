local _, addon = ...
local module = addon:NewModule("AceHook-3.0")

local L = addon:GetLocale()
local Tooltip = addon:Import("Tooltip")

local EXP_CURRENT_PROGRESS_LABEL_FORMAT = "%s / %s (%s)"
local EXP_RESTED_STATUS_LABEL_FORMAT = "%s (%s)"
local EXP_TNL_PROGRESS_LABEL_FORMAT = "%s (%s)"

module:SecureHook(ExhaustionTickMixin, "ExhaustionToolTipText", function()
    --if IsPlayerAtEffectiveMaxLevel() or IsXPUserDisabled() then return end

    GameTooltip_SetDefaultAnchor(Tooltip, UIParent)

    local xp, xpMax = UnitXP("player"), UnitXPMax("player")
    Tooltip:AddHighlightLine(L["Experience:"])
    Tooltip:AddRightHighlightDoubleLine(L["Current"], EXP_CURRENT_PROGRESS_LABEL_FORMAT:format(AbbreviateNumbers(xp), AbbreviateNumbers(xpMax), FormatPercentage(xp / xpMax, true)))

    local exhaustionThreshold = GetXPExhaustion()
    if exhaustionThreshold then
        Tooltip:AddRightHighlightDoubleLine(L["Rested"], EXP_RESTED_STATUS_LABEL_FORMAT:format(AbbreviateNumbers(exhaustionThreshold), FormatPercentage(exhaustionThreshold / xpMax, true)))
    end
    
    local tnl = xpMax - xp
    Tooltip:AddRightHighlightDoubleLine(L["To Next Level (|cffffffff%d|r)"]:format(UnitLevel("player") + 1), EXP_TNL_PROGRESS_LABEL_FORMAT:format(AbbreviateNumbers(tnl), FormatPercentage(tnl / xpMax, true)))
    
    Tooltip:Show()
end)
