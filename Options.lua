if not LynxUI:IsOptionsLoaded() then return end

local _, addon = ...
local module = addon:NewModule("AceEvent-3.0")

local L = addon:GetLocale()
local Options = addon:Import("Options")
local GoldDB = addon:Import("GoldDB")
local FriendsDB = addon:Import("FriendsDB")
local GuildFriendsDB = addon:Import("GuildFriendsDB")
local ReputationDB = addon:Import("ReputationDB")

local options = {}

function module:OnInitialize()
    options = {
        name = L["Hints"],
        type = "group",
        args = {
            {
                type = "separator"
            },
            {
                type = "group",
                name = L["Backpack"],
                args = {
                    {
                        type = "group",
                        name = L["Gold Tooltip"],
                        inline = true,
                        handler = GoldDB,
                        args = {
                            {
                                type = "toggle",
                                name = L["Hide Connected Realms Names"],
                                descStyle = "hidden",
                                width = "full",
                                get = function(self)
                                    return self.handler:IsConnectedRealmsNamesHidden()
                                end,
                                set = function(self)
                                    self.handler:ToggleConnectedRealmsNames()
                                end
                            },
                            {
                                type = "description",
                                name = "\n" .. L["Show only characters that has more than specified amount of |TInterface\\MoneyFrame\\UI-GoldIcon:0:0:0:-1|t gold:"],
                            },
                            {
                                type = "input",
                                name = "",
                                get = function(self)
                                    return tostring(self.handler:GetMinGoldAmount())
                                end,
                                set = function(self, value)
                                    self.handler:SetMinGoldAmount(value)
                                end,
                                validate = function(info, value)
                                    if value ~= nil and value ~= "" and (not tonumber(value) or tonumber(value) >= 2^31) then
                                        return false;
                                    end
                                    return true
                                end
                            },
                            {
                                type = "newline"
                            },
                            {
                                type = "execute",
                                name = L["Reset Gold Information"],
                                descStyle = "hidden",
                                width = "double",
                                func = function(self)
                                    self.handler:ResetGold()
                                end
                            }
                        }
                    }
                }
            },
            {
                type = "group",
                name = L["Social"],
                args = {
                    {
                        type = "group",
                        name = L["Social Tooltip"],
                        inline = true,
                        handler = FriendsDB,
                        args = {
                            {
                                type = "range",
                                name = L["Maximum Friends Online"],
                                width = "double",
                                descStyle = "hidden",
                                step = 1,
                                min = 0,
                                max = 50,
                                get = function(self)
                                    return self.handler:GetMaxOnlineFriends()
                                end,
                                set = function(self, value)
                                    self.handler:SetMaxOnlineFriends(value)
                                end
                            },
                        }
                    }
                }
            },
            {
                type = "group",
                name = L["Guild & Communities"],
                args = {
                    {
                        type = "group",
                        name = L["Friends Tooltip"],
                        inline = true,
                        handler = GuildFriendsDB,
                        args = {
                            {
                                type = "range",
                                name = L["Maximum Friends Online"],
                                descStyle = "hidden",
                                width = "double",
                                step = 1,
                                min = 0,
                                max = 50,
                                get = function(self)
                                    return self.handler:GetMaxOnlineGuildFriends()
                                end,
                                set = function(self, value)
                                    self.handler:SetMaxOnlineGuildFriends(value)
                                end
                            },
                        }
                    }
                }
            }
        }
    }
    Options:RegisterOptions(options)
end

local function CreateReputationOptions()
    local args = {}
    local prevTable

    table.insert(args, {
        type = "header",
        name = L["Reputation Tooltip"]
    })

    for index = 1, GetNumFactions() do
        local name, _, _, _, _, _, _, _, isHeader, _, _, _, _, factionID = GetFactionInfo(index)
        if isHeader then
            prevTable = {
                name = name,
                type = "group",
                inline = true,
                args = {}
            }
            table.insert(args, prevTable)
        else
            table.insert(prevTable.args, {
                name = name,
                type = "toggle",
                descStyle = "hidden",
                width = "full",
                handler = ReputationDB,
                get = function(self)
                    return self.handler:IsSelectedFaction(factionID)
                end,
                set = function(self)
                    self.handler:ToggleFaction(factionID)
                end
            })
        end
    end

    return args
end

module:RegisterEvent("PLAYER_LOGIN", function(event) 
    table.insert(options.args, {
        name = L["Character Info"],
        type = "group",
        args = CreateReputationOptions()
    })
end)