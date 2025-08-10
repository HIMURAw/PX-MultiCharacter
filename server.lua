if Config.Core == "qb" then
    local QBCore = exports['qb-core']:GetCoreObject()
    hasDonePreloading = {}
    QBCore.Functions.CreateCallback("px-multicharacter:server:GetNumberOfCharacters", function(source, cb)
        local src = source
        local license = QBCore.Functions.GetIdentifier(src, 'license')
        local numOfChars = Config.PlayersNumberOfCharacters[license]

        if not numOfChars then
            numOfChars = 0
        end

        cb(numOfChars)
    end)

    QBCore.Functions.CreateCallback("px-multicharacter:server:getCharacters", function(source, cb)
        local license = QBCore.Functions.GetIdentifier(source, 'license')
        local plyChars = {}
        local result = ExecuteSql('SELECT * FROM players WHERE license = ?', { license })
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)
            plyChars[#plyChars + 1] = {
                charidentifier = result[i].citizenid,
                firstname = result[i].charinfo.firstname or "",
                lastname = result[i].charinfo.lastname or "",
                birthdate = result[i].charinfo.birthdate or "",
                gender = result[i].charinfo.gender or "",
                nationality = result[i].charinfo.nationality or "",
                job = result[i].job.label or "",
                cash = result[i].money.cash or "",
                bank = result[i].money.bank or "",
            }
        end
        local numOfChars = Config.PlayersNumberOfCharacters[license]

        if not numOfChars then
            numOfChars = Config.DefaultNumberOfCharacters
        end
        cb({ chars = plyChars, maxchars = numOfChars })
    end)

    AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
        Wait(1000)
        hasDonePreloading[Player.PlayerData.source] = true
    end)

    AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
        hasDonePreloading[src] = false
    end)

    local function sendDiscordLog(title, description, webhookUrl)
        local embed = {
            {
                ["color"] = 3145645,
                ["title"] = "**" .. title .. "**",
                ["description"] = description,
                ["footer"] = {
                    ["text"] = "PX-Multicharacter",
                    ["icon_url"] =
                        Config.DiscordLoginIcon
                }
            }
        }

        PerformHttpRequest(webhookUrl, function(err, text, headers)
            if err ~= 204 and err ~= 200 then
                print("Discord log gönderilemedi: " .. tostring(err))
            end
        end, 'POST', json.encode({ embeds = embed }), {
            ['Content-Type'] = 'application/json'
        })
    end

    QBCore.Functions.CreateCallback("px-multicharacter:server:getSkin", function(_, cb, cid)
        local result = exports.oxmysql:executeSync("SELECT * FROM playerskins WHERE citizenid = ? AND active = 1",
            { cid })
        if result[1] ~= nil then
            cb(result[1].model, result[1].skin)
        else
            cb(nil)
        end
    end)

    function GiveStarterItems(source)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)

        for k, v in pairs(QBCore.Shared.StarterItems) do
            Player.Functions.AddItem(v.item, 1)
        end

        for _, v in pairs(Config.StarterItems) do
            local info = {}
            Player.Functions.AddItem(v.item, v.amount, false, info)
        end
    end

    RegisterNetEvent('px-multicharacter:server:selectChar', function(charidentifier)
        local src = source
        if not src or not charidentifier then return end

        if QBCore.Player.Login(src, charidentifier) then
            local Player = QBCore.Functions.GetPlayer(src)
            if not Player then return end

            local steam = QBCore.Functions.GetIdentifier(src, "steam") or "Bilinmiyor"
            local license = QBCore.Functions.GetIdentifier(src, "license") or "Bilinmiyor"
            local discord = QBCore.Functions.GetIdentifier(src, "discord") or "Bilinmiyor"
            local ip = QBCore.Functions.GetIdentifier(src, "ip") or "Bilinmiyor"
            local citizenid = Player.PlayerData.citizenid
            local firstname = Player.PlayerData.charinfo.firstname or "Bilinmiyor"
            local lastname = Player.PlayerData.charinfo.lastname or "Bilinmiyor"
            local job = Player.PlayerData.job.name or "Bilinmiyor"
            local grade = Player.PlayerData.job.grade.name or tostring(Player.PlayerData.job.grade.level)
            local charname = firstname .. " " .. lastname
            local slot = Player.PlayerData.metadata["charSlot"] or "Bilinmiyor"
            local loginTime = os.date("%Y-%m-%d %H:%M:%S")
            local playerName = GetPlayerName(src)

            -- Log açıklaması
            local logDesc = string.format([[
            ** Oyuncu:** %s (%s)
            ** Citizen ID:** %s
            ** Karakter İsmi:** %s
            ** Meslek:** %s - %s
            ** Slot:** %s
            ** Giriş Zamanı:** %s

            ** Steam:** `%s`
            ** Discord:** <@%s>
            ** Lisans:** `%s`
            ** IP:** `%s`
            ]],
                playerName, src, citizenid, charname, job, grade, slot, loginTime,
                steam, discord:gsub("discord:", ""), license, ip)
            local webhook = Config.DiscordLoginWebhook
            sendDiscordLog("Karakter Girişi", logDesc, webhook)
            local cData = { citizenid = charidentifier }
            if GetResourceState('qb-apartments') == 'started' then
                TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
            else
                TriggerClientEvent('qb-spawn:client:setupSpawns', src, cData, false, nil)
                TriggerClientEvent('qb-spawn:client:openUI', src, true)
            end

            QBCore.Commands.Refresh(src)
        end
    end)

    local function GiveStarterItems(source)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)

        for _, v in pairs(QBCore.Shared.StarterItems) do
            local info = {}
            if v.item == "id_card" then
                info.citizenid = Player.PlayerData.citizenid
                info.firstname = Player.PlayerData.charinfo.firstname
                info.lastname = Player.PlayerData.charinfo.lastname
                info.birthdate = Player.PlayerData.charinfo.birthdate
                info.gender = Player.PlayerData.charinfo.gender
                info.nationality = Player.PlayerData.charinfo.nationality
            elseif v.item == "driver_license" then
                info.firstname = Player.PlayerData.charinfo.firstname
                info.lastname = Player.PlayerData.charinfo.lastname
                info.birthdate = Player.PlayerData.charinfo.birthdate
                info.type = "Class C Driver Lzicense"
            end
            Player.Functions.AddItem(v.item, v.amount, false, info)
        end
    end



    RegisterNetEvent('px-multicharacter:server:createChar', function(charData)
        local src = source
        local cData = {
            cid = charData.cid,
            charinfo = {
                cid = charData.cid,
                nationality = charData.nationality,
                birthdate = charData.birthdate,
                firstname = charData.firstname,
                lastname = charData.lastname,
                gender = charData.gender
            }
        }

        if QBCore.Player.Login(src, false, cData) then
            repeat Wait(10) until hasDonePreloading[src]

            -- Gender kontrolü ve string model seçimi
            local model = "mp_m_freemode_01"
            if charData.gender == "female" or charData.gender == 1 or charData.gender == "f" then
                model = "mp_f_freemode_01"
            end

            TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
            TriggerClientEvent("px-multicharacter:client:spawnAtCoords", src, Config.PlayerDefaultSpawn)

            TriggerClientEvent('pxmultichar:startCharacterCreation', src, charData.gender)

            TriggerClientEvent("fivem-appearance:client:openClothingShop", src, true, model)
            -- TriggerClientEvent('qb-clothing:client:openMenu2', src, model)


            TriggerClientEvent("closeui:incchar", src)
            GiveStarterItems(src)
        end
    end)
end

ExecuteSql = function(query, data)
    local IsBusy = true
    local result = nil
    if data == nil then
        dataS = {}
    else
        dataS = data
    end
    if Config.SQL == "oxmysql" then
        if MySQL == nil then
            exports.oxmysql:execute(query, dataS, function(data)
                result = data
                IsBusy = false
            end)
        else
            MySQL.query(query, dataS, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif Config.SQL == "ghmattimysql" then
        exports.ghmattimysql:execute(query, dataS, function(data)
            result = data
            IsBusy = false
        end)
    elseif Config.SQL == "mysql-async" then
        MySQL.Async.fetchAll(query, dataS, function(data)
            result = data
            IsBusy = false
        end)
    end
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end

local function shallowCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
            copy[k] = v
        end
    end
    return copy
end

RegisterServerEvent("PX:dropPlayer", function()
    local src = source
    DropPlayer(src, "Oyundan çıkış yaptınız.")
end)

RegisterNetEvent("PX-multichar:server:deleteChar", function(charId)
    local src = source
    if not charId then return end
    ExecuteSql("DELETE FROM `players` WHERE `citizenid` = @citizenId", { ['@citizenId'] = charId })
    DropPlayer(src, "Karakteriniz başarıyla silinmiştir.")
end)

RegisterNetEvent('PX-MultiCharacter:requestTranslations', function()
    local src = source
    local locale = Config.Locale or "en"
    local phrases = {}

    local file = string.format("Locale/%s.lua", locale)
    local langFile = LoadResourceFile(GetCurrentResourceName(), file)

    if not langFile and locale ~= "en" then
        langFile = LoadResourceFile(GetCurrentResourceName(), "Locale/en.lua")
    end

    if langFile then
        local chunk = load(langFile)
        if chunk then
            chunk()
            if type(Translations) == "table" then
                phrases = shallowCopy(Translations)
            end
        end
    end

    TriggerClientEvent('PX-MultiCharacter:receiveTranslations', src, phrases)
end)
