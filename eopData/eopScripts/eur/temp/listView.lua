--1 or 0, enable console or not
--console shortcut - ctrl+~
enableConsole = 1
--1 if you want the game to crash on an error in your script (Lua exception). You will still receive a message detailing the error, but closing it will also close the game.
terminateAtLuaException = 0

settlement_str = ""

show_listview_window = false
show_listview_shortcut = true
size_listview_window = true

in_campaign_map = false

show_filter_window = false
show_search_window = false

status_col_len = 140

listview_checkbox = false
settlement_open = false
population_checkbox = true
order_checkbox = true
growth_checkbox = true
queue_checkbox = true
income_checkbox = true
governor_checkbox = true
upgrade_checkbox = true
plague_checkbox = true
bu_avail_checkbox = true
siege_checkbox = true
population_checkbox = true

filter_option2 = 1
filter_population_checkbox = false
filter_growth_checkbox = false

show_growth = true
show_pop = true
show_order = true
show_income = true
show_queue = true
show_governor = true
show_bu_avail = true
show_upgrade = true
show_plague = true
show_siege = true

currently_sorting = false
current_sort = 0
sort_option = 0
sorted_ascending = true
curr_set_name = ""
curr_set_name2 = ""

SETT_VIEW = {}
CHAR_VIEW = {}

CHAR_VIEW = {}

CHAR_IN_SETTFORT = {}

SETT_LEVEL = {
    [0] = {
        level = {"Village", "Town", "Large Town", "City", "Large City", "Huge City"}
    },
    [1] = {
        level = {"Keep", "Castle", "Stronghold", "Fortress", "Citadel"}
    }
}

SCROLLS = {
    "army_listview",
    "character_listview",
    "advanced_settlement_info_scroll",
    "unit_info_scroll",
    "family_tree_scroll",
    "faction_ranking_scroll",
    "siege_scroll",
    "prebattle_scroll",
    "agent_info_scroll",
    "building_info_scroll",
    "combined_listview_scroll",
    "siege_scroll",
}

BUTTONS = {
    "increase_taxation_gadget",
    "decrease_taxation_gadget",
    "settlement_info_construction_tab",
}
VALID_CHAR_TYPES = {
    3,
    6,
    7,
}

--HELPER FUNCTIONS--

function sort_on_values(t,...)
    local a = {...}
    table.sort(t, function (u,v)
    for i = 1, #a do
      if u[a[i]] > v[a[i]] then return false end
      if u[a[i]] < v[a[i]] then return true end
    end
    end)
end

function tableContainsListview(table, value)
    for i = 1, #table do
        if (table[i] == value) then
            return true
        end
    end
    return false
end

function compare_up(a, b)
    return a[sort_option] < b[sort_option]
end

function compare_down(a, b)
    return a[sort_option] > b[sort_option]
end
--[[
Action = {}
function Action:new(func, waitTime, ...)
    newObj = {
        func = func or nil,
         -- store func pointer
        waitTime = waitTime,
         -- store time to wait
        waitEndTime = nil,
         -- we initialize end time later
        args = {...} or {}
     -- pack and store function args
    }
    self.__index = self
    return setmetatable(newObj, self)
end

function Action:execute()
    self.func(unpack(self.args)) -- unpack all args and execute function
end

-- table with our waiting functions
ourWaitingFuncs = {}

function waitingFuncsTick()
    local currTime = ImGui.GetTime() -- store time once in func
    for i = #ourWaitingFuncs, 1, -1 do -- check all actions
        if (ourWaitingFuncs[i].waitEndTime == nil) then -- if we not calc end time yet
            ourWaitingFuncs[i].waitEndTime = currTime + ourWaitingFuncs[i].waitTime --calc wait end time for function
        end
        if ourWaitingFuncs[i].waitEndTime <= currTime then -- if now time to execute function
            local currAction = table.remove(ourWaitingFuncs, i) -- table.remove removes our action from table and return it
            currAction:execute() -- execute action. Action destroyed when we out from this code block(it`s local)
        end
    end
end

function wait(functionName, sec, arg1, arg2, arg3, arg4, arg5) -- more arguments can be added
    table.insert(ourWaitingFuncs, Action:new(functionName, sec, arg1, arg2, arg3, arg4, arg5))
end
]]
--HELPER FUNCTIONS--

--TRIGGER FUNCTIONS--

function sort_listview(current_sort, reorder)
    currently_sorting = true
    if sort_option ~= current_sort then
        reorder = false
        sorted_ascending = false
    end
    sort_option = current_sort
    if current_sort > 0 then
        if reorder then
            if sorted_ascending == true then
                sorted_ascending = false
                table.sort(SETT_VIEW, compare_up)
            else
                sorted_ascending = true
                table.sort(SETT_VIEW, compare_down)
            end
                currently_sorting = false
        else
            if sorted_ascending == true then
                table.sort(SETT_VIEW, compare_down)
            else
                table.sort(SETT_VIEW, compare_up)
            end
        end
    end
end

function populate_sett_lists()
    SETT_VIEW = {}
    local campaign = gameDataAll.get().campaignStruct
    local playerFactionId = M2TWEOP.getLocalFactionID()
    local faction = campaign.factionsSortedByID[playerFactionId + 1]

    local sett_num = faction.settlementsNum
    for x = 0, sett_num - 1 do
        local curr_set = faction:getSettlement(x)
        table.insert(
            SETT_VIEW,
            {
                curr_set.localizedName,
                 --1
                curr_set.populationSize,
                 --2
                curr_set.settlementStats.PublicOrder, --3
                curr_set.level,
                 --4
                curr_set,
                 --5
                (curr_set.settlementStats.TotalIncomeWithoutAdmin + curr_set.settlementStats.AdminIncome +
                    curr_set.settlementStats.BuildingsIncome -
                    curr_set.settlementStats.CorruptionExpense -
                    curr_set.settlementStats.RecruitmentExpense -
                    curr_set.settlementStats.DiplomaticExpense -
                    curr_set.settlementStats.EntertainmentExpense -
                    curr_set.settlementStats.DevastationExpense),
                 --6
                (curr_set.settlementStats.PopGrowthBaseFarm + curr_set.settlementStats.PopGrowthTaxBonus +
                    curr_set.settlementStats.PopGrowthFarms +
                    curr_set.settlementStats.PopGrowthHealth +
                    curr_set.settlementStats.PopGrowthBuildings +
                    curr_set.settlementStats.PopGrowthEntertainment +
                    curr_set.settlementStats.PopGrowthTrade +
                    curr_set.settlementStats.PopGrowthGovernorInfluence -
                    curr_set.settlementStats.PopGrowthSqualor -
                    curr_set.settlementStats.PopGrowthPlague -
                    curr_set.settlementStats.PopGrowthTaxPenalty),
                 --7
                curr_set.siegesNum,
                --8
                curr_set.turmoil,
                --9
                curr_set.plagued,
                --10
                curr_set.settlementTaxLevel,
                --11
                0,
                --12 status_sort
                0,
                --13 queue_sort
            }
        )
    end
    --show_listview_window = true
    if current_sort > 0 then
        sort_listview(current_sort, false)
    end
end

function listviewWindow2()
    local size_x, size_y = ImGui.GetWindowSize()
    --ImGui.Image(BANNER_IMAGE.img, 550, 250)
    if (ImGui.BeginTabBar("lists tab bar")) then
        if (ImGui.BeginTabItem("Settlements")) then
            listviewSettlementTab()
            ImGui.EndTabItem()
        end
        if (ImGui.BeginTabItem("Agents")) then
            --listviewAgentsTab()
            ImGui.Text("Not yet")
            ImGui.EndTabItem()
        end
        ImGui.SameLine()
        if (ImGui.ArrowButton("listview_window", ImGuiDir.Left)) then
            size_listview_window = false
        end
    end
end

function listviewWindowSmall2()
    ImGui.SetNextWindowBgAlpha(0)
    --ImGui.SetNextWindowSize(260+status_col_len, 500)
    ImGui.Begin("listview_window small", ImGuiChildFlags.FrameStyle)
    ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 0.1, 0.1)
    ImGui.PushStyleColor(ImGuiCol.Button, 1, 1, 1, 0.1)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1, 1, 1, 0.5)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1, 1, 1, 0.5)
    size_x, size_y = ImGui.GetWindowSize()
    --ImGui.Image(BANNER_IMAGE.img, 550, 250)
    if (ImGui.BeginTabBar("lists tab bar small")) then
        if (ImGui.BeginTabItem("Settlements##2")) then
            listviewSettlementTabSmall()
            ImGui.EndTabItem()
        end
        if (ImGui.BeginTabItem("Global##2")) then
            --listviewAgentsTabSmall()
            ImGui.Text("Not yet")
            ImGui.EndTabItem()
        end
        ImGui.SameLine()
        if (ImGui.ArrowButton("listview_window##2", ImGuiDir.Right)) then
            size_listview_window = true
        end
    end
    ImGui.End()
end

function listviewSettlementTab()
    local col_no = 8
    status_col_len = 140
        if (filter_population_checkbox) then 
            filter_population_checkbox, pressed = ImGui.Checkbox("Show Filters", true)
            show_filter_window = true
        else filter_population_checkbox, pressed = ImGui.Checkbox("Show Filters", false)
            show_filter_window = false
        end

        if (filter_growth_checkbox) then 
            filter_growth_checkbox, pressed = ImGui.Checkbox("Search: ", true)
            show_search_window = true
        else filter_growth_checkbox, pressed = ImGui.Checkbox("Search: ", false) 
            filter_text = ""
            show_search_window = false
        end
    
        if show_search_window == true then
            ImGui.BeginChild("Child Window##A01aaaaaaa", 960, 50)
            filter_text, filter_selected = ImGui.InputText("", filter_text)
            filter_option2, pressed = ImGui.RadioButton("Settlements ", filter_option2, 1)
            --filter_option2, pressed = ImGui.RadioButton("Available Units ", filter_option2, 2)
            --filter_option2, pressed = ImGui.RadioButton("Buildings ", filter_option2, 3)
            ImGui.EndChild() 
        end
        if show_filter_window == true then
            ImGui.BeginChild("Child Window##A01aaaaa", 960, 120)

            if (governor_checkbox) then
                governor_checkbox, pressed = ImGui.Checkbox("Governor Present", true)
                show_governor = true
                status_col_len = status_col_len
                --col_no = col_no + 1
            else
                governor_checkbox, pressed = ImGui.Checkbox("Governor Present", false)
                show_governor = false
                status_col_len = status_col_len-20
            end
            ImGui.SameLine()
            if (siege_checkbox) then
                siege_checkbox, pressed = ImGui.Checkbox("Beseiged", true)
                show_siege = true
                status_col_len = status_col_len
                --col_no = col_no + 1
            else
                siege_checkbox, pressed = ImGui.Checkbox("Beseiged", false)
                show_siege = false
                status_col_len = status_col_len-20
            end
            ImGui.SameLine()
            if (plague_checkbox) then
                plague_checkbox, pressed = ImGui.Checkbox("Plagued", true)
                show_plague = true
                status_col_len = status_col_len
                --col_no = col_no + 1
            else
                plague_checkbox, pressed = ImGui.Checkbox("Plagued", false)
                show_plague = false
                status_col_len = status_col_len-20
            end
            ImGui.SameLine()
            if (upgrade_checkbox) then
                upgrade_checkbox, pressed = ImGui.Checkbox("Upgrade Available", true)
                show_upgrade = true
                status_col_len = status_col_len
                --col_no = col_no + 1
            else
                upgrade_checkbox, pressed = ImGui.Checkbox("Upgrade Available", false)
                show_upgrade = false
                status_col_len = status_col_len-20
            end
            ImGui.SameLine()

            if (bu_avail_checkbox) then
                bu_avail_checkbox, pressed = ImGui.Checkbox("Building Available", true)
                show_bu_avail = true
                --col_no = col_no + 1
            else
                bu_avail_checkbox, pressed = ImGui.Checkbox("Building Available", false)
                show_bu_avail = false
                status_col_len = status_col_len-20
            end

            ImGui.NewLine()
            if (order_checkbox) then
                order_checkbox, pressed = ImGui.Checkbox("Public Order", true)
                show_order = true
                --col_no = col_no + 1
            else
                order_checkbox, pressed = ImGui.Checkbox("Public Order", false)
                show_order = false
            end

            ImGui.SameLine()
            if (growth_checkbox) then
                growth_checkbox, pressed = ImGui.Checkbox("Growth", true)
                show_growth = true
                --col_no = col_no + 1
            else
                growth_checkbox, pressed = ImGui.Checkbox("Growth", false)
                show_growth = false
            end

            ImGui.SameLine()
            if (queue_checkbox) then
                queue_checkbox, pressed = ImGui.Checkbox("Queue", true)
                show_queue = true
                --col_no = col_no + 1
            else
                queue_checkbox, pressed = ImGui.Checkbox("Queue", false)
                show_queue = false
            end

            ImGui.SameLine()
            if (income_checkbox) then
                income_checkbox, pressed = ImGui.Checkbox("Income", true)
                show_income = true
                --col_no = col_no + 1
            else
                income_checkbox, pressed = ImGui.Checkbox("Income", false)
                show_income = false
            end
            ImGui.EndChild() 
        end

    ImGui.NewLine()
    ImGui.BeginChild("Child Window##A01", 960, 50)
    ImGui.Columns(col_no, "MyColumnWithBorder", false)
    ImGui.Text("Settlement")
    if (ImGui.ArrowButton("Settlement_arrow", ImGuiDir.Down)) then
        current_sort = 1
        wait(sort_listview, 0.05, current_sort, true)
    end
    ImGui.NextColumn()
    ImGui.Text("Status")
    if (ImGui.ArrowButton("Status_arrow", ImGuiDir.Down)) then
        current_sort = 12
        wait(sort_listview, 0.05, current_sort, true)
    end
    ImGui.NextColumn()
    ImGui.Text("Level")
    level_col = ImGui.GetColumnIndex()
    if (ImGui.ArrowButton("Level_arrow", ImGuiDir.Down)) then
        current_sort = 4
        wait(sort_listview, 0.05, current_sort, true)
    end
    if show_pop == true then
        ImGui.NextColumn()
        ImGui.Text("Population")
        pop_col = ImGui.GetColumnIndex()
        if (ImGui.ArrowButton("Population_arrow", ImGuiDir.Down)) then
            current_sort = 2
            wait(sort_listview, 0.05, current_sort, true)
        end
    end
    if show_growth == true then
        ImGui.NextColumn()
        ImGui.Text("Growth")
        growth_col = ImGui.GetColumnIndex()
        if (ImGui.ArrowButton("Growth_arrow", ImGuiDir.Down)) then
            current_sort = 7
            wait(sort_listview, 0.05, current_sort, true)
        end
    end
    if show_order == true then
        ImGui.NextColumn()
        ImGui.Text("Public Order")
        if (ImGui.ArrowButton("Order_arrow", ImGuiDir.Down)) then
            current_sort = 3
            wait(sort_listview, 0.05, current_sort, true)
        end
    end
    if show_income == true then
        ImGui.NextColumn()
        ImGui.Text("Income")
        income_col = ImGui.GetColumnIndex()
        if (ImGui.ArrowButton("income_arrow", ImGuiDir.Down)) then
            current_sort = 6
            wait(sort_listview, 0.05, current_sort, true)
        end
    end
    if show_queue == true then
        ImGui.NextColumn()
        ImGui.Text("In Queue")
        if (ImGui.ArrowButton("Queue_arrow", ImGuiDir.Down)) then
            current_sort = 13
            wait(sort_listview, 0.05, current_sort, true)
        end
    end

    count = ImGui.GetColumnsCount()
    for j = 2, count - 1 do
        ImGui.SetColumnWidth(j, 100)
    end
    ImGui.SetColumnWidth(0, 120)
    ImGui.SetColumnWidth(1, status_col_len)
    ImGui.SetColumnWidth(growth_col, 70)
    ImGui.SetColumnWidth(level_col, 100)
    ImGui.SetColumnWidth(pop_col, 90)
    ImGui.SetColumnWidth(income_col, 70)

    ImGui.EndChild()

    ImGui.NewLine()
    ImGui.BeginChild("Child Window##A02", 960, 640)

    for i = 1, #SETT_VIEW do

        if filter_option2 == 1 then
            settlement_str = string.lower(SETT_VIEW[i][5].localizedName)
            text1 = filter_text
            text2 = ""
            text3 = ""
            filter_1 = true
            filter_2 = false
            filter_3 = false
        elseif filter_option2 == 2 then
            text2 = filter_text
            text1 = ""
            text3 = ""
            filter_1 = false
            filter_2 = true
            filter_3 = false
        elseif filter_option2 == 3 then
            text3 = filter_text
            text2 = ""
            text1 = ""
            filter_1 = false
            filter_2 = false
            filter_3 = true
        end
        if string.match(settlement_str, string.lower(text1)) then

            ImGui.SetNextWindowBgAlpha(1)
            ImGui.BeginChild("Child Window##A" .. tostring(i), 960, 25)

            hovered = ImGui.IsWindowHovered(ImGuiHoveredFlags.ChildWindows)
            if hovered then
                ImGui.PushStyleColor(ImGuiCol.ChildWindowBg, 1, 1, 0.4, 1)

                clickedleft = ImGui.IsMouseClicked(ImGuiMouseButton.Left, false)
                if clickedleft then
                    print(SETT_VIEW[i][1] .. " clicked left")
                    stratmap.game.scriptCommand("select_settlement", SETT_VIEW[i][5].name)
                    stratmap.camera.jump(SETT_VIEW[i][5].xCoord - 10, SETT_VIEW[i][5].yCoord)
                    curr_set_name2 = SETT_VIEW[i][1]
                end
                clickedright = ImGui.IsMouseClicked(ImGuiMouseButton.Right, false)
                if clickedright then
                    print(SETT_VIEW[i][1] .. " clicked right")
                    if settlement_open == true then
                        curr_set_name = SETT_VIEW[i][1]
                        if curr_set_name2 == curr_set_name then
                            stratmap.game.scriptCommand("select_settlement", SETT_VIEW[i][5].name)
                            stratmap.camera.jump(SETT_VIEW[i][5].xCoord - 10, SETT_VIEW[i][5].yCoord)
                            local con_button = gameSTDUI.getUiElement("construction_button")
                            con_button:execute()
                        else
                            stratmap.game.scriptCommand("select_settlement", SETT_VIEW[i][5].name)
                            stratmap.camera.jump(SETT_VIEW[i][5].xCoord - 10, SETT_VIEW[i][5].yCoord)
                            curr_set_name2 = SETT_VIEW[i][1]
                        end
                    elseif settlement_open == false then
                        stratmap.game.scriptCommand("select_settlement", SETT_VIEW[i][5].name)
                        stratmap.camera.jump(SETT_VIEW[i][5].xCoord - 10, SETT_VIEW[i][5].yCoord)
                        local con_button = gameSTDUI.getUiElement("construction_button")
                        con_button:execute()
                        curr_set_name2 = SETT_VIEW[i][1]
                    end
                end
            else
                ImGui.PushStyleColor(ImGuiCol.ChildWindowBg, 1, 1, 1, 1)
            end
            
            ImGui.Columns(col_no, "MyColumnWithBorder", false)
            ImGui.Text(SETT_VIEW[i][1])
            ImGui.NextColumn()
            if show_governor then
                ImGui.BeginChild("Child Window gov", 21, 21)
                if SETT_VIEW[i][5].governor ~= nil then
                    SETT_VIEW[i][12] = SETT_VIEW[i][12]+2
                    ImGui.Image(gov.img, 20, 20)
                    hovered_siege = ImGui.IsWindowHovered(ImGuiHoveredFlags.ChildWindows)
                    if hovered_siege then
                        ImGui.BeginTooltip()
                        ImGui.TextColored(1, 1, 1, 1, "Governor: "..SETT_VIEW[i][5].governor.namedCharacter.localizedDisplayName)
                        ImGui.EndTooltip()
                    end
                end
                ImGui.EndChild()
                ImGui.SameLine()
            end
            --ImGui.SameLine()
            if show_siege then
                ImGui.BeginChild("Child Window siege", 21, 21)
                if SETT_VIEW[i][5].siegesNum > 0 then
                    SETT_VIEW[i][12] = SETT_VIEW[i][12]+100
                    ImGui.Image(siege.img, 20, 20)
                    hovered_siege = ImGui.IsWindowHovered(ImGuiHoveredFlags.ChildWindows)
                    if hovered_siege then
                        ImGui.BeginTooltip()
                        ImGui.TextColored(1, 1, 1, 1, "Under siege")
                        ImGui.EndTooltip()
                    end
                end
                ImGui.EndChild()
                ImGui.SameLine()    
            end
            if show_plague then
                ImGui.BeginChild("Child Window plague", 21, 21)
                if SETT_VIEW[i][5].plagued == 1 then
                    SETT_VIEW[i][12] = SETT_VIEW[i][12]+1
                    ImGui.Image(plague.img, 20, 20)
                    local hovered_siege = ImGui.IsWindowHovered(ImGuiHoveredFlags.ChildWindows)
                    if hovered_siege then
                        ImGui.BeginTooltip()
                        ImGui.TextColored(1, 1, 1, 1, "Plague")
                        ImGui.EndTooltip()
                    end
                end
                ImGui.EndChild()
                ImGui.SameLine()
            end
            --f
            --[[local con_options = SETT_VIEW[1][5]:getConstructionOptions()
            if show_upgrade then
                ImGui.BeginChild("Child Window upgrade available", 21, 21)
                if con_options ~= nil then
                    if con_options.buildingNum ~= 0 then
                        for j = 0, con_options.buildingNum - 1 do
                            local building = con_options:getConstructionOption(j)
                            if building.edbEntry.isCoreBuilding == 1 then
                                if building.building == nil then
                                    SETT_VIEW[i][12] = SETT_VIEW[i][12]+10
                                    ImGui.Image(sett_upgrade.img, 20, 20)
                                    local hovered_siege = ImGui.IsWindowHovered(ImGuiHoveredFlags.ChildWindows)
                                    if hovered_siege then
                                        ImGui.BeginTooltip()
                                        ImGui.TextColored(1, 1, 1, 1, "Upgrade available")
                                        ImGui.EndTooltip()
                                    end
                                end
                            end
                        end
                    end
                end
                ImGui.EndChild()
                ImGui.SameLine()
            end
            if show_bu_avail then
                ImGui.BeginChild("Child Window building available", 21, 21)
                local curr_building = SETT_VIEW[i][5].buildingsQueue.numBuildingsInQueue
                if con_options ~= nil then
                    if con_options.buildingNum ~= 0 then
                        if con_options.buildingNum > 0 
                        and curr_building == 0 then
                            local building = con_options:getConstructionOption(j)
                            SETT_VIEW[i][12] = SETT_VIEW[i][12]+5
                            ImGui.Image(hammer.img, 20, 20)
                            local hovered_siege = ImGui.IsWindowHovered(ImGuiHoveredFlags.ChildWindows)
                            if hovered_siege then
                                ImGui.BeginTooltip()
                                ImGui.TextColored(1, 1, 1, 1, "Buildings available")
                                ImGui.EndTooltip()
                            end
                        end
                    end
                end
                ImGui.EndChild()
            end]]
            ImGui.NextColumn()
            index = ImGui.GetColumnIndex()
            ImGui.Text(SETT_LEVEL[SETT_VIEW[i][5].isCastle].level[(SETT_VIEW[i][5].level + 1)])
            if show_pop == true then
                ImGui.NextColumn()
                pop_col = ImGui.GetColumnIndex()
                ImGui.Text(SETT_VIEW[i][2])
            end
            if show_growth == true then
                ImGui.NextColumn()
                growth_col = ImGui.GetColumnIndex()
                ImGui.Text((SETT_VIEW[i][7] / 2))
            end
            if show_order == true then
                ImGui.NextColumn()
                if SETT_VIEW[i][3] <= 80
                and SETT_VIEW[i][3] >= 75 then
                    ImGui.Image(poblue.img, 20, 20)
                elseif SETT_VIEW[i][3] <= 95
                and SETT_VIEW[i][3] >= 85 then
                    ImGui.Image(poyellow.img, 20, 20)
                elseif SETT_VIEW[i][3] <= 75 then
                    ImGui.Image(pored.img, 20, 20)
                else
                    ImGui.Image(pogreen.img, 20, 20)
                end
                ImGui.SameLine()
                ImGui.Text(SETT_VIEW[i][3])
                ImGui.SameLine()
                ImGui.BeginChild("Child Window unrest", 21, 21)
                if SETT_VIEW[i][5].isProvokedRebellion then
                    ImGui.Image(unrest.img, 20, 20)
                    hovered_siege = ImGui.IsWindowHovered(ImGuiHoveredFlags.ChildWindows)
                    if hovered_siege then
                        ImGui.BeginTooltip()
                        ImGui.TextColored(1, 1, 1, 1, "Rioting")
                        ImGui.EndTooltip()
                    end
                end
                ImGui.EndChild()
            end
            if show_income == true then
                ImGui.NextColumn()
                ImGui.Text(SETT_VIEW[i][6])
            end
            if show_queue == true then
                ImGui.NextColumn()
                local curr_building = SETT_VIEW[i][5].buildingsQueue.numBuildingsInQueue
                ImGui.BeginChild("Child Window cu_rec", 21, 21)
                if curr_building ~= nil then
                    if curr_building > 0 then
                        SETT_VIEW[i][13] = SETT_VIEW[i][13]+2
                        ImGui.Image(hammer.img, 20, 20)
                        local hovered_siege = ImGui.IsWindowHovered(ImGuiHoveredFlags.ChildWindows)
                        if hovered_siege then
                            ImGui.BeginTooltip()
                            ImGui.TextColored(1, 1, 1, 1, "Currently building")
                            ImGui.EndTooltip()
                        end
                    end
                end
                ImGui.EndChild()
            end
            for j = 2, count - 1 do
                ImGui.SetColumnWidth(j, 100)
            end
            ImGui.SetColumnWidth(0, 120)
            ImGui.SetColumnWidth(1, status_col_len)
            ImGui.SetColumnWidth(growth_col, 70)
            ImGui.SetColumnWidth(level_col, 100)
            ImGui.SetColumnWidth(pop_col, 90)
            ImGui.SetColumnWidth(income_col, 70)
            ImGui.PopStyleColor()
            ImGui.EndChild()
        end
    end
    for i = 0, eur_player_faction.settlementsNum - 1 do
        local sett = eur_player_faction:getSettlement(i)
        ImGui.SetNextWindowBgAlpha(0.0)
        ImGui.BeginChild(sett.name..tostring(i).."1", 940*eurbackgroundWindowSizeRight, 62*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
        local con_options = sett:getConstructionOptions()
        if con_options ~= nil then
            if con_options.buildingNum ~= 0 then
                for j = 0, con_options.buildingNum - 1 do
                    local building = con_options:getConstructionOption(j)
                    if building ~= nil then
                        local name = building:getQueueBuildingName()
                        if eur_tga_table_bu[name] then
                            ImGui.Image(eur_tga_table_bu[name].img, 62, 48)
                        end
                    end
                    ImGui.SameLine()
                end
            end
        end
        ImGui.EndChild()
    end
    ImGui.EndChild()      
end


function listviewArmiesTab()

end

function listviewAgentsTab()

end

function listviewArmiesTabSmall()

end

function listviewAgentsTabSmall()

end
