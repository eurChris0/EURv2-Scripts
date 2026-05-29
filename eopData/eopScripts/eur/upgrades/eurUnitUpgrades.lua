in_campaign_map = false

local temp_unit_choice = 1
local upgrade_message = ""
local unit_cost = 0
local temp_upgrade_unit = nil

   
unit_names = {}



  local upgradeName = ""
  local old_unit_army = nil
  local old_unit_exp = 0
  local old_unit_sol = 0
  local old_unit_solmax = 0

  local old_unit_edu = ""
  local old_unit_weapon = 0

function upgradeWindow()
    upgrade_message = ""
    unit_cost = 0
    local faction_id = M2TWEOP.getLocalFactionID()
    if sel_unit == nil then return end
    scroll_unit = sel_unit
    if scroll_unit == nil then return end
    if not unit_only then return end
    if scroll_unit ~= nil then
        unit = scroll_unit
        if unit == nil then return end
        if unit ~= temp_upgrade_unit then
            temp_unit_choice = 1
        end
        if unit.army ~= nil then
            if unit.army.faction.factionID ~= faction_id then 
                window_states.show_upgrade_window = false
            return end
            if unit.eduEntry == nil then return end
            if not UNIT_UPGRADES[unit.eduEntry.eduType] then return end
            --if unit.army:findInFort() or unit.army:findInSettlement() then

                ImGui.SetNextWindowPos(5*eurbackgroundWindowSizeRight, 5*eurbackgroundWindowSizeBottom)
                ImGui.SetNextWindowBgAlpha(0)
                ImGui.SetNextWindowSize(955*eurbackgroundWindowSizeRight, 825*eurbackgroundWindowSizeBottom)
                ImGui.Begin("Upgrades2", true, bit.bor(ImGuiWindowFlags.NoScrollWithMouse, ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoBackground))
                ImGui.SetWindowFontScale(1.1*eurbackgroundWindowSizeRight)
                eurStyle("basic_4", true)
                if faction_bg[M2TWEOP.getCultureName(eur_player_faction.cultureID)] then
                    ImGui.Image(faction_bg[M2TWEOP.getCultureName(eur_player_faction.cultureID)].img, 945*eurbackgroundWindowSizeRight, 815*eurbackgroundWindowSizeBottom)
                end

                ImGui.SetNextWindowPos(300*eurbackgroundWindowSizeRight, 50*eurbackgroundWindowSizeBottom)
                ImGui.SetNextWindowBgAlpha(0)
                ImGui.SetNextWindowSize(400*eurbackgroundWindowSizeRight, 100*eurbackgroundWindowSizeBottom)
                ImGui.BeginChild("Child Window##A13", 840*eurbackgroundWindowSizeRight, 680*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)


                ImGui.Image(u_text.img,400*eurbackgroundWindowSizeRight,50*eurbackgroundWindowSizeBottom)
                ImGui.EndChild()

                ImGui.SetNextWindowBgAlpha(0.6)
                ImGui.SetNextWindowPos(70*eurbackgroundWindowSizeRight, 100*eurbackgroundWindowSizeBottom)
                if not UNIT_UPGRADES[unit.eduEntry.eduType] then return end
                ImGui.BeginChild("Child Window##A12", 820*eurbackgroundWindowSizeRight, 640*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
                ImGui.NewLine()
                --ImGui.Separator()
                ImGui.Text(unit.eduEntry.localizedName)
                ImGui.Text("Experience: "..tostring(unit.exp))
                if eur_tga_table[unit.eduEntry.unitCardTga] ~= nil then
                    ImGui.Image(eur_tga_table[unit.eduEntry.unitCardTga].img, img_x, img_y)
                end
                local hovered = ImGui.IsItemHovered()
                if hovered then
                    eurStyle("tooltip", true)
                    ImGui.BeginTooltip()
                    ImGui.Text(M2TWEOPDU.getEduEntryByType(unit.eduEntry.eduType).localizedName)
                    showEDUStats(unit.eduEntry.eduType)
                    ImGui.EndTooltip()
                    eurStyle("tooltip", false)
                end
                ImGui.Text("Upgrades:")
                --[[for j = 1, #UNIT_UPGRADES[unit.eduEntry.eduType].unit do
                    local eduEntry = M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[unit.eduEntry.eduType].unit[j])
                    if eduEntry:hasOwnership(faction_id) then
                        local check_counter = checkCounter(UNIT_UPGRADES[unit.eduEntry.eduType].counter[j])
                        if check_counter == true then
                            ImGui.Text(
                                "- " ..
                                    UNIT_UPGRADES[unit.eduEntry.eduType].unit[j] ..
                                        ", " .. "Gold: " .. tostring(math.ceil((eduEntry.recruitCost * UNIT_UPGRADES[unit.eduEntry.eduType].cost_multi[j]))) .. ", Rank: ")
                            ImGui.SameLine()
                            if unit.exp >= (UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[j]-unit_upgrades_multi) then
                                ImGui.TextColored(0,1,0,1,tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[j]-unit_upgrades_multi))
                            else
                                ImGui.TextColored(1,0,0,1,tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[j]-unit_upgrades_multi))
                            end
                        end
                    end
                end
                ImGui.NewLine()]]
                for i = 1, #UNIT_UPGRADES[unit.eduEntry.eduType].unit do
                    if unit.character ~= nil then
                        return
                    end
                    if UNIT_UPGRADES[unit.eduEntry.eduType].unit[i] ~= nil then
                        local eduEntry = M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[unit.eduEntry.eduType].unit[i])
                        local unit_tga = eduEntry.unitCardTga
                        if eduEntry:hasOwnership(faction_id) then
                            if (UNIT_UPGRADES[unit.eduEntry.eduType].faction == nil) or ( UNIT_UPGRADES[unit.eduEntry.eduType].faction ~= nil and UNIT_UPGRADES[unit.eduEntry.eduType].faction[i] == eur_player_faction.name) then
                                if checkCounter(UNIT_UPGRADES[unit.eduEntry.eduType].counter[i]) then
                                    if tableContains(list_edu_table, eduEntry.index) then
                                        unit_cost = math.ceil((eduEntry.recruitCost * UNIT_UPGRADES[unit.eduEntry.eduType].cost_multi[i]))
                                        if unit.army.faction.money >= unit_cost then
                                            -----local unitSize = getUnitSizeMult()
                                            local exp_req = (UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                            if unit.exp >= exp_req then
                                                if eur_tga_table[unit_tga] ~= nil then
                                                    local upgrade_clicked = ImGui.ImageButton("upgrade_button_0"..tostring(i),eur_tga_table[unit_tga].img, img_x, img_y)
                                                    if (upgrade_clicked == true) then
                                                        temp_unit_choice=i
                                                        M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
                                                    end
                                                    local hovered = ImGui.IsItemHovered()
                                                    if hovered then
                                                        playMenuSound("2"..unit.eduEntry.eduType)
                                                        eurStyle("tooltip", true)
                                                        ImGui.BeginTooltip()
                                                        ImGui.Text(eduEntry.localizedName)
                                                        local exp_req_string = ""
                                                        if unit.exp >= (UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi) then
                                                            exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                                        else
                                                            exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                                        end
                                                        ImGui.Text("Experience required: "..exp_req_string)
                                                        ImGui.Text("Gold: " ..tostring(math.ceil((eduEntry.recruitCost * UNIT_UPGRADES[unit.eduEntry.eduType].cost_multi[i]))))
                                                        showEDUStats(eduEntry.eduType)
                                                        ImGui.EndTooltip()
                                                        eurStyle("tooltip", false)
                                                    end
                                                else
                                                    local upgrade_clicked = ImGui.Button(upgrade_message)
                                                    if (upgrade_clicked == true) then
                                                        M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
                                                        temp_unit_choice=i
                                                    end
                                                end
                                                ImGui.SameLine()
                                            else
                                                ImGui.SetNextWindowBgAlpha(0)
                                                ImGui.BeginChild("swapUGButton_button"..tostring(i), img_x, img_y, ImGuiChildFlags.FrameStyle)
                                                local pos_x, pos_y = ImGui.GetWindowPos()
                                                
                                                --centeredText(tostring(math.floor(unit_pool.availablePool)),65*eurbackgroundWindowSizeRight)
                                                
                                                ImGui.EndChild()
                                                ImGui.SetNextWindowBgAlpha(0)
                                                ImGui.SetNextWindowPos(pos_x, pos_y)
                                                ImGui.BeginChild("swapUGButton_button"..tostring(i).."##2", img_x, img_y, ImGuiChildFlags.FrameStyle)
                                                if eur_tga_table[unit_tga] ~= nil then
                                                    ImGui.Image(eur_tga_table[unit_tga].img, img_x, img_y)
                                                end
                                                ImGui.EndChild()
                                                ImGui.SetNextWindowBgAlpha(0.5)
                                                ImGui.SetNextWindowPos(pos_x, pos_y)
                                                ImGui.PushStyleColor(ImGuiCol.FrameBg,0.75,0.75,0.75,0.1)
                                                ImGui.BeginChild("swapUGButton_button"..tostring(i).."##3", img_x, img_y, ImGuiChildFlags.FrameStyle)
                                                ImGui.EndChild()
                                                ImGui.PopStyleColor()
                                                --ImGui.Image(eur_tga_table[unit_tga].img, img_x, img_y)
                                                ImGui.SameLine()
                                                local hovered = ImGui.IsItemHovered()
                                                if hovered then
                                                    eurStyle("tooltip", true)
                                                    ImGui.BeginTooltip()
                                                    ImGui.Text(eduEntry.localizedName)
                                                    local exp_req_string = ""
                                                    if unit.exp >= (UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi) then
                                                        exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                                    else
                                                        exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                                    end
                                                    ImGui.Text("Experience required: "..exp_req_string)
                                                    ImGui.Text("Gold: " ..tostring(math.ceil((eduEntry.recruitCost * UNIT_UPGRADES[unit.eduEntry.eduType].cost_multi[i]))))
                                                    ImGui.Text("Experience too low.")
                                                    showEDUStats(eduEntry.eduType)
                                                    ImGui.EndTooltip()
                                                    eurStyle("tooltip", false)
                                                end
                                            end
                                        else
                                            ImGui.SetNextWindowBgAlpha(0)
                                            ImGui.BeginChild("swapUGButton_button"..tostring(i), img_x, img_y, ImGuiChildFlags.FrameStyle)
                                            local pos_x, pos_y = ImGui.GetWindowPos()
                                            --ImGui.PushStyleColor(ImGuiCol.Text,0,0,0,1)
                                            --centeredText(tostring(math.floor(unit_pool.availablePool)),65*eurbackgroundWindowSizeRight)
                                            --ImGui.PopStyleColor()
                                            ImGui.EndChild()
                                            ImGui.SetNextWindowBgAlpha(0)
                                            ImGui.SetNextWindowPos(pos_x, pos_y)
                                            ImGui.BeginChild("swapUGButton_button"..tostring(i).."##2", img_x, img_y, ImGuiChildFlags.FrameStyle)
                                            if test1 ~= nil then
                                                ImGui.Image(test1.img, img_x, img_y)
                                            end
                                            ImGui.EndChild()
                                            ImGui.SetNextWindowBgAlpha(0.5)
                                            ImGui.SetNextWindowPos(pos_x, pos_y)
                                            ImGui.PushStyleColor(ImGuiCol.FrameBg,0.75,0.75,0.75,0.1)
                                            ImGui.BeginChild("swapUGButton_button"..tostring(i).."##3", img_x, img_y, ImGuiChildFlags.FrameStyle)
                                            ImGui.EndChild()
                                            ImGui.PopStyleColor()
                                            --ImGui.Image(eur_tga_table[unit_tga].img, img_x, img_y)
                                            ImGui.SameLine()
                                            local hovered = ImGui.IsItemHovered()
                                            if hovered then
                                                eurStyle("tooltip", true)
                                                ImGui.BeginTooltip()
                                                ImGui.Text(eduEntry.localizedName)
                                                local exp_req_string = ""
                                                if unit.exp >= (UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi) then
                                                    exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                                else
                                                    exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                                end
                                                ImGui.Text("Experience required: "..exp_req_string)
                                                ImGui.Text("Gold: " ..tostring(math.ceil((eduEntry.recruitCost * UNIT_UPGRADES[unit.eduEntry.eduType].cost_multi[i]))))
                                                ImGui.Text("Not enough gold.")
                                                showEDUStats(eduEntry.eduType)
                                                ImGui.EndTooltip()
                                                eurStyle("tooltip", false)
                                            end
                                        end
                                    else
                                        ImGui.SetNextWindowBgAlpha(0)
                                        ImGui.BeginChild("swapUGButton_button"..tostring(i), img_x, img_y, ImGuiChildFlags.FrameStyle)
                                        local pos_x, pos_y = ImGui.GetWindowPos()
                                        --ImGui.PushStyleColor(ImGuiCol.Text,0,0,0,1)
                                        --centeredText(tostring(math.floor(unit_pool.availablePool)),65*eurbackgroundWindowSizeRight)
                                        --ImGui.PopStyleColor()
                                        ImGui.EndChild()
                                        ImGui.SetNextWindowBgAlpha(0)
                                        ImGui.SetNextWindowPos(pos_x, pos_y)
                                        ImGui.BeginChild("swapUGButton_button"..tostring(i).."##2", img_x, img_y, ImGuiChildFlags.FrameStyle)
                                        if eur_tga_table[unit_tga] ~= nil then
                                            ImGui.Image(eur_tga_table[unit_tga].img, img_x, img_y)
                                        end
                                        ImGui.EndChild()
                                        ImGui.SetNextWindowBgAlpha(0.5)
                                        ImGui.SetNextWindowPos(pos_x, pos_y)
                                        ImGui.PushStyleColor(ImGuiCol.FrameBg,0.75,0.75,0.75,0.1)
                                        ImGui.BeginChild("swapUGButton_button"..tostring(i).."##3", img_x, img_y, ImGuiChildFlags.FrameStyle)
                                        ImGui.EndChild()
                                        ImGui.PopStyleColor()
                                        --ImGui.Image(eur_tga_table[unit_tga].img, img_x, img_y)
                                        ImGui.SameLine()
                                        local hovered = ImGui.IsItemHovered()
                                        if hovered then
                                            playMenuSound("5"..unit.eduEntry.eduType)
                                            eurStyle("tooltip", true)
                                            ImGui.BeginTooltip()
                                            ImGui.Text(eduEntry.localizedName)
                                            local exp_req_string = ""
                                            if unit.exp >= (UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi) then
                                                exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                            else
                                                exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                            end
                                            ImGui.Text("Experience required: "..exp_req_string)
                                            ImGui.Text("Gold: " ..tostring(math.ceil((eduEntry.recruitCost * UNIT_UPGRADES[unit.eduEntry.eduType].cost_multi[i]))))
                                            ImGui.Text("Building not present, a recruitment building for this unit must be present somewhere within the realm.")
                                            showEDUStats(eduEntry.eduType)
                                            ImGui.EndTooltip()
                                            eurStyle("tooltip", false)
                                        end
                                    end
                                else
                                    ImGui.SetNextWindowBgAlpha(0)
                                    ImGui.BeginChild("swapUGButton_button"..tostring(i), img_x, img_y, ImGuiChildFlags.FrameStyle)
                                    local pos_x, pos_y = ImGui.GetWindowPos()
                                    ImGui.PushStyleColor(ImGuiCol.Text,0,0,0,1)
                                    --centeredText(tostring(math.floor(unit_pool.availablePool)),65*eurbackgroundWindowSizeRight)
                                    ImGui.PopStyleColor()
                                    ImGui.EndChild()
                                    ImGui.SetNextWindowBgAlpha(0)
                                    ImGui.SetNextWindowPos(pos_x, pos_y)
                                    ImGui.BeginChild("swapUGButton_button"..tostring(i).."##2", img_x, img_y, ImGuiChildFlags.FrameStyle)
                                    if eur_tga_table[unit_tga] ~= nil then
                                        ImGui.Image(eur_tga_table[unit_tga].img, img_x, img_y)
                                    end
                                    ImGui.EndChild()
                                    ImGui.SetNextWindowBgAlpha(0.5)
                                    ImGui.SetNextWindowPos(pos_x, pos_y)
                                    ImGui.PushStyleColor(ImGuiCol.FrameBg,0.75,0.75,0.75,0.1)
                                    ImGui.BeginChild("swapUGButton_button"..tostring(i).."##3", img_x, img_y, ImGuiChildFlags.FrameStyle)
                                    ImGui.EndChild()
                                    ImGui.PopStyleColor()
                                    --ImGui.Image(eur_tga_table[unit_tga].img, img_x, img_y)
                                    ImGui.SameLine()
                                    local hovered = ImGui.IsItemHovered()
                                    if hovered then
                                        eurStyle("tooltip", true)
                                        ImGui.BeginTooltip()
                                        ImGui.Text(eduEntry.localizedName)
                                        local exp_req_string = ""
                                        if unit.exp >= (UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi) then
                                            exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                        else
                                            exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                        end
                                        ImGui.Text("Experience required: "..exp_req_string)
                                        ImGui.Text("Gold: " ..tostring(math.ceil((eduEntry.recruitCost * UNIT_UPGRADES[unit.eduEntry.eduType].cost_multi[i]))))
                                        ImGui.Text("Upgrade unlocked after special event.")
                                        showEDUStats(eduEntry.eduType)
                                        ImGui.EndTooltip()
                                        eurStyle("tooltip", false)
                                    end
                                end
                            end
                        else
                            ImGui.SetNextWindowBgAlpha(0)
                            ImGui.BeginChild("swapUGButton_button"..tostring(i), img_x, img_y, ImGuiChildFlags.FrameStyle)
                            local pos_x, pos_y = ImGui.GetWindowPos()
                            --ImGui.PushStyleColor(ImGuiCol.Text,0,0,0,1)
                            --centeredText(tostring(math.floor(unit_pool.availablePool)),65*eurbackgroundWindowSizeRight)
                            --ImGui.PopStyleColor()
                            ImGui.EndChild()
                            ImGui.SetNextWindowBgAlpha(0)
                            ImGui.SetNextWindowPos(pos_x, pos_y)
                            ImGui.BeginChild("swapUGButton_button"..tostring(i).."##2", img_x, img_y, ImGuiChildFlags.FrameStyle)
                            if eur_tga_table[unit_tga] ~= nil then
                                ImGui.Image(eur_tga_table[unit_tga].img, img_x, img_y)
                            end
                            ImGui.EndChild()
                            ImGui.SetNextWindowBgAlpha(0.5)
                            ImGui.SetNextWindowPos(pos_x, pos_y)
                            ImGui.PushStyleColor(ImGuiCol.FrameBg,0.75,0.75,0.75,0.1)
                            ImGui.BeginChild("swapUGButton_button"..tostring(i).."##3", img_x, img_y, ImGuiChildFlags.FrameStyle)
                            ImGui.EndChild()
                            ImGui.PopStyleColor()
                            --ImGui.Image(eur_tga_table[unit_tga].img, img_x, img_y)
                            ImGui.SameLine()
                            local hovered = ImGui.IsItemHovered()
                            if hovered then
                                eurStyle("tooltip", true)
                                ImGui.BeginTooltip()
                                ImGui.Text(eduEntry.localizedName)
                                local exp_req_string = ""
                                if unit.exp >= (UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi) then
                                    exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                else
                                    exp_req_string = tostring(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i]-unit_upgrades_multi)
                                end
                                ImGui.Text("Experience required: "..exp_req_string)
                                ImGui.Text("Gold: " ..tostring(math.ceil((eduEntry.recruitCost * UNIT_UPGRADES[unit.eduEntry.eduType].cost_multi[i]))))
                                ImGui.Text("Upgrade is for a different faction.")
                                showEDUStats(eduEntry.eduType)
                                ImGui.EndTooltip()
                                eurStyle("tooltip", false)
                            end
                        end
                    end
                end
                ImGui.NewLine()
                local exp_req = (UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[temp_unit_choice]-unit_upgrades_multi)
                local eduEntry = M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice])
                if eduEntry:hasOwnership(faction_id) then
                    if unit.exp >= exp_req then
                        unit_cost = math.ceil((eduEntry.recruitCost * UNIT_UPGRADES[unit.eduEntry.eduType].cost_multi[temp_unit_choice]))
                    end
                end
        end
        temp_upgrade_unit = unit
    end
    --ImGui.EndChild()
    local exp_req = (UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[temp_unit_choice]-unit_upgrades_multi)
    if unit.exp >= exp_req then
        local eduEntry = M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice])
        if (UNIT_UPGRADES[unit.eduEntry.eduType].faction == nil) or ( UNIT_UPGRADES[unit.eduEntry.eduType].faction ~= nil and UNIT_UPGRADES[unit.eduEntry.eduType].faction[temp_unit_choice] == eur_player_faction.name) then
            if checkCounter(UNIT_UPGRADES[unit.eduEntry.eduType].counter[temp_unit_choice]) then
                if tableContains(list_edu_table, eduEntry.index) then
                    if unit.army ~= nil then
                        if unit.army.faction.money >= unit_cost then
                            if not (unit.army:findInSettlement() or unit.army:findInFort()) then
                                ImGui.TextColored(1,0,0,1,"Cannot change as not garrisoned in a fort or settlement.")
                            else
                                unit_cost = math.ceil((eduEntry.recruitCost * UNIT_UPGRADES[unit.eduEntry.eduType].cost_multi[temp_unit_choice]))
                                upgradeName = UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice]
                                old_unit_army = unit.army
                                old_unit_exp = unit.exp
                                old_unit_sol = unit.soldierCountStratMap
                                old_unit_solmax = unit.soldierCountStratMapMax
                                if unit.eduEntry ~= nil then
                                    if eduEntry:hasOwnership(faction_id) then
                                        old_unit_edu = unit.eduEntry.eduType
                                        old_unit_weapon = unit.weaponLVL
                                            if old_unit_army ~= nil then
                                                --[[
                                                ImGui.SetNextWindowPos(350*eurbackgroundWindowSizeRight, 630*eurbackgroundWindowSizeBottom)
                                                ImGui.SetNextWindowBgAlpha(0)
                                                ImGui.SetNextWindowSize(200*eurbackgroundWindowSizeRight, 200*eurbackgroundWindowSizeBottom)
                                                ImGui.BeginChild("Child Window##A14", 300*eurbackgroundWindowSizeRight, 100*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
                                                if temp_gen_units[temp_gen_units_target+1] then
                                                    if eur_tga_table[M2TWEOPDU.getEduEntryByType(temp_gen_units[temp_gen_units_target+1]).unitCardTga] then
                                                        if ImGui.ImageButton("options_child_accept##01", eur_tga_table[M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice]).unitCardTga].img,img_x, img_y) then
                                                            show_ug_accept = true
                                                            
                                                        end
                                                    end
                                                    ImGui.SameLine()
                                                    ImGui.BeginGroup()
                                                    ImGui.Text(UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice])
                                                    ImGui.Text("Cost: "..tostring(unit_cost))
                                                    ImGui.EndGroup()
                                                end
                                                ImGui.SameLine()
                                                ImGui.EndChild()
                                                ]]
                                                if UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice] ~= nil then
                                                    ImGui.SetNextWindowBgAlpha(0)
                                                    ImGui.SetNextWindowPos(450*eurbackgroundWindowSizeRight, 100*eurbackgroundWindowSizeBottom)
                                                    ImGui.BeginChild("swapUGButton_button_next_window"..tostring(temp_unit_choice).."##2", 400*eurbackgroundWindowSizeRight, 580*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
                                                    ImGui.NewLine()
                                                    if UNIT_UPGRADES[UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice]] ~= nil then
                                                        ImGui.Text("Upgrade Path for "..(M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice]).localizedName))
                                                        for y = 1, #UNIT_UPGRADES[UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice]].unit do
                                                            if UNIT_UPGRADES[UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice]].unit[y] ~= nil then
                                                                ImGui.SetNextWindowBgAlpha(0)
                                                                ImGui.BeginChild("swapUGButton_button_next"..tostring(y).."##2", img_x, img_y, ImGuiChildFlags.FrameStyle)
                                                                local edu = M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice]].unit[y])
                                                                if edu ~= nil then
                                                                    if eur_tga_table[edu.unitCardTga] ~= nil then
                                                                        ImGui.Image(eur_tga_table[edu.unitCardTga].img, img_x, img_y)
                                                                    end
                                                                    local hovered = ImGui.IsItemHovered()
                                                                    if hovered then
                                                                        eurStyle("tooltip", true)
                                                                        ImGui.BeginTooltip()
                                                                        ImGui.Text(edu.localizedName)
                                                                        showEDUStats(edu.eduType)
                                                                        ImGui.EndTooltip()
                                                                        eurStyle("tooltip", false)
                                                                    end
                                                                end
                                                                ImGui.EndChild()
                                                            end
                                                            ImGui.SameLine()
                                                        end
                                                    else
                                                        ImGui.Text("No further upgeades.")
                                                    end
                                                    ImGui.EndChild()
                                                end

                                                ImGui.SetNextWindowPos(400*eurbackgroundWindowSizeRight, 580*eurbackgroundWindowSizeBottom)
                                                ImGui.SetNextWindowBgAlpha(0.5)
                                                ImGui.BeginChild("Child Window##A14", 110*eurbackgroundWindowSizeRight, 110*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
                                                local pos_x, pos_y = ImGui.GetWindowPos()
                                                ImGui.Indent(24*eurbackgroundWindowSizeRight)
                                                ImGui.Image(coins.img,20*eurbackgroundWindowSizeRight,20*eurbackgroundWindowSizeBottom)
                                                ImGui.SameLine()
                                                ImGui.Text(tostring(unit_cost))
                                                if eur_tga_table[M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice]).unitCardTga] ~= nil then
                                                    centeredImage(eur_tga_table[M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice]).unitCardTga].img,img_x, img_y,0)
                                                end
                                                ImGui.EndChild()
                                                ImGui.SetNextWindowBgAlpha(0)
                                                ImGui.SetNextWindowPos(pos_x, pos_y)
                                                ImGui.PushStyleColor(ImGuiCol.Button, 1, 1, 1, 0)
                                                ImGui.PushStyleColor(ImGuiCol.ButtonHovered, fact_inner_colour[eur_player_faction.name].r,fact_inner_colour[eur_player_faction.name].g,fact_inner_colour[eur_player_faction.name].b, 0.2)
                                                ImGui.PushStyleColor(ImGuiCol.ButtonActive, fact_inner_colour[eur_player_faction.name].r,fact_inner_colour[eur_player_faction.name].g,fact_inner_colour[eur_player_faction.name].b, 0.5)
                                                ImGui.PushStyleColor(ImGuiCol.Border, 1, 1, 1, 0.5)
                                                ImGui.BeginChild("Child Window##A15", 110*eurbackgroundWindowSizeRight, 110*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
                                                --if temp_gen_units[temp_gen_units_target+1] then
                                                    if ImGui.Button("##15",110*eurbackgroundWindowSizeRight, 110*eurbackgroundWindowSizeBottom) then
                                                        show_ug_accept = true
                                                        M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
                                                    end
                                                    local hovered = ImGui.IsItemHovered()
                                                    if hovered then
                                                        playMenuSound("7"..unit.eduEntry.eduType)
                                                        eurStyle("tooltip", true)
                                                        ImGui.BeginTooltip()
                                                        ImGui.Text(M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice]).localizedName)
                                                        showEDUStats(UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice])
                                                        ImGui.EndTooltip()
                                                        eurStyle("tooltip", false)
                                                    end
                                                --end
                                                ImGui.EndChild()
                                                ImGui.PopStyleColor(4)

                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        ImGui.SameLine()
    end
    ImGui.EndChild()
    eurStyle("basic_4", false)
    eurStyle("button_1", true)
    if faction_bu[M2TWEOP.getCultureName(eur_player_faction.cultureID)] then
        if centeredImageButtonReal("##upgclose", faction_bu[M2TWEOP.getCultureName(eur_player_faction.cultureID)].img, 100*eurbackgroundWindowSizeRight, 80*eurbackgroundWindowSizeBottom, 420*eurbackgroundWindowSizeRight) then
            window_states.show_upgrade_window = false
            M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
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
end

function ugSwapAccept()
    ImGui.SetNextWindowBgAlpha(0)
    ImGui.SetNextWindowSize(610*eurbackgroundWindowSizeRight, 310*eurbackgroundWindowSizeBottom)
    ImGui.SetNextWindowPos(660*eurbackgroundWindowSizeRight, 350*eurbackgroundWindowSizeBottom)
    ImGui.Begin("bg_accept_1", true, bit.bor(ImGuiWindowFlags.NoScrollWithMouse, ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoBackground))
    eurStyle("basic_4", true)
    if faction_bg[M2TWEOP.getCultureName(eur_player_faction.cultureID)] then
        ImGui.Image(faction_accept[M2TWEOP.getCultureName(eur_player_faction.cultureID)].img, 600*eurbackgroundWindowSizeRight, 300*eurbackgroundWindowSizeBottom)
    end
    ImGui.SetNextWindowPos(710*eurbackgroundWindowSizeRight, 380*eurbackgroundWindowSizeBottom)
    ImGui.SetNextWindowBgAlpha(0.6)
    ImGui.BeginChild("bg_accept_1Child Window##A13", 500*eurbackgroundWindowSizeRight, 250*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
    ImGui.SetWindowFontScale(1.1*eurbackgroundWindowSizeRight)
    centeredText("Upgrade to "..UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice],0)
    ImGui.SetNextWindowPos(710*eurbackgroundWindowSizeRight, 510*eurbackgroundWindowSizeBottom)
    ImGui.SetNextWindowBgAlpha(0)
    ImGui.BeginChild("bg_accept_1Child Window##A16", 500*eurbackgroundWindowSizeRight, 100*eurbackgroundWindowSizeBottom, ImGuiChildFlags.FrameStyle)
    ImGui.SetWindowFontScale(1.1*eurbackgroundWindowSizeRight)
    if (centeredImageButton("Yes", 80, 50, -40)) then
        pause_disband = true
        sel_unit = nil
        unit:kill()
        local upgradeUnit =
            old_unit_army:createUnit(
            upgradeName,
            (old_unit_exp - (UNIT_UPGRADES[old_unit_edu].expRequirement[temp_unit_choice]-unit_upgrades_multi)),
            0,
            old_unit_weapon
        )
        if old_unit_sol < old_unit_solmax then
            upgradeUnit.soldierCountStratMap =
                math.min(upgradeUnit.soldierCountStratMapMax, old_unit_sol)
        end
        if upgradeUnit ~= nil then
            sel_unit = upgradeUnit
        end
        -----print("replacing "..unit.eduEntry.eduType.." with "..UNIT_UPGRADES[unit.eduEntry.eduType].unit[i])
        --[[unit.eduEntry = M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[unit.eduEntry.eduType].unit[temp_unit_choice])
        if unit.soldierCountStratMap > old_unit_solmax then
            unit.soldierCountStratMap = old_unit_solmax
        end
        --unit.armourLVL = 0
        unit.exp = unit.exp - (UNIT_UPGRADES[old_unit_edu].expRequirement[temp_unit_choice]-unit_upgrades_multi)]]

        stratmap.game.callConsole("add_money", "-" .. tostring(unit_cost))
        --eurStyle("basic_1", false)
        --ImGui.End()
        window_states.show_upgrade_window = false
        show_ug_accept = false
        pause_disband = false

        
        upgradeName = ""
        old_unit_army = nil
        old_unit_exp = 0
        old_unit_sol = 0
        old_unit_solmax = 0

        old_unit_edu = ""
        old_unit_weapon = 0
        M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
    end
    ImGui.SameLine()
    if (centeredImageButton("No", 80, 50, 40)) then
        show_ug_accept = false
        M2TWEOP.scriptCommand("play_sound_event", "BUTTON_DOWN")
    end
    ImGui.EndChild()
    ImGui.EndChild()
    eurStyle("basic_4", false)
    ImGui.End()
end

function checkAIUpgrades(faction)
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."checkAIUpgrades");
	end
    if not ai_unit_upgrades then return end
    if not options_legendary and eur_turn_number < 50 then return end
    if faction.isPlayerControlled == 1 then return end
    for j = 0, faction.armiesNum - 1 do
        local stack = faction:getArmy(j);
        if stack ~= nil then
            for x = 0, stack.numOfUnits - 1 do
                local unit = stack:getUnit(x)
                if unit ~= nil then
                    if not unit.dead then
                        if UNIT_UPGRADES[unit.eduEntry.eduType] then
                            for i = 1, #UNIT_UPGRADES[unit.eduEntry.eduType].unit do
                                if unit.character == nil then
                                    --M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."checkAIUpgrades"..unit.eduEntry.eduType);
                                    --M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."checkAIUpgrades"..tostring(i));
                                    if UNIT_UPGRADES[unit.eduEntry.eduType].unit[i] ~= nil then
                                        local eduEntry = M2TWEOPDU.getEduEntryByType(UNIT_UPGRADES[unit.eduEntry.eduType].unit[i])
                                        if eduEntry ~= nil then
                                            if eduEntry:hasOwnership(faction.factionID) then
                                                if UNIT_UPGRADES[unit.eduEntry.eduType].cost_multi[i] >= 1 then
                                                    if (UNIT_UPGRADES[unit.eduEntry.eduType].faction == nil) or ( UNIT_UPGRADES[unit.eduEntry.eduType].faction ~= nil and UNIT_UPGRADES[unit.eduEntry.eduType].faction[i] == faction.name) then
                                                        if checkCounter(UNIT_UPGRADES[unit.eduEntry.eduType].counter[i]) then
                                                            local exp_offset = 1
                                                            local random_threshold = 40
                                                            if eur_turn_number < 70 then
                                                                random_threshold = 60
                                                            end
                                                            if options_legendary then
                                                                exp_offset = 3
                                                                random_threshold = 20
                                                            end
                                                            local requiredExp = math.max(UNIT_UPGRADES[unit.eduEntry.eduType].expRequirement[i] - exp_offset, 0)
                                                            if unit.exp >= requiredExp then
                                                                if math.random(1, 100) > random_threshold then
                                                                    print("AI unit upgraded :"..unit.eduEntry.eduType.." to "..UNIT_UPGRADES[unit.eduEntry.eduType].unit[i])
                                                                    local unitSize = getUnitSizeMult()
                                                                    local old_edu = unit.eduEntry.eduType
                                                                    unit.alias = "upgraded from "..old_edu
                                                                    unit.eduEntry = eduEntry
                                                                    if collect_stats then
                                                                        if faction.name ~= "slave" then
                                                                            stats_per_turn_table[faction.localizedName][eur_turn_number+1]["AI Units Upgraded"] = stats_per_turn_table[faction.localizedName][eur_turn_number+1]["AI Units Upgraded"] + 1
                                                                            if stats_per_turn_table[faction.localizedName][eur_turn_number+1]["AI Units Upgraded"] > extents_entries['AI Units Upgraded'] then
                                                                                extents_entries['AI Units Upgraded'] = stats_per_turn_table[faction.localizedName][eur_turn_number+1]["AI Units Upgraded"]
                                                                            end
                                                                            if not stats_units_upgraded_ai[faction.localizedName] then
                                                                                stats_units_upgraded_ai[faction.localizedName] = 1
                                                                            else
                                                                                stats_units_upgraded_ai[faction.localizedName] = stats_units_upgraded_ai[faction.localizedName] + 1
                                                                            end
                                                                        end
                                                                    end
                                                                    print('new edu check '..unit.eduEntry.eduType) 
                                                                    unit.soldierCountStratMap = math.min(unit.soldierCountStratMap, unit.eduEntry.soldierCount * unitSize)
                                                                    if unit.exp - UNIT_UPGRADES[old_edu].expRequirement[i] >= 0 then
                                                                        unit.exp = unit.exp-UNIT_UPGRADES[old_edu].expRequirement[i]
                                                                    else
                                                                        unit.exp = 0
                                                                    end
                                                                    break
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
                        end
                    end
                end
            end
        end
    end
    if to_log then
		M2TWEOP.logGame("EUR SCRIPT: "..tostring(os.clock()).."Script end");
	end
end

function list_edu_recruitable()
    if eur_turn_number == 0 then
        for i = 0, 1500 do
            local eduEntry = M2TWEOPDU.getEduEntry(i)
            if eduEntry ~= nil then
                if eduEntry:hasOwnership(eur_playerFactionId) then
                    table.insert(list_edu_table_default, eduEntry.index)
                end
            end
        end
    end
    if restricted_upgrades then
        list_edu_table = {}
        for i = 0, eur_player_faction.settlementsNum - 1 do
            local sett = eur_player_faction:getSettlement(i)
            if sett ~= nil then
                local capabilitynum = sett.recruitmentCapabilityNum
                for y = 0, capabilitynum -1 do
                    local temp_capability = sett:getRecruitmentCapability(y)
                    if temp_capability ~= nil then
                        if temp_capability.maxSize >= 1 then
                            if temp_capability.eduIndex ~= nil then
                                if not tableContains(list_edu_table, temp_capability.eduIndex) then
                                    table.insert(list_edu_table, temp_capability.eduIndex)
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        list_edu_table = list_edu_table_default
    end
end
