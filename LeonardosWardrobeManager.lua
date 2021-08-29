-- Main Table
LeonardosWardrobeManager = {}

-- Aliases
local LAM2 = LibAddonMenu2
local LWM = LeonardosWardrobeManager

-- Main Table Details
LWM.name = "LeonardosWardrobeManager"
LWM.fullName = "Leonardo's Wardrobe Manager"
LWM.allOutfits = { "No Outfit"}
LWM.username = "@Leonardo1123"

LWM.variableVersion = 6
LWM.default = {
    defaultOutfit = "No Outfit",
    defaultOutfitIndex = 0,

    combatOutfit = "No Outfit",
    combatOutfitIndex = 0,

    stealthOutfit = "No Outfit",
    stealthOutfitIndex = 0
}

-- Check for optional dependencies
LWM.LibFeedbackInstalled = false

OUTFIT_OFFSET = 1

panelData = {
    type = "panel",
    name = LWM.fullName,
    registerForRefresh = true
}

optionsData = {
    [1] = {
        type = "description",
        title = nil,
        text = "Use command /lwmfeedback to leave feedback.",
        width = "full",
    },
    [2] = {
        type = "dropdown",
        name = "Default Outfit",
        tooltip = "The outfit to be worn by default",
        choices = LWM.allOutfits,
        getFunc = function() return LWM.vars.defaultOutfit end,
        setFunc = function(var) LWM.SetStateOutfitChoice("DEFAULT", var) end,
        reference = "LWM_Default_Dropdown"
    },
    [3] = {
        type = "submenu",
        name = "Combat",
        tooltip = "Options related to combat and stealth", --(optional)
        controls = {
            [1] = {
                type = "dropdown",
                name = "Combat Outfit",
                tooltip = "The outfit to be switched to upon entering combat",
                choices = LWM.allOutfits,
                getFunc = function() return LWM.vars.combatOutfit end,
                setFunc = function(var) LWM.SetStateOutfitChoice("COMBAT", var) end,
                reference = "LWM_Combat_Dropdown"
            },
            [2] = {
                type = "dropdown",
                name = "Stealth Outfit",
                tooltip = "The outfit to be switched to upon entering stealth",
                choices = LWM.allOutfits,
                getFunc = function() return LWM.vars.stealthOutfit end,
                setFunc = function(var) LWM.SetStateOutfitChoice("STEALTH", var) end,
                reference = "LWM_Stealth_Dropdown"
            },
        }
    }
}

function LWM.SetStateOutfitChoice(state, name)
    local index

    if name == "No Outfit" then
        index = 0
    else
        for i=1,GetNumUnlockedOutfits() do
            if GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i) == name then
                index = i
                break
            end
        end
    end

    if state == "DEFAULT" then
        LWM.ChangeOutfit(index)
    end

    local state_d = string.lower(state) .. "Outfit"

    LWM.vars[state_d] = name
    LWM.vars[state_d .. "Index"] = index
end



function LWM.ChangeOutfit(index)
    if index == 0 then
        UnequipOutfit()
    else
        EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, index)
    end
end

function LWM.OnOutfitRenamed(event, response, index)
    for i=1,GetNumUnlockedOutfits() do
        LWM.allOutfits[i + OUTFIT_OFFSET] = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
    end

    if LWM_Default_Dropdown then LWM_Default_Dropdown:UpdateChoices() end
    if LWM_Combat_Dropdown then LWM_Combat_Dropdown:UpdateChoices() end
    if LWM_Stealth_Dropdown then LWM_Stealth_Dropdown:UpdateChoices() end
end

isFirstTimePlayerActivated = true

function LWM.OnPlayerActivated(_, initial)
    if initial then
        if isFirstTimePlayerActivated == false then -- After fast travel
            LWM.ChangeOutfit(LWM.vars.defaultOutfitIndex)
        else -- --------------------------------- after login
            isFirstTimePlayerActivated = false
        end
    else -- ------------------------------------- after reloadui
        isFirstTimePlayerActivated = false
    end
end

function LWM.OnPlayerCombatState(_, inCombat)
    if inCombat ~= LWM.inCombat then
        LWM.inCombat = inCombat
        if LWM.inCombat then
            LWM.ChangeOutfit(LWM.vars.combatOutfitIndex)
        else
            if LWM.inStealth > 0 then
                LWM.ChangeOutfit(LWM.vars.stealthOutfitIndex)
            else
                LWM.ChangeOutfit(LWM.vars.defaultOutfitIndex)
            end
        end
    end
end

function LWM.OnPlayerStealthState(_, unitTag, StealthState)
    if StealthState ~= LWM.inStealth and unitTag == "player" then
        LWM.inStealth = StealthState
        if LWM.inStealth > 0 then
            LWM.ChangeOutfit(LWM.vars.stealthOutfitIndex)
        else
            if LWM.inCombat then
                LWM.ChangeOutfit(LWM.vars.combatOutfitIndex)
            else
                LWM.ChangeOutfit(LWM.vars.defaultOutfitIndex)
            end
        end
    end
end

function LWM.OnPlayerRes(_)
    LWM.ChangeOutfit(LWM.vars.defaultOutfitIndex)
end

function LWM.OnPlayerUseOutfitStation(_)
    for i=1,GetNumUnlockedOutfits() do
        name = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
        if name == "" then
            name = "Outfit " .. tostring(i)
            LWM.allOutfits[(i + OUTFIT_OFFSET)] = name
            RenameOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i, name)
        end
    end
end

function LWM:Initialize()
    LWM.vars = ZO_SavedVars:NewCharacterIdSettings("LWMVars", LWM.variableVersion, nil, LWM.default, GetWorldName())

    local handlers = ZO_AlertText_GetHandlers() -- TODO: Make this safer using code below
    handlers[EVENT_OUTFIT_EQUIP_RESPONSE] = function() end

    --local handlers = ZO_AlertText_GetHandlers()
    --local originalHandler = handlers[EVENT_OUTFIT_CHANGE_RESPONSE]
    --handlers[EVENT_OUTFIT_CHANGE_RESPONSE] = function(result, actorCategory, outfitIndex)
    --    if result == something then
    --        return false -- do not show the alert
    --    else
    --        return originalHandler(result, actorCategory, outfitIndex)
    --    end
    --end

    self.inCombat = IsUnitInCombat("player")
    self.inStealth = GetUnitStealthState("player")

    for i=1,GetNumUnlockedOutfits() do
        self.allOutfits[i + OUTFIT_OFFSET] = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
    end

    if LWM.LibFeedbackInstalled then
        button, LWM.feedback = LibFeedback:initializeFeedbackWindow(
                LWM,
                LWM.fullName,
                WINDOW_MANAGER:CreateTopLevelWindow("LWMDummyControl"),
                LWM.username,
                {CENTER , GuiRoot , CENTER , 10, 10},
                {0,5000,50000},
                "Send feedback or a tip! Please consider reporting any bugs to ESOUI or GitHub as well."
        )
        button:SetHidden(true)

        SLASH_COMMANDS['/lwmfeedback'] = function(_)
            LWM.feedback:SetHidden(false)
        end
    else
        SLASH_COMMANDS['/lwmfeedback'] = function(_)
            d("Install LibFeedback to use this function.")
        end
    end

    LAM2:RegisterAddonPanel("LWMOptions", panelData)
    LAM2:RegisterOptionControls("LWMOptions", optionsData)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OUTFIT_RENAME_RESPONSE, self.OnOutfitRenamed)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, self.OnPlayerStealthState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_REINCARNATED, self.OnPlayerRes)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DYEING_STATION_INTERACT_START , self.OnPlayerUseOutfitStation)
end

function LWM.OnAddOnLoaded(_, addonName)
    if addonName == "LibFeedback" then
        LWM.LibFeedbackInstalled = true
    elseif addonName == LWM.name then
        LWM:Initialize()
        EVENT_MANAGER:UnregisterForEvent(LWM.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(LWM.name, EVENT_ADD_ON_LOADED, LWM.OnAddOnLoaded)