local _, addon = ...
local module = addon:NewModule()

local GuildFriendsDB, options = addon:NewObject("GuildFriendsDB")

local defaults = {
    profile = {
        maxOnlineFriends = 20
    }
}

function module:OnInitialize()
    options = addon.Db:NewTable("GuildFriends", defaults)
end

function GuildFriendsDB:GetMaxOnlineGuildFriends()
    return options.profile.maxOnlineFriends
end

function GuildFriendsDB:SetMaxOnlineGuildFriends(value)
    options.profile.maxOnlineFriends = tonumber(value)
end