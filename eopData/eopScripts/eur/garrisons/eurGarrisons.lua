

FACTION_PLAYER = {
	["aztecs"] = false,
	["byzantium"] = false,
	["denmark"] = false,
	["england"] = false,
	["france"] = false,
	["gundabad"] = false,
	["hre"] = false,
	["hungary"] = false,
	["ireland"] = false,
	["khand"] = false,
	["milan"] = false,
	["mongols"] = false,
	["moors"] = false,
	["normans"] = false,
	["norway"] = false,
	["poland"] = false,
	["portugal"] = false,
	["russia"] = false,
	["saxons"] = false,
	["scotland"] = false,
	["sicily"] = false,
	["spain"] = false,
	["teutonic_order"] = false,
	["timurids"] = false,
	["turks"] = false,
	["venice"] = false,
    ["null"] = false,
}



GARRISON_TRACK = {}

function addAiGarrison(faction)
	if not game_options.garrisons then return end
	if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."addAiGarrison");
	end
	if checkCounter("garrison_skip") then return end
    -- we don't support rebels n mur'cans!
    local facName = faction.name
    if facName == "slave" then return end
    if not SETT_GARRISONS[facName] then return end
	if GARRISON_TRACK[facName] == nil then 
		GARRISON_TRACK[facName] = {}
	end
    for k, v in pairs(SETT_GARRISONS[facName]) do
        local settlement = eur_sMap:getSettlement(k)
        if settlement ~= nil then
            if settlement.ownerFaction.name == facName then
				if GARRISON_TRACK[facName][settlement.name] == nil then 
					GARRISON_TRACK[facName][settlement.name] = {}
				end
                if settlement.army ~= nil then
                    local army = settlement.army
                    --for k2, v2 in pairs(SETT_GARRISONS[facName][k]) do
                        if SETT_GARRISONS[facName][k][eur_localFactionName] then
							local trackIndex = 1  -- declare before the i loop

							for i = 1, #SETT_GARRISONS[facName][k][eur_localFactionName] do
								for j = 1, SETT_GARRISONS[facName][k][eur_localFactionName][i][2] do
									if settlement.army.numOfUnits < 20 then
										if army:findInSettlement() then
											local unitData = SETT_GARRISONS[facName][k][eur_localFactionName][i]
											local new_unit = army:createUnit(
												unitData[1], unitData[3], unitData[4], unitData[5]
											)
											if new_unit then
												new_unit.alias = settlement.localizedName .. " Garrison"
							
												if GARRISON_TRACK[facName][settlement.name][trackIndex] == nil then
													print("new entry added")
													GARRISON_TRACK[facName][settlement.name][trackIndex] = {}
													GARRISON_TRACK[facName][settlement.name][trackIndex].ID = new_unit.ID
													GARRISON_TRACK[facName][settlement.name][trackIndex].eduType = new_unit.eduEntry.eduType
													GARRISON_TRACK[facName][settlement.name][trackIndex].count = new_unit.soldierCountStratMap
												else
													print("entry found")
													local track = GARRISON_TRACK[facName][settlement.name][trackIndex]
													print("found garrison unit " .. new_unit.eduEntry.eduType
														.. " setting to " .. tostring(track.count)
														.. " max " .. tostring(new_unit.soldierCountStratMapMax))
													track.ID = new_unit.ID
													new_unit.soldierCountStratMap = track.count
													if new_unit.soldierCountStratMap < new_unit.soldierCountStratMapMax then
														print("found garrison unit " .. new_unit.eduEntry.eduType
															.. " setting to " .. tostring(new_unit.soldierCountStratMap))
													end
												end
							
												trackIndex = trackIndex + 1  -- only advance when a unit was actually created
											end
										end
									end
								end
							end
                        else
							local trackIndex = 1  -- declare before the i loop

							for i = 1, #SETT_GARRISONS[facName][k]["null"] do
								for j = 1, SETT_GARRISONS[facName][k]["null"][i][2] do
									if settlement.army.numOfUnits < 20 then
										if army:findInSettlement() then
											local unitData = SETT_GARRISONS[facName][k]["null"][i]
											local new_unit = army:createUnit(
												unitData[1], unitData[3], unitData[4], unitData[5]
											)
											if new_unit then
												new_unit.alias = settlement.localizedName .. " Garrison"
							
												if GARRISON_TRACK[facName][settlement.name][trackIndex] == nil then
													print("new entry added")
													GARRISON_TRACK[facName][settlement.name][trackIndex] = {}
													GARRISON_TRACK[facName][settlement.name][trackIndex].ID = new_unit.ID
													GARRISON_TRACK[facName][settlement.name][trackIndex].eduType = new_unit.eduEntry.eduType
													GARRISON_TRACK[facName][settlement.name][trackIndex].count = new_unit.soldierCountStratMap
												else
													print("entry found")
													local track = GARRISON_TRACK[facName][settlement.name][trackIndex]
													print("found garrison unit " .. new_unit.eduEntry.eduType
														.. " setting to " .. tostring(track.count)
														.. " max " .. tostring(new_unit.soldierCountStratMapMax))
													track.ID = new_unit.ID
													new_unit.soldierCountStratMap = track.count
													if new_unit.soldierCountStratMap < new_unit.soldierCountStratMapMax then
														print("found garrison unit " .. new_unit.eduEntry.eduType
															.. " setting to " .. tostring(new_unit.soldierCountStratMap))
													end
												end
							
												trackIndex = trackIndex + 1  -- only advance when a unit was actually created
											end
										end
									end
								end
							end
                        end
                    --end
                else
                    --for k2, v2 in pairs(SETT_GARRISONS[facName][k]) do
                        if SETT_GARRISONS[facName][k][eur_localFactionName] then
                            local army = stratmap.game.createArmyInSettlement(settlement)
							local trackIndex = 1  -- declare before the i loop

							for i = 1, #SETT_GARRISONS[facName][k][eur_localFactionName] do
								for j = 1, SETT_GARRISONS[facName][k][eur_localFactionName][i][2] do
									if settlement.army.numOfUnits < 20 then
										if army:findInSettlement() then
											local unitData = SETT_GARRISONS[facName][k][eur_localFactionName][i]
											local new_unit = army:createUnit(
												unitData[1], unitData[3], unitData[4], unitData[5]
											)
											if new_unit then
												new_unit.alias = settlement.localizedName .. " Garrison"
							
												if GARRISON_TRACK[facName][settlement.name][trackIndex] == nil then
													print("new entry added")
													GARRISON_TRACK[facName][settlement.name][trackIndex] = {}
													GARRISON_TRACK[facName][settlement.name][trackIndex].ID = new_unit.ID
													GARRISON_TRACK[facName][settlement.name][trackIndex].eduType = new_unit.eduEntry.eduType
													GARRISON_TRACK[facName][settlement.name][trackIndex].count = new_unit.soldierCountStratMap
												else
													print("entry found")
													local track = GARRISON_TRACK[facName][settlement.name][trackIndex]
													print("found garrison unit " .. new_unit.eduEntry.eduType
														.. " setting to " .. tostring(track.count)
														.. " max " .. tostring(new_unit.soldierCountStratMapMax))
													track.ID = new_unit.ID
													new_unit.soldierCountStratMap = track.count
													if new_unit.soldierCountStratMap < new_unit.soldierCountStratMapMax then
														print("found garrison unit " .. new_unit.eduEntry.eduType
															.. " setting to " .. tostring(new_unit.soldierCountStratMap))
													end
												end
							
												trackIndex = trackIndex + 1  -- only advance when a unit was actually created
											end
										end
									end
								end
							end
                        else
                            local army = stratmap.game.createArmyInSettlement(settlement)
							local trackIndex = 1  -- declare before the i loop

							for i = 1, #SETT_GARRISONS[facName][k]["null"] do
								for j = 1, SETT_GARRISONS[facName][k]["null"][i][2] do
									if settlement.army.numOfUnits < 20 then
										if army:findInSettlement() then
											local unitData = SETT_GARRISONS[facName][k]["null"][i]
											local new_unit = army:createUnit(
												unitData[1], unitData[3], unitData[4], unitData[5]
											)
											if new_unit then
												new_unit.alias = settlement.localizedName .. " Garrison"
							
												if GARRISON_TRACK[facName][settlement.name][trackIndex] == nil then
													print("new entry added")
													GARRISON_TRACK[facName][settlement.name][trackIndex] = {}
													GARRISON_TRACK[facName][settlement.name][trackIndex].ID = new_unit.ID
													GARRISON_TRACK[facName][settlement.name][trackIndex].eduType = new_unit.eduEntry.eduType
													GARRISON_TRACK[facName][settlement.name][trackIndex].count = new_unit.soldierCountStratMap
												else
													print("entry found")
													local track = GARRISON_TRACK[facName][settlement.name][trackIndex]
													print("found garrison unit " .. new_unit.eduEntry.eduType
														.. " setting to " .. tostring(track.count)
														.. " max " .. tostring(new_unit.soldierCountStratMapMax))
													track.ID = new_unit.ID
													new_unit.soldierCountStratMap = track.count
													if new_unit.soldierCountStratMap < new_unit.soldierCountStratMapMax then
														print("found garrison unit " .. new_unit.eduEntry.eduType
															.. " setting to " .. tostring(new_unit.soldierCountStratMap))
													end
												end
							
												trackIndex = trackIndex + 1  -- only advance when a unit was actually created
											end
										end
									end
								end
							end
                        end
                    --end
                end
			else
				print("wrong owner "..k)
            end
		else
			print("settlement not found "..k)
        end
    end
end

GARRISON_KILL = {}

function removeAiGarrison(faction, start)
	GARRISON_KILL = {}
	if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."removeAiGarrison");
	end
	if not SETT_GARRISONS[faction.name] then return end
    --if faction.isPlayerControlled == 0 then
        local sett_num = faction.settlementsNum;
		if faction.settlementsNum > 0 then
			for x = 0, sett_num -1 do
				local settlement = faction:getSettlement(x)
				if settlement ~= nil then
					if (settlement.siegesNum > 0 and start) then
						--do nothing
					else
						if settlement.army ~= nil then
							local army = settlement.army
							if army ~= nil then
								local num_unit = army.numOfUnits
								for i = 0, num_unit -1 do
									local stack_unit = army:getUnit(i);
									if stack_unit ~= nil then
										if string.find(stack_unit.alias, "Garrison") then
											if not GARRISON_KILL[stack_unit] then
												table.insert(GARRISON_KILL, stack_unit)
												--print(stack_unit.ID)
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if faction.stacksNum > 0 then
			for j = 0, faction.stacksNum - 1 do
				local army = faction:getArmy(j);
				if army ~= nil then
					if not army:findInSettlement() then
						local num_unit = army.numOfUnits
						for i = 0, num_unit - 1 do
							local stack_unit = army:getUnit(i);
							if stack_unit ~= nil then
								if string.find(stack_unit.alias, "Garrison") then
									if not GARRISON_KILL[stack_unit] then
										table.insert(GARRISON_KILL, stack_unit)
									end
								end
							end
						end
					end
				end
			end
		end
    --end
	for k = 1, #GARRISON_KILL do
		if GARRISON_KILL[k] ~= nil then
			if not GARRISON_KILL[k].dead then
				GARRISON_KILL[k]:kill()
			end
		end
	end
	if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."Function End");
	end
end

function addPlayerGarrison(settlement)
	if settlement ~= nil then
		--print("2")
		--if settlement.army == nil then
			--print("3")
			local army = settlement:createArmyInSettlement()
			if army ~= nil then
				--print("4")
				--local unit = army:createUnit("Dwarf Garrison", 0, 0, 0)
				--local unit = army:createUnit("Elf Garrison", 0, 0, 0)
				local unit = army:createUnit("Peasant Militia", 0, 0, 0)
				if unit ~= nil then
					--print("5")
					unit.movePoints = 0
					unit.alias = ""
				end
			end
		--else
			--print("6")
			--local unit = settlement.army:createUnit(SWAP_GARRISON[eur_player_faction.name].new[1], 0, 0, 0)
			--if unit ~= nil then
				--print("7", SWAP_GARRISON[eur_player_faction.name].new[1])
				--unit.movePoints = 0
			--end
		--end
	end
end

function legendaryGarrisons()
	SETT_GARRISONS["sicily"] = {
		["Anorien"] = {
			["null"] = {
				{ "Fountain Guard Garrison", 2, 3, 1, 1 },
				{ "Lossarnach Axemen Garrison", 2, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 3, 3, 1, 1 },
				{ "Gondor Garrison Archers", 3, 3, 1, 1 },
			},
			["england"] = {
				{ "Fountain Guard Garrison", 2, 3, 1, 1 },
				{ "Lossarnach Axemen Garrison", 2, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 3, 3, 1, 1 },
				{ "Gondor Garrison Archers", 3, 3, 1, 1 },
			},
			["spain"] = {
				{ "Fountain Guard Garrison", 2, 3, 1, 1 },
				{ "Lossarnach Axemen Garrison", 2, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 3, 3, 1, 1 },
				{ "Gondor Garrison Archers", 3, 3, 1, 1 },
			},
		},
		["Anorien_Fields"] = {
			["null"] = {
				{ "Gondor Garrison Infantry", 4, 3, 1, 1 },
			},
			["england"] = {
				{ "Gondor Garrison Infantry", 4, 3, 1, 1 },
			},
			["spain"] = {
				{ "Gondor Garrison Infantry", 4, 3, 1, 1 },
			},
		},
		["Cair_Andros"] = {
			["null"] = {
				{ "Osgiliath Veterans Garrison", 1, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 3, 3, 1, 1 },
				{ "Gondor Garrison Archers", 3, 3, 1, 1 },
			},
			["england"] = {
				{ "Osgiliath Veterans Garrison", 1, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 2, 3, 1, 1 },
				{ "Gondor Garrison Archers", 1, 3, 1, 1 },
			},
			["spain"] = {
				{ "Osgiliath Veterans Garrison", 1, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 2, 3, 1, 1 },
				{ "Gondor Garrison Archers", 1, 3, 1, 1 },
			},
		},
		["West_Osgiliath"] = {
			["null"] = {
				{ "Gondor Garrison Infantry", 2, 3, 1, 1 },
				{ "Gondor Garrison Archers", 2, 3, 1, 1 },
				{ "Osgiliath Veterans Garrison", 3, 3, 1, 1 },
			},
			["spain"] = {
				{ "Guards of Osgiliath Garrison", 1, 3, 1, 1 },
				{ "Osgiliath Veterans Garrison", 1, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 2, 3, 1, 1 },
				{ "Gondor Garrison Archers", 1, 3, 1, 1 },
			},
			["england"] = {
				{ "Guards of Osgiliath Garrison", 1, 3, 1, 1 },
				{ "Osgiliath Veterans Garrison", 1, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 2, 3, 1, 1 },
				{ "Gondor Garrison Archers", 1, 3, 1, 1 },
			},
		},
		["West_Lebennin"] = {
			["null"] = {
				{ "Gondor Garrison Infantry", 2, 3, 1, 1 },
				{ "Gondor Garrison Archers", 2, 3, 1, 1 },
			},
			["spain"] = {
				{ "Gondor Garrison Infantry", 3, 3, 1, 1 },
				{ "Gondor Garrison Archers", 2, 3, 1, 1 },
			},
			["russia"] = {
				{ "Gondor Garrison Infantry", 3, 3, 1, 1 },
				{ "Gondor Garrison Archers", 2, 3, 1, 1 },
			},
		},
		["Lebennin"] = {
			["null"] = {
				{ "Gondor Garrison Infantry", 3, 3, 1, 1 },
				{ "Gondor Garrison Archers", 3, 3, 1, 1 },
			},
			["spain"] = {
				{ "Gondor Garrison Infantry", 3, 3, 1, 1 },
				{ "Gondor Garrison Archers", 2, 3, 1, 1 },
			},
			["russia"] = {
				{ "Gondor Garrison Infantry", 3, 3, 1, 1 },
				{ "Gondor Garrison Archers", 2, 3, 1, 1 },
			},
		},
		["East_Osgiliath"] = {
			["null"] = {
				{ "Guards of Osgiliath Garrison", 1, 3, 1, 1 },
				{ "Osgiliath Veterans Garrison", 1, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 2, 3, 1, 1 },
				{ "Gondor Garrison Archers", 1, 3, 1, 1 },
			},
			["spain"] = {
				{ "Guards of Osgiliath Garrison", 1, 3, 1, 1 },
				{ "Osgiliath Veterans Garrison", 1, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 2, 3, 1, 1 },
				{ "Gondor Garrison Archers", 1, 3, 1, 1 },
			},
			["england"] = {
				{ "Guards of Osgiliath Garrison", 1, 3, 1, 1 },
				{ "Osgiliath Veterans Garrison", 1, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 2, 3, 1, 1 },
				{ "Gondor Garrison Archers", 1, 3, 1, 1 },
			},
		},
		["Lossarnach"] = {
			["null"] = {
				{ "Lossarnach Axemen Garrison", 2, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 2, 3, 1, 1 },
				{ "Gondor Garrison Archers", 1, 3, 1, 1 },
			},
			["england"] = {
				{ "Lossarnach Axemen Garrison", 2, 3, 1, 1 },
				{ "Gondor Garrison Infantry", 2, 3, 1, 1 },
				{ "Gondor Garrison Archers", 1, 3, 1, 1 },
			},
		},
	}
end
