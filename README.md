# RedM Telegram System (LXRCore, RSGCore, VORP Core)

**Developer:** [iboss21](https://github.com/iboss21)
**Tebex Sale Ready**

## Features
- Full support for LXRCore, RSGCore, VORP Core
- Mailbox registration, upgrades, and premium options
- Send/receive telegrams with attachments
- Notifications for new/unread mail
- Admin tools and Discord webhook integration
- RP features: pigeon delivery, mail fees, anonymous mail, etc.
- Multi-language support
- Tebex license validation and anti-leak
- Premium mailbox features (extra capacity, custom themes, priority delivery)

## Installation
1. **Upload the resource folder to your RedM server.**
2. **Configure your framework:**
   - Supported: LXRCore, RSGCore, VORP Core
   - The script auto-detects your framework.
3. **Set up your database:**
   - Import `Docs/SQL/Install.sql` to your database.
4. **Configure the script:**
   - Edit `server/config.lua` for fees, premium options, Discord webhook, Tebex secret, and language.
5. **Set your Tebex secret:**
   - In `server/config.lua`, set `Config.TebexSecret` to your Tebex license key.
6. **Add your Discord support link:**
   - In `server/config.lua`, set `Config.SupportDiscord`.
7. **Start the resource in your server.cfg:**
   - `ensure lxr-telegram-complete`

## Monetization & Premium Features
- Enable premium mailbox upgrades in `config.lua`.
- Buyers can access extra mailbox capacity, custom themes, and priority delivery.
- All premium features are toggleable and customizable.

## Usage
- Players can register mailboxes, send/receive telegrams, and use all features via the in-game UI.
- Admins can clean mailboxes, monitor mail, and use Discord webhook for notifications.

## Support
- For license issues or support, join our Discord: [Support Discord](https://discord.gg/yourdiscord)
- For custom Tebex features, contact the developer.

## Credits
- Script by [iboss21](https://github.com/iboss21)
- Commercial use and resale permitted only via Tebex.

## License
MIT
