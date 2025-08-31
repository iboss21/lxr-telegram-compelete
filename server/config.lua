-- config.lua
-- Telegram system configuration
-- Developer: iboss21 (https://github.com/iboss21)

local Config = {}

Config.RegistrationFee = 50 -- base fee for mailbox registration
Config.UpgradeFee = 25      -- additional fee per upgrade level
Config.SendMessageFee = 10  -- fee for sending a telegram
Config.MaxAttachments = 3   -- max number of attachments per mail
Config.MailboxCapacity = 50 -- default mailbox capacity
Config.AdminDiscordWebhook = "" -- set Discord webhook for admin actions
Config.TebexSecret = "YOUR_TEBEX_SECRET" -- Set your Tebex secret here
Config.SupportDiscord = "https://discord.gg/yourdiscord" -- Support Discord for buyers
Config.PremiumMailbox = true -- Enable premium mailbox upgrades for Tebex
Config.PremiumFeatures = {
    extraCapacity = 100,
    customThemes = true,
    priorityDelivery = true
}
Config.Languages = {
    en = {
        mailbox_registered = "Mailbox registered!",
        not_enough_money = "Not enough money.",
        mail_sent = "Mail sent!",
        error = "An error occurred.",
        new_mail = "You have new mail!"
    },
    fr = {
        mailbox_registered = "Boîte postale enregistrée!",
        not_enough_money = "Pas assez d'argent.",
        mail_sent = "Courrier envoyé!",
        error = "Une erreur s'est produite.",
        new_mail = "Vous avez du nouveau courrier!"
    }
}
Config.DefaultLanguage = "en"

return Config
