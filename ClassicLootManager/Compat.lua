-- ============================================================
-- TBC 2.5.5 Compatibility Shim
-- Defines WoW global constants that may be absent on older or
-- version-limited classic clients (e.g., TBC Anniversary 2.5.5).
-- This file must be loaded FIRST, before any other CLM code.
-- ============================================================

-- LE_EXPANSION_* numeric constants.
-- Blizzard's canonical values – safe to define if missing.
LE_EXPANSION_CLASSIC                = LE_EXPANSION_CLASSIC                or 0
LE_EXPANSION_BURNING_CRUSADE        = LE_EXPANSION_BURNING_CRUSADE        or 1
LE_EXPANSION_WRATH_OF_THE_LICH_KING = LE_EXPANSION_WRATH_OF_THE_LICH_KING or 2
LE_EXPANSION_CATACLYSM              = LE_EXPANSION_CATACLYSM              or 3
LE_EXPANSION_MISTS_OF_PANDARIA      = LE_EXPANSION_MISTS_OF_PANDARIA      or 4
LE_EXPANSION_WARLORDS_OF_DRAENOR    = LE_EXPANSION_WARLORDS_OF_DRAENOR    or 5
LE_EXPANSION_LEGION                 = LE_EXPANSION_LEGION                 or 6
LE_EXPANSION_BATTLE_FOR_AZEROTH     = LE_EXPANSION_BATTLE_FOR_AZEROTH     or 7
LE_EXPANSION_SHADOWLANDS            = LE_EXPANSION_SHADOWLANDS            or 8
LE_EXPANSION_DRAGONFLIGHT           = LE_EXPANSION_DRAGONFLIGHT           or 9
LE_EXPANSION_WAR_WITHIN             = LE_EXPANSION_WAR_WITHIN             or 10

-- Enum namespace – may be absent or incomplete on TBC clients.
if not Enum then
    Enum = {}
end

-- Enum.SeasonID – used by IsClassicEra() / IsSoD() checks.
if not Enum.SeasonID then
    Enum.SeasonID = {
        NoSeason          = 0,
        SeasonOfDiscovery = 2,
    }
end

-- Enum.LootMethod – used when building loot-method sets.
-- On TBC the old GetLootMethod() returns strings ("master", "group", …),
-- so populate with the numeric values retail uses but guard so we never
-- overwrite the real table if the client already provides it.
if not Enum.LootMethod then
    Enum.LootMethod = {
        FreeForAll  = 0,
        RoundRobin  = 1,
        MasterLoot  = 2,   -- "master" string in classic
        Group       = 3,   -- "group"  string in classic
        -- Keep both spelling variants present so the Set() helper is happy.
        Masterlooter = 2,
    }
end

-- Enum.TooltipDataType – used by the tooltip post-call hook.
-- Protected behind an existence check in Tooltips.lua already;
-- supply a stub so bare Enum.TooltipDataType references don't error.
if not Enum.TooltipDataType then
    Enum.TooltipDataType = {
        Item = 1,
    }
end

-- Settings.OpenToCategory – retail replacement for
-- InterfaceOptionsFrame_OpenToCategory; MinimapIcon.lua falls back
-- gracefully with `or`, but let's ensure Settings at least exists.
if not Settings then
    Settings = {}
end

-- C_AddOns – Utils.lua falls back to this if GetAddOnInfo is missing.
-- In TBC the global GetAddOnInfo() exists, so C_AddOns is only
-- referenced if GetAddOnInfo is nil. Provide an empty stub to avoid a
-- nil-index error on the right-hand side of the `or`.
if not C_AddOns then
    C_AddOns = {}
end

-- C_Container – similarly guarded in Utils.lua.
if not C_Container then
    C_Container = {}
end

-- C_PartyInfo – guarded in Utils.lua.
if not C_PartyInfo then
    C_PartyInfo = {}
end

-- C_Item – guarded in Utils.lua.
if not C_Item then
    C_Item = {}
end
