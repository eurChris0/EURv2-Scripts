temp_gen_units_target = 0
temp_gen_units_target_clicked = false
temp_gen_units = {}

temp_gen_units = {}

guard_add = 0
temp_used = false

temp_com_inf = 0

player_start_threshold = 5

gen_rank_char = nil
gen_units_char = nil

local randomseed = 1

local cost = 0


basic_rank_check = {

}

local check_cards_window = false

sel_unit = nil
unit_only = false

temp_card_list = {

}

new_list = {}

local replen_rate = 0
local upgrade_avail = false
local replen_status_checked = false
local waystation_present = false

local ui_replen_multi      = safe_round_divide(100, replen_values.replen_multi)
local ui_replen_waystation = safe_round_divide(100, replen_values.waystation_bonus)
local ui_replen_paved      = safe_round_divide(100, replen_values.replen_road_level[2])
local ui_replen_dirt       = safe_round_divide(100, replen_values.replen_road_level[1])
local ui_replen_trade      = safe_round_divide(100, replen_values.replen_road_level[3])
local ui_field_multi       = safe_round_divide(100, replen_values.replen_field_other)
local ui_road_multi = 0
local ui_allied = false

function replenStatusCheck(army)
    ui_replen_multi      = safe_round_divide(100, replen_values.replen_multi)
    ui_replen_waystation = safe_round_divide(100, replen_values.waystation_bonus)
    ui_replen_paved      = safe_round_divide(100, replen_values.replen_road_level[2])
    ui_replen_dirt       = safe_round_divide(100, replen_values.replen_road_level[1])
    ui_replen_trade      = safe_round_divide(100, replen_values.replen_road_level[3])
    ui_replen_allied     = safe_round_divide(100, replen_values.replen_field_own)
    ui_replen_nonallied  = safe_round_divide(100, replen_values.replen_field_other)
     local road_level, owner = replenRoadLevel(army.regionID)
     if road_level ~= 0 then
         if road_level == 1 then
            ui_road_multi = ui_replen_paved
         elseif road_level == 2 then
            ui_road_multi = ui_replen_dirt
         elseif road_level == 3 then
            ui_road_multi = ui_replen_trade
         end
     end
     if road_level == 0 then
        ui_road_multi = 0
     end
     if owner ~= nil then
         if owner == army.faction then
            ui_field_multi = round_half(100 / replen_values.replen_field_own)
            ui_allied = true
         else
             local alliance = eur_campaign:checkDipStance(dipRelType.alliance, army.faction, owner)
             if alliance then
                ui_field_multi = round_half(100 / replen_values.replen_field_own)
                ui_allied = true
             else
                ui_allied = false
                ui_field_multi = round_half(100 / replen_values.replen_field_other)
             end
         end
     end
    if army:findInSettlement() then
        local sett = army:findInSettlement()
        if sett:buildingPresentMinLevel("military_academy", false) then
            replen_rate = ui_replen_multi+ui_replen_waystation+ui_road_multi
            waystation_present = true
            --print("waystation")
        else
            waystation_present = false
            replen_rate = ui_replen_multi+ui_road_multi
        end
    elseif army:findInFort() then
        waystation_present = false
        replen_rate = ui_replen_multi+ui_road_multi
    elseif replen_always then
        waystation_present = false
        replen_rate = ui_field_multi+ui_road_multi
    else
        waystation_present = false
    end
end

function replenTooltip(army)
    if army:findInSettlement() then
        if army:findInSettlement().siegesNum > 0 then return end
    end
    if army:findInFort() then
        if army:findInFort().siegeNum > 0 then return end
    end
    eurStyle("tooltip", true)
    ImGui.BeginTooltip()
    if replen_values.replen_bonus ~= nil then
        if replen_values.replen_bonus > 0 then
            local bonus = replen_values.replen_bonus / 100
            replen_rate = math.floor(replen_rate * (1 + bonus))
        end
    end
    if (army:findInSettlement() or army:findInFort()) then
        ImGui.Text("Replenishment: "..tostring(replen_rate).."%%")
        ImGui.NewLine()
        ImGui.Text("Base rate: "..tostring(ui_replen_multi).."%%")
        if waystation_present then
            ImGui.Text("Waystation bonus: "..tostring(ui_replen_waystation).."%%")
        end
        if ui_road_multi > 0 then
            ImGui.Text("Roads: "..tostring(ui_road_multi).."%%")
        end
        if replen_values.replen_bonus ~= nil then
            if replen_values.replen_bonus > 0 then
                ImGui.Text("Global bonus: "..tostring(replen_values.replen_bonus).."%%")
            end
        end
    else
        if replen_always then
            ImGui.Text("Replenishment: "..tostring(replen_rate).."%%")
            ImGui.NewLine()
            if ui_allied then 
                ImGui.Text("Friendly territory: "..tostring(ui_field_multi).."%%")
            else
                ImGui.Text("Foriegn territory: "..tostring(ui_field_multi).."%%")
            end
            if ui_road_multi > 0 then
                ImGui.Text("Roads: "..tostring(ui_road_multi).."%%")
            end
            if replen_values.replen_bonus ~= nil then
                local bonus = replen_values.replen_bonus / 100
                if replen_values.replen_bonus > 0 then
                    ImGui.Text("Global bonus: "..tostring(replen_values.replen_bonus).."%%")
                end
            end
        end
    end

    if upgrade_avail then
        ImGui.Text("Upgrades available")
    end
    ImGui.EndTooltip()
    eurStyle("tooltip", false)

end

function checkcard()
    local army = nil
    temp_card_list = {}
    free_upkeep_index = {}

    local agent_present = false
    local in_fort = false
    local in_sett = false
    local sorted_fort = false
    local sorted_sett = false    
 

    if M2TW.selectionInfo.selectedCharacter then
        if M2TW.selectionInfo.selectedCharacter.characterType == 6 or M2TW.selectionInfo.selectedCharacter.characterType == 7 then
            if M2TW.selectionInfo.selectedCharacter.army then
                army = M2TW.selectionInfo.selectedCharacter.army
            end
        end
    elseif M2TW.selectionInfo.selectedFort then
        hud_show_units_tab_pressed = true
        show_replen_ui = true
        in_fort = true
        if sel_unit ~= nil then
            if sel_unit.army ~= nil then
                if not sel_unit.army:findInFort() then
                    --print("check 1")
                    sel_unit = nil
                    temp_fort_char = nil
                    window_states.swap_bg_window = false
                    window_states.show_upgrade_window = false
                    if M2TW.selectionInfo.selectedFort.army then
                        sel_unit = M2TW.selectionInfo.selectedFort.army:getUnit(0)
                        if sel_unit.character then
                            temp_fort_char = sel_unit.character
                        end
                    end
                else
                    if sel_unit.army:findInFort() ~= M2TW.selectionInfo.selectedFort then
                        --print("check 2")
                        sel_unit = nil
                        temp_fort_char = nil
                        window_states.swap_bg_window = false
                        window_states.show_upgrade_window = false
                        if M2TW.selectionInfo.selectedFort.army then
                            sel_unit = M2TW.selectionInfo.selectedFort.army:getUnit(0)
                            if sel_unit.character then
                                temp_fort_char = sel_unit.character
                            end
                        end
                    end
                end
            end
        else
            if M2TW.selectionInfo.selectedFort.army ~= nil then
                --print("check 3")
                sel_unit = M2TW.selectionInfo.selectedFort.army:getUnit(0)
                if sel_unit.character ~= nil then
                    temp_fort_char = sel_unit.character
                end
            end
        end
        if M2TW.selectionInfo.selectedFort.army then
            army = M2TW.selectionInfo.selectedFort.army
            if temp_fort_char ~= nil then
                if temp_fort_char.bodyguards ~= nil then
                    if temp_fort_char.bodyguards.army ~= nil then
                        if not temp_fort_char.bodyguards.army:findInFort() then
                            sel_unit = nil
                            temp_fort_char = nil
                            window_states.swap_bg_window = false
                            window_states.show_upgrade_window = false
                            if M2TW.selectionInfo.selectedFort.army then
                                --print("check 4")
                                sel_unit = M2TW.selectionInfo.selectedFort.army:getUnit(0)
                                if sel_unit.character then
                                    temp_fort_char = sel_unit.character
                                end
                            end
                        else
                            if temp_fort_char.bodyguards.army:findInFort() ~= M2TW.selectionInfo.selectedFort then
                                --print("check 6")
                                sel_unit = nil
                                temp_fort_char = nil
                                window_states.swap_bg_window = false
                                window_states.show_upgrade_window = false
                                if M2TW.selectionInfo.selectedFort.army then
                                    sel_unit = M2TW.selectionInfo.selectedFort.army:getUnit(0)
                                    --print("check 5")
                                    if sel_unit.character then
                                        temp_fort_char = sel_unit.character
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif M2TW.selectionInfo.selectedSettlement then
        in_sett = true
        if M2TW.selectionInfo.selectedSettlement.army then
            army = M2TW.selectionInfo.selectedSettlement.army
        end
    end

    if M2TW.selectionInfo.selectedCharacter
    or M2TW.selectionInfo.selectedFort
    or M2TW.selectionInfo.selectedSettlement then
        check_cards_window = true
    else
        check_cards_window = false
        sel_unit = nil
        temp_fort_char = nil
    end

    if not M2TW.selectionInfo.selectedFort then
        in_fort = false
    end

    if not M2TW.selectionInfo.selectedSettlement then
        in_sett = false
    end

    if check_cards_window then
        ImGui.SetNextWindowPos(512*eurbackgroundWindowSizeRight, 900*eurbackgroundWindowSizeBottom)
        ImGui.SetNextWindowBgAlpha(0.0)
        ImGui.SetNextWindowSize(900*eurbackgroundWindowSizeRight, 180*eurbackgroundWindowSizeBottom)
        ImGui.Begin("cardcheck", true, bit.bor(ImGuiWindowFlags.NoMouseInputs, ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoBackground))
        eurStyle("basic_2", true)
        if army then
            temp_card_list = {}
            new_list = {}
            free_upkeep_index = {}
            for i = 0, army.numOfUnits -1 do
                local unit_get = army:getUnit(i)
                if unit_get ~= nil then
                    --unit_get.alias = tostring(i)
                    local cost = math.ceil(unit_get.eduEntry.upkeepCost*(unit_get.soldierCountStratMap/unit_get.soldierCountStratMapMax))
                    local ischar = false
                    if unit_get.character then
                        ischar = true
                    else
                        ischar = false
                    end
                    table.insert(temp_card_list, i, {eduindex = unit_get.eduEntry.index ,free = unit_get.eduEntry.freeUpkeepUnit ,char = ischar, cost = cost, new_index = i})
                end
            end
            if in_fort then
                if not sorted_fort then
                    new_list = reorder_top_cost_items(temp_card_list, 4)
                    sorted_fort = true
                end
            end
            if in_sett then
                if not sorted_sett then
                    if M2TW.selectionInfo.selectedSettlement then
                        for x = 0, M2TW.selectionInfo.selectedSettlement.recruitmentPoolCount -1 do
                            local unit_pool = M2TW.selectionInfo.selectedSettlement:getSettlementRecruitmentPool(x)
                            table.insert(free_upkeep_index, unit_pool.eduIndex)
                        end
                        local cap = M2TW.selectionInfo.selectedSettlement:getSettlementCapability(42)
                        new_list = reorder_top_cost_free_upkeep_only(temp_card_list, cap.bonus, free_upkeep_index)
                        
                        sorted_sett = true
                    end
                end
            end
            local dummy_set = false
            local second_dummy_set = false
            local ui_unit = nil
            for i = 0, army.numOfUnits -1 do
                if in_fort then
                    ui_unit = army:getUnit(new_list[i].new_index)
                elseif in_sett then
                    ui_unit = army:getUnit(new_list[i].new_index)
                else
                    ui_unit = army:getUnit(i)
                end
                
                replenStatusCheck(army)
                --print(replen_rate)
                if replen_rate > 0 then
                    if show_replen_ui then
                        if (army:findInSettlement() or army:findInFort()) then
                            local under_siege = false
                            if army:findInSettlement() then
                                if army:findInSettlement().siegesNum > 0 then under_siege = true end
                            end
                            if army:findInFort() then
                                if army:findInFort().siegeNum > 0 then under_siege = true end
                            end
                            if not under_siege then
                                if ui_unit ~= nil then
                                    if ui_unit.character == nil then
                                        --print(i, ui_unit.eduEntry.eduType)
                                        --print("check 1")
                                        local edu = ui_unit.eduEntry
                                        if edu ~= nil then
                                            if ui_unit.soldierCountStratMap < ui_unit.soldierCountStratMapMax then
                                                if replen then
                                                    if i == 10 then
                                                        ImGui.NewLine()
                                                        ImGui.Unindent(indent_900*eurbackgroundWindowSizeBottom)
                                                        ImGui.Dummy(0*eurbackgroundWindowSizeRight, 56*eurbackgroundWindowSizeBottom)
                                                        second_dummy_set = true
                                                    else
                                                        ImGui.SameLine()
                                                    end
                                                    if i > 10 then
                                                        --print(ImGui.GetCursorPos())
                                                        --print("indenting x 90 replen")
                                                        ImGui.Indent(indent_90*eurbackgroundWindowSizeBottom)
                                                        --print(ImGui.GetCursorPos())
                                                        if not second_dummy_set then
                                                            --print(ImGui.GetCursorPos())
                                                            --print("indenting y 64 replen")
                                                            ImGui.Dummy(0*eurbackgroundWindowSizeRight, 56*eurbackgroundWindowSizeBottom)
                                                            second_dummy_set = true
                                                        end
                                                    elseif i > 0 then
                                                        --print(ImGui.GetCursorPos())
                                                        --print("indenting x 90 replen")
                                                        ImGui.Indent(indent_90*eurbackgroundWindowSizeBottom)
                                                        --print(ImGui.GetCursorPos())
                                                    else
                                                        ImGui.Indent(indent_70*eurbackgroundWindowSizeBottom)
                                                        
                                                    end
                                                    if not dummy_set then
                                                        ImGui.Dummy(0*eurbackgroundWindowSizeRight, 32*eurbackgroundWindowSizeBottom)
                                                        dummy_set = true
                                                    end
                                                    if ui_unit.eduEntry.soldierCount <= 10 then
                                                        if ui_unit.eduEntry.soldierCount > replen_beast_value then
                                                            if not tableContains(replen_exempt, ui_unit.eduEntry.eduType) then
                                                                ImGui.Image(replen.img, 16*eurbackgroundWindowSizeRight, 16*eurbackgroundWindowSizeBottom)
                                                            end
                                                            local hovered = ImGui.IsMouseHoveringRect((unit_card_loc[i].coords.startx+indent_70), (unit_card_loc[i].coords.starty+40)*eurbackgroundWindowSizeBottom, unit_card_loc[i].coords.endx, (unit_card_loc[i].coords.endy-32)*eurbackgroundWindowSizeBottom)
                                                            if hovered then
                                                                eurStyle("tooltip", true)
                                                                ImGui.BeginTooltip()
                                                                ImGui.Text("Max 1 per turn.")
                                                                ImGui.EndTooltip()
                                                                eurStyle("tooltip", false)
                                                            end
                                                        end
                                                    else
                                                        --print(ImGui.GetCursorPos())
                                                       -- print("adding pic")
                                                       if not tableContains(replen_exempt, ui_unit.eduEntry.eduType) then
                                                            ImGui.Image(replen.img, 16*eurbackgroundWindowSizeRight, 16*eurbackgroundWindowSizeBottom)
                                                        end
                                                        local hovered = ImGui.IsMouseHoveringRect((unit_card_loc[i].coords.startx+indent_70), (unit_card_loc[i].coords.starty+40)*eurbackgroundWindowSizeBottom, unit_card_loc[i].coords.endx, (unit_card_loc[i].coords.endy-32)*eurbackgroundWindowSizeBottom)
                                                        if hovered then
                                                            if not tableContains(replen_exempt, ui_unit.eduEntry.eduType) then
                                                                replenTooltip(army)
                                                            end
                                                        end
                                                    end
                                                end
                                            else
                                                if i == 10 then
                                                    --print(ImGui.GetCursorPos())
                                                    --print("indenting to next line")
                                                    ImGui.NewLine()
                                                    ImGui.Unindent(indent_900*eurbackgroundWindowSizeBottom)
                                                    ImGui.Dummy(0*eurbackgroundWindowSizeRight, 56*eurbackgroundWindowSizeBottom)
                                                    --print(ImGui.GetCursorPos())
                                                else
                                                    ImGui.SameLine()
                                                end
                                                if i > 0 then
                                                    --print(ImGui.GetCursorPos())
                                                    --print("indenting x 90")
                                                    ImGui.Indent(indent_90*eurbackgroundWindowSizeBottom)
                                                   --print(ImGui.GetCursorPos())
                                                else
                                                    --print(ImGui.GetCursorPos())
                                                    --print("indenting x 70 y 32")
                                                    ImGui.Indent(indent_70*eurbackgroundWindowSizeBottom)
                                                    ImGui.Dummy(0*eurbackgroundWindowSizeRight, 32*eurbackgroundWindowSizeBottom)
                                                    --print(ImGui.GetCursorPos())
                                                    
                                                end
                                            end
                                        end
                                    else
                                        
                                        --print(i, ui_unit.eduEntry.eduType)
                                        --print("check 2")
                                        if i == 10 then
                                            ImGui.NewLine()
                                            ImGui.Unindent(indent_900*eurbackgroundWindowSizeBottom)
                                            ImGui.Dummy(0*eurbackgroundWindowSizeRight, 32*eurbackgroundWindowSizeBottom)
                                            ImGui.Text(tostring(i))
                                        else
                                            ImGui.SameLine()
                                        end
                                        if i > 0 then
                                            ImGui.Indent(indent_90*eurbackgroundWindowSizeBottom)
                                        else
                                            ImGui.Indent(indent_70*eurbackgroundWindowSizeBottom)
                                            ImGui.Dummy(0*eurbackgroundWindowSizeRight, 32*eurbackgroundWindowSizeBottom)
                                            
                                        end
                                        --ImGui.Image(replen.img, 16*eurbackgroundWindowSizeRight, 16*eurbackgroundWindowSizeBottom)
                                    end
                                else
                                    if i == 10 then
                                        ImGui.NewLine()
                                        ImGui.Unindent(indent_900*eurbackgroundWindowSizeBottom)
                                        ImGui.Dummy(0*eurbackgroundWindowSizeRight, 56*eurbackgroundWindowSizeBottom)
                                    else
                                        ImGui.SameLine()
                                    end
                                    if i > 0 then
                                        ImGui.Indent(indent_90*eurbackgroundWindowSizeBottom)
                                    else
                                        ImGui.Indent(indent_70*eurbackgroundWindowSizeBottom)
                                        ImGui.Dummy(0*eurbackgroundWindowSizeRight, 32*eurbackgroundWindowSizeBottom)
                                    end
                                end
                            end
                        else
                            if replen_always then
                                if ui_unit ~= nil then
                                    if ui_unit.character == nil then
                                        --print(i, ui_unit.eduEntry.eduType)
                                        --print("check 1")
                                        local edu = ui_unit.eduEntry
                                        if edu ~= nil then
                                            if ui_unit.soldierCountStratMap < ui_unit.soldierCountStratMapMax then
                                                if replen then
                                                    if i == 10 then
                                                        ImGui.NewLine()
                                                        ImGui.Unindent(indent_900*eurbackgroundWindowSizeBottom)
                                                        ImGui.Dummy(0*eurbackgroundWindowSizeRight, 56*eurbackgroundWindowSizeBottom)
                                                        second_dummy_set = true
                                                    else
                                                        ImGui.SameLine()
                                                    end
                                                    if i > 10 then
                                                        --print(ImGui.GetCursorPos())
                                                        --print("indenting x 90 replen")
                                                        ImGui.Indent(indent_90*eurbackgroundWindowSizeBottom)
                                                        --print(ImGui.GetCursorPos())
                                                        if not second_dummy_set then
                                                            --print(ImGui.GetCursorPos())
                                                            --print("indenting y 64 replen")
                                                            ImGui.Dummy(0*eurbackgroundWindowSizeRight, 56*eurbackgroundWindowSizeBottom)
                                                            second_dummy_set = true
                                                        end
                                                    elseif i > 0 then
                                                        --print(ImGui.GetCursorPos())
                                                        --print("indenting x 90 replen")
                                                        ImGui.Indent(indent_90*eurbackgroundWindowSizeBottom)
                                                        --print(ImGui.GetCursorPos())
                                                    else
                                                        ImGui.Indent(indent_70*eurbackgroundWindowSizeBottom)
                                                        
                                                    end
                                                    if not dummy_set then
                                                        ImGui.Dummy(0*eurbackgroundWindowSizeRight, 32*eurbackgroundWindowSizeBottom)
                                                        dummy_set = true
                                                    end
                                                    if ui_unit.eduEntry.soldierCount <= 10 then
                                                        if ui_unit.eduEntry.soldierCount > replen_beast_value then
                                                            if not tableContains(replen_exempt, ui_unit.eduEntry.eduType) then
                                                                ImGui.Image(replen.img, 16*eurbackgroundWindowSizeRight, 16*eurbackgroundWindowSizeBottom)
                                                            end
                                                            local hovered = ImGui.IsMouseHoveringRect((unit_card_loc[i].coords.startx+indent_70), (unit_card_loc[i].coords.starty+40)*eurbackgroundWindowSizeBottom, unit_card_loc[i].coords.endx, (unit_card_loc[i].coords.endy-32)*eurbackgroundWindowSizeBottom)
                                                            if hovered then
                                                                eurStyle("tooltip", true)
                                                                ImGui.BeginTooltip()
                                                                ImGui.Text("Max 1 per turn.")
                                                                ImGui.EndTooltip()
                                                                eurStyle("tooltip", false)
                                                            end
                                                        end
                                                    else
                                                        --print(ImGui.GetCursorPos())
                                                        --print("adding pic")
                                                        if not tableContains(replen_exempt, ui_unit.eduEntry.eduType) then
                                                            ImGui.Image(replen.img, 16*eurbackgroundWindowSizeRight, 16*eurbackgroundWindowSizeBottom)
                                                        end
                                                        local hovered = ImGui.IsMouseHoveringRect((unit_card_loc[i].coords.startx+indent_70), (unit_card_loc[i].coords.starty+40)*eurbackgroundWindowSizeBottom, unit_card_loc[i].coords.endx, (unit_card_loc[i].coords.endy-32)*eurbackgroundWindowSizeBottom)
                                                        if hovered then
                                                            if not tableContains(replen_exempt, ui_unit.eduEntry.eduType) then
                                                                replenTooltip(army)
                                                            end
                                                        end
                                                    end
                                                end
                                            else
                                                if i == 10 then
                                                    --print(ImGui.GetCursorPos())
                                                    --print("indenting to next line")
                                                    ImGui.NewLine()
                                                    ImGui.Unindent(indent_900*eurbackgroundWindowSizeBottom)
                                                    ImGui.Dummy(0*eurbackgroundWindowSizeRight, 56*eurbackgroundWindowSizeBottom)
                                                    --print(ImGui.GetCursorPos())
                                                else
                                                    ImGui.SameLine()
                                                end
                                                if i > 0 then
                                                    --print(ImGui.GetCursorPos())
                                                    --print("indenting x 90")
                                                    ImGui.Indent(indent_90*eurbackgroundWindowSizeBottom)
                                                    --print(ImGui.GetCursorPos())
                                                else
                                                    --print(ImGui.GetCursorPos())
                                                    --print("indenting x 70 y 32")
                                                    ImGui.Indent(indent_70*eurbackgroundWindowSizeBottom)
                                                    ImGui.Dummy(0*eurbackgroundWindowSizeRight, 32*eurbackgroundWindowSizeBottom)
                                                    --print(ImGui.GetCursorPos())
                                                    
                                                end
                                            end
                                        end
                                    else
                                        --print(i, ui_unit.eduEntry.eduType)
                                        --print("check 1")
                                        if i == 10 then
                                            ImGui.NewLine()
                                            ImGui.Unindent(indent_900*eurbackgroundWindowSizeBottom)
                                            ImGui.Dummy(0*eurbackgroundWindowSizeRight, 56*eurbackgroundWindowSizeBottom)
                                        else
                                            ImGui.SameLine()
                                        end
                                        if i > 0 then
                                            ImGui.Indent(indent_90*eurbackgroundWindowSizeBottom)
                                        else
                                            ImGui.Indent(indent_70*eurbackgroundWindowSizeBottom)
                                            ImGui.Dummy(0*eurbackgroundWindowSizeRight, 32*eurbackgroundWindowSizeBottom)
                                        end
                                    end
                                else
                                    if i == 10 then
                                        ImGui.NewLine()
                                        ImGui.Unindent(indent_900*eurbackgroundWindowSizeBottom)
                                        ImGui.Dummy(0*eurbackgroundWindowSizeRight, 56*eurbackgroundWindowSizeBottom)
                                    else
                                        ImGui.SameLine()
                                    end
                                    if i > 0 then
                                        ImGui.Indent(indent_90*eurbackgroundWindowSizeBottom)
                                    else
                                        ImGui.Indent(indent_70*eurbackgroundWindowSizeBottom)
                                        ImGui.Dummy(0*eurbackgroundWindowSizeRight, 32*eurbackgroundWindowSizeBottom)
                                    end
                                end
                            end
                        end
                    end
                end
                local hovered = ImGui.IsMouseHoveringRect(unit_card_loc[i].coords.startx, unit_card_loc[i].coords.starty*eurbackgroundWindowSizeBottom, unit_card_loc[i].coords.endx, unit_card_loc[i].coords.endy*eurbackgroundWindowSizeBottom)
                if hovered then
                    --hoveredSimple(tostring(i))
                    if ImGui.IsKeyDown(ImGuiKey.LeftShift) then
                        --print("clicked")
                        if in_fort then
                            temp_hov_unit = army:getUnit(new_list[i].new_index)
                        elseif in_sett then
                            temp_hov_unit = army:getUnit(new_list[i].new_index)
                        else
                            temp_hov_unit = army:getUnit(i)
                        end
                        if temp_hov_unit ~= nil then
                            if temp_hov_unit.eduEntry ~= nil then
                                eurStyle("tooltip", true)
                                ImGui.BeginTooltip()
                                ImGui.Text(temp_hov_unit.eduEntry.localizedName)
                                showEDUStats(temp_hov_unit.eduEntry.eduType)
                                ImGui.EndTooltip()
                                eurStyle("tooltip", false)
                            end
                        end
                    end


                    local rclicked = ImGui.IsMouseClicked(ImGuiMouseButton.Right)
                    local lclicked = ImGui.IsMouseClicked(ImGuiMouseButton.Left)
                    --hoveredSimple(tostring(i))
                    if rclicked or lclicked then
                        --print("clicked")
                        if in_fort then
                            sel_unit = army:getUnit(new_list[i].new_index)
                        elseif in_sett then
                            sel_unit = army:getUnit(new_list[i].new_index)
                        else
                            sel_unit = army:getUnit(i)
                        end
                        if sel_unit ~= nil then
                            if sel_unit.character ~= nil then
                                if sel_unit.character.characterRecord ~= nil then
                                    if persistent_gen_list_reset[sel_unit.character.characterRecord.label] == nil then
                                        setBGSize(nil, sel_unit.character, nil)
                                    end
                                    temp_fort_char = sel_unit.character
                                    if window_states.show_upgrade_window == true then
                                        set_active_left_window("swap_bg_window")
                                    end
                                end
                            else
                                temp_fort_char = nil
                                if window_states.swap_bg_window == true then

                                    set_active_left_window("show_upgrade_window")
                                end
                            end
                        end
                    end
                end
            end
            dummy_set = false
        end
        eurStyle("basic_2", false)
        ImGui.End()
    end

    if not M2TW.selectionInfo.selectedCharacter
    and not M2TW.selectionInfo.selectedFort
    and not M2TW.selectionInfo.selectedSettlement then
        window_states.swap_bg_window = false
        window_states.show_upgrade_window = false
        temp_fort_char = nil
        --print("closing window nothing selected")

        return
    end

    if not army then 
        window_states.swap_bg_window = false
        --print("closing window no army")

        return 
    end
    
    local tga = nil
    if temp_fort_char then
        if temp_fort_char.markedForDeath == false then
            unit_only = false
            if temp_fort_char.bodyguards then
                if temp_fort_char.bodyguards.eduEntry then
                    tga = temp_fort_char.bodyguards.eduEntry.unitCardTga
                end
            end
        end
    elseif sel_unit ~= nil then
        --print(sel_unit.eduEntry.eduType)
        unit_only = true
        if sel_unit.eduEntry ~= nil then
            tga = sel_unit.eduEntry.unitCardTga
        end
    end

    local level = 0
    local tiertext = faction_bg_name_list[eur_player_faction.name].t1
    if temp_fort_char ~= nil then
        if temp_fort_char.markedForDeath == false then
            level = 1
            char_rank = genRankCheck(nil, temp_fort_char.characterRecord)
            if char_rank then
                genUnitCheck(temp_fort_char.characterRecord, char_rank)
            end
            --print(char_rank, "rank check 1")
            local name = temp_fort_char.characterRecord.shortName..tostring(temp_fort_char.characterRecord.label)
            if persistent_gen_list[name] then
                --char_rank = math.floor(char_rank / math.max(1, persistent_gen_list[name].turns) * 5)
                char_rank = char_rank * 5 
                --print(persistent_gen_list[name].turns)
                char_rank = char_rank / persistent_gen_list[name].turns
                char_rank = math.floor(char_rank)
            end
            --print(char_rank, "rank check 2")
            genUnitCheck(temp_fort_char.characterRecord, char_rank)
            if basic_rank_check[temp_fort_char.characterRecord.label] then
                level = basic_rank_check[temp_fort_char.characterRecord.label]
            end
        end
    end
    --if not show_gen_unit_card then
        ImGui.SetNextWindowPos(350*eurbackgroundWindowSizeRight, 818*eurbackgroundWindowSizeBottom)
    --else
        --ImGui.SetNextWindowPos(350*eurbackgroundWindowSizeRight, 830*eurbackgroundWindowSizeBottom)
    --end
    if UNIT_UPGRADES == nil then return end
    ImGui.SetNextWindowBgAlpha(0)
    ImGui.SetNextWindowSize(100*eurbackgroundWindowSizeRight, 120*eurbackgroundWindowSizeBottom)
    ImGui.Begin("swapBG_1a", true, bit.bor(ImGuiWindowFlags.NoDecoration,ImGuiWindowFlags.NoBackground))
    eurStyle("basic_1", true)
    local bg_image = nil
    if show_gen_unit_card then
        if eur_tga_table[tga] == nil then
            bg_image = test1
        else
            bg_image = eur_tga_table[tga]
        end
    else
        bg_image = faction_upgrade_card_silver[eur_player_faction.name]
    end
    if not show_gen_unit_card then
        if level == 0 then
            bg_image = faction_upgrade_card_bw[eur_player_faction.name]
            if sel_unit ~= nil then
                if sel_unit.eduEntry ~= nil then
                    if UNIT_UPGRADES[sel_unit.eduEntry.eduType] then
                        ImGui.PushStyleColor(ImGuiCol.Button, 1, 1, 1, 0)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1, 1, 1, 0)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1, 1, 1, 0)
                        ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0)
                    else
                        ImGui.PushStyleColor(ImGuiCol.Button, 1, 1, 1, 0)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1, 1, 1, 0)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1, 1, 1, 0)
                        ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0)
                    end
                end
            end
        elseif level == 1 then
            bg_image = faction_upgrade_card_bronze[eur_player_faction.name]
            tiertext = faction_bg_name_list[eur_player_faction.name].t1
            ImGui.PushStyleColor(ImGuiCol.Button, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0)
        elseif level == 2 then
            bg_image = faction_upgrade_card_silver[eur_player_faction.name]
            tiertext = faction_bg_name_list[eur_player_faction.name].t2
            ImGui.PushStyleColor(ImGuiCol.Button, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0)
        elseif level == 3 then
            bg_image = faction_upgrade_card_gold[eur_player_faction.name]
            tiertext = faction_bg_name_list[eur_player_faction.name].t3
            ImGui.PushStyleColor(ImGuiCol.Button, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0)
        elseif level == 4 then
            bg_image = faction_upgrade_card_blue[eur_player_faction.name]
            tiertext = "Unique"
            ImGui.PushStyleColor(ImGuiCol.Button, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1, 1, 1, 0)
            ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0)
        end
    else
        if level == 0 then
            if sel_unit ~= nil then
                if sel_unit.eduEntry ~= nil then
                    if UNIT_UPGRADES[sel_unit.eduEntry.eduType] then
                        ImGui.PushStyleColor(ImGuiCol.Button, 1, 1, 1, 0.5)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1, 1, 1, 0.6)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1, 1, 1, 0.7)
                        ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0.5)
                    else
                        ImGui.PushStyleColor(ImGuiCol.Button, 0, 0, 0, 0.5)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0, 0, 0, 0.6)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0, 0, 0, 0.7)
                        ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0.5)
                    end
                end
            end
        elseif level == 1 then
            tiertext = faction_bg_name_list[eur_player_faction.name].t1
            ImGui.PushStyleColor(ImGuiCol.Button, 0.80, 0.50, 0.20, 0.5)
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.80, 0.50, 0.20, 0.6)
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.80, 0.50, 0.20, 0.7)
            ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0.5)
        elseif level == 2 then
            tiertext = faction_bg_name_list[eur_player_faction.name].t2
            ImGui.PushStyleColor(ImGuiCol.Button, 0.75, 0.75, 0.75, 0.5)
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.75, 0.75, 0.75, 0.6)
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.75, 0.75, 0.75, 0.7)
            ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0.5)
        elseif level == 3 then
            tiertext = faction_bg_name_list[eur_player_faction.name].t3
            ImGui.PushStyleColor(ImGuiCol.Button, 1.00, 0.84, 0.00, 0.5)
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.00, 0.84, 0.00, 0.6)
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1.00, 0.84, 0.00, 0.7)
            ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0.5)
        elseif level == 4 then
            tiertext = "Unique"
            ImGui.PushStyleColor(ImGuiCol.Button, 0.53, 0.81, 0.92, 0.5)
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.53, 0.81, 0.92, 0.6)
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.53, 0.81, 0.92, 0.7)
            ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0.5)
        end
    end
    if temp_fort_char ~= nil then
        if show_gen_unit_card then
            ImGui.Dummy(0,12*eurbackgroundWindowSizeBottom)
        end
        if temp_fort_char.markedForDeath == false then
            if temp_fort_char.characterRecord ~= nil then
                if options_gen_upgrades then
                    --if not tableContains(not_increase_guard, temp_fort_char.characterRecord.label) then
                        if bg_image then
                            if not (temp_fort_char.settlement or temp_fort_char.fort) then
                                --window_states.swap_bg_window = false
                                --window_states.show_upgrade_window = false
                                --ImGui.Image(eur_tga_table[tga].img,75*eurbackgroundWindowSizeRight,75*eurbackgroundWindowSizeBottom)
                                if ImGui.ImageButton("swapBGButton_button_1",bg_image.img,75*eurbackgroundWindowSizeRight,75*eurbackgroundWindowSizeBottom) then
                                    if window_states.swap_bg_window == false then
                                        --swap_bg_window = true
                                        set_active_left_window("swap_bg_window")
                                        --temp_char_stuff = temp_fort_char
                                        M2TWEOP.scriptCommand("play_sound_event", "STRAT_SCROLL_OPENS")
                                    else
                                        window_states.swap_bg_window = false
                                        M2TWEOP.scriptCommand("play_sound_event", "STRAT_SCROLL_CLOSES")
                                    end
                                end
                                local hovered = ImGui.IsItemHovered()
                                if hovered then
                                    eurStyle("tooltip", true)
                                    ImGui.BeginTooltip()
                                    ImGui.Text(temp_fort_char.characterRecord.localizedDisplayName)
                                    ImGui.Text(tiertext)
                                    ImGui.Text("Bodyguard: "..temp_fort_char.bodyguards.eduEntry.localizedName)
                                    local upkeepcost = temp_fort_char.bodyguards.eduEntry.upkeepCost
                                    upkeepcost = math.ceil((upkeepcost / temp_fort_char.bodyguards.soldierCountStratMapMax) * temp_fort_char.bodyguards.soldierCountStratMap)
                                    ImGui.Text("Upkeep "..tostring(upkeepcost))
                                    ImGui.Text("Move to fort or settlement to change bodyguard.")
                                    ImGui.EndTooltip()
                                    eurStyle("tooltip", false)
                                end
                            else
                                if ImGui.ImageButton("swapBGButton_button_1",bg_image.img,75*eurbackgroundWindowSizeRight,75*eurbackgroundWindowSizeBottom) then
                                    if window_states.swap_bg_window == false then
                                        --swap_bg_window = true
                                        set_active_left_window("swap_bg_window")
                                        --temp_char_stuff = temp_fort_char
                                        M2TWEOP.scriptCommand("play_sound_event", "STRAT_SCROLL_OPENS")
                                    else
                                        window_states.swap_bg_window = false
                                        M2TWEOP.scriptCommand("play_sound_event", "STRAT_SCROLL_CLOSES")
                                    end
                                end
                                local hovered = ImGui.IsItemHovered()
                                if hovered then
                                    eurStyle("tooltip", true)
                                    ImGui.BeginTooltip()
                                    ImGui.Text(temp_fort_char.characterRecord.localizedDisplayName)
                                    ImGui.Text(tiertext)
                                    ImGui.Text("Bodyguard: "..temp_fort_char.bodyguards.eduEntry.localizedName)
                                    local upkeepcost = temp_fort_char.bodyguards.eduEntry.upkeepCost
                                    upkeepcost = math.ceil((upkeepcost / temp_fort_char.bodyguards.soldierCountStratMapMax) * temp_fort_char.bodyguards.soldierCountStratMap)
                                    ImGui.Text("Upkeep "..tostring(upkeepcost))
                                    ImGui.EndTooltip()
                                    eurStyle("tooltip", false)
                                end
                            end
                        end
                    --end
                end
            end
        end
    else 
        ImGui.PushStyleColor(ImGuiCol.Button, 1, 1, 1, 0)
        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1, 1, 1, 0)
        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1, 1, 1, 0)
        ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0)
        --eur_tga_table[tga]
        if bg_test2 then
            if sel_unit ~= nil then
                if sel_unit.eduEntry ~= nil then
                    tiertext = "Unit"
                    if UNIT_UPGRADES[sel_unit.eduEntry.eduType] then
                        if not (army:findInSettlement() or army:findInFort()) then
                            --window_states.swap_bg_window = false
                            --window_states.show_upgrade_window = false
                            --ImGui.Image(eur_tga_table[tga].img,75*eurbackgroundWindowSizeRight,75*eurbackgroundWindowSizeBottom)
                            bg_image = faction_upgrade_card_silver[eur_player_faction.name]
                            if ImGui.ImageButton("swapBGButton_button_1",bg_image.img,75*eurbackgroundWindowSizeRight,75*eurbackgroundWindowSizeBottom) then
                                if window_states.show_upgrade_window == false then
                                    --show_upgrade_window = true
                                    set_active_left_window("show_upgrade_window")
                                    M2TWEOP.scriptCommand("play_sound_event", "STRAT_SCROLL_OPENS")
                                else
                                    window_states.show_upgrade_window = false
                                    M2TWEOP.scriptCommand("play_sound_event", "STRAT_SCROLL_CLOSES")
                                end
                            end
                            local hovered = ImGui.IsItemHovered()
                            if hovered then
                                eurStyle("tooltip", true)
                                ImGui.BeginTooltip()
                                --ImGui.Text(tiertext)
                                ImGui.Text(sel_unit.eduEntry.localizedName)
                                ImGui.Text("Move to fort or settlement to upgrade.")
                                ImGui.EndTooltip()
                                eurStyle("tooltip", false)
                            end
                        else
                            bg_image = faction_upgrade_card_silver[eur_player_faction.name]
                            if ImGui.ImageButton("swapBGButton_button_1",bg_image.img,75*eurbackgroundWindowSizeRight,75*eurbackgroundWindowSizeBottom) then
                                if window_states.show_upgrade_window == false then
                                    --show_upgrade_window = true
                                    set_active_left_window("show_upgrade_window")
                                    M2TWEOP.scriptCommand("play_sound_event", "STRAT_SCROLL_OPENS")
                                else
                                    window_states.show_upgrade_window = false
                                    M2TWEOP.scriptCommand("play_sound_event", "STRAT_SCROLL_CLOSES")
                                end
                            end
                            local hovered = ImGui.IsItemHovered()
                            if hovered then
                                eurStyle("tooltip", true)
                                ImGui.BeginTooltip()
                                --ImGui.Text(tiertext)
                                ImGui.Text(sel_unit.eduEntry.localizedName)
                                ImGui.EndTooltip()
                                eurStyle("tooltip", false)
                            end
                        end
                    else
                        bg_image = faction_upgrade_card_bw[eur_player_faction.name]
                        ImGui.ImageButton("swapBGButton_button_1",bg_image.img,75*eurbackgroundWindowSizeRight,75*eurbackgroundWindowSizeBottom)
                        local hovered = ImGui.IsItemHovered()
                        if hovered then
                            eurStyle("tooltip", true)
                            ImGui.BeginTooltip()
                            --ImGui.Text(tiertext)
                            ImGui.Text(sel_unit.eduEntry.localizedName)
                            ImGui.Text("No upgrades for this unit.")
                            ImGui.EndTooltip()
                            eurStyle("tooltip", false)
                        end
                    end
                end
            end
        end
    end

    ImGui.PopStyleColor(4)
    eurStyle("basic_1", false)
    ImGui.End()
end


function swapBGWindow()
    if not options_gen_upgrades then return end
    if not M2TW.selectionInfo.selectedCharacter
    and not M2TW.selectionInfo.selectedFort
    and not M2TW.selectionInfo.selectedSettlement then
        swap_bg_window = false
        temp_fort_char = nil
        --print("closing window nothing selected")
        return
    end
    
    if not temp_fort_char then 
        swap_bg_window = false
        --print("closing window no char")
        return 
    end

    --

    if not options_gen_upgrades then return end
    if temp_char_stuff == nil then
        if temp_fort_char ~= nil then
            --print("temp_char_stuff was nil")
            temp_char_stuff = temp_fort_char
        end
    end

    if gen_units_char ~= nil then
        --print("check 1")
        if temp_char_stuff ~= nil then
            --print("check 2")
            if gen_units_char ~= temp_char_stuff then
                --print("check 3")
                --print(gen_units_char.characterRecord.localizedDisplayName,temp_char_stuff.characterRecord.localizedDisplayName,"resetting")
                temp_gen_units_target = 0
                temp_gen_units = {}
                guard_add = 0
            end    
        end
    else

    end

    if temp_char_stuff == nil then return end

    if temp_char_stuff ~= temp_fort_char then
        temp_char_stuff = temp_fort_char
        temp_gen_units_target = 0
        temp_gen_units = {}
        guard_add = 0
    end
    cost = 0
    local army = nil
    local name = ""
    ImGui.SetNextWindowPos(5*eurbackgroundWindowSizeRight, 5*eurbackgroundWindowSizeBottom)
    ImGui.SetNextWindowBgAlpha(0)
    ImGui.SetNextWindowSize(955*eurbackgroundWindowSizeRight, 825*eurbackgroundWindowSizeBottom)
    ImGui.Begin("swap_bg_window_background", true, bit.bor(ImGuiWindowFlags.NoScrollWithMouse, ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoBackground))
    ImGui.SetWindowFontScale(1.2*eurbackgroundWindowSizeRight)
    eurStyle("basic_4", true)
    if faction_bg[M2TWEOP.getCultureName(eur_player_faction.cultureID)] then
        ImGui.Image(faction_bg[M2TWEOP.getCultureName(eur_player_faction.cultureID)].img, 945*eurbackgroundWindowSizeRight, 815*eurbackgroundWindowSizeBottom)
    end

    ImGui.SetNextWindowPos(280*eurbackgroundWindowSizeRight, 50*eurbackgroundWindowSizeBottom)
    ImGui.SetNextWindowBgAlpha(0)
    ImGui.SetNextWindowSize(200*eurbackgroundWindowSizeRight, 100*eurbackgroundWindowSizeBottom)
    ImGui.BeginChild("Child Window##A13", 400*eurbackgroundWindowSizeRight, 100*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
    --ImGui.SetWindowFontScale(1.8*eurbackgroundWindowSizeRight)
    --ImGui.TextColored(0,0,0,1,"General Upgrades")
    --ImGui.SetWindowFontScale(1.2*eurbackgroundWindowSizeRight)
    ImGui.Image(gu_text.img,400*eurbackgroundWindowSizeRight,50*eurbackgroundWindowSizeBottom)
    ImGui.EndChild()

    ImGui.SetNextWindowPos(70*eurbackgroundWindowSizeRight, 100*eurbackgroundWindowSizeBottom)
    ImGui.SetNextWindowBgAlpha(0.6)
    ImGui.BeginChild("swap_bg_child_1", 820*eurbackgroundWindowSizeRight, 640*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
    --ImGui.NewLine()
    ImGui.SetNextWindowBgAlpha(0)
    ImGui.BeginChild("swap_bg_child_sub_1", 410*eurbackgroundWindowSizeRight, 480*eurbackgroundWindowSizeBottom, ImGuiWindowFlags.NoDecoration)

    --if selectedUnit ~= nil then
        --if selectedUnit.army == nil then return end
        --if selectedUnit.army:findInSettlement() ~= nil then
            --if selectedUnit.character ~= nil then
                --temp_char_stuff = selectedUnit.character
                if temp_char_stuff:getTypeID() == 7 then
                    --ImGui.Separator()
                    ImGui.Text(temp_char_stuff.characterRecord.localizedDisplayName)
                    if char_rank then
                        local rank = math.floor(char_rank/10)
                        local ranktext = "Rank: "..tostring(rank).." - "..faction_bg_name_list[eur_player_faction.name].t1
                        local rankmessage = "Unlock "..faction_bg_name_list[eur_player_faction.name].t2.." units at rank "..tostring(bg_t2_rank)
                        if char_rank >= (bg_t3_rank*10) then
                            ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 1.00, 0.84, 0.00, 0.5)
                            ranktext = "Rank: "..tostring(rank).." - "..faction_bg_name_list[eur_player_faction.name].t3
                            rankmessage = "All regular units unlocked."
                        elseif char_rank >= (bg_t2_rank*10) then
                            ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0.75, 0.75, 0.75, 0.5)
                            ranktext = "Rank: "..tostring(rank).." - "..faction_bg_name_list[eur_player_faction.name].t2
                            rankmessage = "Unlock "..faction_bg_name_list[eur_player_faction.name].t3.." units at rank "..tostring(bg_t3_rank)
                        else
                            ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0.80, 0.50, 0.20, 0.5)
                        end
                        local rankprogress = (12*rank)/144
                        ImGui.ProgressBar(rankprogress, 300, 25, ranktext)
                        local hovered = ImGui.IsItemHovered()
                        if hovered then
                            eurStyle("tooltip", true)
                            ImGui.BeginTooltip()
                            ImGui.Text(rankmessage)
                            ImGui.EndTooltip()
                            eurStyle("tooltip", false)
                        end
                        ImGui.PopStyleColor()
                    end
                    ImGui.Text("Current Bodyguard: "..temp_char_stuff.bodyguards.eduEntry.localizedName)
                    if char_portraits[temp_char_stuff.characterRecord.portrait_custom] then
                        ImGui.Image(char_portraits[temp_char_stuff.characterRecord.portrait_custom].img,128*eurbackgroundWindowSizeRight, 128*eurbackgroundWindowSizeBottom)
                        ImGui.SameLine()
                        if eur_tga_table[temp_char_stuff.bodyguards.eduEntry.unitCardTga] then
                            ImGui.Image(eur_tga_table[temp_char_stuff.bodyguards.eduEntry.unitCardTga].img,100*eurbackgroundWindowSizeRight, 100*eurbackgroundWindowSizeBottom)
                            if temp_char_stuff.bodyguards.eduEntry ~= nil then
                                local hovered = ImGui.IsItemHovered()
                                if hovered then
                                    eurStyle("tooltip", true)
                                    ImGui.BeginTooltip()
                                    ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_char_stuff.bodyguards.eduEntry.eduType).localizedName)
                                    showEDUStats(temp_char_stuff.bodyguards.eduEntry.eduType)
                                    ImGui.EndTooltip()
                                    eurStyle("tooltip", false)
                                end
                            end
                        end
                    end
                    if temp_char_stuff.characterRecord.portrait then
                        local portrait = temp_char_stuff.characterRecord.portrait
                        portrait = string.gsub(portrait, "mods/Divide_and_Conquer_V2/data/ui/"..eur_localculture.."/portraits/portraits/young/generals/", "")
                        --print(portrait)
                        if char_portraits[portrait] then
                            ImGui.Image(char_portraits[portrait].img,128*eurbackgroundWindowSizeRight, 128*eurbackgroundWindowSizeBottom)
                            ImGui.SameLine()
                            if eur_tga_table[temp_char_stuff.bodyguards.eduEntry.unitCardTga] then
                                ImGui.Image(eur_tga_table[temp_char_stuff.bodyguards.eduEntry.unitCardTga].img,100*eurbackgroundWindowSizeRight, 100*eurbackgroundWindowSizeBottom)
                                if temp_char_stuff.bodyguards.eduEntry ~= nil then
                                    local hovered = ImGui.IsItemHovered()
                                    if hovered then
                                        eurStyle("tooltip", true)
                                        ImGui.BeginTooltip()
                                        ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_char_stuff.bodyguards.eduEntry.eduType).localizedName)
                                        showEDUStats(temp_char_stuff.bodyguards.eduEntry.eduType)
                                        local upkeepcost = temp_char_stuff.bodyguards.eduEntry.upkeepCost
                                        upkeepcost = math.ceil((upkeepcost / temp_char_stuff.bodyguards.soldierCountStratMapMax) * temp_char_stuff.bodyguards.soldierCountStratMap)
                                        ImGui.Text("Upkeep "..tostring(upkeepcost))
                                        ImGui.EndTooltip()
                                        eurStyle("tooltip", false)
                                    end
                                end
                            end
                        end
                    end
                    char_rank = genRankCheck(nil, temp_char_stuff.characterRecord)
                    --print(char_rank, "rank check 3")
                    name = temp_char_stuff.characterRecord.shortName..tostring(temp_char_stuff.characterRecord.label)
                    if persistent_gen_list[name] then
                        --char_rank = math.floor(char_rank / math.max(1, persistent_gen_list[name].turns) * 5)
                        char_rank = char_rank * 5 
                        char_rank = char_rank / persistent_gen_list[name].turns
                        char_rank = math.floor(char_rank)
                    end
                    --print(char_rank, "rank check 4")
                    if char_rank >= 200 then
                        char_rank = 200
                    end
                    genUnitCheck(temp_char_stuff.characterRecord, char_rank)
                    temp_gen_units = removeDuplicates(temp_gen_units)
                    --temp_gen_units_target, temp_gen_units_target_clicked = ImGui.Combo("", temp_gen_units_target, temp_gen_units, #temp_gen_units, #temp_gen_units+1)
                    if temp_gen_units[temp_gen_units_target+1] then
                        local edu = M2TWEOPDU.getEduEntryByType(temp_gen_units[temp_gen_units_target+1])
                        if edu ~= nil then
                            cost = M2TWEOPDU.getEduEntryByType(temp_gen_units[temp_gen_units_target+1]).recruitCost
                        end
                    end
                    ImGui.Text("Personal Guard: "..tostring(temp_char_stuff.characterRecord.personalSecurity))
                    if not tableContains(not_increase_guard, temp_char_stuff.characterRecord.label) then
                        if temp_char_stuff.characterRecord.personalSecurity < personal_guard_limit then
                            --ImGui.Separator()
                            ImGui.Text("Add Personal Guard")
                            if eur_player_faction.money > 499 then
                                if (ImGui.Button("+", 25, 25)) then
                                    M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
                                    if temp_char_stuff.characterRecord.personalSecurity <= personal_guard_limit then
                                        temp_char_stuff.characterRecord.personalSecurity=temp_char_stuff.characterRecord.personalSecurity+1
                                        stratmap.game.callConsole("add_money", "-" .. "500")
                                    end
                                end
                                ImGui.SameLine()
                                ImGui.Image(coins.img,20*eurbackgroundWindowSizeRight,20*eurbackgroundWindowSizeBottom)
                                ImGui.SameLine()
                                ImGui.Text("500")
                            else
                                ImGui.Text("Not enough gold")
                            end
                        else
                                ImGui.Text("Personal Guard limit reached")
                        end
                            --guard_add, temp_used = ImGui.SliderInt("", guard_add, 0, (10-temp_char_stuff.characterRecord.personalSecurity))
                        --ImGui.Separator()
                    end
                end
            --else
                --ImGui.TextColored(0,1,0,1,"Please select a general unit card.")
                --temp_gen_units_target = 0
                --temp_gen_units = {}
            --end
        --end
    --else
        --ImGui.TextColored(0,1,0,1,"Please select a general unit card.")
        --temp_gen_units_target = 0
        --temp_gen_units = {}
    --end
    ImGui.EndChild()
    ImGui.SameLine()
    ImGui.SetNextWindowBgAlpha(0)
    ImGui.BeginChild("swap_bg_child_sub_2", 410*eurbackgroundWindowSizeRight, 480*eurbackgroundWindowSizeBottom, ImGuiWindowFlags.NoDecoration)
    ImGui.Text(faction_bg_name_list[eur_player_faction.name].t1)
    for i = 1, #temp_gen_units do
        if temp_gen_units[i] ~= nil then
            if tableContains(gen_units_list[eur_player_faction.name]["T1"], temp_gen_units[i]) then
                if eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga] then
                    if ImGui.ImageButton("swapBGButton_button_t1_0"..tostring(i),eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga].img,img_x, img_y) then
                        temp_gen_units_target=i-1
                        M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
                    end
                end
                local hovered = ImGui.IsItemHovered()
                if hovered then
                    playMenuSound("7"..temp_gen_units[i])
                    eurStyle("tooltip", true)
                    ImGui.BeginTooltip()
                    ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).localizedName)
                    showEDUStats(temp_gen_units[i])
                    ImGui.EndTooltip()
                    eurStyle("tooltip", false)
                end
                if i == 4 then
                    ImGui.SameLine()
                else
                    ImGui.SameLine()
                end
            end
        end
    end
    ImGui.NewLine()
    ImGui.Text(faction_bg_name_list[eur_player_faction.name].t2)
    for i = 1, #temp_gen_units do
        if temp_gen_units[i] ~= nil then
            if tableContains(gen_units_list[eur_player_faction.name]["T2"], temp_gen_units[i]) then
                if char_rank >= (bg_t2_rank*10) then
                    if eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga] then
                        if ImGui.ImageButton("swapBGButton_button_t2_0"..tostring(i),eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga].img,img_x, img_y) then
                            temp_gen_units_target=i-1
                            M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
                        end
                    end
                    local hovered = ImGui.IsItemHovered()
                    if hovered then
                        playMenuSound("8"..temp_gen_units[i])
                        eurStyle("tooltip", true)
                        ImGui.BeginTooltip()
                        ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).localizedName)
                        showEDUStats(temp_gen_units[i])
                        ImGui.EndTooltip()
                        eurStyle("tooltip", false)
                    end
                    if i == 4 then
                        ImGui.SameLine()
                    else
                        ImGui.SameLine()
                    end
                else
                    ImGui.SetNextWindowBgAlpha(0)
                    ImGui.BeginChild("swapBGButton_button_t2_1"..tostring(i), img_x, img_y, ImGuiChildFlags.FrameStyle)
                    local pos_x, pos_y = ImGui.GetWindowPos()
                    --ImGui.PushStyleColor(ImGuiCol.Text,0,0,0,1)
                    --centeredText(tostring(math.floor(unit_pool.availablePool)),65*eurbackgroundWindowSizeRight)
                    --ImGui.PopStyleColor()
                    ImGui.EndChild()
                    ImGui.SetNextWindowBgAlpha(0)
                    ImGui.SetNextWindowPos(pos_x, pos_y)
                    ImGui.BeginChild("swapBGButton_button_t2_1"..tostring(i).."##2", img_x, img_y, ImGuiChildFlags.FrameStyle)
                    if eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga] then
                        ImGui.Image(eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga].img, img_x, img_y)
                    end
                    ImGui.EndChild()
                    ImGui.SetNextWindowBgAlpha(0.5)
                    ImGui.SetNextWindowPos(pos_x, pos_y)
                    ImGui.PushStyleColor(ImGuiCol.FrameBg,0.75,0.75,0.75,0.1)
                    ImGui.BeginChild("swapBGButton_button_t2_1"..tostring(i).."##3", img_x, img_y, ImGuiChildFlags.FrameStyle)
                    ImGui.EndChild()
                    ImGui.PopStyleColor()
                    if i == 4 then
                        ImGui.SameLine()
                    else
                        ImGui.SameLine()
                    end
                    local hovered = ImGui.IsItemHovered()
                    if hovered then
                        eurStyle("tooltip", true)
                        ImGui.BeginTooltip()
                        ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).localizedName.." Locked.")
                        showEDUStats(temp_gen_units[i])
                        ImGui.EndTooltip()
                        eurStyle("tooltip", false)
                    end
                end
            end
        end
    end
    ImGui.NewLine()
    ImGui.Text(faction_bg_name_list[eur_player_faction.name].t3)
    for i = 1, #temp_gen_units do
        if temp_gen_units[i] ~= nil then
            if bgunlock_units_list[temp_char_stuff.characterRecord.label] then
                if bgunlock_units_list[temp_char_stuff.characterRecord.label] == temp_gen_units[i] then
                    if char_rank >= (bg_t3_rank*10) then
                        if eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga] then
                            if ImGui.ImageButton("swapBGButton_button_bgunlock_0"..tostring(i),eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga].img,img_x, img_y) then
                                temp_gen_units_target=i-1
                                M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
                            end
                        end
                        local hovered = ImGui.IsItemHovered()
                        if hovered then
                            playMenuSound("9"..temp_gen_units[i])
                            eurStyle("tooltip", true)
                            ImGui.BeginTooltip()
                            ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).localizedName)
                            showEDUStats(temp_gen_units[i])
                            ImGui.EndTooltip()
                            eurStyle("tooltip", false)
                        end
                        if i == 4 then
                            ImGui.SameLine()
                        else
                            ImGui.SameLine()
                        end
                    else
                        ImGui.SetNextWindowBgAlpha(0)
                        ImGui.BeginChild("swapBGButton_button_bgunlock_1"..tostring(i), img_x, img_y, ImGuiChildFlags.FrameStyle)
                        local pos_x, pos_y = ImGui.GetWindowPos()
                        --ImGui.PushStyleColor(ImGuiCol.Text,0,0,0,1)
                        --centeredText(tostring(math.floor(unit_pool.availablePool)),65*eurbackgroundWindowSizeRight)
                        --ImGui.PopStyleColor()
                        ImGui.EndChild()
                        ImGui.SetNextWindowBgAlpha(0)
                        ImGui.SetNextWindowPos(pos_x, pos_y)
                        ImGui.BeginChild("swapBGButton_button_bgunlock_1"..tostring(i).."##2", img_x, img_y, ImGuiChildFlags.FrameStyle)
                        if eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga] then
                            ImGui.Image(eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga].img, img_x, img_y)
                        end
                        ImGui.EndChild()
                        ImGui.SetNextWindowBgAlpha(0.5)
                        ImGui.SetNextWindowPos(pos_x, pos_y)
                        ImGui.PushStyleColor(ImGuiCol.FrameBg,0.75,0.75,0.75,0.1)
                        ImGui.BeginChild("swapBGButton_button_bgunlock_1"..tostring(i).."##3", img_x, img_y, ImGuiChildFlags.FrameStyle)
                        ImGui.EndChild()
                        ImGui.PopStyleColor()
                        if i == 4 then
                            ImGui.SameLine()
                        else
                            ImGui.SameLine()
                        end
                        local hovered = ImGui.IsItemHovered()
                        if hovered then
                            eurStyle("tooltip", true)
                            ImGui.BeginTooltip()
                            ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).localizedName.." Locked.")
                            showEDUStats(temp_gen_units[i])
                            ImGui.EndTooltip()
                            eurStyle("tooltip", false)
                        end
                    end
                end
            end
            if tableContains(gen_units_list[eur_player_faction.name]["T3"], temp_gen_units[i]) then
                if char_rank >= (bg_t3_rank*10) then
                    if eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga] then
                        if ImGui.ImageButton("swapBGButton_button_t3_0"..tostring(i),eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga].img,img_x, img_y) then
                            temp_gen_units_target=i-1
                            M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
                        end
                    end
                    local hovered = ImGui.IsItemHovered()
                    if hovered then
                        playMenuSound("10"..temp_gen_units[i])
                        eurStyle("tooltip", true)
                        ImGui.BeginTooltip()
                        ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).localizedName)
                        showEDUStats(temp_gen_units[i])
                        ImGui.EndTooltip()
                        eurStyle("tooltip", false)
                    end
                    if i == 4 then
                        ImGui.SameLine()
                    else
                        ImGui.SameLine()
                    end
                else
                    ImGui.SetNextWindowBgAlpha(0)
                    ImGui.BeginChild("swapBGButton_button_t3_1"..tostring(i), img_x, img_y, ImGuiChildFlags.FrameStyle)
                    local pos_x, pos_y = ImGui.GetWindowPos()
                    --ImGui.PushStyleColor(ImGuiCol.Text,0,0,0,1)
                    --centeredText(tostring(math.floor(unit_pool.availablePool)),65*eurbackgroundWindowSizeRight)
                    --ImGui.PopStyleColor()
                    ImGui.EndChild()
                    ImGui.SetNextWindowBgAlpha(0)
                    ImGui.SetNextWindowPos(pos_x, pos_y)
                    ImGui.BeginChild("swapBGButton_button_t3_1"..tostring(i).."##2", img_x, img_y, ImGuiChildFlags.FrameStyle)
                    if eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga] then
                        ImGui.Image(eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga].img, img_x, img_y)
                    end
                    ImGui.EndChild()
                    ImGui.SetNextWindowBgAlpha(0.5)
                    ImGui.SetNextWindowPos(pos_x, pos_y)
                    ImGui.PushStyleColor(ImGuiCol.FrameBg,0.75,0.75,0.75,0.1)
                    ImGui.BeginChild("swapBGButton_button_t3_1"..tostring(i).."##3", img_x, img_y, ImGuiChildFlags.FrameStyle)
                    ImGui.EndChild()
                    ImGui.PopStyleColor()
                    if i == 4 then
                        ImGui.SameLine()
                    else
                        ImGui.SameLine()
                    end
                    local hovered = ImGui.IsItemHovered()
                    if hovered then
                        eurStyle("tooltip", true)
                        ImGui.BeginTooltip()
                        ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).localizedName.." Locked.")
                        showEDUStats(temp_gen_units[i])
                        ImGui.EndTooltip()
                        eurStyle("tooltip", false)
                    end
                end
            end
        end
    end
    ImGui.NewLine()

    ImGui.Text("Unique")
    for i = 1, #temp_gen_units do
        if temp_gen_units[i] ~= nil then
            if not tableContains(gen_units_list[eur_player_faction.name]["T1"], temp_gen_units[i]) then
                if not tableContains(gen_units_list[eur_player_faction.name]["T2"], temp_gen_units[i]) then
                    if not tableContains(gen_units_list[eur_player_faction.name]["T3"], temp_gen_units[i]) then
                        if bgunlock_units_list[temp_char_stuff.characterRecord.label] then
                            if bgunlock_units_list[temp_char_stuff.characterRecord.label] == temp_gen_units[i] then
                                --nothing
                            else
                                if eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga] then
                                    if ImGui.ImageButton("swapBGButton_button_s_0"..tostring(i),eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga].img,img_x, img_y) then
                                        temp_gen_units_target=i-1
                                        M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
                                    end
                                end
                                local hovered = ImGui.IsItemHovered()
                                if hovered then
                                    playMenuSound("11"..temp_gen_units[i])
                                    eurStyle("tooltip", true)
                                    ImGui.BeginTooltip()
                                    ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).localizedName)
                                    showEDUStats(temp_gen_units[i])
                                    ImGui.EndTooltip()
                                    eurStyle("tooltip", false)
                                end
                                if i == 4 then
                                    ImGui.SameLine()
                                else
                                    ImGui.SameLine()
                                end
                            end
                        else
                            if eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga] then
                                if ImGui.ImageButton("swapBGButton_button_s_0"..tostring(i),eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).unitCardTga].img,img_x, img_y) then
                                    temp_gen_units_target=i-1
                                    M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
                                end
                            end
                            local hovered = ImGui.IsItemHovered()
                            if hovered then
                                playMenuSound("12"..temp_gen_units[i])
                                eurStyle("tooltip", true)
                                ImGui.BeginTooltip()
                                ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_gen_units[i]).localizedName)
                                showEDUStats(temp_gen_units[i])
                                ImGui.EndTooltip()
                                eurStyle("tooltip", false)
                            end
                            if i == 4 then
                                ImGui.SameLine()
                            else
                                ImGui.SameLine()
                            end
                        end
                    end
                end
            end
        end
    end
    ImGui.NewLine()
    ImGui.EndChild()
    if temp_char_stuff then
        if temp_char_stuff.settlement then
            army = temp_char_stuff.settlement.army
        elseif temp_char_stuff.fort then
            army = temp_char_stuff.fort.army
        elseif temp_char_stuff.army ~= nil then
            army = temp_char_stuff.army
        end
        if not tableContains(not_increase_guard,temp_char_stuff.characterRecord.label) then
            if army ~= nil then
                if persistent_gen_list[name] ~= nil then
                    if persistent_gen_list[name].cooldown == 0 then
                        if temp_gen_units[temp_gen_units_target+1] then
                            if temp_gen_units[temp_gen_units_target+1] ~= temp_char_stuff.bodyguards.eduEntry.eduType then
                                if army.numOfUnits < 20 then
                                    if temp_char_stuff.faction.money >= cost then
                                        if (army:findInSettlement() or army:findInFort()) then

                                            ImGui.SetNextWindowPos(400*eurbackgroundWindowSizeRight, 580*eurbackgroundWindowSizeBottom)
                                            ImGui.SetNextWindowBgAlpha(0.5)
                                            ImGui.BeginChild("Child Window##A14", 110*eurbackgroundWindowSizeRight, 110*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
                                            local pos_x, pos_y = ImGui.GetWindowPos()
                                            ImGui.Indent(24*eurbackgroundWindowSizeRight)
                                            ImGui.Image(coins.img,20*eurbackgroundWindowSizeRight,20*eurbackgroundWindowSizeBottom)
                                            ImGui.SameLine()
                                            ImGui.Text(tostring(cost))
                                            if eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[temp_gen_units_target+1]).unitCardTga] then
                                                centeredImage(eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[temp_gen_units_target+1]).unitCardTga].img,img_x, img_y,0)
                                            end
                                            ImGui.EndChild()
                                            ImGui.SetNextWindowBgAlpha(0)
                                            ImGui.SetNextWindowPos(pos_x, pos_y)
                                            ImGui.PushStyleColor(ImGuiCol.Button, 1, 1, 1, 0)
                                            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, fact_inner_colour[eur_player_faction.name].r,fact_inner_colour[eur_player_faction.name].g,fact_inner_colour[eur_player_faction.name].b, 0.2)
                                            ImGui.PushStyleColor(ImGuiCol.ButtonActive, fact_inner_colour[eur_player_faction.name].r,fact_inner_colour[eur_player_faction.name].g,fact_inner_colour[eur_player_faction.name].b, 0.5)
                                            ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0.5)
                                            ImGui.BeginChild("Child Window##A15", 110*eurbackgroundWindowSizeRight, 110*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
                                            if temp_gen_units[temp_gen_units_target+1] then
                                                if ImGui.Button("##15",110*eurbackgroundWindowSizeRight, 110*eurbackgroundWindowSizeBottom) then
                                                    show_bg_accept = true
                                                    swap_bg_window = false
                                                    M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
                                                end
                                                local hovered = ImGui.IsItemHovered()
                                                if hovered then
                                                    eurStyle("tooltip", true)
                                                    ImGui.BeginTooltip()
                                                    ImGui.Text(M2TWEOPDU.getEduEntryByType(temp_gen_units[temp_gen_units_target+1]).localizedName)
                                                    showEDUStats(temp_gen_units[temp_gen_units_target+1])
                                                    ImGui.EndTooltip()
                                                    eurStyle("tooltip", false)
                                                end
                                            end
                                            ImGui.EndChild()
                                            ImGui.PopStyleColor(4)
                                        else
                                            ImGui.TextColored(1,0,0,1,"Cannot change as not garrisoned in a fort or settlement.")
                                        end
                                    else
                                        ImGui.TextColored(1,0,0,1,"Not enough gold.")
                                    end
                                end
                            else
                                ImGui.TextColored(1,0,0,1,"Same as current bodyguard.")
                            end
                        end
                        if army.numOfUnits > 19 then
                            ImGui.TextColored(1,0,0,1,"Cannot swap with full army.")
                        end
                    else
                        ImGui.TextColored(1,0,0,1,"Cannot change for: "..tostring(persistent_gen_list[temp_char_stuff.characterRecord.shortName..tostring(temp_char_stuff.characterRecord.label)].cooldown).." turns.")
                    end
                else
                    ImGui.TextColored(1,0,0,1,"New general, cannot change yet.")
                end
            end
        else
            ImGui.TextColored(1,0,0,1,"Cannot change this general.")
        end
    end
    ImGui.EndChild()
    eurStyle("basic_4", false)
    eurStyle("button_1", true)
    if faction_bu[M2TWEOP.getCultureName(eur_player_faction.cultureID)] then
        if centeredImageButtonReal("##upgclose", faction_bu[M2TWEOP.getCultureName(eur_player_faction.cultureID)].img, 100*eurbackgroundWindowSizeRight, 80*eurbackgroundWindowSizeBottom, 420*eurbackgroundWindowSizeRight) then
            window_states.swap_bg_window = false
            M2TWEOP.scriptCommand("play_sound_event", "STRAT_SCROLL_CLOSES")
        end
        local hovered = ImGui.IsItemHovered()
        if hovered then
            eurStyle("tooltip", true)
            ImGui.BeginTooltip()
            ImGui.Text("Close this scroll")
            ImGui.EndTooltip()
            eurStyle("tooltip", false)
        end
    end
    eurStyle("button_1", false)
    ImGui.End()
    gen_units_char = temp_char_stuff
end

function bgSwapAccept()
    if temp_gen_units[temp_gen_units_target+1] == nil then
        swap_bg_window = true
        show_bg_accept = false
    end
    ImGui.SetNextWindowBgAlpha(0)
    ImGui.SetNextWindowSize(610*eurbackgroundWindowSizeRight, 310*eurbackgroundWindowSizeBottom)
    ImGui.SetNextWindowPos(660*eurbackgroundWindowSizeRight, 350*eurbackgroundWindowSizeBottom)
    ImGui.SetNextWindowFocus()
    ImGui.Begin("options_bg_accept_main", true, bit.bor(ImGuiWindowFlags.NoScrollWithMouse, ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoBackground))
    if faction_bg[M2TWEOP.getCultureName(eur_player_faction.cultureID)] then
        ImGui.Image(faction_accept[M2TWEOP.getCultureName(eur_player_faction.cultureID)].img, 600*eurbackgroundWindowSizeRight, 300*eurbackgroundWindowSizeBottom)
    end
    eurStyle("basic_4", true)
    ImGui.SetNextWindowPos(710*eurbackgroundWindowSizeRight, 380*eurbackgroundWindowSizeBottom)
    ImGui.SetNextWindowBgAlpha(0.6)
    ImGui.BeginChild("options_bg_accept Window##A15", 500*eurbackgroundWindowSizeRight, 250*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
    ImGui.SetWindowFontScale(1.1*eurbackgroundWindowSizeRight)
    centeredText("Swap bodyguard to "..temp_gen_units[temp_gen_units_target+1],0)
    ImGui.SetNextWindowPos(710*eurbackgroundWindowSizeRight, 510*eurbackgroundWindowSizeBottom)
    ImGui.SetNextWindowBgAlpha(0)
    ImGui.BeginChild("options_bg_accept Window##A16", 500*eurbackgroundWindowSizeRight, 100*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
    ImGui.SetWindowFontScale(1.1*eurbackgroundWindowSizeRight)

    if (centeredImageButton("Yes", 80, 50, -40)) then
        local name = temp_char_stuff.characterRecord.shortName..tostring(temp_char_stuff.characterRecord.label)
        persistent_gen_list[name].cooldown = bg_swap_cooldown
        stratmap.game.callConsole("add_money", "-" .. tostring(cost))
        setBodyguard(temp_char_stuff, (temp_gen_units[temp_gen_units_target+1]), temp_char_stuff.bodyguards.exp, temp_char_stuff.bodyguards.weaponLVL, 0, "")
        swap_bg_window = false
        show_bg_accept = false
        temp_gen_units_target = 0
        M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
    end
    ImGui.SameLine()
    if (centeredImageButton("No", 80, 50, 40)) then
        swap_bg_window = true
        show_bg_accept = false
        M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
    end
    ImGui.EndChild()
    ImGui.EndChild()
    eurStyle("basic_4", false)
    ImGui.End()

end

function genUnitCheck(char, char_rank)
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."genUnitCheck");
	end
    if char == nil then return end
    if gen_units_char == char then return end
    local faction = char.character.faction.name
    temp_gen_units = {}
    for i = 0, #gen_units_list[faction]["T1"] do
        local eduEntry = M2TWEOPDU.getEduEntryByType(gen_units_list[faction]["T1"][i])
        if eduEntry ~= nil then
            if eduEntry:hasOwnership(eur_playerFactionId) then
                if not tableContains(temp_gen_units, gen_units_list[faction]["T1"][i]) then
                    table.insert(temp_gen_units, gen_units_list[faction]["T1"][i])
                end
            end
        end
    end
    if char_rank >= 0 then
        for i = 0, #gen_units_list[faction]["T2"] do
            local eduEntry = M2TWEOPDU.getEduEntryByType(gen_units_list[faction]["T2"][i])
            if eduEntry ~= nil then
                if eduEntry:hasOwnership(eur_playerFactionId) then
                    if not tableContains(temp_gen_units, gen_units_list[faction]["T2"][i]) then
                        table.insert(temp_gen_units, gen_units_list[faction]["T2"][i])
                    end
                    if char_rank >= (bg_t2_rank*10) then
                        if not basic_rank_check[char.label] then
                            basic_rank_check[char.label] = 2
                        else
                            if basic_rank_check[char.label] < 2 then
                                basic_rank_check[char.label] = 2
                            end
                        end
                    end
                end
            end
        end
    end
    if char_rank >= 0 then
        for i = 0, #gen_units_list[faction]["T3"] do
            local eduEntry = M2TWEOPDU.getEduEntryByType(gen_units_list[faction]["T3"][i])
            if eduEntry ~= nil then
                if eduEntry:hasOwnership(eur_playerFactionId) then
                    if not tableContains(temp_gen_units, gen_units_list[faction]["T3"][i]) then
                        table.insert(temp_gen_units, gen_units_list[faction]["T3"][i])
                    end
                    if char_rank >= (bg_t3_rank*10) then
                        if not basic_rank_check[char.label] then
                            basic_rank_check[char.label] = 3
                        else
                            if basic_rank_check[char.label] < 3 then
                                basic_rank_check[char.label] = 3
                            end
                        end
                    end
                end
            end
        end
    end
    traits_temp = {}
    --eurListTraits(char)
    --printTable(traits_temp)
    for k, v in pairs(labtrait_units_list) do 
        if char:getTraitLevel(k) > 0 then
            local eduEntry = M2TWEOPDU.getEduEntryByType(v)
            if eduEntry ~= nil then
                if eduEntry:hasOwnership(eur_playerFactionId) then
                    table.insert(temp_gen_units, v)
                end
            end
        end
    end
    for k, v in pairs(conquer_traits) do 
        if char:getTraitLevel(k) > v then
            for i = 1, #gen_units_list[faction]["special"] do
                local eduEntry = M2TWEOPDU.getEduEntryByType(gen_units_list[faction]["special"][i])
                if eduEntry ~= nil then
                    if eduEntry:hasOwnership(eur_playerFactionId) then
                        if not tableContains(temp_gen_units, gen_units_list[faction]["special"][i]) then
                            table.insert(temp_gen_units, gen_units_list[faction]["special"][i])
                        end
                        if not basic_rank_check[char.label] then
                            basic_rank_check[char.label] = 4
                        else
                            if basic_rank_check[char.label] < 4 then
                                basic_rank_check[char.label] = 4
                            end
                        end
                    end
                end
            end
        end
    end
    if labtrait_units_list[char.label] then
        local eduEntry = M2TWEOPDU.getEduEntryByType(labtrait_units_list[char.label])
        if eduEntry ~= nil then
            if eduEntry:hasOwnership(eur_playerFactionId) then
                if not tableContains(temp_gen_units, labtrait_units_list[char.label]) then
                    table.insert(temp_gen_units, labtrait_units_list[char.label])
                end
            end
        end
    end
    if bgunlock_units_list[char.label] then
        local eduEntry = M2TWEOPDU.getEduEntryByType(bgunlock_units_list[char.label])
        if eduEntry ~= nil then
            if eduEntry:hasOwnership(eur_playerFactionId) then
                if not tableContains(temp_gen_units, bgunlock_units_list[char.label]) then
                    table.insert(temp_gen_units, bgunlock_units_list[char.label])
                end
            end
        end
    end
    if char:getTraitLevel("FactionLeader") > 0 or char:getTraitLevel("FactionLeaderCustom") > 0 then
        if leaderheir_combi_list[char.character.faction.name] then
            local eduEntry = M2TWEOPDU.getEduEntryByType(leaderheir_combi_list[char.character.faction.name].leader.unit)
            if eduEntry ~= nil then
                if eduEntry:hasOwnership(char.character.faction.factionID) then
                    if not tableContains(temp_gen_units, leaderheir_combi_list[char.character.faction.name].leader.unit) then
                        table.insert(temp_gen_units, leaderheir_combi_list[char.character.faction.name].leader.unit)
                    end
                    if not basic_rank_check[char.label] then
                        basic_rank_check[char.label] = 4
                    else
                        if basic_rank_check[char.label] < 4 then
                            basic_rank_check[char.label] = 4
                        end
                    end
                end
            end
        end
    end
    if current_heir_check[0] == nil then
        swapHierStuffCheck(eur_player_faction)
    end
    if current_heir_check[0] == char then
        if char:getTraitLevel("FactionHeir") > 0 or char:getTraitLevel("FactionHeirCustom") > 0 then
            if leaderheir_combi_list[char.character.faction.name] then
                local eduEntry = M2TWEOPDU.getEduEntryByType(leaderheir_combi_list[char.character.faction.name].heir.unit)
                if eduEntry ~= nil then
                    if eduEntry:hasOwnership(char.character.faction.factionID) then
                        if not tableContains(temp_gen_units, leaderheir_combi_list[char.character.faction.name].heir.unit) then
                            table.insert(temp_gen_units, leaderheir_combi_list[char.character.faction.name].heir.unit)
                        end
                        if not basic_rank_check[char.label] then
                            basic_rank_check[char.label] = 4
                        else
                            if basic_rank_check[char.label] < 4 then
                                basic_rank_check[char.label] = 4
                            end
                        end
                    end
                end
            end
        end
    end
    gen_units_char = char.character

    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."Function End");
	end
end

function genRankCheck(faction, char)
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."genRankCheck");
	end
    temp_com_inf = 0
    if faction ~= nil then
        if faction.isPlayerControlled == 0 then return end
        for i = 0, faction.numOfCharacters - 1 do
            local char = faction:getCharacter(i)
            if char:getTypeID() == 7 then
                if char.bodyguards ~= nil then
                    local char = char.characterRecord
                    if char.label == "" then
                        --char.label = char.shortName..tostring(eur_turn_number)
                        char:giveValidLabel()
                    end
                    local name = char.shortName..tostring(char.label)
                    if not persistent_gen_list[name] then
                        persistent_gen_list[name] = {}
                        persistent_gen_list[name].turns = 1
                        persistent_gen_list[name].cooldown = 0
                        persistent_gen_list[name].command = {}
                        persistent_gen_list[name].loyalty = {}
                        persistent_gen_list[name].authority = {}
                        persistent_gen_list[name].battle_kills = 0
                        persistent_gen_list[name].battle_won = 0
                        persistent_gen_list[name].command[persistent_gen_list[name].turns]   = math.min(char.command, 10)
                        if char:isLeader() then
                            persistent_gen_list[name].authority[persistent_gen_list[name].turns] = math.min(char.authority, 10)
                        else
                            persistent_gen_list[name].authority[persistent_gen_list[name].turns] = 0
                        end
                        if not char:isLeader() then
                            persistent_gen_list[name].loyalty[persistent_gen_list[name].turns]   = math.min(char.loyalty, 10)
                        else
                            persistent_gen_list[name].loyalty[persistent_gen_list[name].turns]   = 0
                        end
                    else
                        if persistent_gen_list[name].turns > 4 then
                            persistent_gen_list[name].turns = 1
                        else
                            persistent_gen_list[name].turns = persistent_gen_list[name].turns+1
                        end
                        if persistent_gen_list[name].cooldown > 0 then
                            persistent_gen_list[name].cooldown = persistent_gen_list[name].cooldown-1
                        end
                        persistent_gen_list[name].command[persistent_gen_list[name].turns]   = math.min(char.command, 10)
                        if char:isLeader() then
                            persistent_gen_list[name].authority[persistent_gen_list[name].turns] = math.min(char.authority, 10)
                        else
                            persistent_gen_list[name].authority[persistent_gen_list[name].turns] = 0
                        end
                        if not char:isLeader() then
                            persistent_gen_list[name].loyalty[persistent_gen_list[name].turns]   = math.min(char.loyalty, 10)
                        else
                            persistent_gen_list[name].loyalty[persistent_gen_list[name].turns]   = 0
                        end
                    end
                end
            end
        end
    end
    if char ~= nil then
        if gen_rank_char ~= char then
            local name = char.shortName..tostring(char.label)
            if persistent_gen_list[name] ~= nil then
                for i = 1, persistent_gen_list[name].turns do
                    if persistent_gen_list[name].command[i] ~= nil then
                        temp_com_inf = temp_com_inf+((persistent_gen_list[name].command[i]+persistent_gen_list[name].loyalty[i]+persistent_gen_list[name].authority[i])*2)
                        local kills_rank = math.floor(persistent_gen_list[name].battle_kills/100)
                        local won_rank = math.floor(persistent_gen_list[name].battle_won / 2)
                        temp_com_inf = temp_com_inf + kills_rank + won_rank
                    end
                end
                return temp_com_inf
            else
                return 0
            end
            gen_rank_char = char
        else
            return temp_com_inf
        end
    end
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."Function End");
	end
end

function setBGSize(faction, character, unit)
    if faction ~= nil then
        if faction.name == "slave" then return end
    end
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."setBGSize");
	end
    if options_first_run then return end
    if faction ~= nil then
        for i = 0, faction.numOfCharacters - 1 do
            temp_char = faction:getCharacter(i)
            if temp_char:getTypeID() == 7 then
                if temp_char.bodyguards ~= nil then
                    if faction.isPlayerControlled == 1 then
                        if temp_char.characterRecord.label == "" then
                            --char.label = char.shortName..tostring(eur_turn_number)
                            temp_char.characterRecord:giveValidLabel()
                        end
                        if persistent_gen_list_reset[temp_char.characterRecord.label] == nil then
                            if default_general_units[faction.name] ~= nil then
                                if default_general_units[faction.name].old == temp_char.bodyguards.eduEntry.eduType then
                                    local army = temp_char.army
                                    if temp_char.army == nil then
                                        if temp_char.settlement ~= nil then
                                            army = temp_char.settlement.army
                                        elseif temp_char.fort ~= nil then
                                            army = temp_char.fort.army
                                        elseif temp_char.armyNotLeaded ~= nil then
                                            army = temp_char.armyNotLeaded
                                        end
                                    end
                                    if army.numOfUnits < 20 then
                                        local level = (temp_char.characterRecord.command+temp_char.characterRecord.loyalty)
                                        if level > player_start_threshold then
                                            local rand = random_no_repeat(0, #gen_units_list[faction.name]["T2"]-1)
                                            new_bg = gen_units_list[faction.name]["T2"][rand]
                                        else
                                            local rand = random_no_repeat(0, #gen_units_list[faction.name]["T1"]-1)
                                            new_bg = gen_units_list[faction.name]["T1"][rand]
                                        end
                                        if new_bg then
                                            setBodyguard(temp_char, (new_bg), temp_char.bodyguards.exp, temp_char.bodyguards.weaponLVL, 0, "")
                                            persistent_gen_list_reset[temp_char.characterRecord.label] = true
                                        end
                                    end
                                else
                                    persistent_gen_list_reset[temp_char.characterRecord.label] = true
                                    if not labtrait_units_list[temp_char.characterRecord.label] then
                                        --table.insert(combo_labtrait_list, temp_char.characterRecord.label)
                                        labtrait_units_list[temp_char.characterRecord.label] = temp_char.bodyguards.eduEntry.eduType
                                    end
                                end
                            end
                        end
                    else
                        if temp_char.characterRecord.label == "" then
                            --char.label = char.shortName..tostring(eur_turn_number)
                            temp_char.characterRecord:giveValidLabel()
                        end
                        if persistent_gen_list_reset[temp_char.characterRecord.label] == nil then
                            if default_general_units[faction.name] ~= nil then
                                if default_general_units[faction.name].old == temp_char.bodyguards.eduEntry.eduType then
                                    local army = temp_char.army
                                    if temp_char.army == nil then
                                        if temp_char.settlement ~= nil then
                                            army = temp_char.settlement.army
                                        elseif temp_char.fort ~= nil then
                                            army = temp_char.fort.army
                                        elseif temp_char.armyNotLeaded ~= nil then
                                            army = temp_char.armyNotLeaded
                                        end
                                    end
                                    if army == nil then return end
                                    if army.numOfUnits < 20 then
                                        local level = (temp_char.characterRecord.command+temp_char.characterRecord.loyalty)
                                        if level > 7 then
                                            if random_no_repeat(1, 100) > 75 then
                                                local rand = random_no_repeat(1, #gen_units_list[faction.name]["special"])
                                                new_bg = gen_units_list[faction.name]["special"][rand]
                                            else
                                                local rand = random_no_repeat(0, #gen_units_list[faction.name]["T3"]-1)
                                                new_bg = gen_units_list[faction.name]["T3"][rand]
                                            end
                                        else
                                            local rand = random_no_repeat(0, #gen_units_list[faction.name]["T2"]-1)
                                            new_bg = gen_units_list[faction.name]["T2"][rand]
                                        end
                                        if default_general_units[army.faction.name] then
                                            if new_bg then
                                                if new_bg ~= default_general_units[army.faction.name].old then
                                                    setBodyguard(temp_char, (new_bg), temp_char.bodyguards.exp, temp_char.bodyguards.weaponLVL, 0, "")
                                                    persistent_gen_list_reset[temp_char.characterRecord.label] = true
                                                end
                                            end
                                        end
                                    end
                                else
                                    persistent_gen_list_reset[temp_char.characterRecord.label] = true
                                    if not labtrait_units_list[temp_char.characterRecord.label] then
                                        --table.insert(combo_labtrait_list, temp_char.characterRecord.label)
                                        labtrait_units_list[temp_char.characterRecord.label] = temp_char.bodyguards.eduEntry.eduType
                                    end
                                end
                            end
                        end
                    end
                    if options_gen_bg_size then
                        local un_max = temp_char.bodyguards.soldierCountStratMapMax
                        local un_min = (un_max * (bg_min_size_multi/100))
                        local multi = (un_max - un_min) / 10
                        local command_add = 0
                        if temp_char.characterRecord.command > 0 then
                            command_add = (multi*temp_char.characterRecord.command)
                        end
                        local additional = 0
                        if (temp_char.characterRecord.personalSecurity+temp_char.characterRecord.bodyguardSize) > 0 then
                            additional = ((temp_char.characterRecord.personalSecurity+temp_char.characterRecord.bodyguardSize) * 2.5)
                        end
                        local new_max = math.floor(un_min + command_add + additional)
                        if temp_char.bodyguards.soldierCountStratMap > new_max then
                            temp_char.bodyguards.soldierCountStratMap = new_max
                        end
                    end
                end
            end
        end
    end
    if character ~= nil then
        local faction = character.faction
        if character:getTypeID() == nil then return end
        if character:getTypeID() == 7 then
            if character.bodyguards ~= nil then
                if character.faction.isPlayerControlled == 1 then
                    if character.characterRecord.label == "" then
                        --char.label = char.shortName..tostring(eur_turn_number)
                        character.characterRecord:giveValidLabel()
                    end
                    if persistent_gen_list_reset[character.characterRecord.label] == nil then
                        if default_general_units[character.faction.name] ~= nil then
                            if default_general_units[character.faction.name].old == character.bodyguards.eduEntry.eduType then
                                local army = character.army
                                if character.army == nil then
                                    if character.settlement ~= nil then
                                        army = character.settlement.army
                                    elseif character.fort ~= nil then
                                        army = character.fort.army
                                    elseif character.armyNotLeaded ~= nil then
                                        army = character.armyNotLeaded
                                    end
                                end
                                if army == nil then return end
                                if army.numOfUnits < 20 then
                                    if level > player_start_threshold then
                                        local rand = random_no_repeat(0, #gen_units_list[faction.name]["T2"]-1)
                                        new_bg = gen_units_list[faction.name]["T2"][rand]
                                    else
                                        local rand = random_no_repeat(0, #gen_units_list[faction.name]["T1"]-1)
                                        new_bg = gen_units_list[faction.name]["T1"][rand]
                                    end
                                    if new_bg then
                                        setBodyguard(character, (new_bg), character.bodyguards.exp, character.bodyguards.weaponLVL, 0, "")
                                        persistent_gen_list_reset[character.characterRecord.label] = true
                                    end
                                end
                            else
                                persistent_gen_list_reset[character.characterRecord.label] = true
                                if not labtrait_units_list[character.characterRecord.label] then
                                    --table.insert(combo_labtrait_list, character.characterRecord.label)
                                    labtrait_units_list[character.characterRecord.label] = character.bodyguards.eduEntry.eduType
                                end
                            end
                        end
                    end
                else
                    if character.characterRecord.label == "" then
                        --char.label = char.shortName..tostring(eur_turn_number)
                        character.characterRecord:giveValidLabel()
                    end
                    if persistent_gen_list_reset[character.characterRecord.label] == nil then
                        if default_general_units[faction.name] ~= nil then
                            if default_general_units[faction.name].old == character.bodyguards.eduEntry.eduType then
                                local army = character.army
                                if character.army == nil then
                                    if character.settlement ~= nil then
                                        army = character.settlement.army
                                    elseif character.fort ~= nil then
                                        army = character.fort.army
                                    elseif character.armyNotLeaded ~= nil then
                                        army = character.armyNotLeaded
                                    end
                                end
                                if army == nil then return end
                                if army.numOfUnits < 20 then
                                    local level = (character.characterRecord.command+character.characterRecord.loyalty)
                                    if level > 7 then
                                        if random_no_repeat(1, 100) > 75 then
                                            local rand = random_no_repeat(1, #gen_units_list[faction.name]["special"])
                                            new_bg = gen_units_list[faction.name]["special"][rand]
                                        else
                                            local rand = random_no_repeat(0, #gen_units_list[faction.name]["T3"]-1)
                                            new_bg = gen_units_list[faction.name]["T3"][rand]
                                        end
                                    else
                                        local rand = random_no_repeat(0, #gen_units_list[faction.name]["T2"]-1)
                                        new_bg = gen_units_list[faction.name]["T2"][rand]
                                    end
                                    if default_general_units[army.faction.name] then
                                        if new_bg then
                                            if new_bg ~= default_general_units[army.faction.name].old then
                                                setBodyguard(temp_char, (new_bg), temp_char.bodyguards.exp, temp_char.bodyguards.weaponLVL, 0, "")
                                                persistent_gen_list_reset[temp_char.characterRecord.label] = true
                                            end
                                        end
                                    end
                                end
                            else
                                persistent_gen_list_reset[character.characterRecord.label] = true
                                if not labtrait_units_list[character.characterRecord.label] then
                                    --table.insert(combo_labtrait_list, temp_char.characterRecord.label)
                                    labtrait_units_list[character.characterRecord.label] = character.bodyguards.eduEntry.eduType
                                end
                            end
                        end
                    end
                end
                if options_gen_bg_size then
                    local un_max = character.bodyguards.soldierCountStratMapMax
                    local un_min = (un_max * (bg_min_size_multi/100))
                    local multi = (un_max - un_min) / 10
                    local command_add = 0
                    if character.characterRecord.command > 0 then
                        command_add = (multi*character.characterRecord.command)
                    end
                    local additional = 0
                    if (character.characterRecord.personalSecurity+character.characterRecord.bodyguardSize) > 0 then
                        additional = ((character.characterRecord.personalSecurity+character.characterRecord.bodyguardSize) * 2.5)
                    end
                    local new_max = math.floor(un_min + command_add + additional)
                    if character.bodyguards.soldierCountStratMap > new_max then
                        character.bodyguards.soldierCountStratMap = new_max
                    end
                end
            end
        end
    end
    if unit ~= nil then
        if unit.character == nil then return end
        temp_char = unit.character
        local faction = temp_char.faction
        if temp_char:getTypeID() == 7 then
            if temp_char.bodyguards ~= nil then
                if temp_char.faction.isPlayerControlled == 1 then
                    if temp_char.characterRecord.label == "" then
                        --char.label = char.shortName..tostring(eur_turn_number)
                        temp_char.characterRecord:giveValidLabel()
                    end
                    if persistent_gen_list_reset[temp_char.characterRecord.label] == nil then
                        if default_general_units[temp_char.faction.name] ~= nil then
                            if default_general_units[temp_char.faction.name].old == temp_char.bodyguards.eduEntry.eduType then
                                local army = temp_char.army
                                if temp_char.army == nil then
                                    if temp_char.settlement ~= nil then
                                        army = temp_char.settlement.army
                                    elseif temp_char.fort ~= nil then
                                        army = temp_char.fort.army
                                    elseif temp_char.armyNotLeaded ~= nil then
                                        army = temp_char.armyNotLeaded
                                    end
                                end
                                if army == nil then return end
                                if army.numOfUnits < 20 then
                                    local level = (temp_char.characterRecord.command+temp_char.characterRecord.loyalty)
                                    if level > player_start_threshold then
                                        local rand = random_no_repeat(0, #gen_units_list[faction.name]["T2"]-1)
                                        new_bg = gen_units_list[faction.name]["T2"][rand]
                                    else
                                        local rand = random_no_repeat(0, #gen_units_list[faction.name]["T1"]-1)
                                        new_bg = gen_units_list[faction.name]["T1"][rand]
                                    end
                                    if new_bg then
                                        setBodyguard(temp_char, (new_bg), temp_char.bodyguards.exp, temp_char.bodyguards.weaponLVL, 0, "")
                                        persistent_gen_list_reset[temp_char.characterRecord.label] = true
                                    end
                                end
                            else
                                persistent_gen_list_reset[temp_char.characterRecord.label] = true
                                if not labtrait_units_list[temp_char.characterRecord.label] then
                                    --table.insert(combo_labtrait_list, temp_char.characterRecord.label)
                                    labtrait_units_list[temp_char.characterRecord.label] = temp_char.bodyguards.eduEntry.eduType
                                end
                            end
                        end
                    end
                else
                    if temp_char.characterRecord.label == "" then
                        --char.label = char.shortName..tostring(eur_turn_number)
                        temp_char.characterRecord:giveValidLabel()
                    end
                    if persistent_gen_list_reset[temp_char.characterRecord.label] == nil then
                        if default_general_units[faction.name] ~= nil then
                            if default_general_units[faction.name].old == temp_char.bodyguards.eduEntry.eduType then
                                local army = temp_char.army
                                if temp_char.army == nil then
                                    if temp_char.settlement ~= nil then
                                        army = temp_char.settlement.army
                                    elseif temp_char.fort ~= nil then
                                        army = temp_char.fort.army
                                    elseif temp_char.armyNotLeaded ~= nil then
                                        army = temp_char.armyNotLeaded
                                    end
                                end
                                if army == nil then return end
                                if army.numOfUnits < 20 then
                                    local level = (temp_char.characterRecord.command+temp_char.characterRecord.loyalty)
                                    if level > 7 then
                                        if random_no_repeat(1, 100) > 75 then
                                            local rand = random_no_repeat(1, #gen_units_list[faction.name]["special"])
                                            new_bg = gen_units_list[faction.name]["special"][rand]
                                        else
                                            local rand = random_no_repeat(0, #gen_units_list[faction.name]["T3"]-1)
                                            new_bg = gen_units_list[faction.name]["T3"][rand]
                                        end
                                    else
                                        local rand = random_no_repeat(0, #gen_units_list[faction.name]["T2"]-1)
                                        new_bg = gen_units_list[faction.name]["T2"][rand]
                                    end
                                    if new_bg then
                                        if default_general_units[army.faction.name] then
                                            if new_bg then
                                                if new_bg ~= default_general_units[army.faction.name].old then
                                                    setBodyguard(temp_char, (new_bg), temp_char.bodyguards.exp, temp_char.bodyguards.weaponLVL, 0, "")
                                                    persistent_gen_list_reset[temp_char.characterRecord.label] = true
                                                end
                                            end
                                        end
                                    end
                                end
                            else
                                persistent_gen_list_reset[temp_char.characterRecord.label] = true
                                if not labtrait_units_list[temp_char.characterRecord.label] then
                                    --table.insert(combo_labtrait_list, temp_char.characterRecord.label)
                                    labtrait_units_list[temp_char.characterRecord.label] = temp_char.bodyguards.eduEntry.eduType
                                end
                            end
                        end
                    end
                end
                if options_gen_bg_size then
                    local un_max = temp_char.bodyguards.soldierCountStratMapMax
                    local un_min = (un_max * (bg_min_size_multi/100))
                    local multi = (un_max - un_min) / 10
                    local additional = ((temp_char.characterRecord.personalSecurity+temp_char.characterRecord.bodyguardSize) * 2.5)
                    local new_max = math.floor(un_min + (multi*temp_char.characterRecord.command) + additional)
                    if temp_char.bodyguards.soldierCountStratMap > new_max then
                        temp_char.bodyguards.soldierCountStratMap = new_max
                    end
                end
            end
        end
    end
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."Function End");
	end
end

gen_pool_info = {}
gen_pool_reset = false

function genPoolReset()
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."genPoolReset");
	end
    local reset = false
    if not gen_pool_reset then return end
    for k, v in pairs(gen_pool_info) do
        local sett = M2TW.stratMap:getSettlement(gen_pool_info[k].name)
        for i = 0, sett.recruitmentPoolCount - 1 do
            local pool = sett:getSettlementRecruitmentPool(i)
            if pool.eduIndex == gen_pool_info[k].eduIndex then
                --print(pool.availablePool)
                --print(gen_pool_info[k].availablePool)
                if pool.availablePool == gen_pool_info[k].availablePool then
                    --
                else
                    pool.availablePool = gen_pool_info[k].availablePool
                    reset = true
                    --print("resetting pool: "..gen_pool_info[k].name)
                end
            end
        end
    end
    if reset then
        gen_pool_reset = false
        gen_pool_info = {}
    end
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."Function End");
	end
end

function setBodyguard(character, newBodyguardType, expLvl, weaponLvl, armourLvl, bgAlias)
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."setBodyguard");
	end
    if not options_gen_upgrades then return end
    local edu = M2TWEOPDU.getEduEntryByType(newBodyguardType)
    if edu == nil then return end
    local expLvl = expLvl or 0;
    local armourLvl = armourLvl or 0;
    local weaponLvl = weaponLvl or 0;
    if character.bodyguards.eduEntry.eduType == default_general_units[character.faction.name].old then
        character.bodyguards.eduEntry = M2TWEOPDU.getEduEntryByType("Bandits")
    end
    local originalBodyguard = character.bodyguards;
    local pool_check = originalBodyguard
    if pool_check.eduEntry.eduType == default_general_units[character.faction.name].old then
        local sett = character.settlement
        if sett then
            for i = 0, sett.recruitmentPoolCount - 1 do
                local pool = sett:getSettlementRecruitmentPool(i)
                if pool.eduIndex == pool_check.eduEntry.index then
                    if not gen_pool_info[sett.name] then
                        gen_pool_info[sett.name] = {}
                        gen_pool_info[sett.name].set_already = false
                    end
                    if gen_pool_info[sett.name].set_already == false then
                        gen_pool_info[sett.name].availablePool = pool.availablePool
                        gen_pool_info[sett.name].eduIndex = pool.eduIndex
                        gen_pool_info[sett.name].name = sett.name
                        gen_pool_info[sett.name].set_already = true
                        gen_pool_reset = true
                    end
                end
            end
        end
    end
    --  does the stack have space for a new unit?
    if originalBodyguard.army.numOfUnits < 20 then
        newBodyguard = originalBodyguard.army:createUnit(newBodyguardType, expLvl, armourLvl, weaponLvl);
        newBodyguard.alias = bgAlias
        character:setBodyguardUnit(newBodyguard);
        setBGSize(nil, character, nil)
        originalBodyguard:kill();
    else
        local tempBodyguard = nil;
        for i = 0, originalBodyguard.army.numOfUnits, 1 do
            unit = originalBodyguard.army:getUnit(i);
            newBodyguard.alias = bgAlias
            if unit.character == nil then
                tempBodyguard = unit;
                break
            end
        end
        -- if this is nil, your stack is full of generals (for some reason)
        if tempBodyguard then
            character:setBodyguardUnit(tempBodyguard);
            originalBodyguard:kill();
            newBodyguard = tempBodyguard.army:createUnit(newBodyguardType, expLvl, armourLvl, weaponLvl);
            newBodyguard.alias = bgAlias
            character:setBodyguardUnit(newBodyguard);
            setBGSize(nil, character, nil)
        end
    end
    temp_char_stuff = nil
    temp_char_stuff2 = nil

    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."Function End");
	end
end


function setBodyguardnoUP(character, newBodyguardType, expLvl, weaponLvl, armourLvl, bgAlias)
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."setBodyguard");
	end
    local edu = M2TWEOPDU.getEduEntryByType(newBodyguardType)
    if edu == nil then return end
    local expLvl = expLvl or 0;
    local armourLvl = armourLvl or 0;
    local weaponLvl = weaponLvl or 0;
    if character.bodyguards.eduEntry.eduType == default_general_units[character.faction.name].old then
        character.bodyguards.eduEntry = M2TWEOPDU.getEduEntryByType("Bandits")
    end
    local originalBodyguard = character.bodyguards;
    local pool_check = originalBodyguard
    if pool_check.eduEntry.eduType == default_general_units[character.faction.name].old then
        local sett = character.settlement
        if sett then
            for i = 0, sett.recruitmentPoolCount - 1 do
                local pool = sett:getSettlementRecruitmentPool(i)
                if pool.eduIndex == pool_check.eduEntry.index then
                    if not gen_pool_info[sett.name] then
                        gen_pool_info[sett.name] = {}
                        gen_pool_info[sett.name].set_already = false
                    end
                    if gen_pool_info[sett.name].set_already == false then
                        gen_pool_info[sett.name].availablePool = pool.availablePool
                        gen_pool_info[sett.name].eduIndex = pool.eduIndex
                        gen_pool_info[sett.name].name = sett.name
                        gen_pool_info[sett.name].set_already = true
                        gen_pool_reset = true
                    end
                end
            end
        end
    end
    --  does the stack have space for a new unit?
    if originalBodyguard.army.numOfUnits < 20 then
        newBodyguard = originalBodyguard.army:createUnit(newBodyguardType, expLvl, armourLvl, weaponLvl);
        newBodyguard.alias = bgAlias
        character:setBodyguardUnit(newBodyguard);
        setBGSize(nil, character, nil)
        originalBodyguard:kill();
    else
        local tempBodyguard = nil;
        for i = 0, originalBodyguard.army.numOfUnits, 1 do
            unit = originalBodyguard.army:getUnit(i);
            newBodyguard.alias = bgAlias
            if unit.character == nil then
                tempBodyguard = unit;
                break
            end
        end
        -- if this is nil, your stack is full of generals (for some reason)
        if tempBodyguard then
            character:setBodyguardUnit(tempBodyguard);
            originalBodyguard:kill();
            newBodyguard = tempBodyguard.army:createUnit(newBodyguardType, expLvl, armourLvl, weaponLvl);
            newBodyguard.alias = bgAlias
            character:setBodyguardUnit(newBodyguard);
            setBGSize(nil, character, nil)
        end
    end
    temp_char_stuff = nil
    temp_char_stuff2 = nil

    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."Function End");
	end
end



function genUnlockNotifation(faction)
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."genUnlockNotifation");
	end
    if not options_gennotif then return end
    if faction.isPlayerControlled == 0 then return end
    for i = 0, faction.numOfCharacters - 1 do
        local char = faction:getCharacter(i)
        if char:getTypeID() == 7 then
            if char.label == "" then
                char:giveValidLabel()
            end
            char = char.characterRecord
            local char_rank = genRankCheck(nil, char)
            if not char_unlocks[char.label] then
                char_unlocks[char.label] = {}
                char_unlocks[char.label].high = 0
                char_unlocks[char.label].t2 = false
                char_unlocks[char.label].t3 = false
                char_unlocks[char.label].heir = false
                char_unlocks[char.label].leader = false
                char_unlocks[char.label].special = false
            end
            if char_rank == nil then return end
            if char_rank > char_unlocks[char.label].high then
                if not char_unlocks[char.label].t2 then
                    if char_rank > 110 then
                        char_unlocks[char.label].t2 = true
                        local un_list = "\n"
                        for i = 0, #gen_units_list[faction.name]["T2"] - 1 do 
                            --un_list = un_list.."\n"..gen_units_list[faction.name]["T2"][i]
                        end
                        --stratmap.game.historicEvent("militaryunithired", "Bodyguard Unlocked", "A new tier of units is has been unlocked for this general:\n\n"..char.localizedDisplayName..un_list)
                    end
                end
                if not char_unlocks[char.label].t3 then
                    if char_rank > 170 then
                        local un_list = "\n"
                        for i = 0, #gen_units_list[faction.name]["T3"] - 1 do 
                            --un_list = un_list.."\n"..gen_units_list[faction.name]["T3"][i]
                        end
                        char_unlocks[char.label].t3 = true
                        --stratmap.game.historicEvent("militaryunithired", "Bodyguard Unlocked", "A new tier of units is has been unlocked for this general:\n\n"..char.localizedDisplayName..un_list)
                    end
                end
            end
            char_unlocks[char.label].high = char_rank
            if not char_unlocks[char.label].special then
                for k, v in pairs(conquer_traits) do 
                    if char:getTraitLevel(k) > v then
                        local un_list = "\n"
                        for i = 1, #gen_units_list[faction.name]["special"] do 
                            --un_list = un_list.."\n"..gen_units_list[faction.name]["special"][i]
                        end
                        char_unlocks[char.label].special = true
                        --stratmap.game.historicEvent("militaryunithired", "Bodyguard Unlocked", "A new tier of units is has been unlocked for this general:\n\n"..char.localizedDisplayName..un_list)
                    end
                end
            end
            if not char_unlocks[char.label].leader then
                if char:getTraitLevel("FactionLeader") > 0 then
                    local un_list = "\n"
                    --un_list = un_list..leaderheir_combi_list[char.character.faction.name].leader.unit
                    char_unlocks[char.label].leader = true
                    --stratmap.game.historicEvent("militaryunithired", "Bodyguard Unlocked", "A new tier of units is has been unlocked for this general:\n\n"..char.localizedDisplayName..un_list)
                end
            end
            if not char_unlocks[char.label].heir then
                if char:getTraitLevel("FactionHeir") > 0 then
                    local un_list = "\n"
                    --un_list = un_list..leaderheir_combi_list[char.character.faction.name].heir.unit
                    char_unlocks[char.label].heir = true
                    --stratmap.game.historicEvent("militaryunithired", "Bodyguard Unlocked", "A new tier of units is has been unlocked for this general:\n\n"..char.localizedDisplayName..un_list)
                end
            end
        end
    end
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."Function End");
	end
end

function dorwinionGeneralBGCheck()
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."dorwinionGeneralBGCheck");
	end
    if not kon_bg_check then
        if checkCounter("kon_council_choice_accepted") then
        --gen upgrades
                gen_units_list_default["denmark"] = {
                    ["T1"] = {
                        [0] = "Eregion Lindar Guards",
                        [1] = "Eregion Lindar Mariners",
                        [2] = "Eregion Lindar Bowmen",
                    },
                    ["T2"] = {
                        [0] = "Eregion Mithrim Spearmen",
                        [1] = "Eregion Mithrim Swordsmen",
                        [2] = "Eregion Mithrim Archers",
                    },
                    ["T3"] = {
                        [0] = "Eregion Barad Bladesmen",
                        [1] = "Eregion Barad Marines",
                        [2] = "Eregion Barad Archers",
                    },
                    ["special"] = {
                        "Mithlond Nobles",
                    },
                }
                gen_units_list_default["saxons"] = {
                    ["T1"] = {
                        [0] = "Eregion Sword Quendi",
                        [1] = "Eregion Spear Quendi",
                        [2] = "Eregion Bow Quendi",
                    },
                    ["T2"] = {
                        [0] = "Eregion Mithrim Spearmen",
                        [1] = "Eregion Mithrim Swordsmen",
                        [2] = "Eregion Mithrim Archers",
                    },
                    ["T3"] = {
                        [0] = "Eregion Barad Bladesmen",
                        [1] = "Eregion Barad Marines",
                        [2] = "Eregion Barad Archers",
                    },
                    ["special"] = {
                        "Elderinwe Roquen",
                    },
                }
            kon_bg_check = true
        end
    end
    if not dorwinion_bg_check then
        if checkCounter("dorwinion_elf") then
            gen_units_list_default["byzantium"]["T3"][0] = "Moriquendi Sentinels"
            gen_units_list_default["byzantium"]["special"][0] = "Moriquendi Gladelords"
            
            dorwinion_bg_check = true
        end
        if checkCounter("dorwinion_men") then
            gen_units_list_default["byzantium"]["T3"][0] = "Vintner-Court Paladins"
            gen_units_list_default["byzantium"]["special"][0] = "Elvellyn Hammerguard"
            
            dorwinion_bg_check = true
        end
    end
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."Function End");
	end
end
