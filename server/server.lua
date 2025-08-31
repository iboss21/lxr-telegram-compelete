local CoreUtils = require('core_utils')
local LicenseCheck = require('license_check')
local coreType = nil
Citizen.CreateThread(function()
	coreType = CoreUtils.coreType()
	LicenseCheck.CheckLicense()
end)

local lastmessage = {}
local firstreceipt = false
local PlayersConnected = {}

RegisterNetEvent("Fists-GlideMail:checkMailbox")
AddEventHandler("Fists-GlideMail:checkMailbox", function(source,model,name)
	exports.vorp_inventory:closeInventory(source, 'default')
	local _source = source
	local User = CoreUtils.getUser(source)
	local Character = CoreUtils.getCharacter(User)
	local charidentifier = CoreUtils.getIdentifier(Character)
	exports.oxmysql:query('SELECT mailbox_id FROM mailboxes WHERE char_identifier = ?', {charidentifier}, function(result)
		if result and #result > 0 then
			TriggerClientEvent("Fists-GlideMail:mailboxStatus", _source, true, result[1].mailbox_id,model,name,source)
		else
			TriggerClientEvent("Fists-GlideMail:mailboxStatus", _source, false, nil,model,name,source)
		end
	end)
end)

RegisterNetEvent("Fists-GlideMail:registerMailbox")
AddEventHandler("Fists-GlideMail:registerMailbox", function()
	if not LicenseCheck.IsLicenseValid() then
		TriggerClientEvent("Fists-GlideMail:registerResult", source, false, "License invalid. Please contact support: " .. Config.SupportDiscord)
		return
	end
	local _source = source
	local User = CoreUtils.getUser(_source)
	local Character = CoreUtils.getCharacter(User)
	local charidentifier = CoreUtils.getIdentifier(Character)
	local first_name = Character.firstname or Character.first_name
	local last_name = Character.lastname or Character.last_name
	local PlayerName = GetPlayerName(_source)
	CoreUtils.addItem(_source, "BoxTicket", 1)
	if CoreUtils.getMoney(Character) >= Config.RegistrationFee then
		CoreUtils.removeMoney(Character, Config.RegistrationFee)
		exports.oxmysql:insert('INSERT INTO mailboxes (char_identifier, steamname, first_name, last_name) VALUES (?, ?, ?, ?)', 
		{charidentifier, PlayerName, first_name, last_name}, function(insertId)
			if insertId then
				exports.oxmysql:execute('SELECT mailbox_id FROM mailboxes WHERE mailbox_id = ?', {insertId}, function(result)
					if result and #result > 0 then
						local newMailboxId = result[1].mailbox_id
						TriggerClientEvent("Fists-GlideMail:updateMailboxId", _source, newMailboxId)
						TriggerEvent("Mail:RegisterInventory",newMailboxId)
						TriggerClientEvent("Fists-GlideMail:registerResult", _source, true, "Mailbox registered successfully.")
					else
						TriggerClientEvent("Fists-GlideMail:registerResult", _source, false, "Error fetching new mailbox ID.")
					end
				end)
			else
				TriggerClientEvent("Fists-GlideMail:registerResult", _source, false, "Error in mailbox registration.")
			end
		end)
	else
		TriggerClientEvent("vorp:TipRight", _source, "Not enough money to register a mailbox.", 5000)
	end
end)


RegisterNetEvent("Fists-GlideMail:sendMail")
AddEventHandler("Fists-GlideMail:sendMail", function(recipientId, subject, message, location, eta,model,sourceid,Playerstable,anonymous,name)	
	local _source = source
	local User = CoreUtils.getUser(source)
	local Character = CoreUtils.getCharacter(User)
	local identifier = Character.identifier
	local charidentifier = CoreUtils.getIdentifier(Character)
	--[[
	PlayersConnected = {}
	local Playerisconnected = false
	TriggerClientEvent('CRSC',-1)
	if CoreUtils.getMoney(Character) >= Config.SendMessageFee then
		CoreUtils.removeMoney(Character, Config.SendMessageFee)
        exports.oxmysql:query('SELECT mailbox_id,first_name,last_name,Animation FROM mailboxes WHERE char_identifier = ?', {charidentifier}, function(senderResult)
		local SenderChar = (senderResult[1].first_name.." "..senderResult[1].last_name)
            if senderResult and #senderResult > 0 then
                local senderMailboxId = senderResult[1].mailbox_id
                if recipientId and recipientId ~= "" and subject and subject ~= "" and message and message ~= "" and location and location ~= "" then
                    local timestamp = os.date('%Y-%m-%d %H:%M:%S') 
                    exports.oxmysql:insert('INSERT INTO mailbox_messages (from_char, to_char, subject, message, location, timestamp, eta_timestamp) VALUES (?, ?, ?, ?, ?, ?, ?)', 
                    {senderMailboxId, recipientId, subject, message, location, os.date('%Y-%m-%d %H:%M:%S'), etaTimestamp}, function(inserted)
					--print(anonymous) -- debug
					if anonymous == true then
						lastmessage = {
							sender = "Anonyme",
							label = "Lettre",
							description = "Reçue le: "..timestamp.." de "..location.." expéditeur: Anonyme",
							subject = subject,
							coords = location,
							date = os.date('%Y-%m-%d %H:%M:%S')
						}
					else
						lastmessage = {
							sender = SenderChar,
							label = "Lettre",
							message = message,
							subject = subject,
							coords = location,
							date = os.date('%Y-%m-%d %H:%M:%S')
						}
					end
						if inserted then
							local MailData = MySQL.query.await('SELECT char_identifier,steamname,first_name,last_name FROM mailboxes WHERE mailbox_id = ?', {recipientId})
							if MailData[1] then
								TriggerEvent('Mailbox:subitem',_source,name)  
								TriggerClientEvent("vorp:TipRight", _source, "You have sent a message", 5000)
								TriggerClientEvent('SendPigeon',_source,model)
								print(json.encode(PlayersConnected))
								for i,v in ipairs(PlayersConnected) do
									print(v.charIdentifier , MailData[1].char_identifier) -- debug
									if (tonumber(v.charIdentifier) == tonumber(MailData[1].char_identifier)) then
										TriggerClientEvent("ReceivePigeon", v.source,model,MailData[1].steamname,recipientId)
										firstreceipt = true
										Playerisconnected = true
									end 
								end
								if Playerisconnected == false then
									TriggerEvent('Mail:IsConnected',recipientId,_source)
							else
								TriggerClientEvent("vorp:TipRight", _source, "Boite postale non trouvée", 5000)
							end
                        else
                            TriggerClientEvent("vorp:TipRight", _source, "Boite Mail inconnue", 5000)
                        end
                    end)
                else
                    print("N° de boite mail invalide: " .. tostring(recipientId))
                    print("Message Invalide : " .. tostring(message))
                    print("Localisation invalide: " .. tostring(location))
                    TriggerClientEvent("vorp:TipRight", _source, "Invalid recipient, message, or location", 5000)
                end
            else
                TriggerClientEvent("vorp:TipRight", _source, "Sender mailbox not found", 5000)
            end
        end)
    else
        TriggerClientEvent("vorp:TipRight", _source, "Not enough money to send a message.", 5000)
    end
end)

RegisterNetEvent("Fists-GlideMail:deleteMail")
AddEventHandler("Fists-GlideMail:deleteMail", function(mailId)
    exports.oxmysql:execute('DELETE FROM mailbox_messages WHERE id = ?', {mailId}, function(affectedRows)
        if affectedRows then
            TriggerClientEvent("vorp:TipRight", _source, "Mail deleted successfully.", 5000)
        else
            TriggerClientEvent("vorp:TipRight", _source, "Failed to delete mail.", 5000)
        end
    end)
end)
RegisterNetEvent('Mailbox:subitem')
AddEventHandler('Mailbox:subitem', function(source,name)
	if coreType == 'VORPCore' then
		exports.vorp_inventory:subItem(source,name,1)
	else
		-- Implement subItem for LXRCore/RSGCore if needed
	end
end)

Citizen.CreateThread(function()
	for i,v in ipairs(Config.UsableItems) do
		if coreType == 'VORPCore' then
			VORP.RegisterUsableItem(v.name,function(Item)
				TriggerEvent("Fists-GlideMail:checkMailbox",Item.source,v.model,v.name)
			end)
		else
			-- Register usable items for LXRCore/RSGCore if needed
		end
	end
end)

---@param id integer
--@param model string
RegisterServerEvent('Mail:RegisterInventory', function(MailboxId)
    local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered('Mailbox_' .. tostring(MailboxId))
	if isRegistered then return end
	Wait(0)
		print("Boite postale "..MailboxId.." enregistré") -- debug
		local data = {
            id = 'Mailbox_' .. tostring(MailboxId),
            name = 'Boite Postale',--_U('horseInv'),
            limit = tonumber(Config.invLimit),
            acceptWeapons = false,
            shared = true,
            ignoreItemStackLimit = true,
            whitelistItems = false,
            UsePermissions = false,
            UseBlackList = false,
            whitelistWeapons = false
        }
        exports.vorp_inventory:registerInventory(data)
end) --]]

---@param id integer
--@param model string
RegisterServerEvent('Mail:Start:RegisterInventory', function()
	exports.oxmysql:query('SELECT mailbox_id FROM mailboxes', function(data)
	--print(json.encode(data))
	for _,v in pairs(data) do
		local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered('Mailbox_' .. tostring(v.mailbox_id))
		if isRegistered then return end
		Wait(0)
			print("Boite postale "..v.mailbox_id.." enregistrée") -- debug
			local data = {
				id = 'Mailbox_' .. tostring(v.mailbox_id),
				name = 'Boite Postale',--_U('horseInv'),
				limit = tonumber(Config.invLimit),
				acceptWeapons = false,
				shared = true,
				ignoreItemStackLimit = true,
				whitelistItems = false,
				UsePermissions = false,
				UseBlackList = false,
				whitelistWeapons = false
			}
			exports.vorp_inventory:registerInventory(data)
		end
	end)
end) --]]

---@param id integer
RegisterServerEvent('Mail:OpenInventory', function(PlayerName)
	local src = source
	local user = CoreUtils.getUser(src)
	if not user then return end
	local character = CoreUtils.getCharacter(user)
	local charIdentifier = CoreUtils.getIdentifier(character)
	exports.oxmysql:query('SELECT mailbox_id FROM mailboxes WHERE steamname = ? AND `char_identifier` = ?', {PlayerName,charIdentifier}, function(id)
		if coreType == 'VORPCore' then
			exports.vorp_inventory:openInventory(src, 'Mailbox_' .. tostring(id[1].mailbox_id))
		else
			-- Implement openInventory for LXRCore/RSGCore if needed
		end
	end)
end)

if coreType == 'VORPCore' then
	VORP.RegisterUsableItem('Mail',function(Item)
		local src = Item.source
		local user = CoreUtils.getUser(src)
		local Player = GetPlayerName(src)
		local character = CoreUtils.getCharacter(user)
		local charIdentifier = CoreUtils.getIdentifier(character)
		exports.oxmysql:query('SELECT Animation FROM mailboxes WHERE steamname = ? AND `char_identifier` = ?', {Player,charIdentifier}, function(anim)
			exports.vorp_inventory:closeInventory(Item.source)
			TriggerClientEvent("PlayAnim",Item.source,Item.item.metadata,anim[1].Animation)
		end)
	end)
end

if coreType == 'VORPCore' then
	VORP.RegisterUsableItem('BoxTicket',function(Item)
		local src = Item.source
		local user = CoreUtils.getUser(src)
		local Player = GetPlayerName(src)
		local character = CoreUtils.getCharacter(user)
		local charIdentifier = CoreUtils.getIdentifier(character)
		exports.oxmysql:query('SELECT mailbox_id FROM mailboxes WHERE steamname = ? AND `char_identifier` = ?', {Player,charIdentifier}, function(MailID)
			exports.vorp_inventory:closeInventory(Item.source)
			TriggerClientEvent("OpenMailTicket",src, MailID[1].mailbox_id)
		end)
	end)
end

RegisterCommand('ARead', function(source,args,rawCommand)
	local src = source
	local user = CoreUtils.getUser(src)
	local Player = GetPlayerName(src)
	local character = CoreUtils.getCharacter(user)
	local charIdentifier = CoreUtils.getIdentifier(character)
	animselected = args[1]
	MySQL.query.await('UPDATE `mailboxes` SET `Animation` = ? WHERE `steamname` = ? AND `char_identifier` = ?',{animselected,Player,charIdentifier})
end)

RegisterNetEvent('AddItemMailToPlayer')
AddEventHandler('AddItemMailToPlayer', function()
	local _source = source
	CoreUtils.addItem(_source, 'Mail', 1)
end)

RegisterNetEvent('AddItemMailToMailbox')
AddEventHandler('AddItemMailToMailbox', function(MailBoxID)
	local _source = source
	if coreType == 'VORPCore' then
		local Mail = {
			name       = "Mail",
			metadata   = lastmessage,
			amount     = 1,
			limit      = 300,
			weight     = "0.00",
			mainid     = 530,
			percentage = 0,
			label      = "Lettre",
			count      = 1,
			isDegradable= false,
			group      = 1,
			id         = 530,
			desc       = "Message Reçu",
			type       = "item_standard",      
		}
		local items = {Mail}
		local MailboxMail = exports.vorp_inventory:addItemsToCustomInventory('Mailbox_'..tostring(MailBoxID), items, 6,callback,false)
	else
		-- Implement mailbox item addition for LXRCore/RSGCore if needed
	end
end)

RegisterNetEvent('Mail:IsConnected')
AddEventHandler('Mail:IsConnected', function(recipientId,_source)
	TriggerEvent('AddItemMailToMailbox', recipientId)
	TriggerClientEvent("vorp:TipRight", _source, "La personne est absente, envoi à sa boite postale", 5000)
end)


RegisterCommand('CRS', function(source,args,rawCommand)
	PlayersConnected = {}
	TriggerClientEvent('CRSC',-1)
	Wait(5000)
	--print(json.encode(PlayersConnected))
end)

RegisterNetEvent('CR2S')
AddEventHandler('CR2S', function(source,PlayerTable)
	local user = Core.getUser(source) --[[@as User]]  
	if not user then return end -- is player in session?
	local character = user.getUsedCharacter
	local charIdentifier = character.charIdentifier
	local firstname = character.firstname
	local lastname = character.lastname
	PlayerTable = {
		source = source,
		steamname = steamname,
		charIdentifier = charIdentifier,
		firstname = firstname,
		lastname = lastname
	}
	table.insert(PlayersConnected,PlayerTable)
	print(json.encode(PlayersConnected))
end)

-- debug console commands
RegisterCommand('MailboxClean', function(source,args,rawCommand)
	local Mails = exports.vorp_inventory:getCustomInventoryItems('Mailbox_'..tostring(args[1]), callback)
	for i,r in ipairs(Mails) do
		print(r.name.." retiré de la Mailbox "..tostring(args[1]))
	end
	MySQL.Async.execute('DELETE FROM `character_inventories` WHERE `inventory_type`= ?',{'Mailbox_'..tostring(args[1])})
end)

RegisterCommand('MailboxRemove', function(source,args,rawCommand)
	exports.vorp_inventory:removeInventory('Mailbox_'..tostring(args[1]))
end)

RegisterCommand('IsMailbox', function(source,args,rawCommand)
	print(exports.vorp_inventory:isCustomInventoryRegistered('Mailbox_'..tostring(args[1])))
end)

RegisterCommand('RegisterMailbox', function(source,args,rawCommand)
	TriggerEvent('Mail:RegisterInventory',args[1])
end)

RegisterCommand('OpenMailbox', function(source,args,rawCommand)
	exports.vorp_inventory:openInventory(source, 'Mailbox_'..tostring(args[1]))
end)
--]]

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
		TriggerEvent('Mail:Start:RegisterInventory')
    end
end)