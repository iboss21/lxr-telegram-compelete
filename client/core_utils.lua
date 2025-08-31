-- client/core_utils.lua
-- Framework abstraction for client-side
-- Developer: iboss21 (https://github.com/iboss21)

local coreType = nil
local coreObject = nil

Citizen.CreateThread(function()
    if GetResourceState('lxr_core') == 'started' then
        coreType = 'LXRCore'
        TriggerEvent('LXRCore:GetObject', function(obj) coreObject = obj end)
    elseif GetResourceState('rsg-core') == 'started' then
        coreType = 'RSGCore'
        TriggerEvent('RSGCore:GetObject', function(obj) coreObject = obj end)
    elseif GetResourceState('vorp_core') == 'started' then
        coreType = 'VORPCore'
        TriggerEvent('getCore', function(obj) coreObject = obj end)
    end
end)

local function getPlayer()
    if coreType == 'LXRCore' or coreType == 'RSGCore' then
        return coreObject.Functions.GetPlayerData()
    elseif coreType == 'VORPCore' then
        return coreObject.getUser(PlayerId())
    end
    return nil
end

local function getIdentifier()
    local player = getPlayer()
    if coreType == 'LXRCore' or coreType == 'RSGCore' then
        return player.identifier
    elseif coreType == 'VORPCore' then
        return player.getUsedCharacter.charIdentifier
    end
    return nil
end

return {
    getPlayer = getPlayer,
    getIdentifier = getIdentifier,
    coreType = function() return coreType end
}
