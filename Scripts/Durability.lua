local _, addon = ...
local module = addon:NewModule("AceEvent-3.0")

local L = addon:GetLocale()
local ScriptLoader = addon:Import("ScriptLoader")
local Tooltip = addon:Import("Tooltip")

local NUM_BAG_FRAMES = 4

local SLOTS = {
    "HeadSlot",
    "ShoulderSlot",
    "ChestSlot",
    "WristSlot",
    "HandsSlot",
    "WaistSlot",
    "LegsSlot",
    "FeetSlot",
    "MainHandSlot",
    "SecondaryHandSlot"
}

local inventoryPct, backpackPct

local function GetColoredText(percent)
    local r, g

    if percent >= 0.5 then
        r = (1 - percent) * 2
        g = 1
    else
        r = 1
        g = percent * 2
    end

    return format("|cff%02x%02x%02x%d%%|r", r * 255, g * 255, 0, (percent * 100))
end

local function GetPercentage(current, total)
    if current and total > 0 then
        local perc = current / total
        local fixed = perc
        -- Makes sure we never round down to 0 so we can distinguish between completely broken and fully functional
        if perc > 0 then
            fixed = max(0.01, perc)
        end
        return fixed, perc
    end
end

local function UpdateDurability()
    local mostDamaged = 1
    local mostDamagedSlot
    local inventory, inventoryMax = 0, 0
    local backpack, backpackMax = 0, 0
    
    for i, slot in ipairs(SLOTS) do
        local durability, durabilityMax = GetInventoryItemDurability(GetInventorySlotInfo(slot))
        if durability and durabilityMax then
            local fixedPct, exactPct = GetPercentage(durability, durabilityMax)
            if fixedPct < mostDamaged then
                mostDamaged = fixedPct
                mostDamagedSlot = slot
            end
            -- Adds item durability values to total inventory durability value
            inventory = inventory + exactPct
            inventoryMax = inventoryMax + 1
        end
    end
    
    -- Scans backpack items' durability status
    for bag = 0, NUM_BAG_FRAMES do
        for slot = 1, GetContainerNumSlots(bag) do
            local durability, durabilityMax = GetContainerItemDurability(bag, slot)
            if durability then
                backpack = backpack + durability
                backpackMax = backpackMax + durabilityMax
            end
        end
    end

    inventoryPct = GetPercentage(inventory, inventoryMax)
    backpackPct = GetPercentage(backpack, backpackMax)
end

module:RegisterEvent("UPDATE_INVENTORY_DURABILITY", UpdateDurability)
module:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", UpdateDurability)

ScriptLoader:AddHookScript(CharacterMicroButton, "OnEnter", function()
    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(L["Durability:"])
    Tooltip:AddDoubleLine(L["Equipped"], inventoryPct and GetColoredText(inventoryPct) or L["N/A"])
    Tooltip:AddDoubleLine(L["Bags"], backpackPct and GetColoredText(backpackPct) or L["|cffa0a0a0None|r"])
    Tooltip:Show()
end)