local LAM2 = LibAddonMenu2
local LWM   = LeonardosWardrobeManager

-- LAM2 Helpers
function LWM.MakeOutfitDropdown(name, tip, varName, disFunc, alliance)
    outfits, choices = LWM.allOutfits, LWM.allOutfitChoices
    if alliance then outfits, choices = LWM.allAlliedOutfits, LWM.allAlliedOutfitChoices end
    return {
        type = "dropdown",
        name = name,
        tooltip = "The outfit to be worn " .. tip,
        choices = outfits,
        choicesValues = choices,
        getFunc = function() return LWM.vars.outfitIndices[varName] end,
        setFunc = function(var) LWM.SetStateOutfitChoice(varName, var) end,
        disabled = disFunc,
    }
end

function LWM.MakeCheckbox(name, tip, var)
    return {
        type = "checkbox",
        name = name,
        tooltip = tip,
        getFunc = function() return LWM.vars.settings[var] end,
        setFunc = function() LWM.vars.settings[var] = not LWM.vars.settings[var] end,
    }
end

function LWM.MakeDivider() return { type = "divider" } end
function LWM.MakeDescription(dText) return { type = "description", title = nil, text = dText } end
function LWM.MakeSubmenu(name, tip, items) return { type = "submenu", name = name, tooltip = tip, controls = items } end

-- LAM2 Settings
local panelData = {
    type = "panel",
    name = LWM.fullName,
    registerForRefresh = true
}

local optionsData = {
    [1] = LWM.MakeDescription("Use command /lwmfeedback to leave feedback."),
    [2] = LWM.MakeOutfitDropdown("Default", "by default", "default"),
    [3] = LWM.MakeSubmenu("Combat", "Options related to combat and stealth", {
                [1] = LWM.MakeOutfitDropdown("Stealth", "in stealth", "stealth"),
                [2] = LWM.MakeDivider(),
                [3] = LWM.MakeCheckbox("Ability Bar Outfits", "Enable per-bar outfits?", "perBarToggle"),
                [4] = LWM.MakeOutfitDropdown("Combat", "in combat", "combat",
                        function() return LWM.vars.settings.perBarToggle end),
                [5] = LWM.MakeOutfitDropdown("Main Bar", "when using your main ability bar", "mainbar",
                        function() return not LWM.vars.settings.perBarToggle end),
                [6] = LWM.MakeOutfitDropdown("Back Bar", "when using your back ability bar", "backbar",
                        function() return not LWM.vars.settings.perBarToggle end),
    }),
    [4] = LWM.MakeSubmenu("Locations", "Options related to locations", {
        [1] = LWM.MakeOutfitDropdown("Houses", "in houses", "house"),
        [2] = LWM.MakeOutfitDropdown("Dungeons", "in dungeons", "dungeon"),
        [3] = LWM.MakeSubmenu("PVP", "Options related to PVP locations", {
            [1] = LWM.MakeOutfitDropdown("Battlegrounds", "in Battlegrounds", "battleground"),
            [2] = LWM.MakeDivider(),
            [3] = LWM.MakeOutfitDropdown("Cyrodiil", "in Cyrodiil", "cyrodiil"),
            [4] = LWM.MakeOutfitDropdown("Cyrodiil Delves", "in Cyrodiil Delves", "cyrodiil_d"),
            [5] = LWM.MakeOutfitDropdown("Imperial City", "in Imperial City", "imperial"),
            [6] = LWM.MakeOutfitDropdown("Imperial City Sewers", "in Imperial City Sewers", "sewers"),
        }),
        [4] = LWM.MakeSubmenu("Aldmeri Dominion", "Options related to Zones in the Aldmeri Dominion", {
            [1] = LWM.MakeOutfitDropdown("Dominion Default", "in the Aldmeri Dominion", "dominion"),
            [2] = LWM.MakeDivider(),
            [3] = LWM.MakeOutfitDropdown("Auridon", "in Auridon", "auridon", nil, true),
            [4] = LWM.MakeOutfitDropdown("Grahtwood", "in Grahtwood", "grahtwood", nil, true),
            [5] = LWM.MakeOutfitDropdown("Greenshade", "in Greenshade", "greenshade", nil, true),
            [6] = LWM.MakeOutfitDropdown("Khenarthi's Roost", "in Khenarthi's Roost", "khenarthi", nil, true),
            [7] = LWM.MakeOutfitDropdown("Malabal Tor", "in Malabal Tor", "malabal", nil, true),
            [8] = LWM.MakeOutfitDropdown("Reaper's March", "in Reaper's March", "reapers", nil, true),
        }),
        [5] = LWM.MakeSubmenu("Daggerfall Covenant", "Options related to Zones in the Daggerfall Covenant", {
            [1] = LWM.MakeOutfitDropdown("Covenant Default", "in Daggerfall Covenant", "covenant"),
            [2] = LWM.MakeDivider(),
            [3] = LWM.MakeOutfitDropdown("Alik'r Desert", "in Alik'r Desert", "alikr", nil, true),
            [4] = LWM.MakeOutfitDropdown("Bangkorai", "in Bangkorai", "bangkorai", nil, true),
            [5] = LWM.MakeOutfitDropdown("Betnikh", "in Betnikh", "betnikh", nil, true),
            [6] = LWM.MakeOutfitDropdown("Glenumbra", "in Glenumbra", "glenumbra", nil, true),
            [7] = LWM.MakeOutfitDropdown("Rivenspire", "in Rivenspire", "rivenspire", nil, true),
            [8] = LWM.MakeOutfitDropdown("Stormhaven", "in Stormhaven", "stormhaven", nil, true),
            [9] = LWM.MakeOutfitDropdown("Stros M'Kai", "in Stros M'Kai", "stros", nil, true),
        }),
        [6] = LWM.MakeSubmenu("Ebonheart Pact", "Options related to Zones in the Ebonheart Pact", {
            [1] = LWM.MakeOutfitDropdown("Pact Default", "in Ebonheart Pact", "pact"),
            [2] = LWM.MakeDivider(),
            [3] = LWM.MakeOutfitDropdown("Bal Foyen", "in Bal Foyen", "bal", nil, true),
            [4] = LWM.MakeOutfitDropdown("Bleakrock Isle", "in Bleakrock Isle", "bleakrock", nil, true),
            [5] = LWM.MakeOutfitDropdown("Deshaan", "in Deshaan", "deshaan", nil, true),
            [6] = LWM.MakeOutfitDropdown("Eastmarch", "in Eastmarch", "eastmarch", nil, true),
            [7] = LWM.MakeOutfitDropdown("The Rift", "in The Rift", "rift", nil, true),
            [8] = LWM.MakeOutfitDropdown("Shadowfen", "in Shadowfen", "shadowfen", nil, true),
            [9] = LWM.MakeOutfitDropdown("Stonefalls", "in Stonefalls", "stonefalls", nil, true),
        }),
        [7] = LWM.MakeSubmenu("Neutral", "Options related to Neutral Zones", {
            [1] = LWM.MakeOutfitDropdown("Coldharbour", "in Coldharbour", "coldharbour"),
            [2] = LWM.MakeOutfitDropdown("Craglorn", "in Craglorn", "craglorn"),
        }),
        [8] = LWM.MakeSubmenu("Chapter", "Options related to Chapter Zones", {
            [1] = LWM.MakeOutfitDropdown("Artaeum", "in Artaeum", "artaeum"),
            [2] = LWM.MakeOutfitDropdown("Blackreach: Greymoor Caverns", "in Greymoor Caverns", "greymoor"),
            [3] = LWM.MakeOutfitDropdown("Blackwood", "in Blackwood", "blackwood"),
            [4] = LWM.MakeOutfitDropdown("Northern Elsweyr", "in Northern Elsweyr", "nelsweyr"),
            [5] = LWM.MakeOutfitDropdown("Summerset", "in Summerset", "summerset"),
            [6] = LWM.MakeOutfitDropdown("Vvardenfell", "in Vvardenfell", "vvardenfell"),
            [7] = LWM.MakeOutfitDropdown("Western Skyrim", "in Western Skyrim", "skyrim"),
        }),
        [9] = LWM.MakeSubmenu("DLC", "Options related to DLC Zones", {
            [1] = LWM.MakeOutfitDropdown("Blackreach: Arkthzand Cavern", "in Arkthzand Cavern", "arkthzand"),
            [2] = LWM.MakeOutfitDropdown("Clockwork City", "in Clockwork City", "clockwork"),
            [3] = LWM.MakeOutfitDropdown("Gold Coast", "in Gold Coast", "gold"),
            [4] = LWM.MakeOutfitDropdown("Hew's Bane", "in Hew's Bane", "hew"),
            [5] = LWM.MakeOutfitDropdown("Murkmire", "in Murkmire", "murkmire"),
            [6] = LWM.MakeOutfitDropdown("The Reach", "in The Reach", "reach"),
            [7] = LWM.MakeOutfitDropdown("Southern Elsweyr", "in Southern Elsweyr", "selsweyr"),
            [8] = LWM.MakeOutfitDropdown("Wrothgar", "in Wrothgar", "wrothgar"),
        }),
    })
}

-- Init LAM2
function LWM.initSettings()
    LAM2:RegisterAddonPanel("LWMOptions", panelData)
    LAM2:RegisterOptionControls("LWMOptions", optionsData)
end
