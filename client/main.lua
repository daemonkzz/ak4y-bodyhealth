camera = nil
playerDead = false
bleedingNow = false
inspectedPlayer = {
    inspectedPlayerId = nil,
    playerPed = nil,
    health = 0,
    bodyParts = {}
}
local boneData = {
    Head = {
        boneIndex = 98, -- SKEL_Head
        bodyPart = {
            { id = 31086 },
        },
        currentHealth = 100,
        damagedBy = nil,
    },
    Body = {
        boneIndex = 0, -- SKEL_Pelvis
        bodyPart = {
            { id = 23553 },
            { id = 57597 },
            { id = 23554 },
            { id = 24816 },
            { id = 24817 },
            { id = 39317 },
            { id = 11816 }
        },
        currentHealth = 100,
        damagedBy = nil,
    },
    RightArm = {
        boneIndex = 41, -- SKEL_R_UpperArm
        bodyPart = {
            { id = 10706 },
            { id = 40269 },
            { id = 28252 },
            { id = 57005 },
            { id = 58866 },
            { id = 64016 },
            { id = 64017 },
            { id = 58867 },
            { id = 64096 },
            { id = 64097 },
            { id = 58868 },
            { id = 64112 },
            { id = 64113 },
            { id = 58869 },
            { id = 64064 },
            { id = 64065 },
            { id = 58870 },
            { id = 64080 },
            { id = 64081 }
        },
        currentHealth = 50,
        damagedBy = nil,
    },
    LeftArm = {
        boneIndex = 70, -- SKEL_L_UpperArm
        bodyPart = {
            { id = 64729 },
            { id = 45509 },
            { id = 61163 },
            { id = 18905 },
            { id = 26610 },
            { id = 4089 },
            { id = 4090 },
            { id = 26611 },
            { id = 4169 },
            { id = 4170 },
            { id = 26612 },
            { id = 4185 },
            { id = 4186 },
            { id = 26613 },
            { id = 4137 },
            { id = 4138 },
            { id = 26614 },
            { id = 4153 },
            { id = 4154 }
        },
        currentHealth = 50,
        damagedBy = nil,
    },
    RightLeg = {
        boneIndex = 3, -- SKEL_R_Thigh
        bodyPart = {
            { id = 51826 },
            { id = 36864 },
            { id = 52301 },
            { id = 20781 }
        },
        currentHealth = 50,
        damagedBy = nil,
    },
    LeftLeg = {
        boneIndex = 22, -- SKEL_L_Thigh
        bodyPart = {
            { id = 58271 },
            { id = 63931 },
            { id = 14201 },
            { id = 2108 }
        },
        currentHealth = 50,
        damagedBy = nil,
    }
}

-- inspect the nearest player with command
RegisterCommand(AK4Y.CheckPlayerCommand, function()
    local checkJob = checkMyJob()
    if not checkJob then
        sendNotify("error", AK4Y.Translate.notDoctor)
        return
    end
    local playerPed = PlayerPedId()
    local checkDead = checkPedIsDead(playerPed)
    if checkDead then
        sendNotify("error", AK4Y.Translate.youAreDead)
        return
    end
    local playerCoords = GetEntityCoords(playerPed)
    local peds = GetGamePool("CPed")

    for _, peda in pairs(peds) do
        local closestPed = peda

        if IsPedAPlayer(closestPed) then
            local ped = PlayerPedId()

            if closestPed ~= ped then
                local closestPlayer = NetworkGetPlayerIndexFromPed(closestPed)
                local closestPedCoords = GetEntityCoords(closestPed)
                local pedCoords = GetEntityCoords(ped)

                if #(closestPedCoords - pedCoords) < 3.0 then
                    SendNUIMessage({
                        action = "showRevive"
                    })
                    TriggerServerEvent('ak4y-bodyparts:inspectPlayer', GetPlayerServerId(closestPlayer))
                    return
                end
            end
        end
    end
end)

CreateThread(function()
    RegisterKeyMapping(AK4Y.CheckPlayerCommand, "Player Check - ak4yBodyHealth", "keyboard", AK4Y.CheckPlayerKey)
end)

RegisterCommand(AK4Y.CheckPlayerCommand2, function()
    SendNUIMessage({
        action = "hideRevive"
    })
    TriggerServerEvent('ak4y-bodyparts:inspectPlayer', GetPlayerServerId(PlayerId()))
end)

CreateThread(function()
    RegisterKeyMapping(AK4Y.CheckPlayerCommand2, "Player Check - ak4yBodyHealth", "keyboard", "f4")
end)


local performanceCd = 2
CreateThread(function()
    while true do
        performanceCd = 2
        if inspectedPlayer.playerPed ~= nil then
            performanceCd = 2
            local playerPed = inspectedPlayer.playerPed
            -- check player bones, and get them screen coords
            for boneGroup, groupData in pairs(inspectedPlayer.bodyParts) do
                -- print("INCELENIYO")
                local boneCoords = GetWorldPositionOfEntityBone(playerPed, groupData.boneIndex)
                local onScreen, screenCoordX, screenCoordY = GetScreenCoordFromWorldCoord(boneCoords.x, boneCoords.y,
                    boneCoords.z + 0.5)

                -- Send the data to the NUI
                SendNUIMessage({
                    action = "updateBodyPart",
                    bodyPart = boneGroup,
                    groupTaken = groupData.damagedBy,
                    groupHealth = groupData.currentHealth,
                    health = groupData.currentHealth,
                    onScreen = onScreen,
                    screenCoordX = screenCoordX * 100,
                    screenCoordY = screenCoordY * 100,
                })
            end
        end
        Wait(performanceCd)
    end
end)

CreateThread(function()
    while true do
        Wait(2000)
        performanceCd = 2
        local playerPed = inspectedPlayer.playerPed
        -- check player bones, and get them screen coords
        for boneGroup, groupData in pairs(boneData) do
            -- print("INCELENIYO")
            local boneCoords = GetWorldPositionOfEntityBone(playerPed, groupData.boneIndex)
            local onScreen, screenCoordX, screenCoordY = GetScreenCoordFromWorldCoord(boneCoords.x, boneCoords.y,
                boneCoords.z + 0.5)

            -- Send the data to the NUI
            SendNUIMessage({
                action = "updateBodyPart",
                bodyPart = boneGroup,
                groupTaken = groupData.damagedBy,
                groupHealth = groupData.currentHealth,
                health = groupData.currentHealth,
                onScreen = onScreen,
                screenCoordX = screenCoordX * 100,
                screenCoordY = screenCoordY * 100,
            })
        end
    end
end)



RegisterNetEvent('ak4y-bodyparts:show-data', function(data, target, itemList)
    -- get target player ped and set it to the inspected player
    local playerPed = GetPlayerPed(GetPlayerFromServerId(target))
    inspectedPlayer.inspectedPlayerId = target
    inspectedPlayer.playerPed = playerPed
    inspectedPlayer.health = 100
    inspectedPlayer.bodyParts = data


    local isTargetDead = checkPedIsDead(playerPed)
    if isTargetDead then
        local targetCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.5, 7.5)
        camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        PointCamAtEntity(camera, playerPed, 0.0, 0.0, 0.0, true)
        SetCamCoord(camera, targetCoords.x, targetCoords.y, targetCoords.z)
        RenderScriptCams(true, true, 1000, true, true)
        SetCamActive(camera, true)
        SetCamFov(camera, 20.0)
    else
        local targetCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 10.0, 0.5)
        camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        PointCamAtEntity(camera, playerPed, 0.0, 0.0, 0.0, true)
        SetCamCoord(camera, targetCoords.x, targetCoords.y, targetCoords.z)
        RenderScriptCams(true, true, 1000, true, true)
        SetCamActive(camera, true)
        SetCamFov(camera, 20.0)
    end


    -- show the NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "show",
        itemList = itemList,
        targetIsDead = isTargetDead,
        translate = AK4Y.Translate
    })
end)

RegisterNetEvent('ak4y-bodyparts:request-data', function(target)
    local boneDataCopy = boneData
    for boneGroup, groupData in pairs(boneDataCopy) do
        for _, bone in ipairs(groupData.bodyPart) do
            bone.bodyPart = nil
        end
    end
    TriggerServerEvent('ak4y-bodyparts:send-data', boneDataCopy, target)
end)

function GetBoneGroupFromID(boneID)
    for groupName, groupData in pairs(boneData) do
        for _, bone in ipairs(groupData.bodyPart) do
            if bone.id == boneID then
                return groupName
            end
        end
    end
    return "Body"
end

function IsMeleeWeapon(ped)
    for _, weapon in ipairs(meleeWeapons) do
        if HasPedBeenDamagedByWeapon(ped, weapon.hash, 0) then
            return true, weapon.hash
        end
    end
    return false, nil
end

function IsFirearm(ped)
    for _, weapon in ipairs(allWeapons) do
        if HasPedBeenDamagedByWeapon(ped, weapon.hash, 0) and not IsMeleeWeapon(ped) then
            return true, weapon.hash
        end
    end
    return false, nil
end

function GetWeaponNameFromHash(weaponHash)
    for _, weapon in ipairs(allWeapons) do
        if weapon.hash == weaponHash then
            return weapon.name
        end
    end
    return AK4Y.Translate.unknownWeapon
end

function GetMeleeWeaponNameFromHash(weaponHash)
    for _, weapon in ipairs(meleeWeapons) do
        if weapon.hash == weaponHash then
            return weapon.name
        end
    end
    return AK4Y.Translate.unknownMeleeWeapon
end

function ApplyRandomDamage(boneGroup, damageAmount, damageType)
    if boneData[boneGroup] then
        boneData[boneGroup].currentHealth = boneData[boneGroup].currentHealth - damageAmount
        if boneData[boneGroup].currentHealth < 0 then
            boneData[boneGroup].currentHealth = 0
        end

        if not boneData[boneGroup].damagedBy then
            boneData[boneGroup].damagedBy = {}
        end

        local alreadyExists = false
        for _, existingDamageType in ipairs(boneData[boneGroup].damagedBy) do
            if existingDamageType == damageType then
                alreadyExists = true
                break
            end
        end

        if not alreadyExists then
            table.insert(boneData[boneGroup].damagedBy, damageType)
        end
    end
    TriggerServerEvent("Sweepz:DamageKaydet", boneData)
end

-- [YENI FONKSIYON] - Can barını script canına anlık eşitler
local function SyncHudHealth()
    -- Oyuncu ölü değilse canını senkronize et
    if not playerDead then
        local playerPed = PlayerPedId()
        local totalHealth = 0
        local partCount = 0

        -- Tüm vücut parçalarının canlarını topla
        for boneGroup, groupData in pairs(boneData) do
            totalHealth = totalHealth + groupData.currentHealth
            partCount = partCount + 1
        end

        if partCount > 0 then
            -- Can ortalamasını 0-100 arasında hesapla
            local averageHealthPercent = totalHealth / partCount

            -- GTA'nın can sistemine (100 = ölü, 200 = tam can) uyarla
            local newGameHealth = 100 + averageHealthPercent

            if newGameHealth > 200 then
                newGameHealth = 200
            end

            -- Oyuncunun ana can barını (HUD) güncelle
            SetEntityHealth(playerPed, math.ceil(newGameHealth))
        end
    end
end
-- [YENI FONKSIYON BITIS]

AddEventHandler('gameEventTriggered', function(eventName, eventData)
    if eventName == 'CEventNetworkEntityDamage' then
        local victim = eventData[1]
        if IsEntityAPed(victim) and IsPedAPlayer(victim) then
            local playerPed = PlayerPedId()
            if victim == playerPed then
                CancelEvent()
                local hit, boneID = GetPedLastDamageBone(playerPed)
                -- if hit then
                local boneGroup = GetBoneGroupFromID(boneID)
                if boneGroup then
                    -- Determine damage amount and type
                    local damageAmount
                    local damageType
                    local isMelee, meleeWeaponHash = IsMeleeWeapon(playerPed)
                    local isFirearm, firearmWeaponHash = IsFirearm(playerPed)

                    if isMelee then
                        damageAmount = math.random(5, 15) -- Melee attack damage
                        damageType = GetMeleeWeaponNameFromHash(meleeWeaponHash)
                    elseif isFirearm then
                        damageAmount = math.random(20, 40)                    -- Firearm attack damage
                        damageType = GetWeaponNameFromHash(firearmWeaponHash) -- Silahın adı
                    elseif HasEntityBeenDamagedByAnyVehicle(playerPed) then
                        damageAmount = math.random(10, 30)                    -- Vehicle damage
                        damageType = AK4Y.Translate.vehicle
                    elseif eventData[4] == GetHashKey("weapon_pistol") then
                        damageAmount = 10
                        damageType = "Pistol"
                    else
                        damageAmount = math.random(1, 10) -- Default unknown damage
                        damageType = AK4Y.Translate.unknown
                    end

                    -- Apply damage
                    ApplyRandomDamage(boneGroup, damageAmount, damageType)
                    SyncHudHealth()
                end

                if AK4Y.AllPartDamageWhenFatalDamage then
                    if GetEntityHealth(playerPed) <= 0 then
                        playerDead = true
                        -- Fatal attack, apply damage to all body parts
                        ApplyRandomDamage(boneGroup, math.random(AK4Y.FatalDamageRandom.min, AK4Y.FatalDamageRandom.max),
                            "Fatal Damage")
                        SyncHudHealth()
                    end
                end
                -- end

                ClearEntityLastDamageEntity(playerPed)
            end
        end
    end
end)

local effect = false
local lastBleed = 0
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        if AK4Y.PlayerRagdoll and not playerDead then
            -- check players legs health and ragdoll if they are below 50

            -- Ragdoll player if his running
            if boneData["RightLeg"].currentHealth < 50 or boneData["LeftLeg"].currentHealth < 50 then
                local playerPed = PlayerPedId()
                if IsPedSprinting(playerPed) then
                    SetPedToRagdoll(playerPed, 1000, 1000, 0, 0, 0, 0)
                end

                if IsPedRunning(playerPed) then
                    SetPedToRagdoll(playerPed, 500, 500, 0, 0, 0, 0)
                end
            end
        end

        if AK4Y.Bleeding and not playerDead then
            -- check players body health and apply blood overlay if they are below 50
            if boneData[AK4Y.BleedingIfThisPartGetDamage].currentHealth < AK4Y.BleedingStopHealth then
                bleedingNow = true
                lastBleed = GetGameTimer() + AK4Y.BleedingTime * 1000
                if GetGameTimer() > lastBleed then
                    goto continue
                end

                if AK4Y.BleedingScreenEffect then
                    SetFlash(0, 0, 100, 100, 100)
                    if not effect then
                        effect = true
                        StartScreenEffect('Rampage', 0, true)
                    end
                end

                -- Decrease health
                for boneGroup, groupData in pairs(boneData) do
                    if boneGroup ~= "Head" then
                        ApplyRandomDamage(boneGroup, AK4Y.BleedingDecreaseAllPartHealth, "Bleeding")
                    end
                end

                if AK4Y.BleedingScreenEffect then
                    -- Apply blood overlay
                    SetTimecycleModifier("health_bleed")
                    SetTimecycleModifierStrength(0.5)
                end
                ::continue::
            else
                bleedingNow = false
                if AK4Y.BleedingScreenEffect then
                    SetFlash(0, 0, 0, 0, 0)
                    if effect then
                        effect = false
                        StopScreenEffect('Rampage')
                    end
                    SetTimecycleModifier("default")
                    SetTimecycleModifierStrength(0.0)
                end
            end
        end

        if AK4Y.DisarmPed and not playerDead then
            -- check players arms health and disarm if they are below 50
            if boneData["RightArm"].currentHealth < AK4Y.DisarmPedArmHealth or boneData["LeftArm"].currentHealth < AK4Y.DisarmPedArmHealth then
                local playerPed = PlayerPedId()
                if IsPedArmed(playerPed, 6) then
                    disarmPed(playerPed)
                end
            end
        end
    end
end)


----

RegisterNetEvent("ak4y-bodyhealth:youHealed", function(data, doctor)
    local healedPart = data.healedPart
    local usedItem = data.usedItem
    local healAmount = checkDoctorItemsHowMuchHealthRenew(usedItem.name)
    if healAmount then
        if healAmount.healGeneral > 0 then
            for boneGroup, groupData in pairs(boneData) do
                if boneData[boneGroup].currentHealth + healAmount.healGeneral > 100 then
                    boneData[boneGroup].currentHealth = 100
                else
                    boneData[boneGroup].currentHealth = boneData[boneGroup].currentHealth + healAmount.healGeneral
                end
            end
        end
        if healAmount.healPart > 0 then
            if boneData[healedPart].currentHealth + healAmount.healPart > 100 then
                boneData[healedPart].currentHealth = 100
            else
                boneData[healedPart].currentHealth = boneData[healedPart].currentHealth + healAmount.healPart
            end
        end
    end

    SyncHudHealth()
end)


RegisterNetEvent('ak4y-bodyhealth:revivedInjured', function()
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(camera, true)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "hide"
    })
end)

function checkDoctorItemsHowMuchHealthRenew(itemName)
    for _, item in pairs(AK4Y.DoctorItems) do
        if item.itemName == itemName then
            return {
                healPart = item.healPart,
                healGeneral = item.healGeneral
            }
        end
    end
    return nil
end

function checkAllPartIsHundreds()
    -- return true if all boneData health is 100
    for boneGroup, groupData in pairs(boneData) do
        if boneData[boneGroup].currentHealth < 100 then
            return false
        end
    end
    return true
end

-- check all part health and return true if all parts heath is more than AK4Y.MinimumAllPartHealthForRevive
function checkAllPartHealthForRevive()
    -- inspectedPlayer
    for boneGroup, groupData in pairs(inspectedPlayer.bodyParts) do
        if inspectedPlayer.bodyParts[boneGroup].currentHealth < AK4Y.MinimumAllPartHealthForRevive then
            return false
        end
    end
    return true
end

RegisterNetEvent('ak4y-bodyhealth:revivePlayer', function()
    for boneGroup, groupData in pairs(boneData) do
        boneData[boneGroup].currentHealth = 100
        boneData[boneGroup].damagedBy = nil
        playerDead = false
        bleedingNow = false
    end
    AK4Y.RevivePlayer()
end)

RegisterNetEvent('zombi-vurdu', function()
    -- 1. Rastgele bir vücut parçası seç
    local bodyParts = { "Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }
    local randomPart = bodyParts[math.random(1, #bodyParts)]

    -- 2. Config'den rastgele bir hasar miktarı al
    local damageAmount = math.random(AK4Y.ZombieDamage.min, AK4Y.ZombieDamage.max)

    -- 3. Hasarı, scriptin kendi fonksiyonunu kullanarak uygula (UI'da "Zombie" olarak görünür)
    ApplyRandomDamage(randomPart, damageAmount, "Zombie")

    -- 4. Kanama şansını kontrol et
    local bleedRoll = math.random(1, 100)
    if bleedRoll <= AK4Y.ZombieDamage.BleedChance then
        -- Kanama şansı tutarsa, scriptin ana kanama döngüsünü tetikle
        if not bleedingNow then
            bleedingNow = true
        end
    end

    -- 5. Can barını anında eşitle
    SyncHudHealth()
end)

exports('GetBleedingStatus', function()
    return bleedingNow
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    TriggerServerEvent("Sweepz:KullaniciLogIn", false, boneData)
end)

CreateThread(function()
    while true do
        local sleep = 0
        if LocalPlayer.state.isLoggedIn then
            TriggerServerEvent("Sweepz:KullaniciLogIn", true, boneData)
            break
        end
        Wait(sleep)
    end
end)

RegisterNetEvent("Sweepz:VeriIsle", function(data)
    local canzirh = json.decode(data.canzirh)
    boneData = json.decode(data.data)
    SetEntityHealth(cache.ped, canzirh.can)
    SyncHudHealth()
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
	end
end)