local LWM = LeonardosWardrobeManager

-- Helper functions
function LWM.GetAbilityName(rawSlot, bar)
    bar = bar or HOTBAR_CATEGORY_PRIMARY
    local slot = rawSlot + 2

    local id = GetSlotBoundId(slot, bar)
    local name = GetAbilityName(id)

    return name
end

function LWM.CheckForNoDuration(slot, bar)
    bar = bar or HOTBAR_CATEGORY_PRIMARY
    slot = slot + 2

    local id = GetSlotBoundId(slot, bar)
    local duration = GetAbilityDuration(id)

    return duration == 0
end

function LWM.SetStateOutfitChoice(state, index)
    if state == "default" then
        LWM.ChangeOutfit(index)
    end

    LWM.vars.outfitIndices[state] = index
end

function LWM.ChangeOutfit(index)
    if index == 0 then
        UnequipOutfit()
    else
        EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, index)
    end
end

function LWM.ChangeToStateOutfit()
    if LWM.inCombat then
        if LWM.vars.settings.perBarToggle then
            local weaponPair, _ = GetActiveWeaponPairInfo()
            local mainBar = (weaponPair == 1)

            if mainBar then
                LWM.ChangeOutfit(LWM.vars.outfitIndices.mainbar)
            else
                LWM.ChangeOutfit(LWM.vars.outfitIndices.backbar)
            end
        else
            LWM.ChangeOutfit(LWM.vars.outfitIndices.combat)
        end
    elseif LWM.inStealth > 0 then
        LWM.ChangeOutfit(LWM.vars.outfitIndices.stealth)
    else
        LWM.ChangeToLocationOutfit()
    end
end

function LWM.ChangeToZoneOutfit()
    local allZoneIds = LWM.GetAllZoneIds()

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if zoneId ~= GetParentZoneId(zoneId) then
        zoneId = GetParentZoneId(zoneId)
    end

    local zone = allZoneIds[zoneId]
    local outfit = zone.outfit

    if outfit ~= -1 then
        LWM.ChangeOutfit(outfit)
    elseif alliance then
        if alliance=="dominion" then
            LWM.ChangeOutfit(LWM.vars.outfitIndices.dominion)
        elseif alliance=="covenant" then
            LWM.ChangeOutfit(LWM.vars.outfitIndices.covenant)
        elseif alliance=="pact" then
            LWM.ChangeOutfit(LWM.vars.outfitIndices.pact)
        end
    else
        LWM.ChangeOutfit(LWM.vars.outfitIndices.default)
    end
end

function LWM.ChangeToLocationOutfit()
    if GetCurrentZoneHouseId() ~= 0 then
        LWM.ChangeOutfit(LWM.vars.outfitIndices.house)
    elseif IsActiveWorldBattleground() then
        LWM.ChangeOutfit(LWM.vars.outfitIndices.battleground)
    elseif IsPlayerInAvAWorld() then
        if IsInCyrodiil() then
            LWM.ChangeOutfit(LWM.vars.outfitIndices.cyrodil)
        elseif IsInImperialCity() then
            if GetCurrentMapIndex() then
                LWM.ChangeOutfit(LWM.vars.outfitIndices.imperial)
            else
                LWM.ChangeOutfit(LWM.vars.outfitIndices.sewers)
            end
        else
            LWM.ChangeOutfit(LWM.vars.outfitIndices.cyrodil_d)
        end
    elseif IsUnitInDungeon("player") then
        LWM.ChangeOutfit(LWM.vars.outfitIndices.dungeon)
    else
        LWM.ChangeToZoneOutfit()
    end
end