NAZGUL = {
    data = {
        ---@type table<string, nazgulData>
        characters = {

        },
        ---@type table<string, boolean>
        factions = {
        },
        enabled = true,
        isengardTimer = 0,
    },
    RESPAWN_TIME = 15,
}

function NAZGUL:initData()
    self.data = {
        characters = {

        },
        factions = {
        },
        enabled = true,
        isengardTimer = 0,
    }
    self:init()
end

---@class (exact) nazgulData
---@field name string The name of the Nazgul
---@field localName string The localized name of the Nazgul
---@field index integer The index of the Nazgul (-1 by default)
---@field indexLetter string The letter associated with the index
---@field traits? table<string, integer> Traits of the Nazgul with their levels
---@field ancillaries table<string> List of ancillaries associated with the Nazgul
---@field ownerFaction? string The faction owning the Nazgul
---@field deathTurn? integer The turn when the Nazgul died (-1 by default)
---@field model? string The model used for the Nazgul
---@field ability? string The ability of the Nazgul
---@field unit string The unit associated with the Nazgul
---@field stratModel? string The stratModel associated with the Nazgul
---@field spawnCounter? integer The spawn counter
---@field playerCounter? integer The player-specific counter
---@field isengardCounter? integer The Isengard-specific counter
---@field descriptionMessage string Description message of the Nazgul
---@field returnMessage? string Return message for the Nazgul
---@field messageShown? boolean Whether the message was shown
---@field spawnCount? integer The spawn count
---@field checkForSpawn? fun(self)
---@field spawn? fun(self): nazgul: characterRecord
---@field respawn? fun(self): nazgul: characterRecord
---@field getSpawnCoords? fun(self): x: integer, y: integer
---@field bringBack? fun(self)
---@field mordorPlayer? fun(self, nazgul: characterRecord)
---@field new? fun(self: nazgulData, o: nazgulData):nazgulData
---@field __index? any
nazgulData = {}

---@param o nazgulData
---@return nazgulData
function nazgulData:new(o)
    o = o or {}
    o.name = o.name or ""
    o.localName = o.localName or ""
    o.index = o.index or -1
    o.indexLetter = o.indexLetter or ""
    o.traits = o.traits or {
        HeroAbilityNazgul = 1,
        BattleFear = 2,
        GoodCommander = 2,
        GoodAttacker = 1,
    }
    o.ancillaries = o.ancillaries or {
        "nazgul_sword",
    }
    o.ownerFaction = o.ownerFaction or "england"
    o.deathTurn = o.deathTurn or -1
    o.stratModel = o.stratModel or "nazgul"
    o.model = o.model or "mounted_nazgul"
    o.ability = o.ability or "Terror_of_the_Nazgul"
    o.unit = o.unit or ""
    o.spawnCounter = o.spawnCounter or 0
    o.playerCounter = o.playerCounter or 0
    o.isengardCounter = o.isengardCounter or 0
    o.descriptionMessage = o.descriptionMessage or ""
    o.returnMessage = o.returnMessage or ""
    o.messageShown = o.messageShown or false
    o.spawnCount = o.spawnCount or 1
    setmetatable(o, self)
    self.__index = self
    return o
end

function NAZGUL:reload()
    for key, nazgulEntry in pairs(self.data.characters) do
        self.data.characters[key] = nazgulData:new(nazgulEntry)
    end
end

function NAZGUL:isenSpawnNazgul(indexletter)
    self.data.characters["Nazgul" .. indexletter].ownerFaction = F_ISENGARD.name
    local nazgul = getnamedCharbyLabel("real_nazgul" .. indexletter)
    if nazgul and nazgul:isOffMap() then
        self.data.characters["Nazgul" .. indexletter]:spawn()
    else
        self.data.characters["Nazgul" .. indexletter]:respawn()
    end
end

function NAZGUL:isengardSpawns()
    if self.data.isengardTimer == 0 then
        self.data.characters["Nazgula"].unit = "Nazg Hai"
        self.data.characters["Nazgulb"].unit = "Nazg Hai"
        self.data.characters["Nazgulc"].unit = "Nazg Hai"
        self.data.characters["Nazguld"].unit = "Nazg Hai"
        self.data.characters["Nazgule"].unit = "Nazg Hai"
        self.data.characters["Nazgulf"].unit = "Nazg Hai"
        self.data.characters["Nazgulg"].unit = "Nazg Hai"
        self.data.characters["Nazgulh"].unit = "Nazg Hai"
        self.data.characters["Nazguli"].unit = "Nazg Hai"
        self.data.characters["Nazgula"].ownerFaction = F_ISENGARD.name
        self.data.characters["Nazgulb"].ownerFaction = F_ISENGARD.name
        self.data.characters["Nazgulc"].ownerFaction = F_ISENGARD.name
        self.data.characters["Nazguld"].ownerFaction = F_ISENGARD.name
        self.data.characters["Nazgule"].ownerFaction = F_ISENGARD.name
        self.data.characters["Nazgulf"].ownerFaction = F_ISENGARD.name
        self.data.characters["Nazgulg"].ownerFaction = F_ISENGARD.name
        self.data.characters["Nazgulh"].ownerFaction = F_ISENGARD.name
        self.data.characters["Nazguli"].ownerFaction = F_ISENGARD.name
        self:isenSpawnNazgul("a")
    end
    if self.data.isengardTimer == 1 then
        self:isenSpawnNazgul("b")
    end
    if self.data.isengardTimer == 2 then
        self:isenSpawnNazgul("c")
    end
    if self.data.isengardTimer == 3 then
        self:isenSpawnNazgul("d")
    end
    if self.data.isengardTimer == 4 then
        self:isenSpawnNazgul("e")
    end
    if self.data.isengardTimer == 5 then
        self:isenSpawnNazgul("f")
    end
    if self.data.isengardTimer == 6 then
        self:isenSpawnNazgul("g")
    end
    if self.data.isengardTimer == 7 then
        self:isenSpawnNazgul("h")
    end
    if self.data.isengardTimer == 8 then
        self:isenSpawnNazgul("i")
    end
    self.data.isengardTimer = self.data.isengardTimer + 1
end

function NAZGUL:init()
    self.data.characters = {
        Nazgula = nazgulData:new {
            name = "Nazgula",
            localName = "The Witch-king",
            index = 1,
            indexLetter = "a",
            returnMessage = "nazgul_return_5",
            traits = {
                HeroAbilityWitchKing = 1,
                BattleFear = 3,
                GoodCommander = 4,
                GoodAttacker = 3,
            },
            ancillaries = {
                "ring_witchking",
                "witchking_flail",
                "witchking_helmet",
            },
            model = "witchking",
            ability = "Terror_of_the_Witch_King",
            unit = "Temple War Lords",
            playerCounter = 48,
            descriptionMessage = "witch_king",
            stratModel = "witchking",
        },
        Nazgulb = nazgulData:new {
            name = "Nazgulb",
            localName = "Gan Altan",
            index = 2,
            indexLetter = "b",
            returnMessage = "nazgul_return_4",
            ancillaries = {
                "nazgul_sword",
                "ring_nazgulb",
            },
            unit = "Temple War Champions",
            playerCounter = 38,
            descriptionMessage = "gan_altan",
        },
        Nazgulc = nazgulData:new {
            name = "Nazgulc",
            localName = "Balak’nar",
            index = 3,
            indexLetter = "c",
            returnMessage = "nazgul_return_3",
            ancillaries = {
                "nazgul_sword",
                "ring_nazgulc",
            },
            unit = "Temple War Priests",
            playerCounter = 28,
            descriptionMessage = "balaknar",
        },
        Nazguld = nazgulData:new {
            name = "Nazguld",
            localName = "Khamûl",
            index = 4,
            indexLetter = "d",
            traits = {
                HeroAbilityNazgul = 1,
                BattleFear = 2,
                GoodCommander = 4,
                GoodAttacker = 2,
            },
            ancillaries = {
                "nazgul_sword",
                "ring_nazguld",
            },
            ownerFaction = F_DOLGULDUR.name,
            unit = "Khamuls Shadow Lancers",
            descriptionMessage = "khamul",
            model = "khamul",
            stratModel = "khamul",
        },
        Nazgule = nazgulData:new {
            name = "Nazgule",
            localName = "Lagoren",
            index = 5,
            indexLetter = "e",
            ancillaries = {
                "nazgul_sword",
                "ring_nazgule",
            },
            ownerFaction = F_DOLGULDUR.name,
            unit = "Khamuls Shadow Blades",
            descriptionMessage = "lagoren",
        },
        Nazgulf = nazgulData:new {
            name = "Nazgulf",
            localName = "Aglarâkhôr",
            index = 6,
            indexLetter = "f",
            ancillaries = {
                "nazgul_sword",
                "ring_nazgulf",
            },
            ownerFaction = F_DOLGULDUR.name,
            unit = "Khamuls Shadow Wardens",
            descriptionMessage = "aglarakhor",
        },
        Nazgulg = nazgulData:new {
            name = "Nazgulg",
            localName = "Shi-vuus",
            index = 7,
            indexLetter = "g",
            returnMessage = "nazgul_return_2",
            ancillaries = {
                "nazgul_sword",
                "ring_nazgulg",
            },
            unit = "Temple War Sentinels",
            playerCounter = 18,
            descriptionMessage = "shivuus",
        },
        Nazgulh = nazgulData:new {
            name = "Nazgulh",
            localName = "Zagar",
            index = 8,
            returnMessage = "nazgul_return_1",
            indexLetter = "h",
            ancillaries = {
                "nazgul_sword",
                "ring_nazgulh",
            },
            unit = "Temple War Priests",
            playerCounter = 8,
            descriptionMessage = "zagar",
        },
        Nazguli = nazgulData:new {
            name = "Nazguli",
            localName = "Leofric",
            index = 9,
            indexLetter = "i",
            ancillaries = {
                "nazgul_sword",
                "ring_nazguli",
            },
            unit = "Temple War Sentinels",
            descriptionMessage = "leofric",
        },
    }

    self.data.factions = {
        poland = true,
        england = true,
        france = false,
        portugal = false,
    }

    if not IsFactionAIControlled(F_MORDOR.name) then
        self:mordorPlayerStart()
    end
end

function NAZGUL:mordorPlayerStart()
    if CAMPAIGN.turnNumber == 0 then
        for key, nazgulEntry in pairs(self.data.characters) do
            if nazgulEntry.ownerFaction == F_MORDOR.name and nazgulEntry.playerCounter > 0 then
                local nazgul = M2TW.campaign:getCharacterByLabel("real_nazgul" .. nazgulEntry.indexLetter .. "_1")
                if nazgul then nazgul.character:sendOffMap() end
            end
        end
        --local sauron = getCharacter("sauron_1")
        --if sauron then sendCharacterOffMap(sauron) end
    end
end

---comment
---@param faction factionStruct
function NAZGUL:script(faction)
    if not self.data.enabled then return end
    self:angmarWitchKingCheck()
    if not self.data.factions[faction.name] then return end
    if ONE_RING.data.stage == ringStage.saruman and self.data.isengardTimer < 9 then
        self:isengardSpawns()
        return
    end
    if self.data.factions[F_DOLGULDUR.name] and ONE_RING.data.stage ~= ringStage.saruman and
        FACTION:getFaction(F_DOLGULDUR.name).settlementsNum < 1 then
        self.data.characters["Nazguld"].ownerFaction = F_MORDOR.name
        self.data.characters["Nazgule"].ownerFaction = F_MORDOR.name
        self.data.characters["Nazgulf"].ownerFaction = F_MORDOR.name
        self.data.factions[F_DOLGULDUR.name] = false
    end
    for key, nazgulEntry in pairs(self.data.characters) do
        if nazgulEntry.ownerFaction == faction.name then
            local nazgul = getCharacterByLabelFac(faction, "real_nazgul" .. nazgulEntry.indexLetter, true)
            if nazgul then
                if faction.factionID == F_MORDOR.id then
                    if not IsFactionAIControlled(F_MORDOR.name) then
                        nazgulEntry:mordorPlayer(nazgul)
                    end
                end
            else
                nazgulEntry:checkForSpawn()
            end
        end
    end
end

function NAZGUL:angmarWitchKingCheck()
    if ONE_RING.data.stage == ringStage.saruman then return end
    local angmar = F_ANGMAR:getFaction()
    if angmar.settlementsNum < 1 and self.data.factions[F_ANGMAR.name] then
        self.data.characters["Nazgula"].ownerFaction = F_MORDOR.name
        self.data.factions[F_ANGMAR.name] = false
        return
    end
    if self.data.factions[F_ANGMAR.name] then return end
    if STRAT_MAP:getSettlement("Arthedain").ownerFaction.factionID == F_ANGMAR.id
        and STRAT_MAP:getSettlement("Imladris").ownerFaction.factionID == F_ANGMAR.id
        and STRAT_MAP:getSettlement("Carn_Dum").ownerFaction.factionID == F_ANGMAR.id
    then
        fireHistoricEvent("nazgul_setoff_carndum", "", 1)
        self.data.factions[F_ANGMAR.name] = true
        self.data.characters["Nazgula"].ownerFaction = F_ANGMAR.name
        local nazgula = getnamedCharbyLabel("real_nazgula")
        if nazgula and nazgula.character then
            nazgula.character:kill()
            self.data.characters["Nazgula"]:respawn()
        end
    end
end

---comment
---@param namedChar characterRecord
function NAZGUL:checkStories(namedChar)
    if not self.data.factions[CAMPAIGN.currentFaction.name] then return end
    if not string.find(namedChar.label, "real_nazgul") then return end
    local entry = self.data.characters[namedChar.shortName]
    if entry and not entry.messageShown then
        entry.messageShown = true
        M2TWEOP.scriptCommand("historic_event", entry.descriptionMessage)
    end
end

---@param nazgul characterRecord
function nazgulData:mordorPlayer(nazgul)
    if nazgul:isOffMap() and self.playerCounter > 0 then
        self:bringBack()
    end
end

function nazgulData:checkForSpawn()
    if self.deathTurn == -1 then
        self.deathTurn = CAMPAIGN.turnNumber
    elseif CAMPAIGN.turnNumber - self.deathTurn > NAZGUL.RESPAWN_TIME then
        self:respawn()
    end
end

function nazgulData:bringBack()
    if CAMPAIGN.turnNumber <= self.playerCounter then return end
    log("Nazgul bring back: " .. self.name, logLevel.INFO)
    self.playerCounter = 0
    self:spawn()
    M2TWEOP.scriptCommand("historic_event", self.returnMessage .. " factions { " .. self.ownerFaction .. ", }")
end

---comment
---@return integer x
---@return integer y
function nazgulData:getSpawnCoords()
    local faction = getFaction(self.ownerFaction)
    if not faction then return 0, 0 end
    local x, y = faction.capital.xCoord, faction.capital.yCoord
    return getValidTile(x, y)
end

function nazgulData:spawn()
    local x, y = self:getSpawnCoords()
    if ONE_RING.data.stage == ringStage.saruman then
        self.ownerFaction = F_ISENGARD.name
    end

    local trait_table_nazgul = { "Nazgul", self.index, "Hero", 1, "NazgulRace", 1, "FearGeneral", 1, "NightBattleCapable", 1, "NazgulEpithet", self.index }
    for key, value in pairs(self.traits) do
        table.insert(trait_table_nazgul, key)
        table.insert(trait_table_nazgul, value)
    end

    local newNazgulArmy = CAMPAIGN:getFaction(self.ownerFaction):spawnArmy(
        self.name, "", characterType.named_character, "real_nazgul" .. self.indexLetter .. "_" .. self.spawnCount, "nazgul" .. self.index
        , x, y, 16, true, 31, M2TWEOPDU.getEduIndexByType(self.unit), 9, 1, 1
    )
    local newNazgul = newNazgulArmy.leader
    addTraits(newNazgul.characterRecord, trait_table_nazgul)
    addAncs(newNazgul.characterRecord, self.ancillaries)
    if IsFactionAIControlled(self.ownerFaction) then
        newNazgul.characterRecord:addTrait("AIBoost", 1)
    end
    log("Nazgul spawned: " .. newNazgul.characterRecord.localizedDisplayName .. " for " .. self.ownerFaction .. " at " .. x .. " " .. y, logLevel.INFO)
    self.deathTurn = -1
    if newNazgul.characterRecord.faction.name ~= self.ownerFaction then
        newNazgul:switchFaction(CAMPAIGN:getFaction(self.ownerFaction), true, true)
    end
    newNazgul:setCharacterModel(self.stratModel)
    newNazgul.characterRecord.modelName = self.model
    newNazgul.ability = self.ability
    return newNazgul.characterRecord
end

---comment
function nazgulData:respawn()
    self.spawnCount = self.spawnCount + 1
    if self.ownerFaction == F_MORDOR.name then
        M2TWEOP.scriptCommand("historic_event", "nazgul_returned_mordor")
    elseif self.ownerFaction == F_DOLGULDUR.name then
        M2TWEOP.scriptCommand("historic_event", "nazgul_returned_dolguldur")
    elseif self.ownerFaction == F_ISENGARD.name then
        M2TWEOP.scriptCommand("historic_event", "nazgul_returned_isengard")
    elseif self.ownerFaction == F_ANGMAR.name then
        M2TWEOP.scriptCommand("historic_event", "nazgul_returned_carndum")
    end
    self.deathTurn = -1
    return self:spawn()
end
