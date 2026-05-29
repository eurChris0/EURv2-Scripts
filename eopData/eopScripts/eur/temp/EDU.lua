EDU_MODIFIERS = {
    moveSpeedText = "\n• Movement Speed: ",
    freeUpkeepText = "\n• Free upkeep",
    generalsUnitText = "\n• General's Bodyguard",
    relentlessText = "\n• Relentless",
    rangeText = "\n• Range: ",
    ammoText = "\n• Missiles: ",
    bpRangeText = "\n• Body Piercing Missiles",
    apRangeText = "\n• Armour Piercing Missiles",
    gunpowderText = "\n• Gunpowder Unit",
    apSecText = "\n• Armour Piercing Secondary",
    secAttText = "\n• Secondary Attack: ",
    lockMoraleText = "\n• Morale: Unbreakable",
    moraleResText = "\n• Morale Response: ",
    poisonArrowText = "\n• Poison Arrows",
    fireArrowText = "\n• Fire Arrows",
    deadlyPoisonArrowText = "\n• Deadly Poison Arrows",
    moraleText = "\n• Morale: ",
    accuracyText = "\n• Accuracy: ",
    trainingText = "\n• Training: ",
    wargText = "\n• Bonus damage vs. cavalry",
    terrain = {
        bonusText = "\n• Terrain Bonus: ",
        malusText = "\n• Terrain Malus: ",
        scrubText = "Shrubs",
        sandText = "Barren",
        forestText = "Forest",
        snowText = "Snow",
    },
    training = {
        { text = "Untrained",      training = 1 },
        { text = "Trained",        training = 2 },
        { text = "Highly Trained", training = 3 },
    },
    moraleResponse = {
        { text = "Poor",      discipline = 1 },
        { text = "Average",   discipline = 2 },
        { text = "Good",      discipline = 3 },
        { text = "Very Good", discipline = 4 },
    },
    accuracy = {
        { text = "Abysmal",     min = 0.080, max = 1.0 },
        { text = "Low",         min = 0.070, max = 0.080 },
        { text = "Average",     min = 0.055, max = 0.070 },
        { text = "High",        min = 0.045, max = 0.055 },
        { text = "Very High",   min = 0.025, max = 0.045 },
        { text = "Exceptional", min = 0.015, max = 0.025 },
        { text = "Legendary",   min = 0.0,   max = 0.015 },
    },
    morale = {
        { text = "Abysmal",    min = 0,  max = 5 },
        { text = "Poor",       min = 6,  max = 7 },
        { text = "Average",    min = 8,  max = 9 },
        { text = "Fair",       min = 10, max = 11 },
        { text = "Good",       min = 12, max = 13 },
        { text = "Very Good",  min = 14, max = 15 },
        { text = "Excellent",  min = 16, max = 17 },
        { text = "Unwavering", min = 18, max = 64 },
    },
    pikemenAnims = {
        "MTW2_Slow_Pike",
        "MTW2_Dwarf_Pike",
        "MTW2_Dwarf_Pike_primary",
        "MTW2_Dwarf_Slow_Pike",
        "MTW2_Pike",
    },
    relentlessAnims = {
        "MTW2_Mace_no_stun",
        "MTW2_Giant_no_stun",
        "DaC_Nazg-hai_no_knock",
        "DaC_Nazg-hai_no_def_no_knock",
        "MTW2_Dwarf_2H_Axe_relentless",
        "MTW2_Dwarf_Mace_relentless",
    },
    wargMounts = {
        "mount_light_wolf",
        "mount_light_wolf_goblin",
        "indep_warg",
        "warg_camel",
    },
    effectText = "",
}


-- Function to convert a Lua table to CSV
function tableToCSVString(dataTable)
    local csv = {}

    for key, value in pairs(dataTable) do
        table.insert(csv, tostring(value))
    end

    -- Return the concatenated string
    return table.concat(csv, ", ")
end

-- Are you deranged??
---@param entry eduEntry
function EDU_MODIFIERS:isRanged(entry)
    if entry.primaryStats.isMissile or entry.secondaryStats.isMissile or entry.engineStats.isMissile then
        return true
    else
        return false
    end
end

-- Function to apply accuracy modifiers
---@param entry eduEntry
function EDU_MODIFIERS:applyRangedModifiers(entry)
    -- Accuracy
    if not entry.engineStats.isValid then
        local projectile = entry.primaryStats.projectile or entry.secondaryStats.projectile

        local name = projectile.name
        if string.find(name, "poison") then
            if string.find(name, "deadly") then
                self.effectText = self.effectText .. self.deadlyPoisonArrowText
            else
                self.effectText = self.effectText .. self.poisonArrowText
            end
        elseif string.find(name, "rhun_elite_arrow") then
            self.effectText = self.effectText .. self.fireArrowText
        end

        local unitAccuracy = projectile.accuracy
        for _, accuracy in ipairs(EDU_MODIFIERS.accuracy) do
            if unitAccuracy >= accuracy.min and unitAccuracy <= accuracy.max then
                self.effectText = self.effectText .. self.accuracyText .. accuracy.text
                break
            end
        end
    end

    -- Ranged AP
    if (entry.primaryStats.isAP and entry.primaryStats.projectile) or (entry.secondaryStats.isAP and entry.secondaryStats.projectile) or (entry.engineStats.isAP) then
        self.effectText = self.effectText .. self.apRangeText
    end

    -- Ranged BP
    if (entry.primaryStats.isBP and entry.primaryStats.projectile) or (entry.secondaryStats.isBP and entry.secondaryStats.projectile) or (entry.engineStats.isBP) then
        self.effectText = self.effectText .. self.bpRangeText
    end

    -- Range
    if entry.engineStats.range > 1 then
        self.effectText = self.effectText .. EDU_MODIFIERS.rangeText .. entry.engineStats.range
    elseif entry.primaryStats.range > 1 then
        self.effectText = self.effectText .. EDU_MODIFIERS.rangeText .. entry.primaryStats.range
    elseif entry.secondaryStats.range > 1 then
        self.effectText = self.effectText .. EDU_MODIFIERS.rangeText .. entry.secondaryStats.range
    end

    -- Ammo
    if entry.engineStats.ammo > 1 then
        self.effectText = self.effectText .. EDU_MODIFIERS.ammoText .. entry.engineStats.ammo
    elseif entry.primaryStats.ammo > 1 then
        self.effectText = self.effectText .. EDU_MODIFIERS.ammoText .. entry.primaryStats.ammo
    end
end

-- Function to apply morale modifiers
---@param entry eduEntry
function EDU_MODIFIERS:applyMoraleModifiers(entry)
    -- Locked Morale
    if entry.moraleLocked then
        self.effectText = self.effectText .. self.lockMoraleText
        return
    end

    -- Base Morale
    if entry.morale then
        for _, moraleTier in ipairs(EDU_MODIFIERS.morale) do
            if entry.morale >= moraleTier.min and entry.morale <= moraleTier.max then
                self.effectText = self.effectText .. self.moraleText .. moraleTier.text .. " (" .. tostring(entry.morale) .. ")"
                break
            end
        end
    end

    -- Morale Response
    if entry.discipline then
        for _, moraleTier in ipairs(EDU_MODIFIERS.moraleResponse) do
            if entry.discipline == moraleTier.discipline then
                self.effectText = self.effectText .. self.moraleResText .. moraleTier.text
                break
            end
        end
    end

    -- Training
    -- if entry.training then
    --     for _, training in ipairs(EDU_MODIFIERS.training) do
    --         if training ~= 2 then
    --             self.effectText = self.effectText .. self.trainingText .. training.text
    --             break
    --         end
    --     end
    -- end
end

-- Function to apply terrain modifiers
---@param entry eduEntry
function EDU_MODIFIERS:applyTerrainModifiers(entry)
    local bonusTerrain = {}
    local malusTerrain = {}
    local bonusThreshold = 1
    local malusThreshold = -1

    -- ;stat_ground - scrub, sand, forest, snow
    if entry.statScrub > bonusThreshold then
        table.insert(bonusTerrain, self.terrain.scrubText)
    elseif entry.statScrub < malusThreshold then
        table.insert(malusTerrain, self.terrain.scrubText)
    end

    if entry.statSand > bonusThreshold then
        table.insert(bonusTerrain, self.terrain.sandText)
    elseif entry.statSand < malusThreshold then
        table.insert(malusTerrain, self.terrain.sandText)
    end

    if entry.statForest > bonusThreshold then
        table.insert(bonusTerrain, self.terrain.forestText)
    elseif entry.statForest < malusThreshold then
        table.insert(malusTerrain, self.terrain.forestText)
    end

    if entry.statSnow > bonusThreshold then
        table.insert(bonusTerrain, self.terrain.snowText)
    elseif entry.statSnow < malusThreshold then
        table.insert(malusTerrain, self.terrain.snowText)
    end

    if #bonusTerrain > 0 then
        self.effectText = self.effectText .. self.terrain.bonusText .. tableToCSVString(bonusTerrain)
    end
    if #malusTerrain > 0 then
        self.effectText = self.effectText .. self.terrain.malusText .. tableToCSVString(malusTerrain)
    end
end

---@param entry eduEntry
function EDU_MODIFIERS:addEffects(entry)
    if not entry then return end
    self.effectText = ""
    local flavourText = entry.localizedDescription
    if flavourText == "" then
        --log("ERROR: EDU_MODIFIERS:addEffects() - No flavour text found for " .. entry.eduType .. ". Unit description likely has an escape character like '\' when '\n' was expected.", logLevel.ERROR)
    end
    entry.localizedDescription = ""

    local localname = entry.localizedName
    localname = (string.gsub(localname, " Garrison", ""))
    entry.localizedName = localname

    -- Add text for special unit types
    -- General's Bodyguard
    if entry.generalUnit or entry:hasAttribute("general_unit") or entry:hasAttribute("bodyguard_unit") then
        self.effectText = self.effectText .. EDU_MODIFIERS.generalsUnitText
    end
    -- Relentless
    if tableContainsElement(self.relentlessAnims, entry.primaryAnim)
        or tableContainsElement(self.relentlessAnims, entry.secondaryAnim) then
        self.effectText = self.relentlessText .. self.effectText
    end

    -- Secondary AP
    if entry.secondaryStats and entry.secondaryStats.isAP then
        self.effectText = self.effectText .. EDU_MODIFIERS.apSecText
    end

    -- Free Upkeep
    if entry.freeUpkeepUnit then
        self.effectText = self.effectText .. EDU_MODIFIERS.freeUpkeepText
    end

        if entry.hardy then
            --self.effectText = self.effectText .. "\n• Hardy"
        end

        if entry.veryHardy then
            --self.effectText = self.effectText .. "\n• Very Hardy"
        end

    -- Warg
    if entry.mount and entry.mount.name and tableContainsElement(self.wargMounts, entry.mount.name) then
        self.effectText = self.effectText .. EDU_MODIFIERS.wargText
    end
    -- Gunpowder (Don't need this in DaC)
    -- if entry.gunpowderUnit then
    --     self.effectText = self.effectText .. EDU_MODIFIERS.gunpowderText
    -- end

    -- Movement Speed
    if entry.moveSpeedMod ~= 1 then
        self.effectText = self.effectText .. EDU_MODIFIERS.moveSpeedText .. string.format("%.0f%%", entry.moveSpeedMod * 100)
    end

    -- Ranged stuff
    if self:isRanged(entry) then
        EDU_MODIFIERS:applyRangedModifiers(entry)
    end

    -- Apply morale modifiers
    EDU_MODIFIERS:applyMoraleModifiers(entry)

    -- Apply terrain modifiers
    EDU_MODIFIERS:applyTerrainModifiers(entry)

    -- Update desc.
    self.effectText = self.effectText .. "\n\n"
    entry.localizedDescription = self.effectText .. flavourText
    entry.localizedDescription = entry.localizedDescription:sub(2)
end

function removeFreeUPText()
    for i = 0, 1500 do
        local entry = M2TWEOPDU.getEduEntry(i)
        if entry ~= nil then
            if not entry.freeUpkeepUnit then
                local nametext = entry.localizedDescription
                nametext = (string.gsub(nametext, "• Free upkeep", ""))
                entry.localizedDescription = nametext
            end
        end
    end
end

function EDU_MODIFIERS:updateDescriptions()
    if EDUDescSet then return end
    --log("EDU_MODIFIERS:updateDescriptions() - Start")
    -- Iterate through all eduEntries
    for i = 0, 1500 do
        local entry = M2TWEOPDU.getEduEntry(i)
        if entry ~= nil then
            self:addEffects(entry)
        end
    end

    for i = 4990, 5020 do
        local entry = M2TWEOPDU.getEduEntry(i)
        if entry ~= nil then
            self:addEffects(entry)
        end
    end

    --[[for k, v in pairs(EOP_EDU.eopUnits) do
        local entry = M2TWEOPDU.getEopEduEntryByID(v.index)
        if not string.find(entry.localizedDescription, "Morale: ") then
            self:addEffects(entry)
        end
    end]]
    --log("EDU_MODIFIERS:updateDescriptions() - Done")
    EDUDescSet = true
end

-- EDU_MODIFIERS:updateDescriptions()
