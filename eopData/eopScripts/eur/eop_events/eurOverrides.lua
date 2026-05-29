
    function onChangeTurnNum(eventData)
        if eur_turn_number ~= eur_campaign.turnNumber then
            eur_turn_number = eur_campaign.turnNumber
        end
    end

    function onButtonPressed(eventData)
        if eventData.resourceDescription == "end_turn" then
            --show_options_restart_window = true
        end
        local buttons = {
            ["decrease_taxation_gadget"] = true,
            ["increase_taxation_gadget"] = true,
            ["advanced_settlement_info_scroll"] = true,
            ["garrison_info_zoom_to_button"] = true,
            ["settlement_stats_button"] = true,
            ["advanced_stats_show_trade_button"] = true,
            ["settlement_info_construction_tab"] = true,
        }
        if eventData.resourceDescription == "mission_button" then
            if (eur_player_faction.name == "saxons" or eur_player_faction.name == "denmark" or eur_player_faction.name == "egypt") then
                eregionStoryText()
            end
        end
        if eventData.resourceDescription == "settlement_info_construction_tab" then
            show_settUI = true
            show_replen_ui = false
            hud_show_units_tab_pressed = false
        end
        if eventData.resourceDescription == "settlement_info_retrain_tab" then
            show_replen_ui = true
            hud_show_units_tab_pressed = true
        end
        if eventData.resourceDescription == "settlement_info_recruitment_tab" then
            show_replen_ui = true
            hud_show_units_tab_pressed = true
        end
        if eventData.resourceDescription == "settlement_info_repair_tab" then
            show_replen_ui = false
            hud_show_units_tab_pressed = false
        end
        if eventData.resourceDescription == "hud_show_units_tab" then
            show_replen_ui = true
            hud_show_units_tab_pressed = true
        end
        if eventData.resourceDescription == "hud_show_buildings_tab" then
            show_replen_ui = false
            hud_show_units_tab_pressed = false
        end
        if eventData.resourceDescription == "hud_show_agents_tab" then
            hud_show_units_tab_pressed = false
            show_replen_ui = false
        end
        if not buttons[eventData.resourceDescription] then
            show_settUI = false
        end
        print("button")
        print(eventData.resourceDescription)
        if in_campaign_map then
            if game_options.global_recruitment then
                recruitCheckGlobal()
            end
        end
    end

    function onGiveSettlement(eventData)
        wait(eurSwapUnitsOnTrade, 1, eventData.settlement)
    end

    function onFactionTurnEnd(eventData)
        if to_log then
            M2TWEOP.logGame("EUR SCRIPT: ".."onFactionTurnEnd");
        end
        if options_replen == true then
            eurReplenishment.replenishUnits(eventData.faction)
            if options_replen_costs then
                if eventData.faction.isPlayerControlled == 1 then
                    eurReplenishment.deductReplen()
                end
            end
        end
        if options_evolvingnames then
            checkEvolvingFaction(eventData.faction)
        end
        if collect_stats then
            collectFin(eventData.faction)
        end
        if eventData.faction.isPlayerControlled == 0 then 
            if eur_turn_number > 0 then
               removeAiGarrison(eventData.faction, false)
               wait(addAiGarrison, 0.1, eventData.faction)
                --addAiGarrison(eventData.faction)
            end
        elseif eventData.faction.isPlayerControlled == 1 then
            checkEvoCounters()
            if eur_turn_number > 0 then
                removeAiGarrison(eventData.faction, false)
            end
        end
        if options_sort == true then
            eurSortStack.eurSortStack(eventData.faction)
        end
        if options_merge then
            eurMerge.mergeFactionArmies(eventData.faction)
        end
        if options_unit_upgrades then
            checkAIUpgrades(eventData.faction)
        end
        if eur_event_active then
            if ship_4_active then
                hyarmendacilAdd()
            end
            mengood_0_check(eventData.faction.factionID)
            traitCheck(eventData.faction.factionID)
            growthCheck(eventData.faction.factionID)
            modifyEDUcheck(eventData.faction.factionID, true)
            tulkasCheck(eventData.faction.factionID, nil, false)
        end
        eurEventActiveCheck(eventData.faction.factionID, eventData.faction.name)
        eurEventUnlockCheck(eventData.faction.factionID)
        swapHeirLeaderStuffAI(eventData.faction)
        if eventData.faction.isPlayerControlled == 1 then
            dorwinionGeneralBGCheck()
        end
        if to_log then
            M2TWEOP.logGame("EUR SCRIPT END: ".."onFactionTurnEnd");
        end
    end

    function onNewGameLoaded()
        eur_campaign_options = M2TWEOP.getOptions1();
        eur_gameData = gameDataAll.get()
        eur_campaign = gameDataAll.get().campaignStruct
        eur_sMap = gameDataAll.get().stratMap
        eur_numberOfFactions = stratmap.game.getFactionsCount()
        eur_player_faction = stratmap.game.getFaction(0)
        addEURSetts()
        if chris_stuff then
            if add_setts then
                addSetts()
                addSettsBu()
                defaultEDUOffsetSetts()
                M2TWEOP.setScriptCounter("chris_setts", 1)
            end
        end
        if M2TWEOP.getOptions2().campaignDifficulty == 3 then
            show_leg_notif = true
        end
        M2TWEOP.getOptions2().toggleAutoSave = 1
        --NAZGUL:initData()
        saveDefaultSettings()
        loadOptions()
    end

    function onFactionTurnStart(eventData)
        if to_log then
            M2TWEOP.logGame("EUR SCRIPT: ".."onFactionTurnStart");
        end

        if options_evolvingnames then
            if eur_turn_number > 1 then
                --checkEvolvingFaction(eventData.faction)
            end
        end
        if options_legendary then
            legendaryDifficulty(eventData.faction)
        end
        if eventData.faction.name == "slave" then 
            if eur_turn_number == 24 then
                M2TWEOP.setScriptCounter("turn_25", 1)
            end    
            if eur_turn_number == 49 then
                M2TWEOP.setScriptCounter("turn_50", 1)
            end  
        return end
        show_events_window = false
        if eventData.faction.isPlayerControlled == 1 then
            M2TWEOP.setWatchTowerRange(watchtower_range)
            list_edu_recruitable()
            M2TWEOP.setScriptCounter("tile_messages", 0)
            stratmap.game.scriptCommand("hide_all_revealed_tiles")
            revealAllied()
            M2TWEOP.setScriptCounter("tile_messages", 1)
            if eur_player_faction.name == "turks" then
                if not anorien_swap.NDCASset then
                    if checkCounter("reunited_kingdom") then
                        removeAiGarrison(eur_player_faction, false)
                        fixRKCAS()
                        bgunlock_units_list["faramir_1"] = "The White Company"
                        bgunlock_units_list["faramir_rk"] = "The White Company"
                        anorien_swap.NDCASset = true
                    end
                end
            end
            if eventData.faction.name == "egypt" then
                if not misc_options.maernil_ring then
                    maernilRingCheck()
                end
            end
            if (eventData.faction.name == "saxons" or eventData.faction.name == "denmark" or eventData.faction.name == "egypt") then
                if eregion_realms_start < 22 then
                    eurConfed.eregionStoryCheck()
                end
                if (eventData.faction.name == "saxons" or eventData.faction.name == "denmark") then
                    if misc_options.kon_start then
                        if misc_options.kon_start_ai_eregion then
                            if not eregion_spawned then
                                if eur_turn_number >= 68 and eur_turn_number <= 80 then
                                    if math.random(1, 100) > 20 then
                                        spawnEregionHorde(false)
                                        eregion_spawned = true
                                    end
                                elseif eur_turn_number == 81 then
                                    spawnEregionHorde(false)
                                    eregion_spawned = true
                                end
                            end
                        end
                    end
                end
            else
                if game_options.eregion_spawn then
                    if not eregion_spawned then
                        if eur_turn_number >= 68 and eur_turn_number <= 80 then
                            if math.random(1, 100) > 20 then
                                spawnEregionHorde(false)
                                eregion_spawned = true
                            end
                        elseif eur_turn_number == 81 then
                            spawnEregionHorde(false)
                            eregion_spawned = true
                        end
                    end
                end
            end
            if game_options.global_recruitment then
                globalRecruitmentTurnCheck()
            end
            turnImageCheck(eventData.faction)
            genRankCheck(eventData.faction, nil)
            if eventData.faction.name == "turks" or eventData.faction.name == "sicily" then
                if not game_options.eurRKcomplete then
                    if checkCounter("reunited_kingdom") then
                        swapRKBarracks()
                        removeAiGarrison(eventData.faction, false)
                    end
                end
            end
            SwapUnitsOnConfed(eventData.faction)
        end
        if eventData.faction.isPlayerControlled == 0 then 
            if eur_turn_number > 0 then
                --removeAiGarrison(eventData.faction, false)
                 --wait(addAiGarrison, 0.01, eventData.faction)
                 --addAiGarrison(eventData.faction)
             end
            --removeAiGarrison(eventData.faction, true)
        end
        if eventData.faction.isPlayerControlled == 1 then
            swapHierStuffCheck(eur_player_faction)
            local economyTable = eur_player_faction:getFactionEconomy(0)
            finance_calc.missionIncome = economyTable.missionIncome
            finance_calc.diplomacyIncome = economyTable.diplomacyIncome
            finance_calc.tributesIncome = economyTable.tributesIncome
            finance_calc.tributesExpense = economyTable.tributesExpense
            finance_calc.diplomacyExpense = economyTable.diplomacyExpense
            if auto_turn then
                if eur_campaign.turnNumber > 1 and eur_campaign.turnNumber < auto_turn_number then
                    wait(end_turn, 2.5)
                end
            end
        end
        if to_log then
            M2TWEOP.logGame("EUR SCRIPT END: ".."onFactionTurnStart");
        end
    end

    function onGeneralCaptureSettlement(eventData)
        if game_options.global_recruitment then
            globalClearLostSett(eventData.settlement)
        end
    end

    function onBattleDeploymentPhaseCommenced(eventData)
        in_campaign_map = false
    end

    function onPreBattlePanelOpen(eventData)
        eurAddSpoils.getBattlePreInfo()
        in_campaign_map = false
    end

    function onPostBattle(eventData)
        --print("check 1")
        if eventData.faction.name == "slave" then return end
        in_campaign_map = true
        eurAddSpoils.getBattleOutcomeWin()
        if eventData.faction.isPlayerControlled == 1 then
            --print("check 2")
            show_alt_loot = true
            wait(eurAddSpoils.postBattleChecks, 0.5, eventData.faction)
            --wait(restoreSplitUnits, 2, true)
        end
    end

    function onFactionWarDeclared(eventData)
        --
    end

    function onScrollOpened(eventData)
        show_events_window = false
        if eventData.resourceDescription == "unit_info_scroll" then
            --show_upgrade_button = true
            show_unitscroll_tooltip = true
        end
        if eventData.resourceDescription == "end_game_scroll" then
            show_options_button = true
        end
        if eventData.resourceDescription == "prebattle_scroll" then
            eur_pre_battle = true
        end
        if eventData.resourceDescription == "own_settlement_info_scroll" then
            show_temp_char_stuff = true
            swap_bg_button = true
        end
        if eventData.resourceDescription == "post_battle_scroll" then
            --eurAddSpoils.getBattleOutcomeWin()
        end
        if eventData.resourceDescription == "field_construction_scroll" then
            show_buildfort = true
        end
        if eventData.resourceDescription == "hud_show_agents_tab" then
            window_states.swap_bg_window = false
        end
        if tableContains(left_panels, eventData.resourceDescription) then
            window_states.swap_bg_window = false
            window_states.show_upgrade_window = false
            window_states.show_globalrecruit_window = false
        end
        print(eventData.resourceDescription)
    end

    function onScrollClosed(eventData)
        if eventData.resourceDescription == "unit_info_scroll" then
            show_unitscroll_tooltip = false
        end
        if eventData.resourceDescription == "end_game_scroll" then
            show_options_button = false
            show_options_window = false
        end
        if eventData.resourceDescription == "prebattle_scroll" then
            eur_pre_battle = false
            eur_pre_battle_window = false
        end
        if eventData.resourceDescription == "own_settlement_info_scroll" then
            temp_char_stuff = nil
            show_temp_char_stuff = false
            swap_bg_button = false
            window_states.swap_bg_window = false
            window_states.show_globalrecruit_window = false
        end
        if eventData.resourceDescription == "diplomacy_scroll" then
            diplo_open = false
        end
        if eventData.resourceDescription == "post_battle_scroll" then
            show_alt_loot = false
        end
        if eventData.resourceDescription == "field_construction_scroll" then
            show_buildfort = false
        end
        if eventData.resourceDescription == "own_settlement_info_scroll" then
            print("tab closed")
            show_settUI = false
        end

        print(eventData.resourceDescription)
    end

    function onPreBattleWithdrawal(eventData)
        M2TW.campaign.ignoreSpeedUp = false
        M2TW.campaign.speedUp = true
        M2TW.campaign.followMovement = false
        if eventData.faction.name == "slave" then return end
        in_campaign_map = true
        eur_pre_battle = false
        eur_pre_battle_window = false
        --restoreSplitUnits(true)
        eur_already_saved = false
        losses_upkeep = 0
    end


    function onCharacterSelected(eventData)
        print(eventData.character.label)
        print("portrait:", eventData.character.portrait)
        print("custom portrait:", eventData.character.portrait_custom)
        hud_show_units_tab_pressed = true
        show_replen_ui = true
        sel_unit = nil
        window_states.swap_bg_window = false
        window_states.show_upgrade_window = false
        if eventData.character.character.characterType == 7 then
            temp_fort_char = eventData.character.character
        elseif eventData.character.character.characterType == 6 then
            if eventData.character.character.army then
                sel_unit = eventData.character.character.army:getUnit(0)
                temp_fort_char = nil
            end
        else
            temp_fort_char = nil
        end
        if options_sort == true then
            eurSortStack.eurSortOnSelected(eventData.character)
            --print(eventData.character.label)
        end
        if options_gen_upgrades then
            setBGSize(eventData.faction, nil, nil)
        end
    end

    function onAgentCreated(eventData)
        --print(eventData.character)
        --eventData.character:giveValidLabel()
        --local x, y = M2TW.stratMap.findValidTileNearTile(eventData.settlement.xCoord-2, eventData.settlement.yCoord, 2)
        --eventData.character.character:teleport(x, y);
    end

    function onDiplomacyPanelOpen(eventData)
        diplo_open = true
    end

    function onUnitDisbanded(eventData)
        if eventData.faction.isPlayerControlled == 1 then
            eurReplenishment.disbandToPool(eventData.playerUnit)
        end
    end

    function onEventCounter(eventData)
        if eventData.eventCounter == "elven_union" then
            removeAiGarrison(eur_player_faction, false)
            fixWoodElvesUnion()
        end
        if eventData.eventCounter == "reunited_kingdom_gondor_side" then
            removeAiGarrison(eur_player_faction, false)
            fixRKGondor()
        end
        if eventData.eventCounter == "reunited_kingdom" then
            if checkCounter(eventData.eventCounter) then
                faction_revival["sicily"].revived_already = true
            end
        end
        if eventData.eventCounter == "blue_wizards_arrive" then
            if checkCounter(eventData.eventCounter) then
                faction_disposition["khand"] = "good"
            end
        end
        if eventData.eventCounter == "dunland_traitor" then
            if checkCounter(eventData.eventCounter) then
                faction_disposition["aztecs"] = "neutral"
            end
        end
        if eventData.eventCounter == "kon_council_choice_accepted" then
            if checkCounter(eventData.eventCounter) then
                faction_revival["denmark"].revived_already = true
                faction_revival["saxons"].revived_already = true
            end
        end
        if eventData.eventCounter == "elven_union" then
            if checkCounter(eventData.eventCounter) then
                faction_revival["mongols"].revived_already = true
                faction_revival["ireland"].revived_already = true
            end
        end
        if eventData.eventCounter == "durin_stop_7" then
            if checkCounter(eventData.eventCounter) then
                faction_revival["hungary"].revived_already = true
                faction_revival["moors"].revived_already = true
            end
        end
        if eventData.eventCounter == "durin_kh_ok" then
            if checkCounter(eventData.eventCounter) then
                faction_revival["hungary"].revived_already = true
                faction_revival["norway"].revived_already = true
            end
        end
        if eventData.eventCounter == "fusion_bc_accepted" then
            if checkCounter(eventData.eventCounter) then
                faction_revival["normans"].revived_already = true
                faction_revival["hre"].revived_already = true
            end
        end
        
    end

    function onPreFactionTurnStart(eventData)
        M2TWEOP.setScriptCounter("garrison_skip", 0)
        mordorAnorienCheck(eventData.faction)
        isengardSwapCheck(eventData.faction)
        amonlancSwapCheck(eventData.faction)
        minasIthilSwapCheck(eventData.faction)
        carasSwapCheck(eventData.faction)
        helmSwapCheck(eventData.faction)
        tharbadSwapCheck(eventData.faction)
        amonSulSwapCheck(eventData.faction)
        if custom_cas.tauriel then
            spawnTauriel()
        end
        if custom_cas.galadriel then
            spawnGaladriel()
        end

        if eventData.faction.name == "slave" then return end
        if eventData.faction.isPlayerControlled == 0 then
            spawnGeneralLargeArmy(eventData.faction)
        end
        addWatchtowers(eventData.faction)
        if options_gen_upgrades then
            setBGSize(eventData.faction, nil, nil)
        end
        if eventData.faction.isPlayerControlled == 1 then
            if eur_turn_number > 0 then
                if set_mods then
                    setEOPModifiers()
                end
            else
                getEOPModifiers()
            end
        end
    end

    function onUnitTrained(eventData)
        --M2TWEOP.logGame("unit trained test");
        if eventData.faction.name == "slave" then return end
        if options_gen_upgrades then
            setBGSize(nil, nil, eventData.playerUnit)
        end
        if eventData.faction == eur_player_faction then
            print(eventData.playerUnit.eduEntry.eduEntry)
        end
        if eventData.faction == eur_player_faction then
            tulkasCheck(eventData.faction.factionID, eventData.playerUnit, true)
        end
        if collect_stats then
            countUnitsTrained(eventData.faction.localizedName, eventData.playerUnit.eduEntry.eduType)
        end
    end

    function onSettlementTurnStart(eventData)
        if game_options.convert_buildings then
            eurfixBuildingPics(eventData.settlement)
        end
        if to_log then
            M2TWEOP.logGame("EUR SCRIPT: ".."onSettlementTurnStart");
        end
        if strat_cas_setts[eventData.settlement.name] then
            if not cas_set_already[eventData.settlement.name] then
                setCasSett(eventData.settlement)
                cas_set_already[eventData.settlement.name] = true
            end
        end
        if to_log then
            M2TWEOP.logGame("EUR SCRIPT END: ".."onSettlementTurnStart");
        end
    end

    function onSettlementSelected(eventData)
        print(eventData.settlement.name)
        print(eventData.settlement.regionID)
        if hud_show_units_tab_pressed then
            show_replen_ui = true
        else
            show_replen_ui = false
        end
        sel_unit = nil
        window_states.swap_bg_window = false
        window_states.show_upgrade_window = false
        if eventData.settlement.governor ~= nil then
            if eventData.settlement.governor.characterType == 7 then
                temp_fort_char = eventData.settlement.governor
            else
                temp_fort_char = nil
            end
        else
            temp_fort_char = nil
            if eventData.settlement.army ~= nil then
                if eventData.settlement.army.numOfUnits > 0 then
                    sel_unit = eventData.settlement.army:getUnit(0)
                end
            end
        end
        if options_gen_upgrades then
            setBGSize(eventData.settlement.ownerFaction, nil, nil)
        end
        --genPoolReset()
    end

    function onGovernorUnitTrained(eventData)
        if options_gen_upgrades then
            setBGSize(eventData.faction, nil, nil)
        end
    end

    function onBecomesFactionLeader(eventData)
        if eventData.faction.name == "slave" then return end
        if eur_turn_number > 5 then
            galadrielTitleCheck()
        end
        swapHierLeaderStuff(eventData.character.character, true)
    end

    function onBecomesFactionHeir(eventData)
        if eventData.faction.name == "slave" then return end
        swapHierLeaderStuff(eventData.character.character, false)
    end

function onGeneralAssaultsGeneral(eventData)
    if options_hardcore then
        if eventData.characterType == 3 then
            eur_campaign.restrictAutoResolve = 0
        else
            eur_campaign.restrictAutoResolve = 1
        end
    end
end

function onNewGameStart()
    M2TWEOP.setScriptCounter("mithlond_controlled", 1)
    if not options_first_run then
        resetGameVars()
    end
    if collect_stats then
        initTurnStatTable()
    end
end

function onCeasedFactionLeader(eventData)
    if options_poe then
        if ELVEN_FACTIONS[eur_localFactionName] then
            --EurElvenPassing.onCeasedFactionLeader(eventData)
        end
    end
end

function onAddedToTrainingQueue(eventData)
    if game_options.global_recruitment then
        recruitCheckGlobal()
    end
end

function onRemoveFromUnitQueue(eventData)
    if game_options.global_recruitment then
        recruitCheckGlobal()
    end
end

function onUngarrisonedSettlement(eventData)
    if eventData.settlement.ownerFaction == eur_player_faction then
        if deploy_garrison then
           --wait(eurGarrisons.addPlayerGarrison, 0.2, eventData.settlement)
        end
    end
end

function onCharacterTurnStart(eventData)
    if eventData.characterType == 7 then
        eurReplenishment.setGeneralLevel(eventData.character)
        eurReplenishment.setRadagastLevel(eventData.character)
        if eventData.faction.name == "sicily" then
            addGondorFiefTrait(eventData.character)
        end
    end
    fixCharUniqueName(eventData.character)
end

function onCharacterComesOfAge(eventData)
    if eventData.faction.name == "sicily" then
        addGondorFiefTrait(eventData.character)
    end
    fixCharUniqueName(eventData.character)
end

function onOfferedForAdoption(eventData)
    if eventData.faction.name == "sicily" then
        addGondorFiefTrait(eventData.character)
    end
end

function onLesserGeneralOfferedForAdoption(eventData)
    if eventData.faction.name == "sicily" then
        addGondorFiefTrait(eventData.character)
    end
    fixCharUniqueName(eventData.character)
end

function onOfferedForMarriage(eventData)
    if eventData.faction.name == "sicily" then
        addGondorFiefTrait(eventData.character)
    end
    fixCharUniqueName(eventData.character)
end

function onBrotherAdopted(eventData)
    if eventData.faction.name == "sicily" then
        addGondorFiefTrait(eventData.character)
    end
    fixCharUniqueName(eventData.character)
end

function charsOff()
    local characterNum = eur_player_faction.numOfCharacters
    for i = 0, characterNum - 1 do
    local char = eur_player_faction:getCharacter(i)
    print(char.characterRecord.fullName)
    print(char.characterType)
        --if char.isGeneral == true then
            if char.characterType == 7 then
                if char.characterRecord:isHeir() then
                    --
                elseif char.characterRecord:isLeader() then
                    --
                else
                    --char:sendOffMap()
                    --print("2")
                end
            end
        --end
    end
end

---@class (exact) waitCallback
---@field tick integer
---@field hasFired boolean
---@field callback function

CAMPAIGN_WAIT = {
    ---@type table<integer, waitCallback>
    callbacks = {},
}

function CAMPAIGN_WAIT:wait(duration, callback)
    local tick = CAMPAIGN.tickCount + duration
    table.insert(self.callbacks, {
        tick = tick,
        callback = callback,
        hasFired = false,
    })
    --log(stringFormat("Wait started: {1} ticks, {2} seconds", duration, duration / 10.0, logLevel.TRACE))
end

function CAMPAIGN_WAIT:waitSeconds(duration, callback)
    self:wait(duration * 10, callback)
end

function CAMPAIGN_WAIT:execute()
    for key, element in pairs(self.callbacks) do
        if CAMPAIGN.tickCount >= element.tick and not element.hasFired then
            element.hasFired = true
            if element.callback then
                element.callback()
            end
            --log("Wait Finished", logLevel.TRACE)
            self.callbacks[key] = nil
        end
    end
end

function onCampaignTick()
    if in_campaign_map then
        M2TW.campaign.ignoreSpeedUp = false
        M2TW.campaign.speedUp = true
        M2TW.campaign.followMovement = false
    end
    --CAMPAIGN_WAIT:execute()
end

function onCharacterTurnEnd(eventData)
    if eventData.characterType == 7 then
        eurReplenishment.setGeneralLevel(eventData.character)
    end
    M2TW.campaign.ignoreSpeedUp = false
    M2TW.campaign.speedUp = true
    M2TW.campaign.followMovement = false
end

function onEduParsed()
    --EDU_MODIFIERS:updateDescriptions()

end

function onUIElementVisible(eventData)
        print(eventData.resourceDescription)
    end




