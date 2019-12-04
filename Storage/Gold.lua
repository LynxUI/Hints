local _, addon = ...
local module = addon:NewModule()

local GoldDB, info, options = addon:NewObject("GoldDB")

local defaults = {
    profile = {
        hideConnectedRealmsNames = true,
        minGoldAmount = 0
    }
}

function module:OnInitialize()
    options = addon.Db:NewTable("Gold", defaults)
    info = addon.Db:NewGlobalTable("Gold", {})
end

function GoldDB:UpdateGold(player, money)
    info[player] = money
end

function GoldDB:GetGoldInfo()
    return pairs(info)
end

function GoldDB:ResetGold()
    for player in self:GetGoldInfo() do
        info[player] = nil
    end
    info[addon.Character:GetFullName()] = GetMoney()
end

function GoldDB:SetMinGoldAmount(value)
    options.profile.minGoldAmount = tonumber(value)
end

function GoldDB:GetMinGoldAmount()
    return options.profile.minGoldAmount
end

function GoldDB:ToggleConnectedRealmsNames()
    options.profile.hideConnectedRealmsNames = not options.profile.hideConnectedRealmsNames
end

function GoldDB:IsConnectedRealmsNamesHidden()
    return options.profile.hideConnectedRealmsNames
end
