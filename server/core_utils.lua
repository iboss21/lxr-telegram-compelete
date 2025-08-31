-- core_utils.lua
-- Abstraction for LXRCore, RSGCore, VORP Core

local coreType = nil
local coreObject = nil

-- Detect framework
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

local function getUser(source)
    if coreType == 'LXRCore' then
        return coreObject.Functions.GetPlayer(source)
    elseif coreType == 'RSGCore' then
        return coreObject.Functions.GetPlayer(source)
    elseif coreType == 'VORPCore' then
        return coreObject.getUser(source)
    end
    return nil
end

local function getCharacter(user)
    if coreType == 'LXRCore' or coreType == 'RSGCore' then
        return user.PlayerData
    elseif coreType == 'VORPCore' then
        return user.getUsedCharacter
    end
    return nil
end

local function getIdentifier(character)
    if coreType == 'LXRCore' or coreType == 'RSGCore' then
        return character.identifier
    elseif coreType == 'VORPCore' then
        return character.charIdentifier
    end
    return nil
end

local function getMoney(character)
    if coreType == 'LXRCore' or coreType == 'RSGCore' then
        return character.money
    elseif coreType == 'VORPCore' then
        return character.money
    end
    return 0
end

local function removeMoney(character, amount)
    if coreType == 'LXRCore' or coreType == 'RSGCore' then
        character.removeMoney(amount)
    elseif coreType == 'VORPCore' then
        character.removeCurrency(0, amount)
    end
end

local function addItem(source, item, count)
    if coreType == 'LXRCore' then
        coreObject.Functions.AddItem(source, item, count)
    elseif coreType == 'RSGCore' then
        coreObject.Functions.AddItem(source, item, count)
    elseif coreType == 'VORPCore' then
        exports.vorp_inventory:addItem(source, item, count)
    end
end

return {
    getUser = getUser,
    getCharacter = getCharacter,
    getIdentifier = getIdentifier,
    getMoney = getMoney,
    removeMoney = removeMoney,
    addItem = addItem,
    coreType = function() return coreType end
}
