local QBCore = exports['qb-core']:GetCoreObject()
local locale = Config.Locale

RegisterCommand("char", function()
    Display(true)
end)

function SetHudVisible(visible)
    TriggerEvent('hud:client:toggleHud', visible)
end

Display = function(a)
    if a then
        -- Load translations first
        local locale = Config.Locale or 'en'
        local file = LoadResourceFile(GetCurrentResourceName(), "locale/" .. locale .. ".json")
        if file then
            local translations = json.decode(file)
            SendNUIMessage({
                action = "loadTranslations",
                data = translations
            })
        else
            print("^1[ERROR] Locale file not found: " .. locale .. ".json^7")
        end
        
        -- Then load characters
        QBCore.Functions.TriggerCallback('px-multicharacter:server:getCharacters', function(result)
            SendNUIMessage({
                type = "sendChars",
                data = result.chars,
                maxchars = result.maxchars
            })
        end, 'MIKAYISIKIYIM')
        SetHudVisible(false)
    else
        SetHudVisible(true)
    end
    skyCam(a)
    SendNUIMessage({
        type = "display",
        bool = a
    })
    SetNuiFocus(a, a)
end

function skyCam(bool)
    if bool then
        SetEntityCoords(PlayerPedId(), Config.PlayerFreezeCoords)
        Citizen.Wait(1000)
        FreezeEntityPosition(PlayerPedId(), true)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.CamCoords.x, Config.CamCoords.y, Config.CamCoords.z,
            0.0, 0.0, Config.CamCoords.w, 60.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    else
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

RegisterNUICallback("delSkin", function(data, cb)
    if charPed then
        DeleteEntity(charPed)
        charPed = nil
    end
    cb("ok")
end)

RegisterNUICallback("exitgame", function(data, cb)
    TriggerServerEvent("PX:dropPlayer")
end)

RegisterNUICallback("openCredits", function(data, cb)
    local creditsHtml = ""
    for _, section in ipairs(Config.Credits) do
        creditsHtml = creditsHtml .. string.format("<b>%s</b><br>", section.title)
        for _, user in ipairs(section.users) do
            creditsHtml = creditsHtml .. string.format("- %s<br>", user)
        end
        creditsHtml = creditsHtml .. "<br>"
    end
    SendNUIMessage({
        action = "showCredits",
        credits = creditsHtml
    })
    cb('ok')
end)

RegisterNUICallback("closeCreditsAndShowMain", function(data, cb)
    -- Ana karakter ekranını tekrar açan fonksiyonunuzu buraya ekleyin
    if OpenMultiCharacterUI then
        OpenMultiCharacterUI()
    end
    cb('ok')
end)

local particleEffects = {
    { name = 'proj_indep_firework_v2', child = 'scr_firework_indep_repeat_burst_rwb' },
    { name = 'scr_powerplay',          child = 'scr_powerplay_beast_vanish' },
    { name = 'core',                   child = 'ent_dst_gen_gobstop' },
    { name = 'scr_xs_celebration',     child = 'scr_xs_confetti_burst' },
    { name = 'scr_rcbarry2',           child = 'scr_clown_bul' },
}

local function playRandomParticleEffect(coords)
    local effect = particleEffects[math.random(1, #particleEffects)]
    RequestNamedPtfxAsset(effect.name)
    while not HasNamedPtfxAssetLoaded(effect.name) do
        Citizen.Wait(10)
    end
    UseParticleFxAssetNextCall(effect.name)
    StartParticleFxNonLoopedAtCoord(effect.child, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0)
end


local function DeleteCharPed()
    if charPed then
        DeleteEntity(charPed)
        charPed = nil
    end
end

RegisterNUICallback("getSkinOfChar", function(data, cb)
    QBCore.Functions.TriggerCallback('px-multicharacter:server:getSkin', function(model, skinData)
        DeleteCharPed()
        local modelHash = type(model) == "string" and GetHashKey(model) or model
        if modelHash then
            CreateThread(function()
                RequestModel(modelHash)
                while not HasModelLoaded(modelHash) do Wait(0) end

                charPed = CreatePed(2, modelHash, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98,
                    Config.PedCoords.w, false, true)
                SetPedComponentVariation(charPed, 0, 0, 0, 2)
                FreezeEntityPosition(charPed, true)
                SetEntityInvincible(charPed, true)
                PlaceObjectOnGroundProperly(charPed)
                SetBlockingOfNonTemporaryEvents(charPed, true)

                local decodedSkinData = json.decode(skinData)
                if decodedSkinData["Father"] then
                    TriggerEvent('qb-clothing:client:loadPlayerClothing', decodedSkinData, charPed)
                else
                    exports["fivem-appearance"]:setPedAppearance(charPed, decodedSkinData)
                    -- TriggerEvent('qb-clothing:client:loadPlayerClothing', skinData)
                end

                playRandomParticleEffect(GetEntityCoords(charPed))
            end)
        else
            CreateThread(function()
                local randommodels = { "mp_m_freemode_01", "mp_f_freemode_01" }
                local randModel = GetHashKey(randommodels[math.random(#randommodels)])
                RequestModel(randModel)
                while not HasModelLoaded(randModel) do Wait(0) end

                charPed = CreatePed(2, randModel, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98,
                    Config.PedCoords.w, false, true)
                SetPedComponentVariation(charPed, 0, 0, 0, 2)
                FreezeEntityPosition(charPed, true)
                SetEntityInvincible(charPed, true)
                PlaceObjectOnGroundProperly(charPed)
                SetBlockingOfNonTemporaryEvents(charPed, true)

                playRandomParticleEffect(GetEntityCoords(charPed))
            end)
        end
    end, data.charidentifier)
    cb("ok")
end)



function f(n)
    n = n + 0.00000
    return n
end

RegisterNUICallback("selectChar", function(data, cb)
    TriggerServerEvent("px-multicharacter:server:selectChar", data.charid)
    print(data.charid)
    Display(false)
    DeleteCharPed()
    cb("ok")
end)


RegisterNUICallback("createChar", function(data, cb)
    TriggerServerEvent("px-multicharacter:server:createChar", data)
    cb("ok")
end)

RegisterNUICallback("getDeleteCharConfig", function(data, cb)
    SendNUIMessage({
        action = "setDeleteCharConfig",
        deleteCharEnabled = Config.DeleteChar
    })
    cb('ok')
end)

RegisterNetEvent("closeui:incchar", function()
    Display(false)
end)

RegisterNetEvent("px-multicharacter:client:spawnAtCoords", function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    SetEntityHeading(ped, coords.w)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if NetworkIsSessionStarted() then
            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()
            Citizen.Wait(500)
            SetTimeout(1000, function()
                Display(true)
            end)
            return
        end
    end
end)

RegisterNetEvent('pxmultichar:startCharacterCreation', function(gender)
    local model = gender == "male" or gender == 0 or gender == "m" and "mp_m_freemode_01" or "mp_f_freemode_01"
    local modelHash = GetHashKey(model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(0) end

    SetPlayerModel(PlayerId(), modelHash)
    SetModelAsNoLongerNeeded(modelHash)
end)

CreateThread(function()
    local locale = Config.Locale
    local file = LoadResourceFile(GetCurrentResourceName(), "locale/" .. locale .. ".json")
    if file then
        local translations = json.decode(file)
        SendNUIMessage({
            action = "loadTranslations",
            data = translations
        })
    else
        print("Locale dosyası bulunamadı: " .. locale)
    end
end)



RegisterNUICallback('deleteChar', function(data, cb)
    local charId = data.charId
    if not charId then
        cb({ success = false, message = "No charId provided" })
        return
    end

    TriggerServerEvent('PX-multichar:server:deleteChar', charId)
    cb({ success = true })
end)

RegisterNUICallback("setFilter", function(data, cb)
    local filter = data.filter
    if filter == "normal" then
        ClearTimecycleModifier()
    elseif filter == "sepia" then
        SetTimecycleModifier("sepia")
    elseif filter == "grayscale" then
        SetTimecycleModifier("hud_def_blur") -- örnek, farklı bir timecycle da seçebilirsin
    elseif filter == "blur" then
        SetTimecycleModifier("hud_def_blur")
    end
    cb('ok')
end)

RegisterNUICallback('testNui', function(data, cb)
    cb({ test = "ok" })
end)
