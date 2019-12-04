local addonName, addon = ...
addon = LynxUI:NewAddon(addonName, addon)

function addon:OnInitialize()
    self:Initialize("Storage")
end