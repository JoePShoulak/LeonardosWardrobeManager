-- Main Table
LeonardosWardrobeManager = LeonardosWardrobeManager or {}
local LWM = LeonardosWardrobeManager

-- Main Table Details
LWM.name            = "LeonardosWardrobeManager"
LWM.fullName        = "Leonardo's Wardrobe Manager"
LWM.author          = "@Leonardo1123"
LWM.variableVersion = 13

LWM.allOutfits              = {"No Outfit"}
LWM.allOutfitChoices        = {0}
LWM.allAlliedOutfits        = {"Alliance Default", "No Outfit"}
LWM.allAlliedOutfitChoices  = {ALLIANCE_DEFAULT, NO_OUTFIT}

-- Check for optional dependencies
LWM.LibFeedbackInstalled = nil ~= LibFeedback

-- Misc. declarations
local OUTFIT_OFFSET                 = 1
local isFirstTimePlayerActivated    = true
local NO_OUTFIT                     = 0
local ALLIANCE_DEFAULT              = -1

LWM.regularOutfits = {
    "default",      "combat",       "mainbar",      "backbar",      "stealth",
    "house",        "dungeon",
    "cyrodiil",     "cyrodiil_d",   "imperial",     "sewers",       "battleground",
    "dominion",     "covenant",     "pact",
    "coldharbour",  "craglorn",
    "artaeum",      "greymoor",     "blackwood",    "nelsweyr",     "summerset",    "vvardenfell",  "skyrim",
    "arkthzand",    "clockwork",    "gold",         "hew",          "murkmire",     "reach",        "selsweyr",     "wrothgar"
}

LWM.allianceOutfits = {
    "auridon",      "grahtwood",    "greenshade",   "khenarthi",    "malabal",      "reapers",
    "alikr",        "bangkorai",    "betnikh",      "glenumbra",    "rivenspire",   "stormhaven",   "stros",
    "bal",          "bleakrock",    "deshaan",      "eastmarch",    "rift",         "shadowfen",    "stonefalls"
}

-- Saved Vars defaults
LWM.default = {
    outfitIndices = {},
    settings = { perBarToggle = false, }
}

for i=1,#LWM.regularOutfits do LWM.default.outfitIndices[LWM.regularOutfits[i]] = NO_OUTFIT end

for i=1,#LWM.allianceOutfits do LWM.default.outfitIndices[LWM.allianceOutfits[i]] = ALLIANCE_DEFAULT end

-- Event functions
function LWM.OnOutfitRenamed(_, _, _)
    name = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)

    for i=1,GetNumUnlockedOutfits() do
        LWM.allOutfits[i + OUTFIT_OFFSET]           = name
        LWM.allAlliedOutfits[i + 2*OUTFIT_OFFSET]   = name
    end
end

function LWM.OnPlayerActivated(_, initial)
    if initial then
        if isFirstTimePlayerActivated == false then -- After fast travel
            LWM.CheckState()
            LWM.ChangeToStateOutfit()
        else -- --------------------------------- after login
            isFirstTimePlayerActivated = false
            LWM.RenameUnnamedOutfits()
            LWM.CheckState()
            LWM.ChangeToStateOutfit()
        end
    else -- ------------------------------------- after reloadui
        isFirstTimePlayerActivated = false
        LWM.RenameUnnamedOutfits()
        LWM.CheckState()
        LWM.ChangeToStateOutfit()
    end
end

function LWM.CheckState()
    inCombat = IsUnitInCombat("player")
    inStealth = GetUnitStealthState("player")

    if inCombat ~= LWM.inCombat then LWM.inCombat = inCombat end
    if inStealth ~= LWM.inStealth and unitTag == "player" then LWM.inStealth = inStealth end
end

function LWM.OnPlayerCombatState(_, inCombat)
    if inCombat ~= LWM.inCombat then
        LWM.inCombat = inCombat
        LWM.ChangeToStateOutfit()
    end
end

function LWM.OnPlayerStealthState(_, unitTag, inStealth)
    if inStealth ~= LWM.inStealth and unitTag == "player" then
        LWM.inStealth = inStealth
        LWM.ChangeToStateOutfit()
    end
end

function LWM.OnPlayerRes(_)
    LWM.CheckState()
    LWM.ChangeToStateOutfit()
end

function LWM.RenameUnnamedOutfits()
    for i=1,GetNumUnlockedOutfits() do
        local name = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
        if name == "" then
            name = "Outfit " .. tostring(i)

            LWM.allOutfits[i + OUTFIT_OFFSET] = name
            LWM.allOutfitChoices[i + OUTFIT_OFFSET] = i
            LWM.allAlliedOutfits[i + 2*OUTFIT_OFFSET] = name
            LWM.allAlliedOutfitChoices[i + 2*OUTFIT_OFFSET] = i
            RenameOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i, name)
        end
    end
end

function LWM.OnPlayerUseOutfitStation(_)
    LWM.RenameUnnamedOutfits()
    LWM.ChangeToLocationOutfit()
end

-- "Main" functions
function LWM:Initialize()
    LWM.vars = ZO_SavedVars:NewCharacterIdSettings("LWMVars", LWM.variableVersion, nil, LWM.default, GetWorldName())

    local handlers = ZO_AlertText_GetHandlers() -- TODO: Make this safer
    handlers[EVENT_OUTFIT_EQUIP_RESPONSE] = function() end

    self.inCombat = IsUnitInCombat("player")
    self.inStealth = GetUnitStealthState("player")

    for i=1,GetNumUnlockedOutfits() do
        local name = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)

        self.allOutfits[i + OUTFIT_OFFSET] = name
        self.allOutfitChoices[i + OUTFIT_OFFSET] = i
        self.allAlliedOutfits[i + 2*OUTFIT_OFFSET] = name
        self.allAlliedOutfitChoices[i + 2*OUTFIT_OFFSET] = i
    end

    if LWM.LibFeedbackInstalled then
        button, LWM.feedback = LibFeedback:initializeFeedbackWindow(
                LWM,
                LWM.fullName,
                WINDOW_MANAGER:CreateTopLevelWindow("LWMDummyControl"),
                LWM.author,
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

    LWM.initSettings()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OUTFIT_RENAME_RESPONSE,         self.OnOutfitRenamed)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED,               self.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE,            self.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED,          self.OnPlayerStealthState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_REINCARNATED,            self.OnPlayerRes)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DYEING_STATION_INTERACT_END,    self.OnPlayerUseOutfitStation)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED,     self.ChangeToStateOutfit)
end

function LWM.OnAddOnLoaded(_, addonName)
    if addonName == LWM.name then
        LWM:Initialize()
        EVENT_MANAGER:UnregisterForEvent(LWM.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(LWM.name, EVENT_ADD_ON_LOADED, LWM.OnAddOnLoaded)
