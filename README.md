# PX-MultiCharacter
FiveM Multi character script


# PREVİEW
<img src="https://cdn.discordapp.com/attachments/1392478452636192838/1405663284321063022/image.png?ex=689fa572&is=689e53f2&hm=6a67ce24ff03eb8a933798d9d5251cb5e13e485fc68439a55699246eb74ac810&">


# Configuration File Documentation

This file is used to configure the core settings of the server.  
Below is a detailed explanation of each setting.

---

## 📌 Core Settings

| Setting               | Description |
|-----------------------|-------------|
| `Config.Core`         | Server core framework. Supported: `qb`. |
| `Config.SQL`          | SQL resource to use. Supported: `mysql-async`, `oxmysql`, `ghmattimysql`. |
| `Config.Locale`       | Language setting. Supported: `tr`, `en`, `fr`, `de`, `pt`, `es`. |
| `Config.appearance`   | Character appearance system. Supported: `fivem-appearance`, `illenium-appearance`. |

---

## 🎁 Starter Items

```lua
Config.StarterItems = {
    { item = "phone", amount = 1 }
}
```

## 🗑 Character Deletion

-   `Config.DeleteChar = false` → Character deletion is disabled.
    
-   Set to `true` to allow players to delete their characters.

## 📍 Spawn and Coordinate Settings

-   `Config.PlayerDefaultSpawn` → Default spawn coordinates for new characters.
    
-   `Config.PlayerFreezeCoords` → Location where the player is frozen during character selection.
    
-   `Config.PedCoords` → Ped position shown in the character selection screen.
    
-   `Config.CamCoords` → Camera position.
    

Coordinates must be in **vector4(x, y, z, heading)** format.

## 📢 Discord Webhook Settings

-   `Config.DiscordLoginWebhook` → Discord Webhook URL for sending login notifications.
    
-   `Config.DiscordLoginIcon` → Icon URL displayed in the webhook message.

## Character Slot Settings

-   `Config.DefaultNumberOfCharacters` → Default number of character slots for all players.
    
-   `Config.PlayersNumberOfCharacters` → Custom character slot numbers for specific license IDs.
    

Example:

`["license:d782a9d7f326706cad2af7572e30099098e0a6d5"] = 10`

## Credits

-   **Owner** → HIMURA
    
-   **Project Developer** → HIMURA
