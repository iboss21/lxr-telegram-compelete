-- mail_utils.lua
-- Telegram mail logic and admin helpers
-- Developer: iboss21 (https://github.com/iboss21)

local Config = require('config')

local function notifyRecipient(recipientId, subject)
    -- Notify recipient if online
    local recipientSource = nil
    for _, player in ipairs(GetPlayers()) do
        local User = exports['core_utils']:getUser(tonumber(player))
        local Character = exports['core_utils']:getCharacter(User)
        local charidentifier = exports['core_utils']:getIdentifier(Character)
        if tostring(charidentifier) == tostring(recipientId) then
            recipientSource = tonumber(player)
            break
        end
    end
    if recipientSource then
        TriggerClientEvent("Telegram:NewMailNotification", recipientSource, subject)
    end
end

local function isAdmin(source)
    -- Example admin check: can be replaced with your own logic
    return IsPlayerAceAllowed(source, "telegram.admin")
end

return {
    notifyRecipient = notifyRecipient,
    isAdmin = isAdmin
}
