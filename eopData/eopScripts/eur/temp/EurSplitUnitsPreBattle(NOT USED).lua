---@diagnostic disable: lowercase-global
-- Pre-battle options module for EUR mod
-- Handles unit splitting functionality before battles

local SplitUnitsPreBattle = {}

-- Constants for unit splitting
local MIN_SOLDIERS_TO_SPLIT = 40 -- Minimum required soldiers in a unit to allow splitting
local DEFAULT_SPLIT_AMOUNT = 20  -- Default number of soldiers to split off
local MAX_ARMY_SIZE = 20         -- Maximum number of units allowed in an army

-- Categories of units that cannot be split
local INVALID_SPLIT_CATEGORIES = {
    "ship",  -- Naval units
    "siege", -- Siege equipment
}

-- Check if a unit can be split based on various conditions
---@param unit unit -- The unit to check for splitting eligibility
---@return boolean -- canSplit Whether the unit can be split
local function canSplitUnit(unit)
    -- Basic validity checks
    if not unit then
        M2TWEOP.logGame("[INFO] PreBattleOptions: Cannot split - unit is nil")
        return false
    end

    -- Skip if unit has a character (general)
    if unit.character then
        M2TWEOP.logGame("[INFO] PreBattleOptions: Cannot split - unit is a general")
        return false
    end

    -- Skip invalid categories (ships, siege equipment)
    if unit.eduEntry then
        for _, category in ipairs(INVALID_SPLIT_CATEGORIES) do
            if unit.eduEntry.category == category then
                M2TWEOP.logGame("[INFO] PreBattleOptions: Cannot split - invalid category: " .. category)
                return false
            end
        end
    else
        M2TWEOP.logGame("[INFO] PreBattleOptions: Cannot split - no eduEntry")
        return false
    end

    -- Check if unit has enough soldiers to split
    if unit.soldierCountStratMap < MIN_SOLDIERS_TO_SPLIT then
        M2TWEOP.logGame("[INFO] PreBattleOptions: Cannot split - not enough soldiers: " .. unit.soldierCountStratMap)
        return false
    end

    return true
end

---@return table<unit> -- splittableUnits
---@return table<string> -- splittableUnitNames
function SplitUnitsPreBattle.GetSplittableUnits()
    local playerArmy = BATTLE:getPlayerArmy(0)

    local splittableUnits = {}
    local splittableUnitNames = {}


    for i = 0, playerArmy.numOfUnits - 1 do
        local unit = playerArmy:getUnit(i)
        if canSplitUnit(unit) then
            table.insert(splittableUnits, unit)
            table.insert(splittableUnitNames, unit.eduEntry.eduType)
        end
    end

    return splittableUnits, splittableUnitNames
end

---@param faction factionStruct
function SplitUnitsPreBattle.InitSplitUnitsUI(faction)
    if faction.isPlayerControlled == 0 then
        return
    end
    -- local playerSide = nil

    -- for s = 1, BATTLE.sidesNum do -- 1-indexed
    --     local isPlayer = false
    --     local side = BATTLE.sides[s]

    --     -- Figure out which side is the player
    --     for f = 0, side.factionCount - 1 do
    --         local fac = side:getFaction(f)
    --         if fac.isPlayerControlled == 1 then
    --             isPlayer = true
    --             break
    --         end
    --     end

    --     if isPlayer then
    --         playerSide = side
    --         break
    --     end
    -- end

    -- if not playerSide then
    --     M2TWEOP.logGame("[ERROR] SplitUnitsPreBattle: No player side found")
    --     return
    -- end
    -- Set the pre-battle state flag

    UIState.PreBattleUI.IsPreBattleState = true
    UIState.PreBattleUI.IsButtonVisible = true
    print("BATTLE PANEL OPEN")
end

---@param unit unit
---@param splitAmount number
function SplitUnitsPreBattle.SplitUnit(unit, splitAmount)
    -- Validate army size
    local playerArmy = BATTLE:getPlayerArmy(0)

    if playerArmy.numOfUnits >= MAX_ARMY_SIZE then
        M2TWEOP.logGame("[INFO] PreBattleOptions: Cannot split - army at maximum size")
        return false
    end

    -- Calculate split amounts
    local originalAmount = unit.soldierCountStratMap - splitAmount
    local newAmount = splitAmount

    -- to adjust for mismatches in real number and soldierCountStratMap
    if originalAmount < 5 then
        M2TWEOP.logGame("[INFO] PreBattleOptions: Cannot split - original amount is less than 0")
        return false
    end

    -- Create new unit with same characteristics
    local newUnit = playerArmy:createUnit(
        unit.eduEntry.eduType,
        unit.exp,
        unit.weaponLVL,
        unit.armourLVL
    )

    -- Set soldier counts for both units
    unit.soldierCountStratMap = originalAmount
    newUnit.soldierCountStratMap = newAmount

    M2TWEOP.logGame("[INFO] PreBattleOptions: Split unit " .. unit.eduEntry.eduType ..
        " into " .. originalAmount .. " and " .. newAmount .. " soldiers")

    return true
end

return SplitUnitsPreBattle
