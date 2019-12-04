local _, addon = ...
local module = addon:NewModule()

local L = addon:GetLocale()
local ScriptLoader = addon:Import("ScriptLoader")
local Tooltip = addon:Import("Tooltip")
local GuildFriendsDB = addon:Import("GuildFriendsDB")

ScriptLoader:AddHookScript(GuildMicroButton, "OnEnter", function()
    local maxOnlineGuildFriends = GuildFriendsDB:GetMaxOnlineGuildFriends()
    if maxOnlineGuildFriends == 0 then return end

    local numWoWTotal = C_FriendList.GetNumFriends()
    local numBNetTotal = BNGetNumFriends()
    local friends, counter = {}, 0

    for i = 1, numWoWTotal do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.connected then
            friends[info.name] = true
            counter = counter + 1
        end
    end

    for i = 1, numBNetTotal do
        local _, _, _, _, characterName, _, client, isOnline = BNGetFriendInfo(i)
        if client == BNET_CLIENT_WOW and isOnline  then
            friends[characterName] = true
            counter = counter + 1
        end
    end

    local guildFriends = {}
    if counter > 0 then
        counter = 1

        GuildRoster()
        local numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers()
        for i = 1, numTotalMembers do
            local name, _, _, _, _, zone, _, _, online, status, class, _, _, isMobile = GetGuildRosterInfo(i)
            name = Ambiguate(name, "guild")
            if counter >= maxOnlineGuildFriends then
                break
            elseif friends[name] then
                if status == 1 then
                    status = L[" |cffff0000<AFK>|r"]
                elseif status == 2 then
                    status = L[" |cffff0000<DND>|r"]
                else
                    status = ""
                end
                table.insert(guildFriends, {name, zone, online, status, class, isMobile})
                counter = counter + 1
            end
        end
    end
    
    local totalGuildFriends = #guildFriends
    if totalGuildFriends > 0 then        
        Tooltip:AddEmptyLine()
        Tooltip:AddHighlightLine(L["Guild Friends (%d):"]:format(totalGuildFriends))
        for _, data in ipairs(guildFriends) do
            local name, zone, online, status, class, isMobile = unpack(data)
            if not online then
                zone = nil
                if isMobile then
                    name = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:0|t " .. name
                end
            end
            if zone then
                local color = RAID_CLASS_COLORS[class]
                Tooltip:AddRightHighlightDoubleLine(name .. status, zone, color.r, color.g, color.b)
            else
                Tooltip:AddDoubleLine(name, zone, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
            end
        end
    end

    Tooltip:Show()
end)