nonCampaignMapLoaded = onCampaignMapLoaded
onCampaignMapLoaded = function(...) 
    nonCampaignMapLoaded(...)
    in_campaign_map = true

    siege = { x = 0, y = 0, img = nil }
    sword = { x = 0, y = 0, img = nil }
    hammer = { x = 0, y = 0, img = nil }
    unrest = { x = 0, y = 0, img = nil }
    poblue = { x = 0, y = 0, img = nil }
    pored = { x = 0, y = 0, img = nil }
    pogreen = { x = 0, y = 0, img = nil }
    poyellow = { x = 0, y = 0, img = nil }
    sett_upgrade = { x = 0, y = 0, img = nil }
    plague = { x = 0, y = 0, img = nil }
    gov = { x = 0, y = 0, img = nil }

    siege.x, siege.y, siege.img = M2TWEOP.loadTexture(M2TWEOP.getModPath()..'\\eopData\\images\\siege.png')
    sword.x, sword.y, sword.img = M2TWEOP.loadTexture(M2TWEOP.getModPath()..'\\eopData\\images\\sword.png')
    hammer.x, hammer.y, hammer.img = M2TWEOP.loadTexture(M2TWEOP.getModPath()..'\\eopData\\images\\hammer.png')
    unrest.x, unrest.y, unrest.img = M2TWEOP.loadTexture(M2TWEOP.getModPath()..'\\eopData\\images\\unrest.png')
    pored.x, pored.y, pored.img = M2TWEOP.loadTexture(M2TWEOP.getModPath()..'\\eopData\\images\\pored.png')
    poblue.x, poblue.y, poblue.img = M2TWEOP.loadTexture(M2TWEOP.getModPath()..'\\eopData\\images\\poblue.png')
    pogreen.x, pogreen.y, pogreen.img = M2TWEOP.loadTexture(M2TWEOP.getModPath()..'\\eopData\\images\\pogreen.png')
    poyellow.x, poyellow.y, poyellow.img = M2TWEOP.loadTexture(M2TWEOP.getModPath()..'\\eopData\\images\\poyellow.png')
    sett_upgrade.x, sett_upgrade.y, sett_upgrade.img = M2TWEOP.loadTexture(M2TWEOP.getModPath()..'\\eopData\\images\\sett_upgrade.png')
    plague.x, plague.y, plague.img = M2TWEOP.loadTexture(M2TWEOP.getModPath()..'\\eopData\\images\\plague.png')
    gov.x, gov.y, gov.img = M2TWEOP.loadTexture(M2TWEOP.getModPath()..'\\eopData\\images\\gov.png')
end

ndraw = draw
draw = function(...) 
    ndraw(...)
    waitingFuncsTick()
    if show_listview_window == true 
    and in_campaign_map == true then
        if size_listview_window then
            listviewWindow()
        else
            listviewWindowSmall()
        end
    end
    if show_listview_shortcut == true
    and in_campaign_map == true
    and (ImGui.IsKeyPressed(ImGuiKey.Tab)) then
        if show_listview_window == true then
            show_listview_window = false
        else 
            show_listview_window = true
            populate_sett_lists()
        end
    end
    if show_listview_shortcut == true
    and in_campaign_map == true
    and (ImGui.IsKeyPressed(ImGuiKey.Escape)) then
        if show_listview_window == true then
            show_listview_window = false
        end
    end
end

if onUnloadCampaign then
    nonUnloadCampaign = onUnloadCampaign
    onUnloadCampaign = function(...) 
        nonUnloadCampaign(...)
        in_campaign_map = false
        show_listview_window = false
    end
else
    function onUnloadCampaign()
        in_campaign_map = false
        show_listview_window = false
    end
end

if onPreBattlePanelOpen then
    nonPreBattlePanelOpen = onPreBattlePanelOpen
    onPreBattlePanelOpen = function(...) 
        nonPreBattlePanelOpen(...)
        in_campaign_map = false
        show_listview_window = false
    end
else
    function onPreBattlePanelOpen(eventData)
        in_campaign_map = false
        show_listview_window = false
    end
end

if onPreBattleWithdrawal then
    nonPreBattleWithdrawal = onPreBattleWithdrawal
    onPreBattleWithdrawal = function(...) 
        nonPreBattleWithdrawal(...)
        in_campaign_map = true
    end
else
    function onPreBattleWithdrawal(eventData)
        in_campaign_map = true
    end
end

if onPostBattle then
    nonPostBattle = onPostBattle
    onPostBattle = function(...) 
        nonPostBattle(...)
        in_campaign_map = true
    end
else
    function onPostBattle(eventData)
        in_campaign_map = true
    end
end

if onButtonPressed then
    nonButtonPressed = onButtonPressed
    onButtonPressed = function(eventData) 
        nonButtonPressed(eventData)
        if tableContainsListview(BUTTONS, eventData.resourceDescription) then
            wait(populate_sett_lists, 0.1)
        end
    end
else
    function onButtonPressed(eventData)
        if tableContainsListview(BUTTONS, eventData.resourceDescription) then
            wait(populate_sett_lists, 0.1)
        end
    end
end

if onScrollOpened then
    nonScrollOpened = onScrollOpened
    onScrollOpened = function(eventData) 
        nonScrollOpened(eventData)
        if eventData.resourceDescription == "own_settlement_info_scroll" then
            settlement_open = true
        end
        if tableContainsListview(SCROLLS, eventData.resourceDescription) then
            show_listview_window = false
        end
    end
else
    function onScrollOpened(eventData)
        if eventData.resourceDescription == "own_settlement_info_scroll" then
            settlement_open = true
        end
        if tableContainsListview(SCROLLS, eventData.resourceDescription) then
            show_listview_window = false
        end
    end
end

if onScrollClosed then
    nonScrollClosed = onScrollClosed
    onScrollClosed = function(eventData) 
        nonScrollClosed(eventData)
        if eventData.resourceDescription == "own_settlement_info_scroll" then
            settlement_open = false
        end
    end
else
    function onScrollClosed(eventData)
        if eventData.resourceDescription == "own_settlement_info_scroll" then
            settlement_open = false
        end
    end
end

if onPreFactionTurnStart then
    nonPreFactionTurnStart = onPreFactionTurnStart
    onPreFactionTurnStart = function(...) 
        nonPreFactionTurnStart(...)
        show_listview_window = false
    end
else
    function onPreFactionTurnStart(eventData)
        show_listview_window = false
    end  
end
