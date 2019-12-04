local _, addon = ...
local module = addon:NewModule()

local FriendsDB, options = addon:NewObject("FriendsDB")

local defaults = {
    profile = {
        maxOnlineFriends = 20
    }
}

function module:OnInitialize()
    options = addon.Db:NewTable("Friends", defaults)
end

function FriendsDB:GetMaxOnlineFriends()
    return options.profile.maxOnlineFriends
end

function FriendsDB:SetMaxOnlineFriends(value)
    options.profile.maxOnlineFriends = tonumber(value)
end