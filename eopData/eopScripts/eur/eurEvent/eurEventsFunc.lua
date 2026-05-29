eur_spawned_characters = 0

tempgim_units_target = 0
tempgimtarget = 0
tempcharTarget = 0
tempmirrorTarget = 0

mirrorTarget = ""
mirrorTurnsRemain = 0

tempeyeTarget = 0
tempeyeTarget_region = 0

eyeTarget = 0

tempanorTarget = 0
anorTarget = ""

temporchordeTarget = 0
temporchordeTarget_cost = 0

traitToAdd = ""
traitTurnsRemain = 0

mengood_0_pop = 100
mengood_0_cul = 0.1

fert_level = 0
modify_growth = false
growthTurnsRemain = 0
replen_bonus = 0

edumodTurnsRemain = 0
edumodActive = false

edu_modified = false

tulkasTurnsRemain = 0
tulkasActive = false

lindon_0_count = 0
lindon_0_bu_added = false

block_poe_turns = 0

eur_event_active = false
eur_event_activelen = 0

eur_event_min_cooldown = 0
event_number = 99

local invalid_horde_cat = {
   "ship",
   "siege",
}

function eurEventUnlockCheck(id)
   if id ~= eur_playerFactionId then return end
   local dol_guldor = eur_campaign:getFaction("poland")
   if not poe_end_condition then
      if eur_player_faction.name == "ireland" then
         if dol_guldor.numOfCharacters == 0 then
            poe_end_condition = true
            EUR_EVENTS["ireland"][0].duration = 10
            EUR_EVENTS["ireland"][0].cooldown = 25
            EUR_EVENTS["mongols"][0].duration = 10
            EUR_EVENTS["mongols"][0].cooldown = 25
         end
      elseif eur_player_faction.name == "saxons" then
         if checkCounter("jewel_guild_rebuilt") then
            poe_end_condition = true
         end
      elseif eur_player_faction.name == "mongols" then
      elseif eur_player_faction.name == "denmark" then
      end
   end
   if eur_turn_number > 14 then
      --
   elseif eur_turn_number > 49 then
      EUR_EVENTS["denmark"][2].unlocked = true
      --stratmap.game.historicEvent("faction_prosperous", EUR_EVENTS["denmark"][2].name.." available", "\n\n"..EUR_EVENTS["denmark"][2].desc)
   end
   if dol_guldor.numOfCharacters == 0 then
      EUR_EVENTS["ireland"][0].unlocked = true
      --stratmap.game.historicEvent("faction_prosperous", EUR_EVENTS["ireland"][0].name.." available", "\n\n"..EUR_EVENTS["ireland"][0].desc)
      EUR_EVENTS["ireland"][2].unlocked = true
      --stratmap.game.historicEvent("faction_prosperous", EUR_EVENTS["ireland"][2].name.." available", "\n\n"..EUR_EVENTS["ireland"][2].desc)
      EUR_EVENTS["ireland"][0].duration = 10
      EUR_EVENTS["ireland"][0].cooldown = 25
   end
   local sett = eur_sMap:getSettlement("North_Khand")
   if sett.ownerFaction.name == "ireland" then
      EUR_EVENTS["ireland"][2].unlocked = true
      --stratmap.game.historicEvent("faction_prosperous", EUR_EVENTS["ireland"][2].name.." available", "\n\n"..EUR_EVENTS["ireland"][2].desc)
      EUR_EVENTS["ireland"][2].cooldown = 40
   else
      EUR_EVENTS["ireland"][2].cooldown = 60
   end
   local sett = eur_sMap:getSettlement("Deep_Mirkwood")
   if sett.ownerFaction.name == "ireland" then
      if not EUR_EVENTS["ireland"][0].unlocked then
         EUR_EVENTS["ireland"][0].unlocked = true
         --stratmap.game.historicEvent("faction_prosperous", EUR_EVENTS["mongols"][0].name.." available", "\n\n"..EUR_EVENTS["ireland"][0].desc)
      end
   elseif sett.ownerFaction.name == "mongols" then
      if not EUR_EVENTS["mongols"][0].unlocked then
         if checkCounter("elven_union") then
            EUR_EVENTS["mongols"][0].unlocked = true
            --stratmap.game.historicEvent("faction_prosperous", EUR_EVENTS["mongols"][0].name.." available", "\n\n"..EUR_EVENTS["mongols"][0].desc)
         end
      end
   end
   local sett = eur_sMap:getSettlement("Eregion")
   if sett.ownerFaction.name == "saxons" then
      EUR_EVENTS["saxons"][0].unlocked = true
      --stratmap.game.historicEvent("faction_prosperous", EUR_EVENTS["saxons"][0].name.." available", "\n\n"..EUR_EVENTS["saxons"][0].desc)
   end
end

function eurEventActiveCheck(id, faction_name)
   if id ~= eur_playerFactionId then return end
   if eur_event_active then
      if eur_event_activelen == 1 then
         eur_event_activelen = (eur_event_activelen-1)
         --stratmap.game.historicEvent("faction_prosperous", "Event Cooldown Expired", "")
      elseif eur_event_activelen > 1 then
         eur_event_activelen = (eur_event_activelen-1)
      else
         eur_event_active = false
      end
   end
   if not EUR_EVENTS[faction_name] then return end
   for i = 0, #EUR_EVENTS[faction_name] do
      if EUR_EVENTS[faction_name][i].active_cooldown == 1 then
         EUR_EVENTS[faction_name][i].active_cooldown = (EUR_EVENTS[faction_name][i].active_cooldown-1)
         --stratmap.game.historicEvent("faction_prosperous", EUR_EVENTS[faction_name][i].name.." available", "\n\n"..EUR_EVENTS[faction_name][i].desc)
         EUR_EVENTS[faction_name][i].unlocked = true
      elseif EUR_EVENTS[faction_name][i].active_cooldown > 0 then
         EUR_EVENTS[faction_name][i].active_cooldown = (EUR_EVENTS[faction_name][i].active_cooldown-1)
      end
      if EUR_EVENTS[faction_name][i].active_duration == 1 then
         EUR_EVENTS[faction_name][i].active_duration = (EUR_EVENTS[faction_name][i].active_duration-1)
         EUR_EVENTS[faction_name][i].unlocked = true
         --stratmap.game.historicEvent("faction_prosperous", EUR_EVENTS[faction_name][i].name.." expired", "\n\n"..EUR_EVENTS[faction_name][i].desc)
      elseif EUR_EVENTS[faction_name][i].active_duration > 0 then
         EUR_EVENTS[faction_name][i].active_duration = (EUR_EVENTS[faction_name][i].active_duration-1)
      end
   end
   if eur_event_min_cooldown > 0 then
      eur_event_min_cooldown = (eur_event_min_cooldown-1)
   end
   if block_poe_turns == 1 then
      block_poe_turns = (block_poe_turns-1)
      replen_bonus = 0
   elseif block_poe_turns > 0 then
      block_poe_turns = (block_poe_turns-1)
   end
end

labels_unedited = {
   "maernil_1_eregion00",
   "glorfindel_1",
   "Ecthellion_1_eregion",
   "Ciryatan_1_eregion",
   "Tauriel_1",
   "galadriel_1",
}

function eurSpawnArmy(faction_name, name, label, custom_portrait, family, age, unit, x, y, exp, weapon, armor)
   local x, y = getValidTile(x, y)
   if tableContains(labels_unedited, label) then
      -- nothing
   else
      label = label .. tostring(eur_turn_number) .. tostring(eur_spawned_characters)
   end
   local army = stratmap.game.spawnArmy(
   eur_campaign:getFaction(faction_name),
   name,
   "",
   characterType.named_character,
   label,
   custom_portrait,
   x, y,
   age, family, 31,
   M2TWEOPDU.getEduIndexByType(unit), exp, weapon, armor
      )
   eur_spawned_characters = (eur_spawned_characters+1)
   return army
end

function mirrorGaladriel()
   local faction = eur_campaign:getFaction(mirrorTarget)
   for i = 0, faction.settlementsNum - 1 do
      local sett = faction:getSettlement(i)
      if sett then
         --stratmap.game.scriptCommand("reveal_tile", sett.xCoord.." "..sett.yCoord)
         local region = eur_sMap.getRegion(sett.regionID);
         local region_tiles = region.tileCount
         for i = 0, region_tiles -1 do
            if (i % 2 == 0) then
               local tile = region:getTile(i)
               if checkTileEmpty(tile.xCoord, tile.yCoord) then 
                  stratmap.game.scriptCommand("reveal_tile", tile.xCoord.." "..tile.yCoord)
               end
            end
         end
      end
   end
   --[[
   for i = 0, faction.fortsNum - 1 do
      local fort = faction:getFort(i)
      if fort then
         stratmap.game.scriptCommand("reveal_tile", fort.xCoord.." "..fort.yCoord)
      end
   end
   ]]
   for i = 0, faction.stacksNum - 1 do
      local stack = faction:getStack(i)
      if stack then
         if stack.leader ~= nil then
            stratmap.game.scriptCommand("reveal_tile", stack.leader.xCoord.." "..stack.leader.yCoord)
         end
      end
   end
   for i = 0, faction.numOfCharacters - 1 do
      local char = faction:getCharacter(i)
      if char then
         stratmap.game.scriptCommand("reveal_tile", char.xCoord.." "..char.yCoord)
      end
   end
end

function mirrorCheck()
   if mirrorTarget == "" then return end
   if mirrorTurnsRemain == 0 then 
      mirrorTarget = ""
      return end
   mirrorGaladriel()
   mirrorTurnsRemain = (mirrorTurnsRemain-1)
end

function eventAddTrait(faction, bool)
   for i = 0, faction.numOfCharacters - 1 do
      local char = faction:getCharacter(i).namedCharacter
      if char then
         if bool then
            char:addTrait(traitToAdd, 1)
         else
            char:removeTrait(traitToAdd);
         end
      end
   end
end

function traitCheck(id)
   if id ~= eur_playerFactionId then return end
   if traitToAdd == "" then return end
   if traitTurnsRemain == 0 then 
      eventAddTrait(eur_player_faction, false)
      traitToAdd = ""
   elseif traitTurnsRemain == 8 then
      eventAddTrait(eur_player_faction, true)
      traitTurnsRemain = (traitTurnsRemain-1)
   else
      traitTurnsRemain = (traitTurnsRemain-1)
   end
end

function increaseGrowth(faction, level)
   for i = 0, faction.settlementsNum - 1 do
      local sett = faction:getSettlement(i)
      if sett then
         sett.baseFertility = level
         sett.settlementStats.population = (sett.settlementStats.population+25)
      end
   end
end

function growthCheck(id)
   if id ~= eur_playerFactionId then return end
   if modify_growth then
      if growthTurnsRemain == 0 then
         increaseGrowth(eur_player_faction, 1)
         modify_growth = false
      elseif growthTurnsRemain > 0 then
         increaseGrowth(eur_player_faction, fert_level)
         growthTurnsRemain = (growthTurnsRemain-1)
      end
   end
end

function modifyEDU(bool, ammo, locked, cost, time, range)
   if bool then
      for i = 0, 1500 do
         local eduEntry = M2TWEOPDU.getEduEntry(i)
         if eduEntry ~= nil then
            if eduEntry:hasOwnership(eur_playerFactionId) then
               if ammo > 0 then
                  eduEntry.primaryStats.ammo = math.ceil(UNIT_ORIGINAL[eduEntry.eduType].ammo*ammo)
               end
               if locked > 0 then
                  eduEntry.moraleLocked = 1
               end
               if cost > 0 then
                  eduEntry.recruitCost = math.ceil(UNIT_ORIGINAL[eduEntry.eduType].recruitCost*cost)
               end
               if time > 0 then
                  if eduEntry.recruitTime > time then
                     eduEntry.recruitTime = (UNIT_ORIGINAL[eduEntry.eduType].recruitTime-time)
                  end
               end
               if range > 0 then
                  eduEntry.primaryStats.range = (UNIT_ORIGINAL[eduEntry.eduType].range+range)
               end
               edu_modified = true
            end
         end
      end
   else
      for i = 0, 1500 do
         local eduEntry = M2TWEOPDU.getEduEntry(i)
         if eduEntry ~= nil then
            if eduEntry:hasOwnership(eur_playerFactionId) then
               eduEntry.primaryStats.ammo = UNIT_ORIGINAL[eduEntry.eduType].ammo
               eduEntry.moraleLocked = UNIT_ORIGINAL[eduEntry.eduType].moraleLocked
               eduEntry.recruitCost = UNIT_ORIGINAL[eduEntry.eduType].recruitCost
               eduEntry.recruitTime = UNIT_ORIGINAL[eduEntry.eduType].recruitTime
               eduEntry.primaryStats.range = UNIT_ORIGINAL[eduEntry.eduType].range
               edu_modified = false
            end
         end
      end
   end
end

function modifyEDUcheck(id, bool)
   if id ~= eur_playerFactionId then return end
   if edumodActive then
      if edumodTurnsRemain == 0 then
         modifyEDU(false, 0, 0, 0, 0, 0)
         edumodActive = false
      elseif edumodTurnsRemain > 0 then
         if not edu_modified then
            modifyEDU(true, 1.25, 0, 0.65, 1, 0)
         end
         if bool then
            edumodTurnsRemain = (edumodTurnsRemain-1)
         end
      end
   end
   if tulkasActive then
      if tulkasTurnsRemain == 0 then
         modifyEDU(false, 0, 0, 0, 0, 0)
         tulkasActive = false
      elseif tulkasTurnsRemain > 0 then
         if not edu_modified then
            modifyEDU(true, 0, 0, 0.4, 1, 0)
         end
         tulkasTurnsRemain = (tulkasTurnsRemain-1)
      end
   end
end

function tulkasCheck(id, unit, new)
   if id ~= eur_playerFactionId then return end
   if tulkasActive then
      if new then
         if unit.exp < 7 then
            unit:setParams((unit.exp+3),unit.armourLVL,unit.weaponLVL);
         end
      else
         if tulkasTurnsRemain > 3 then
            for i = 0, eur_player_faction.armiesNum - 1 do
               local stack = eur_player_faction:getArmy(i)
               if stack then
                  for i = 0, stack.numOfUnits - 1 do
                     local unit = stack:getUnit(i)
                     if math.random(1,100) > 50 then
                        if unit.exp < 9 then
                           unit:setParams((unit.exp+1),unit.armourLVL,unit.weaponLVL);
                        end
                     end
                  end
               end
            end
         end
      end
   end
end

function ulmoAdd()
   local building = EDB.getBuildingByName("port")
   local bonus = 15
   if lindon_0_count > 0 then
       for i = 1, lindon_0_count do
           for j = 0, 4 do
               bu = building:getBuildingLevel(j)
               bu:addCapability(buildingCapability.income_bonus, (bonus*(j+1)), true, "factions { denmark, }")
               if i < 6 then
                  bu:addCapability(buildingCapability.population_growth_bonus, 1, true, "factions { denmark, }")
               end
               if lindon_0_count == 2 then
                  bu:addRecruitPool(M2TWEOPDU.getEduIndexByType("Lindar Mariners"), 1, 0.1, 2, 1, "factions { denmark, } and region_religion elven 33 and event_counter mithlond_controlled 1")
               end
               if lindon_0_count == 4 then
                   if i == 4 then
                       bu:addRecruitPool(M2TWEOPDU.getEduIndexByType("Mithlond Nobles"), 1, 0.1, 2, 1, "factions { denmark, } and region_religion elven 80 and hidden_resource Lindon")
                   end
               end
           end
       end
       lindon_0_bu_added = true
   end
end

function miningdwarvesAdd()
   local building = EDB.getBuildingByName("hinterland_mines")
   local bonus = 25
   if dwarven_0_count > 0 then
       for i = 1, dwarven_0_count do
           for j = 0, 2 do
               bu = building:getBuildingLevel(j)
               bu:addCapability(buildingCapability.income_bonus, (bonus*(j+1)), true, "factions { moors, hungary, norway, }")
               if i < 6 then
                  bu:addCapability(buildingCapability.population_growth_bonus, 1, true, "factions { moors, hungary, norway, }")
               end
           end
       end
       dwarven_0_bu_added = true
   end
   for i = 0, eur_player_faction.numOfCharacters - 1 do
      local char = eur_player_faction:getCharacter(i)
      local random = math.random(1, 100)
      if char:getTypeID() == 7 then
         if random > 50 then
            if char.characterRecord:getTraitLevel("MiningSkill") == 0 then
               char.characterRecord:addTrait("MiningSkill", 1)
               --stratmap.game.historicEvent("faction_prosperous", "Mining Trait Expanded", "\n\n"..char.characterRecord.localizedDisplayName)
            elseif char.characterRecord:getTraitLevel("MiningSkill") < 2 then
               char.characterRecord:addTraitPoints("MiningSkill", 1)
               --stratmap.game.historicEvent("faction_prosperous", "Mining Trait Expanded", "\n\n"..char.characterRecord.localizedDisplayName)
            end
         end
      end
   end
end

function greatEye(reset)
   if eyeTarget == 0 then return end
   if reset then
      stratmap.game.scriptCommand("hide_all_revealed_tiles")
   end
   local region = eur_sMap.getRegion(eyeTarget);
   local region_tiles = region.tileCount
   for i = 0, region_tiles -1 do
      if (i % 2 == 0) then
         local tile = region:getTile(i)
         if checkTileEmpty(tile.xCoord, tile.yCoord) then 
            stratmap.game.scriptCommand("reveal_tile", tile.xCoord.." "..tile.yCoord)
         end
      end
   end
end

function eyeCheck(id)
   if id ~= eur_playerFactionId then return end
   if eyeTarget == 0 then return end
   greatEye(false)
end

function orcHorde(sett, cost)
   local list = {}
   local limit = cost/5
   local orig_cost = cost
   for i = 0, sett.recruitmentCapabilityNum -1 do
      local capability = sett:getRecruitmentCapability(i).eduIndex
      local eduEntry = M2TWEOPDU.getEduEntry(capability)
      if eduEntry then
         print(eduEntry.eduType)
         if not tableContains(invalid_horde_cat, eduEntry.category) then
            local rand = math.random(1, 3)
            for i = 1, rand do
               if cost > eduEntry.recruitCost then
                  if limit == 3000 then
                     if eduEntry.recruitCost < limit then
                        if eduEntry.recruitCost > 1200 then
                           if #list < 19 then
                              table.insert(list, eduEntry.eduType)
                              cost = cost-eduEntry.recruitCost
                           end
                        else
                           if #list < 19 then
                              table.insert(list, eduEntry.eduType)
                              cost = cost-eduEntry.recruitCost
                           end
                        end
                     end
                  elseif limit == 2000 then
                     if eduEntry.recruitCost < limit then
                        if eduEntry.recruitCost > 800 then
                           if #list < 19 then
                              table.insert(list, eduEntry.eduType)
                              cost = cost-eduEntry.recruitCost
                           end
                        else
                           if #list < 19 then
                              table.insert(list, eduEntry.eduType)
                              cost = cost-eduEntry.recruitCost
                           end
                        end
                     end
                  else
                     if eduEntry.recruitCost < limit then
                        if #list < 19 then
                           table.insert(list, eduEntry.eduType)
                           cost = cost-eduEntry.recruitCost
                        end
                     end
                  end
               end
            end
         end
      end
   end
   local army = eurSpawnArmy(eur_player_faction.name, "random_name", "orchorde_", "", false, 18, default_general_units[eur_player_faction.name].old, sett.xCoord, sett.yCoord, 3, 0, 0)
   if army then
      shuffle(list)
      for i = 1, #list do
         local unit = army:createUnit(list[i], 2, 0, 0)
         if unit.soldierCountStratMap*1.5 > 300 then
            unit.soldierCountStratMap = 300
         else
            unit.soldierCountStratMap = unit.soldierCountStratMap*1.5
         end
      end
   end
   local new_set = (sett.settlementStats.population-(orig_cost/10))
   print("pop red"..tostring(sett.settlementStats.population-(orig_cost/10)))
   sett.settlementStats.population = new_set
   stratmap.game.callConsole("add_money", "-" .. tostring(cost))
   print("refunded"..tostring(cost))
end

function anorStone()
   local anor_target_faction = eur_campaign:getFaction(anorTarget)
   if not anor_target_faction then return end
   for i = 0, anor_target_faction.numOfCharacters - 1 do
      local char = anor_target_faction:getCharacter(i)
      if char then
          if (char.characterType == 6) or (char.characterType == 7) then
              if not (char.settlement or char.fort) then
                  revealTilesAround(char.xCoord, char.yCoord)
              end
          end
      end
  end
  for i = 0, anor_target_faction.settlementsNum - 1 do
      local sett = anor_target_faction:getSettlement(i)
      if sett then
          revealTilesAround(sett.xCoord, sett.yCoord)
      end
  end
end

function anorStoneCheck()
   if anorTarget == "" then return end
   if anorTurnsRemain == 1 then 
      anorTurnsRemain = (anorTurnsRemain-1)
      anorTarget = ""
   elseif anorTurnsRemain > 1 then
      anorStone()
      anorTurnsRemain = (anorTurnsRemain-1)
   end
end

function populationCultureBonus(pop, culture, settlement)
   if not settlement then return end
   settlement.settlementStats.population = settlement.settlementStats.population+pop
   local rel_level = settlement:getReligion(eur_player_faction.religion)
   if rel_level+culture > 1 then
      settlement:setReligion(eur_player_faction.religion, 1)
   else
      settlement:setReligion(eur_player_faction.religion, (rel_level+culture))
   end
end

function mengood_0_check(id)
   if id ~= eur_playerFactionId then return end
   if not mengood_0_sett then return end
   if mengoodTurnsRemain == 1 then
      mengoodTurnsRemain = mengoodTurnsRemain-1
      populationCultureBonus(mengood_0_pop, mengood_0_cul, mengood_0_sett)
      mengood_0_sett = nil
   elseif mengoodTurnsRemain > 1 then
      populationCultureBonus(mengood_0_pop, mengood_0_cul, mengood_0_sett)
      mengoodTurnsRemain = mengoodTurnsRemain-1
   end
end

glory_table = {
   [0] = {
      desc = [[King Tarannon was the 12th King of Gondor, ruling from 830 to 913 of the Third Age. He was the first of the Ship-kings of Gondor, who extended the realm far along the shores west and south of the Mouths of the Anduin. Commemorating his victories, Tarannon assumed the name "Falastur" when he took the crown.]],
      cost = 2500,
      locked = true,
      title = "Ship-kings I: Tarannon Falastur",
      image = nil,
      imagelocked = nil,
   },
   [1] = {
      desc = [[Eärnil was the son of Tarciryan, the brother of King Tarannon Falastur. He succeeded his uncle Tarannon Falastur, who died childless in T.A. 913. He continued with the expansionist maritime policy of his predecessor by repairing the haven of Pelargir and building a great fleet. Eärnil besieged Umbar by land and by sea and conquered Umbarin T.A. 933. Umbar became a great haven and fortress of Gondor.]],
      cost = 5000,
      locked = false,
      title = "Ship-kings II: Eärnil I",
      image = nil,
      imagelocked = nil,
   },
   [2] = {
      desc = [[Ciryandil was born in the year TA 820 and succeeded his father Eärnil I in TA 936. In his reign, Ciryandil continued Eärnil's naval policies and spent his reign defending the recently captured port of Umbar against the Black Númenóreans who had lived there before, and the Haradrim who wished to capture the port.]],
      cost = 10000,
      locked = false,
      title = "Ship-kings III: Ciryandil",
      image = nil,
      imagelocked = nil,
   },
   [3] = {
      desc = [[An extremely strong Dúnadan Warrior-king. He was the last of four Ship-kings, the eldest son of Ciryandil, and the father of Atanatar II. His reign marked the height of the South Kingdom's power. He sought to avenge his father's death and campaigned in the South throughout the early part of his reign. His victory over the Haradrim brought all of Haradwaith under Gondorian control in T.A. 1050; thus his name Hyarmendacil ("South-victor").]],
      cost = 25000,
      locked = false,
      title = "Ship-kings IV: Ciryaher Hyarmendacil I",
      image = nil,
      imagelocked = nil,
   },
   [4] = {
      desc = [[Mardil Voronwë was a Steward of Gondor and the son of Vorondil, a great hunter of beasts. He was the first ruling Steward of Gondor following the death of King Eärnur. Mardil ruled Gondor with a steady hand and was therefor nicknamed 'Voronwë', meaning 'the Steadfast'.]],
      cost = 2500,
      locked = true,
      title = "Stewards I: Mardil Voronwe",
      image = nil,
      imagelocked = nil,
   },
   [5] = {
      desc = [[Boromir I was the 11th Ruling Steward of Gondor. He was noble and fair of face, strong in body and will. Boromir successfully recaptured Ithilien from elements of Sauron's army headquartered at Minas Morgul after their invasion of Gondor in TA 2475. He was considered such a mighty captain and warrior that even the Witch-king feared him.]],
      cost = 5000,
      locked = false,
      title = "Stewards II: Boromir I",
      image = nil,
      imagelocked = nil,
   },
   [6] = {
      desc = [[Born in TA 2449, Cirion was the son of Boromir and the 12th Ruling Steward of Gondor. During his rule in TA 2509 the Balchoth gathered for an assault upon Gondor, the Balchoth were defeated with the help of the Éothéod who came out of the north. Cirion later gifted the province of Calenardhon to the Éothéod, founding the Kingdom of Rohan.]],
      cost = 10000,
      locked = false,
      title = "Stewards III: Cirion",
      image = nil,
      imagelocked = nil,
   },
   [7] = {
      desc = [[Anárion was the youngest son of Elendil, the High King of Arnor and Gondor. He and his brother Isildur jointly ruled Gondor, while their father dwelt in the North. ]],
      cost = 7500,
      locked = true,
      title = "Founders I: Anárion",
      image = nil,
      imagelocked = nil,
   },
   [8] = {
      desc = [[Isildur was the elder son of Elendil and second High King of Gondor and Arnor. He is revered for being the hero who struck the death blow to Sauron, yet he is also infamous for his failure to destroy the One Ring.]],
      cost = 15000,
      locked = false,
      title = "Founders II: Isildur",
      image = nil,
      imagelocked = nil,
   },
   [9] = {
      desc = [[Elendil, meaning "Elf-friend" or "Star-lover", also known as Elendil the Tall, Elendil the Fair or Voronda "The Faithful", was a man of Númenor and the father of Isildur and Anárion who led the survivors of its Downfall to the shores of Middle-earth where they founded two Realms in Exile: Arnor and Gondor. Thus, Elendil became the first King of both realms and held the title of first High King of the Dúnedain, making him supreme overlord of all exiled Númenóreans in the lands east of the Great Sea.]],
      cost = 25000,
      locked = false,
      title = "Founders III: Elendil",
      image = nil,
      imagelocked = nil,
   },
}

function gloryGondor(glorychoice)
   if glorychoice == 99 then return end
   if glorychoice == 0 then
      gloryShip1()
   elseif glorychoice == 1 then
      gloryShip2()
   elseif glorychoice == 2 then
      gloryShip3()
   elseif glorychoice == 3 then
      gloryShip4()
   elseif glorychoice == 4 then
      gloryStew1()
   elseif glorychoice == 5 then
      gloryStew2()
   elseif glorychoice == 6 then
      gloryStew3()
   elseif glorychoice == 7 then
      gloryKings1()
   elseif glorychoice == 8 then
      gloryKings2()
   elseif glorychoice == 9 then
      gloryKings3()
   end
end

function gloryGondorText(glorychoice)
   if glorychoice == 99 then return end
   if glorychoice == 0 then
      ImGui.NewLine()
      ImGui.BulletText("Population Growth(all ports)")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " + 1%%")
      ImGui.BulletText("Recruitment & Upkeep: Lebennin Marines, Aearsul & Alcarondas")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " - 25%%")
   elseif glorychoice == 1 then
      ImGui.NewLine()
      ImGui.BulletText("Port build time")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " -2 turns")
      ImGui.BulletText("Port build cost")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " - 15%%")
      ImGui.BulletText("Enables recruitment of 'Wardens of the White Tower' at Haven ports.")
   elseif glorychoice == 2 then
      ImGui.NewLine()
      ImGui.BulletText("Wharf build time")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " -3 turns")
      ImGui.BulletText("Wharf build cost")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " - 30%%")
      ImGui.BulletText("Additional income for Wharf buildings(per level)")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " +50")
   elseif glorychoice == 3 then
      ImGui.NewLine()
      ImGui.BulletText("Additional trade fleets(all ports)")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " + 2")
      ImGui.BulletText("Grants trait 'Hyarmendacil's Legacy'(all characters)")
      ImGui.BulletText("Command")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " + 2")
      ImGui.BulletText("Hitpoints")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " + 1")
      ImGui.BulletText("Movement")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " + 10%%")
   elseif glorychoice == 4 then
      ImGui.NewLine()
      ImGui.BulletText("Law bonus for Mason buildings: ")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " + 5%%")
      ImGui.BulletText("Additional cost reduction for Mason buildings: ")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " - 5%%")
   elseif glorychoice == 5 then
      ImGui.NewLine()
      ImGui.BulletText("Additional cost reduction for Mason buildingPresent: ")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " - 10%%")
      ImGui.BulletText("Speeds up recruitment of Wardens of the White Tower(Minas Tirith)")
   elseif glorychoice == 6 then
      ImGui.NewLine()
      ImGui.BulletText("Additional turn time reduction for Mason buildings: ")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " - 20%%")
      ImGui.BulletText("Culture bonus for Mason buildings: ")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " + 1%%")
   elseif glorychoice == 7 then
      ImGui.NewLine()
      ImGui.BulletText("Morale bonus for Barracks: ")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " + 2")
      ImGui.BulletText("Speeds up recruitment of Citadel Guard(Minas Tirith)")
   elseif glorychoice == 8 then
      ImGui.NewLine()
      ImGui.BulletText("Experience bonus for Barracks: ")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " + 2")
      ImGui.BulletText("Enables recruitment of Dunedain Steelbowmen(Minas Tirith)")
   elseif glorychoice == 9 then
      ImGui.NewLine()
      ImGui.BulletText("Recruitment time reduction for Barracks: ")
      ImGui.SameLine()
      ImGui.TextColored(0, 1, 0, 1, " - 2 turns")
      ImGui.BulletText("Speeds up recruitment of Fountain Guard(Minas Tirith)")
   end
end

function gloryShip1()
   local building = EDB.getBuildingByName("port")
   for j = 0, 4 do
      bu = building:getBuildingLevel(j)
      if bu ~= nil then
         bu:addCapability(buildingCapability.population_growth_bonus, 2, true, "factions { sicily, }")
      end
   end
   local building = EDB.getBuildingByName("castle_port")
   for j = 0, 4 do
      bu = building:getBuildingLevel(j)
      if bu ~= nil then
         bu:addCapability(buildingCapability.population_growth_bonus, 2, true, "factions { sicily, }")
      end
   end
   ship_1_active = true
   ship_1_added = true
   local eduEntry=M2TWEOPDU.getEduEntryByType("Lebennin Marines");
   if eduEntry then
      eduEntry.recruitCost = math.floor(eduEntry.recruitCost*0.75)
      eduEntry.upkeepCost = math.floor(eduEntry.upkeepCost*0.75)
   end
   local eduEntry=M2TWEOPDU.getEduEntryByType("Gondor Boat");
   if eduEntry then
      eduEntry.recruitCost = math.floor(eduEntry.recruitCost*0.75)
      eduEntry.upkeepCost = math.floor(eduEntry.upkeepCost*0.75)
   end
   local eduEntry=M2TWEOPDU.getEduEntryByType("Gondor Ship");
   if eduEntry then
      eduEntry.recruitCost = math.floor(eduEntry.recruitCost*0.75)
      eduEntry.upkeepCost = math.floor(eduEntry.upkeepCost*0.75)
   end
   defaultEDU()
   glory_table[0].locked = false
   glory_table[1].locked = true
end

function gloryShip2()
   local building = EDB.getBuildingByName("port")
   for j = 0, 4 do
      local bu = building:getBuildingLevel(j)
      bu.buildCost = math.ceil(bu.buildCost*0.85)
      if bu.buildTime-2 > 1 then
         bu.buildTime = bu.buildTime-2
      else
         bu.buildTime = 2
      end
   end
   local bu = building:getBuildingLevel(4)
   bu:addRecruitPool(M2TWEOPDU.getEduIndexByType("Wardens White Tower"), 1, 0.046, 1, 1, "factions { sicily, }")
   
   local building = EDB.getBuildingByName("castle_port")
   for j = 0, 4 do
      local bu = building:getBuildingLevel(j)
      bu.buildCost = math.ceil(bu.buildCost*0.85)
      if bu.buildTime-2 > 1 then
         bu.buildTime = bu.buildTime-2
      else
         bu.buildTime = 2
      end
   end
   local bu = building:getBuildingLevel(4)
   bu:addRecruitPool(M2TWEOPDU.getEduIndexByType("Wardens White Tower"), 1, 0.046, 1, 1, "factions { sicily, }")
   
   ship_2_active = true
   ship_2_added = true
   glory_table[1].locked = false
   glory_table[2].locked = true
end

function gloryShip3()
   local building = EDB.getBuildingByName("sea_trade")
   for j = 0, 2 do
      local bu = building:getBuildingLevel(j)
      bu.buildCost = math.ceil(bu.buildCost*0.70)
      bu:addCapability(buildingCapability.income_bonus, (50*(j+1)), true, "factions { sicily, }")
      if bu.buildTime-3 > 1 then
         bu.buildTime = bu.buildTime-3
      else
         bu.buildTime = 2
      end
   end
   ship_3_active = true
   ship_3_added = true
   glory_table[2].locked = false
   glory_table[3].locked = true
end

function gloryShip4()
   local building = EDB.getBuildingByName("port")
   for j = 0, 4 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.trade_fleet, 2, true, "factions { sicily, }")
   end
   local building = EDB.getBuildingByName("castle_port")
   for j = 0, 4 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.trade_fleet, 2, true, "factions { sicily, }")
   end
   for i = 0, faction.numOfCharacters - 1 do
      local char = eur_player_faction:getCharacter(i).namedCharacter
      if char then
         char:addTrait("Hyarmendacil", 1)
      end
   end
   ship_4_active = true
   ship_4_added = true
   glory_table[3].locked = false
end

function hyarmendacilAdd()
   for i = 0, faction.numOfCharacters - 1 do
      local char = faction:getCharacter(i).namedCharacter
      if char then
         char:addTrait("Hyarmendacil", 1)
      end
   end
end

function gloryKings1()
   local building = EDB.getBuildingByName("hinterland_unique1")
   local bu = building:getBuildingLevel(0)
   bu:addRecruitPool(M2TWEOPDU.getEduIndexByType("Citadel Guard"), 1, 0.05, 1, 1, "factions { sicily, }")
   local building = EDB.getBuildingByName("barracks")
   for j = 0, 2 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.recruits_morale_bonus, 2, true, "factions { sicily, }")
   end
   local building = EDB.getBuildingByName("castle_barracks")
   for j = 0, 2 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.recruits_morale_bonus, 2, true, "factions { sicily, }")
   end
   king_1_active = true
   king_1_added = true
   glory_table[7].locked = false
   glory_table[8].locked = true
end

function gloryKings2()
   local building = EDB.getBuildingByName("hinterland_unique1")
   local bu = building:getBuildingLevel(0)
   bu:addRecruitPool(M2TWEOPDU.getEduIndexByType("Dunedain Steelbowmen"), 2, 0.05, 2, 1, "factions { sicily, }")
   local building = EDB.getBuildingByName("barracks")
   for j = 0, 2 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.recruits_exp_bonus, 2, true, "factions { sicily, }")
   end
   local building = EDB.getBuildingByName("castle_barracks")
   for j = 0, 2 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.recruits_exp_bonus, 2, true, "factions { sicily, }")
   end
   king_2_active = true
   king_2_added = true
   glory_table[8].locked = false
   glory_table[9].locked = true
end

function gloryKings3()
   local building = EDB.getBuildingByName("hinterland_unique1")
   local bu = building:getBuildingLevel(0)
   bu:addRecruitPool(M2TWEOPDU.getEduIndexByType("Fountain Guard"), 2, 0.05, 2, 1, "factions { sicily, }")
   local building = EDB.getBuildingByName("barracks")
   for j = 0, 2 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.recruitment_slots, 1, true, "factions { sicily, }")
      bu:addCapability(buildingCapability.free_upkeep, 1, true, "factions { sicily, }")
   end
   local building = EDB.getBuildingByName("castle_barracks")
   for j = 0, 2 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.recruitment_slots, 1, true, "factions { sicily, }")
      bu:addCapability(buildingCapability.free_upkeep, 1, true, "factions { sicily, }")
   end
   for i = 0, 1500 do
      local eduEntry = M2TWEOPDU.getEduEntry(i)
      if eduEntry ~= nil then
          if eduEntry:hasOwnership(eur_playerFactionId) then
            if eduEntry.recruitTime - 2 >= 1 then
               eduEntry.recruitTime = eduEntry.recruitTime-2
            else
               eduEntry.recruitTime = 1
            end
          end
      end
  end
  defaultEDU()
   king_3_active = true
   king_3_added = true
   glory_table[9].locked = false
end

function gloryStew1()
   local building = EDB.getBuildingByName("city_hall")
   for j = 0, 3 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.law_bonus, 1, true, "factions { sicily, }")
      bu:addCapability(buildingCapability.construction_cost_bonus_wooden, 5, true, "factions { sicily, }")
      bu:addCapability(buildingCapability.construction_cost_bonus_stone, 5, false, "factions { sicily, }")
   end
   local building = EDB.getBuildingByName("castle_hall")
   for j = 0, 3 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.law_bonus, 1, true, "factions { sicily, }")
      bu:addCapability(buildingCapability.construction_cost_bonus_wooden, 5, false, "factions { sicily, }")
      bu:addCapability(buildingCapability.construction_cost_bonus_stone, 5, false, "factions { sicily, }")
   end
   stew_1_active = true
   stew_1_added = true
   glory_table[4].locked = false
   glory_table[5].locked = true
end

function gloryStew2()
   local building = EDB.getBuildingByName("city_hall")
   for j = 0, 3 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.construction_cost_bonus_wooden, 10, true, "factions { sicily, }")
      bu:addCapability(buildingCapability.construction_cost_bonus_stone, 10, true, "factions { sicily, }")
   end
   local building = EDB.getBuildingByName("castle_hall")
   for j = 0, 3 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.construction_cost_bonus_wooden, 10, true, "factions { sicily, }")
      bu:addCapability(buildingCapability.construction_cost_bonus_stone, 10, true, "factions { sicily, }")
   end
   local building = EDB.getBuildingByName("hinterland_unique1")
   local bu = building:getBuildingLevel(0)
   bu:addRecruitPool(M2TWEOPDU.getEduIndexByType("Wardens White Tower"), 1, 0.04, 2, 1, "factions { sicily, }")
   stew_2_active = true
   stew_2_added = true
   glory_table[5].locked = false
   glory_table[6].locked = true
end

function gloryStew3()
   local building = EDB.getBuildingByName("city_hall")
   for j = 0, 3 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.construction_time_bonus_religious, 20, true, "factions { sicily, }")
      bu:addCapability(buildingCapability.construction_time_bonus_other, 20, true, "factions { sicily, }")
      bu:addCapability(buildingCapability.construction_time_bonus_defensive, 20, true, "factions { sicily, }")
   end
   local building = EDB.getBuildingByName("castle_hall")
   for j = 0, 3 do
      local bu = building:getBuildingLevel(j)
      bu:addCapability(buildingCapability.construction_time_bonus_religious, 20, true, "factions { sicily, }")
      bu:addCapability(buildingCapability.construction_time_bonus_other, 20, true, "factions { sicily, }")
      bu:addCapability(buildingCapability.construction_time_bonus_defensive, 20, true, "factions { sicily, }")
   end
   local building = EDB.getBuildingByName("hinterland_unique1")
   local bu = building:getBuildingLevel(0)
   bu:addRecruitPool(M2TWEOPDU.getEduIndexByType("Wardens White Tower"), 2, 0.08, 2, 1, "factions { sicily, }")
   stew_3_active = true
   stew_3_added = true
   glory_table[6].locked = false
end
