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

    LWM.vars[state] = index
end

function LWM.ChangeOutfit(index)
    if index == 0 then
        UnequipOutfit()
    else
        EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, index)
    end
end

function LWM.ChangeToCombatOutfit()
    if LWM.inCombat then
        if LWM.vars.perBarToggle then
            local weaponPair, _ = GetActiveWeaponPairInfo()
            local mainBar = (weaponPair == 1)

            if mainBar then
                LWM.ChangeOutfit(LWM.vars.outfitIndices.mainBar)
            else
                LWM.ChangeOutfit(LWM.vars.outfitIndices.backBar)
            end
        else
            LWM.ChangeOutfit(LWM.vars.outfitIndices.combat)
        end
    end
end

function LWM.ChangeToZoneOutfit()
    local allZoneIds = LWM.GetAllZoneIds()

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if zoneId ~= GetParentZoneId(zoneId) then
        zoneId = GetParentZoneId(zoneId)
    end

    local outfit, alliance = allZoneIds[zoneId]

    if outfit ~= -1 then
        LWM.ChangeOutfit(outfit)
    else
        if alliance=="dominion" then
            LWM.ChangeOutfit(LWM.vars.outfitIndices.dominion)
        elseif alliance=="covenant" then
            LWM.ChangeOutfit(LWM.vars.outfitIndices.covenant)
        elseif alliance=="pact" then
            LWM.ChangeOutfit(LWM.vars.outfitIndices.pact)
        end
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