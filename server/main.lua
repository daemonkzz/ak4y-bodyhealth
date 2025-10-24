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
        cb({success = true, returnData = data})
    else
        cb({success = false})
    end
end)


RegisterNetEvent('ak4y-bodyhealth:injuredRevived', function(data)
    local src = source
    TriggerClientEvent('ak4y-bodyhealth:revivedInjured', tonumber(data), src)
end)



-- revive player
RegisterServerCallback('ak4y-bodyhealth:revivePlayer', function(source, cb, target)
    local source = source
    local neededReviveItems = AK4Y.ReviveItems -- table of items needed to revive player
    if AK4Y.ReviveItemNeeded then 
        local bestItemForRevive = nil -- best reviveChance from neededReviveItems
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
            print( 'Revive chance: ' .. bestItemForRevive.reviveChance)
            local reviveChance = math.random(1, 100)
            if reviveChance <= bestItemForRevive.reviveChance then
                TriggerClientEvent('ak4y-bodyhealth:revivePlayer', target)
                cb({success = true, itemName = bestItemForRevive.name})
            else
                cb({success = false, errorText = AK4Y.Translate.reviveFailed})
            end
        else
            cb({success = false, errorText = AK4Y.Translate.youDontHaveRequiredItem})
        end
    else
        TriggerClientEvent('ak4y-bodyhealth:revivePlayer', target)
        cb({success = true})
    end
end)