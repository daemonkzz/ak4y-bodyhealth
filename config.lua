AK4Y = {}
AK4Y.Framework = "qb" -- "qb"  /  "esx"

AK4Y.CheckPlayerCommand = "checkplayerhealth" -- If you want to change check player health command, you can change this value.
AK4Y.CheckPlayerCommand2 = "checkYourself" -- If you want to change check player health command, you can change this value.
AK4Y.CheckPlayerKey = "F6" -- If you want to change check player health key, you can change this value.

AK4Y.DisarmPed = true -- If player get damage from arms, player will disarm.
AK4Y.DisarmPedArmHealth = 50 -- If player arm health is less than this value, player will disarm.

AK4Y.PlayerRagdoll = true -- If player get damage from legs and if players run, player will ragdoll.

AK4Y.Bleeding = true -- If player get damage, player will start bleeding.
AK4Y.BleedingDecreaseAllPartHealth = 0.5 -- All part health will decrease this value every second.
AK4Y.BleedingIfThisPartGetDamage = "Body" -- Head, Body, LeftArm, RightArm, LeftLeg, RightLeg
AK4Y.BleedingStopHealth = 50 -- If player health is more than this value, bleeding will stop.
AK4Y.BleedingTime = 10 -- Bleeding time in seconds.
AK4Y.BleedingScreenEffect = true -- If player bleeding, screen will be red.

AK4Y.AllPartDamageWhenFatalDamage = true -- If player get fatal damage, all part will get damage.
AK4Y.FatalDamageRandom = { min = 10 , max = 70 } -- If player get fatal damage, all part health will be random value between min and max.

AK4Y.FullHealthOnRevive = true -- If player revived, player will get full health for all parts.
AK4Y.ReviveItemNeeded = true -- If player want to revive player, player must have item.

AK4Y.ReviveItems = { -- If player want to revive player, player must have this items.
    ["bandage"] = {
        name = "bandage", -- item name
        reviveChance = 50,
    },
    ["medikit"] = {
        name = "medikit", -- item name
        reviveChance = 100,
    }
}

-- FOR ESX: esx_ambulancejob:revive
AK4Y.PartHealthNeededForRevive = false -- If player want to revive player, player must have part health.
AK4Y.MinimumAllPartHealthForRevive = 50 -- All part health must be more than this value to revive player.

AK4Y.DoctorItems = {
    ["bandage"] = {
        image = "img/bandage.png",
        label = "Bandage",
        itemName = "bandage",
        healPart = 25,
        healGeneral = 0,
        description = "Bandage protects wounds, supports healing.",
        stopBleeding = false,
    },
    ["firstaid"] = {
        image = "img/firstaid.png",
        label = "Medikit",
        itemName = "firstaid",
        healPart = 85,
        healGeneral = 0,
        description = "First aid saves lives, stabilizes emergencies.",
        stopBleeding = false,
    }
}

AK4Y.AllowedJobs = {
    "ambulance",
    "police",
}

AK4Y.RevivePlayer = function()
    if AK4Y.Framework == "qb" then
        TriggerEvent("hospital:client:Revive")
    elseif AK4Y.Framework == "esx" then
        TriggerEvent("esx_ambulancejob:revive") -- esx_ambulancejob:revive
    else
        print("You can fill the RevivePlayer function for your framework.")
    end
end

AK4Y.Translate = {
    --UI--
    title1 = "LOS SANTOS EMERGENCY",
    title2 = "Body Health System",
    healingItemYouHave = "Healing item you have",
    healthOfBodyParts = "Health of body parts",
    head = "Head",
    body = "Body",
    leftArm = "Left Arm",
    rightArm = "Right Arm",
    leftLeg = "Left Leg",
    rightLeg = "Right Leg",
    warn1 = "Lorem ipsum dolor, sit amet consectetur adipisicing elit. Hic vitae solu",
    warn2 = "Lorem ipsum dolor, sit amet consectetur adipisicing elit. Hic vitae solu",
    damageStatus = "Damage Status",
    damageSource = "Damage Source",
    revive = "Revive",
    health = "Health",

    ---------
    youAreDead = "You are dead.",
    notDoctor = "You are not a doctor.",
    unknownWeapon = "Unknown weapon",
    unknownMeleeWeapon = "Unknown melee weapon",
    vehicle = "Vehicle",
    unknown = "Unknown",
    youDontHaveItem = "You don't have item",
    youCantRevive = "You can't revive this player, all parts should be more healthier", -- all part health must be more than 50
    reviveFailed = "Revive failed",
    youDontHaveRequiredItem = "You don't have required item to revive player",

}

AK4Y.ZombieDamage = {
    min = 3, -- Zombi vuruşu başına minimum hasar
    max = 8, -- Zombi vuruşu başına maksimum hasar
    BleedChance = 15 -- Zombi vuruşunun kanamaya neden olma şansı (% olarak, 1-100 arası)
}