local cubicore = exports['qb-core']:GetCoreObject()
local srcs = {}



RegisterNetEvent('ak4y-bodyparts:inspectPlayer', function(data)
    local src = source
    TriggerClientEvent('ak4y-bodyparts:request-data', data, src)
end)

RegisterNetEvent('ak4y-bodyparts:send-data', function(data, target)
    local src = source
    -- get item list from target inventory as config framework
    local itemList = getPlayerInventoryItemListx(target)
    TriggerClientEvent('ak4y-bodyparts:show-data', target, data, src, itemList)
end)

RegisterServerCallback('ak4y-bodyhealth:usedItem', function(source, cb, data, healedTarget)
    local source = source
    local usedItemData = data.usedItem

    local checkItemCount = checkPlayerItemCount(source, usedItemData.name) -- check if player has the item in inventory
    if checkItemCount > 0 then
        -- remove item from inventory
        xPlayerRemoveItem(usedItemData.name, 1, source)
        TriggerClientEvent('ak4y-bodyhealth:youHealed', healedTarget, data, source)
        cb({ success = true, returnData = data })
    else
        cb({ success = false })
    end
end)


RegisterNetEvent('ak4y-bodyhealth:injuredRevived', function(data)
    local src = source
    TriggerClientEvent('ak4y-bodyhealth:revivedInjured', tonumber(data), src)
end)

-- revive player
RegisterServerCallback('ak4y-bodyhealth:revivePlayer', function(source, cb, target)
    local source = source
    local neededReviveItems = AK4Y.ReviveItems                          -- table of items needed to revive player
    if AK4Y.ReviveItemNeeded then
        local bestItemForRevive = nil                                   -- best reviveChance from neededReviveItems
        for k, v in pairs(neededReviveItems) do
            local checkItemCount = checkPlayerItemCount(source, v.name) -- check if player has the item in inventory
            if checkItemCount > 0 then
                if bestItemForRevive == nil then
                    bestItemForRevive = v
                else
                    if v.reviveChance > bestItemForRevive.reviveChance then
                        bestItemForRevive = v
                    end
                end
            end
        end

        if bestItemForRevive ~= nil then
            -- remove item from inventory
            xPlayerRemoveItem(bestItemForRevive.name, 1, source)
            print('Revive chance: ' .. bestItemForRevive.reviveChance)
            local reviveChance = math.random(1, 100)
            if reviveChance <= bestItemForRevive.reviveChance then
                TriggerClientEvent('ak4y-bodyhealth:revivePlayer', target)
                cb({ success = true, itemName = bestItemForRevive.name })
            else
                cb({ success = false, errorText = AK4Y.Translate.reviveFailed })
            end
        else
            cb({ success = false, errorText = AK4Y.Translate.youDontHaveRequiredItem })
        end
    else
        TriggerClientEvent('ak4y-bodyhealth:revivePlayer', target)
        cb({ success = true })
    end
end)

RegisterNetEvent("Sweepz:DamageKaydet", function(data)
    local src = source
    local ped = GetPlayerPed(src)
    local can = GetEntityHealth(ped)
    local zirh = GetPedArmour(ped)
    local cidid = srcs[src .. ""]
    if cidid then
        local result = ExecuteSql("SELECT * FROM damages WHERE identy = ?", { cidid })
        if next(result) then
            ExecuteSql("UPDATE damages SET data = ?, canzirh = ? WHERE identy = ?",
                { json.encode(data), json.encode({ can = can, zirh = zirh }), cidid })
        else
            ExecuteSql(
                "INSERT INTO damages (identy, data, canzirh) VALUES (?, ?, ?)",
                { cidid, json.encode(data), json.encode({ can = can, zirh = zirh }) })
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local ped = GetPlayerPed(src)
    local can = GetEntityHealth(ped)
    local zirh = GetPedArmour(ped)
    local cidid = srcs[src .. ""]
    if cidid then
        local result = ExecuteSql("SELECT * FROM damages WHERE identy = ?", { cidid })
        if next(result) then
            ExecuteSql("UPDATE damages SET canzirh = ? WHERE identy = ?",
                { json.encode({ can = can, zirh = zirh }), cidid })
        else
            ExecuteSql(
                "INSERT INTO damages (identy, data, canzirh) VALUES (?, ?, ?)",
                { cidid, json.encode({}), json.encode({ can = can, zirh = zirh }) })
        end
        srcs[src .. ""] = nil
    end
end)

RegisterNetEvent("Sweepz:KullaniciLogIn", function(bool, data)
    local src = source
    local ped = GetPlayerPed(src)
    local can = GetEntityHealth(ped)
    local zirh = GetPedArmour(ped)
    if bool then
        local Player = cubicore.Functions.GetPlayer(src)
        if Player then
            local cidid = Player.PlayerData.citizenid
            if cidid then
                srcs[src .. ""] = cidid
                local result = ExecuteSql("SELECT * FROM damages WHERE identy = ?", { cidid })
                if not next(result) then
                    ExecuteSql(
                        "INSERT INTO damages (identy, data, canzirh) VALUES (?, ?, ?)",
                        { cidid, json.encode(data), json.encode({ can = can, zirh = zirh }) })
                end
                result = ExecuteSql("SELECT * FROM damages WHERE identy = ?", { cidid })
                if next(result) then
                    TriggerClientEvent("Sweepz:VeriIsle", src, result[1])
                    SetPedArmour(ped, json.decode(result[1].canzirh).zirh)
                end
            end
        end
    else
        local cidid = srcs[src .. ""]
        if cidid then
            local result = ExecuteSql("SELECT * FROM damages WHERE identy = ?", { cidid })
            if next(result) then
                ExecuteSql("UPDATE damages SET data = ?, canzirh = ? WHERE identy = ?",
                    { json.encode(data), json.encode({ can = can, zirh = zirh }), cidid })
            else
                ExecuteSql(
                    "INSERT INTO damages (identy, data, canzirh) VALUES (?, ?, ?)",
                    { cidid, json.encode(data), json.encode({ can = can, zirh = zirh }) })
            end
        end
    end
end)
