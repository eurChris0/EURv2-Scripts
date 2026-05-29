---@diagnostic disable: lowercase-global
-- Campaign Settings UI Module
-- Handles the campaign settings window and confirmation dialog
-- Uses ImGui for rendering and CampaignState for data storage

-- Import text resources
local TextRes = require('eur/EurTextResources').CampaignSettings

-- UI Constants
local WINDOW_STYLE = {
    MAIN = {
        POS_X = 0.1,   -- 10% from left
        POS_Y = 0.05,  -- 5% from top
        WIDTH = 0.8,   -- 80% of screen width
        HEIGHT = 0.85, -- 85% of screen height
        FONT_SCALE = {
            TITLE = 1.8,
            HEADER = 1.2,
            CONTENT = 1.0
        },
        INDENT = {
            LEFT = 20,
            CONTENT = 40,
            SECTION = 20
        }
    },
    CONFIRM = {
        BUTTON = {
            WIDTH = 80,
            HEIGHT = 30,
            SPACING = 20
        },
        PADDING = {
            WINDOW = 20,
            TEXT = 12
        }
    }
}

local COLORS = {
    WINDOW = {
        BACKGROUND = { 0.85, 0.80, 0.70, 1.0 }, -- Beige parchment
        BORDER = { 0.55, 0.48, 0.35, 1.0 },     -- Darker aged border
        TITLE = { 0.75, 0.70, 0.60, 1.0 },      -- Darker beige
        TITLE_ACTIVE = { 0.80, 0.75, 0.65, 1.0 }
    },
    BUTTON = {
        NORMAL = { 0.70, 0.65, 0.55, 1.0 }, -- Aged beige
        HOVER = { 0.75, 0.70, 0.60, 1.0 },  -- Lighter on hover
        ACTIVE = { 0.65, 0.60, 0.50, 1.0 }, -- Darker when clicked
        ACCEPT = { 0.2, 0.15, 0.1, 1.0 }    -- Brown accept button
    },
    HEADER = {
        NORMAL = { 0, 0, 0, 0 },        -- Transparent
        HOVER = { 0.3, 0.3, 0.3, 0.1 }, -- Subtle hover
        ACTIVE = { 0.3, 0.3, 0.3, 0.2 } -- Subtle active
    },
    TEXT = {
        TITLE = { 0.9, 0.9, 0.9, 1.0 },   -- White for title
        CONTENT = { 0.2, 0.15, 0.1, 1.0 } -- Brown for content
    },
    SEPARATOR = { 0.5, 0.45, 0.35, 1.0 }  -- Aged separator
}

-- Background image for the window
local backgroundImage = {
    x = 0,
    y = 0,
    img = nil
}

-- Track which header is currently open
local currentOpenHeader = nil

-- List of all headers for easy iteration
-- Allows closing all other headers when one is opened
local headerNames = {
    TextRes.MergingArmies.Header,
    TextRes.Replenishment.Header,
    TextRes.PostBattleLoot.Header,
    TextRes.ArmySorting.Header,
    TextRes.ElvenPassing.Header
}

-- Helper function to handle header state
-- @param name string The name of the header
-- @return boolean Whether the header is open
local function handleHeader(name)
    if currentOpenHeader ~= name then
        ImGui.SetNextItemOpen(false)
    end
    local isOpen = ImGui.CollapsingHeader(name)
    if isOpen and currentOpenHeader ~= name then
        currentOpenHeader = name
        -- Close all other headers
        for _, otherName in ipairs(headerNames) do
            if otherName ~= name then
                ImGui.SetNextItemOpen(false)
            end
        end
    elseif not isOpen and currentOpenHeader == name then
        currentOpenHeader = nil
    end
    return isOpen
end

-- Apply window styling
local function pushWindowStyle()
    -- Window colors
    ImGui.PushStyleColor(ImGuiCol.WindowBg, COLORS.WINDOW.BACKGROUND[1], COLORS.WINDOW.BACKGROUND[2],
        COLORS.WINDOW.BACKGROUND[3], COLORS.WINDOW.BACKGROUND[4])
    ImGui.PushStyleColor(ImGuiCol.Border, COLORS.WINDOW.BORDER[1], COLORS.WINDOW.BORDER[2], COLORS.WINDOW.BORDER[3],
        COLORS.WINDOW.BORDER[4])
    ImGui.PushStyleColor(ImGuiCol.TitleBg, COLORS.WINDOW.TITLE[1], COLORS.WINDOW.TITLE[2], COLORS.WINDOW.TITLE[3],
        COLORS.WINDOW.TITLE[4])
    ImGui.PushStyleColor(ImGuiCol.TitleBgActive, COLORS.WINDOW.TITLE_ACTIVE[1], COLORS.WINDOW.TITLE_ACTIVE[2],
        COLORS.WINDOW.TITLE_ACTIVE[3], COLORS.WINDOW.TITLE_ACTIVE[4])

    -- Button colors
    ImGui.PushStyleColor(ImGuiCol.Button, COLORS.BUTTON.NORMAL[1], COLORS.BUTTON.NORMAL[2], COLORS.BUTTON.NORMAL[3],
        COLORS.BUTTON.NORMAL[4])
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, COLORS.BUTTON.HOVER[1], COLORS.BUTTON.HOVER[2], COLORS.BUTTON.HOVER[3],
        COLORS.BUTTON.HOVER[4])
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, COLORS.BUTTON.ACTIVE[1], COLORS.BUTTON.ACTIVE[2], COLORS.BUTTON.ACTIVE
        [3], COLORS.BUTTON.ACTIVE[4])

    -- Header colors
    ImGui.PushStyleColor(ImGuiCol.Header, COLORS.HEADER.NORMAL[1], COLORS.HEADER.NORMAL[2], COLORS.HEADER.NORMAL[3],
        COLORS.HEADER.NORMAL[4])
    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, COLORS.HEADER.HOVER[1], COLORS.HEADER.HOVER[2], COLORS.HEADER.HOVER[3],
        COLORS.HEADER.HOVER[4])
    ImGui.PushStyleColor(ImGuiCol.HeaderActive, COLORS.HEADER.ACTIVE[1], COLORS.HEADER.ACTIVE[2], COLORS.HEADER.ACTIVE
        [3], COLORS.HEADER.ACTIVE[4])

    -- Style variables
    ImGui.PushStyleVar(ImGuiStyleVar.WindowBorderSize, 3.0) -- Thicker border for aged look
    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 8.0)   -- More rounded corners
    ImGui.PushStyleVar(ImGuiStyleVar.FrameRounding, 4.0)    -- Rounded buttons
    ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, 10, 10)   -- Space between items
    ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 6, 6)    -- Padding inside frames
end

-- Section handlers
local function showMergingArmiesSection()
    ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.HEADER)
    if handleHeader(TextRes.MergingArmies.Header) then
        ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.CONTENT)
        ImGui.Spacing()
        ImGui.Indent(WINDOW_STYLE.MAIN.INDENT.CONTENT)

        -- Checkbox with proper state handling
        ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
            COLORS.TEXT.CONTENT[4])
        CampaignState.Settings.MergingArmies.Enabled, pressed = ImGui.Checkbox(TextRes.MergingArmies.EnableLabel,
            CampaignState.Settings.MergingArmies.Enabled)
        if pressed then
            M2TWEOP.logGame("Merging units " ..
                (CampaignState.Settings.MergingArmies.Enabled and "enabled" or "disabled"))
        end
        ImGui.PopStyleColor()

        if CampaignState.Settings.MergingArmies.Enabled then
            ImGui.Spacing()
            ImGui.Spacing()

            -- Cooldown slider title
            ImGui.TextColored(COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4], TextRes.MergingArmies.CooldownLabel)

            local cooldown = CampaignState.Settings.MergingArmies.Cooldown
            local newCooldown
            newCooldown, pressed = ImGui.SliderInt("##MergeCooldown", cooldown, 1, 10,
                TextRes.MergingArmies.CooldownFormat)
            if pressed then
                CampaignState.Settings.MergingArmies.Cooldown = newCooldown
                M2TWEOP.logGame("Army merge cooldown set to: " .. newCooldown .. " turns")
            end
        end

        ImGui.Spacing()
        ImGui.Spacing()

        -- Add explanation text
        ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
            COLORS.TEXT.CONTENT[4])
        ImGui.TextWrapped(string.format(TextRes.MergingArmies.Description, CampaignState.Settings.MergingArmies.Cooldown))
        ImGui.PopStyleColor()

        ImGui.Unindent(WINDOW_STYLE.MAIN.INDENT.CONTENT)
    end
end

local function showReplenishmentSection()
    ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.HEADER)
    if handleHeader(TextRes.Replenishment.Header) then
        ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.CONTENT)
        ImGui.Spacing()
        ImGui.Indent(WINDOW_STYLE.MAIN.INDENT.CONTENT)

        -- Main toggle
        ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
            COLORS.TEXT.CONTENT[4])
        CampaignState.Settings.Replenishment.Enabled, pressed = ImGui.Checkbox(TextRes.Replenishment.EnableLabel,
            CampaignState.Settings.Replenishment.Enabled)
        if pressed then
            M2TWEOP.logGame("Unit replenishment " ..
                (CampaignState.Settings.Replenishment.Enabled and "enabled" or "disabled"))
        end
        ImGui.PopStyleColor()

        if CampaignState.Settings.Replenishment.Enabled then
            ImGui.Spacing()
            ImGui.Spacing()

            -- AI toggle
            ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4])
            CampaignState.Settings.Replenishment.EnableForAI, pressed = ImGui.Checkbox(
                TextRes.Replenishment.EnableAILabel,
                CampaignState.Settings.Replenishment.EnableForAI)
            ImGui.PopStyleColor()

            -- Territory restriction
            ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4])
            CampaignState.Settings.Replenishment.OnlyInOwnTerritory, pressed = ImGui.Checkbox(
                TextRes.Replenishment.TerritoryLabel,
                CampaignState.Settings.Replenishment.OnlyInOwnTerritory)
            ImGui.PopStyleColor()

            ImGui.Spacing()
            ImGui.Spacing()

            -- Replenishment percentage slider title
            ImGui.TextColored(COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4], TextRes.Replenishment.RateLabel)

            local replenishPercent = CampaignState.Settings.Replenishment.ReplenishmentPercent
            local newReplenishPercent
            newReplenishPercent, pressed = ImGui.SliderInt("##ReplenishmentRate", replenishPercent, 5, 10,
                TextRes.Replenishment.RateFormat)
            if pressed then
                CampaignState.Settings.Replenishment.ReplenishmentPercent = newReplenishPercent
                M2TWEOP.logGame("Replenishment rate set to: " .. newReplenishPercent .. "%")
            end

            ImGui.Spacing()
            ImGui.Spacing()

            -- Add explanation text
            ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4])
            ImGui.TextWrapped(string.format(TextRes.Replenishment.Description,
                CampaignState.Settings.Replenishment.ReplenishmentPercent))
            ImGui.PopStyleColor()
        end

        ImGui.Unindent(WINDOW_STYLE.MAIN.INDENT.CONTENT)
    end
end

local function showPostBattleLootSection()
    ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.HEADER)
    if handleHeader(TextRes.PostBattleLoot.Header) then
        ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.CONTENT)
        ImGui.Spacing()
        ImGui.Indent(WINDOW_STYLE.MAIN.INDENT.CONTENT)

        -- Main toggle
        ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
            COLORS.TEXT.CONTENT[4])
        CampaignState.Settings.PostBattleLoot.Enabled, pressed = ImGui.Checkbox(TextRes.PostBattleLoot.EnableLabel,
            CampaignState.Settings.PostBattleLoot.Enabled)
        if pressed then
            M2TWEOP.logGame("Post-battle loot " ..
                (CampaignState.Settings.PostBattleLoot.Enabled and "enabled" or "disabled"))
        end
        ImGui.PopStyleColor()

        if CampaignState.Settings.PostBattleLoot.Enabled then
            ImGui.Spacing()
            ImGui.Spacing()

            -- Loot calculation method
            ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4])
            CampaignState.Settings.PostBattleLoot.UseUnitCosts, pressed = ImGui.Checkbox(
                TextRes.PostBattleLoot.UnitCostsLabel,
                CampaignState.Settings.PostBattleLoot.UseUnitCosts)
            ImGui.PopStyleColor()

            -- Small army penalty
            ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4])
            CampaignState.Settings.PostBattleLoot.SmallArmyPenalty, pressed = ImGui.Checkbox(
                TextRes.PostBattleLoot.SmallArmyLabel,
                CampaignState.Settings.PostBattleLoot.SmallArmyPenalty)
            ImGui.PopStyleColor()

            -- Victory type modifier
            ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4])
            CampaignState.Settings.PostBattleLoot.VictoryTypeModifier, pressed = ImGui.Checkbox(
                TextRes.PostBattleLoot.VictoryModifierLabel,
                CampaignState.Settings.PostBattleLoot.VictoryTypeModifier)
            ImGui.PopStyleColor()

            if not CampaignState.Settings.PostBattleLoot.UseUnitCosts then
                ImGui.Spacing()
                ImGui.Spacing()

                -- Base amount slider title
                ImGui.TextColored(COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                    COLORS.TEXT.CONTENT[4], TextRes.PostBattleLoot.BaseAmountLabel)

                local baseAmount = CampaignState.Settings.PostBattleLoot.BaseAmount
                local newBaseAmount
                newBaseAmount, pressed = ImGui.SliderInt("##BaseAmount", baseAmount, 100, 1000,
                    TextRes.PostBattleLoot.BaseAmountFormat)
                if pressed then
                    CampaignState.Settings.PostBattleLoot.BaseAmount = newBaseAmount
                    M2TWEOP.logGame("Base loot amount set to: " .. newBaseAmount)
                end
            end

            ImGui.Spacing()
            ImGui.Spacing()

            -- Add explanation text
            ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4])
            local lootText = CampaignState.Settings.PostBattleLoot.UseUnitCosts
                and TextRes.PostBattleLoot.Description.UnitCosts
                or string.format(TextRes.PostBattleLoot.Description.BaseAmount,
                    CampaignState.Settings.PostBattleLoot.BaseAmount)
            if CampaignState.Settings.PostBattleLoot.SmallArmyPenalty then
                lootText = lootText .. "\n" .. TextRes.PostBattleLoot.Description.SmallArmyPenalty
            end
            if CampaignState.Settings.PostBattleLoot.VictoryTypeModifier then
                lootText = lootText .. "\n" .. TextRes.PostBattleLoot.Description.VictoryModifier
            end
            ImGui.TextWrapped(lootText)
            ImGui.PopStyleColor()
        end

        ImGui.Unindent(WINDOW_STYLE.MAIN.INDENT.CONTENT)
    end
end

local function showArmySortingSection()
    ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.HEADER)
    if handleHeader(TextRes.ArmySorting.Header) then
        ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.CONTENT)
        ImGui.Spacing()
        ImGui.Indent(WINDOW_STYLE.MAIN.INDENT.CONTENT)

        -- Main toggle
        ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
            COLORS.TEXT.CONTENT[4])
        CampaignState.Settings.ArmySorting.Enabled, pressed = ImGui.Checkbox(TextRes.ArmySorting.EnableLabel,
            CampaignState.Settings.ArmySorting.Enabled)
        if pressed then
            M2TWEOP.logGame("Army sorting " .. (CampaignState.Settings.ArmySorting.Enabled and "enabled" or "disabled"))
        end
        ImGui.PopStyleColor()

        if CampaignState.Settings.ArmySorting.Enabled then
            ImGui.Spacing()
            ImGui.Spacing()

            -- Sort on turn end
            ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4])
            CampaignState.Settings.ArmySorting.SortOnTurnEnd, pressed = ImGui.Checkbox(TextRes.ArmySorting.TurnEndLabel,
                CampaignState.Settings.ArmySorting.SortOnTurnEnd)
            ImGui.PopStyleColor()

            -- Sort on selection
            ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4])
            CampaignState.Settings.ArmySorting.SortOnSelection, pressed = ImGui.Checkbox(
                TextRes.ArmySorting.SelectionLabel,
                CampaignState.Settings.ArmySorting.SortOnSelection)
            ImGui.PopStyleColor()

            ImGui.Spacing()
            ImGui.Spacing()

            -- Add explanation text
            ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4])
            ImGui.TextWrapped(TextRes.ArmySorting.Description)
            ImGui.PopStyleColor()
        end

        ImGui.Unindent(WINDOW_STYLE.MAIN.INDENT.CONTENT)
    end
end

local function showElvenPassingSection()
    ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.HEADER)
    if handleHeader(TextRes.ElvenPassing.Header) then
        ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.CONTENT)
        ImGui.Spacing()
        ImGui.Indent(WINDOW_STYLE.MAIN.INDENT.CONTENT)

        -- Main toggle
        ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
            COLORS.TEXT.CONTENT[4])
        CampaignState.Settings.ElvenPassing.Enabled, pressed = ImGui.Checkbox(TextRes.ElvenPassing.EnableLabel,
            CampaignState.Settings.ElvenPassing.Enabled)
        if pressed then
            M2TWEOP.logGame("Elven Passing " .. (CampaignState.Settings.ElvenPassing.Enabled and "enabled" or "disabled"))
        end
        ImGui.PopStyleColor()

        if CampaignState.Settings.ElvenPassing.Enabled then
            ImGui.Spacing()
            ImGui.Spacing()

            -- Random timing toggle
            ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                COLORS.TEXT.CONTENT[4])
            CampaignState.Settings.ElvenPassing.UseRandomTiming, pressed = ImGui.Checkbox(
                TextRes.ElvenPassing.TimingLabel,
                CampaignState.Settings.ElvenPassing.UseRandomTiming)
            ImGui.PopStyleColor()

            ImGui.Spacing()
            ImGui.Spacing()

            if CampaignState.Settings.ElvenPassing.UseRandomTiming then
                -- Min turns slider
                ImGui.TextColored(COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                    COLORS.TEXT.CONTENT[4], TextRes.ElvenPassing.MinTurnsLabel)
                local minTurns = CampaignState.Settings.ElvenPassing.MinTurns
                local newMinTurns
                newMinTurns, pressed = ImGui.SliderInt("##MinTurns", minTurns, 1, 5, TextRes.ElvenPassing.TurnsFormat)
                if pressed then
                    CampaignState.Settings.ElvenPassing.MinTurns = newMinTurns
                    if CampaignState.Settings.ElvenPassing.MaxTurns < newMinTurns then
                        CampaignState.Settings.ElvenPassing.MaxTurns = newMinTurns
                    end
                end

                -- Max turns slider
                ImGui.TextColored(COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                    COLORS.TEXT.CONTENT[4], TextRes.ElvenPassing.MaxTurnsLabel)
                local maxTurns = CampaignState.Settings.ElvenPassing.MaxTurns
                local newMaxTurns
                newMaxTurns, pressed = ImGui.SliderInt("##MaxTurns", maxTurns, newMinTurns or minTurns, 10,
                    TextRes.ElvenPassing.TurnsFormat)
                if pressed then
                    CampaignState.Settings.ElvenPassing.MaxTurns = newMaxTurns
                end
            else
                -- Fixed interval slider
                ImGui.TextColored(COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
                    COLORS.TEXT.CONTENT[4], TextRes.ElvenPassing.FixedTurnsLabel)
                local maxTurns = CampaignState.Settings.ElvenPassing.MaxTurns
                local newMaxTurns
                newMaxTurns, pressed = ImGui.SliderInt("##FixedTurns", maxTurns, 3, 10, TextRes.ElvenPassing.TurnsFormat)
                if pressed then
                    CampaignState.Settings.ElvenPassing.MaxTurns = newMaxTurns
                end
            end

            ImGui.Spacing()
            ImGui.Spacing()
        end

        ImGui.Unindent(WINDOW_STYLE.MAIN.INDENT.CONTENT)
    end
end

-- Shows Campaign settings window
function ShowCampaignSettingsWindow()
    -- Only show if the window is open
    if not UIState.CampaignSettingsWindow.IsOpen then
        return
    end

    -- Load background texture if not loaded yet
    if backgroundImage.img == nil then
        backgroundImage.x, backgroundImage.y, backgroundImage.img = M2TWEOP.loadTexture(M2TWEOP.getModPath() ..
            "/eopData/resources/images/SCROLL_BACKGROUND.png")
    end

    -- Set window position and size
    ImGui.SetNextWindowPos(SCREEN_WIDTH * WINDOW_STYLE.MAIN.POS_X, SCREEN_HEIGHT * WINDOW_STYLE.MAIN.POS_Y)
    ImGui.SetNextWindowSize(SCREEN_WIDTH * WINDOW_STYLE.MAIN.WIDTH, SCREEN_HEIGHT * WINDOW_STYLE.MAIN.HEIGHT)

    -- Apply window styling
    pushWindowStyle()

    -- Begin a new window with specific flags
    local windowFlags = ImGuiWindowFlags.NoCollapse + ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.NoMove
    if ImGui.Begin("Campaign Settings##main", true, windowFlags) then
        -- Draw background image
        local cursorX, cursorY = ImGui.GetCursorPos()
        ImGui.Image(backgroundImage.img, ImGui.GetWindowWidth(), ImGui.GetWindowHeight())
        ImGui.SetCursorPos(cursorX, cursorY)

        -- Get window width
        local windowWidth = ImGui.GetWindowWidth()

        -- Add a title with custom styling
        ImGui.PushFont(ImGui.GetFont())
        ImGui.Spacing()
        ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.TITLE)
        local titleText = TextRes.Window.Title
        local titleWidth = ImGui.CalcTextSize(titleText)
        ImGui.SetCursorPosX((windowWidth - titleWidth) * 0.5)
        ImGui.TextColored(COLORS.TEXT.TITLE[1], COLORS.TEXT.TITLE[2], COLORS.TEXT.TITLE[3], COLORS.TEXT.TITLE[4],
            titleText)
        ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.CONTENT)
        ImGui.PopFont()

        ImGui.Indent(WINDOW_STYLE.MAIN.INDENT.LEFT)
        ImGui.Spacing()
        ImGui.Spacing()

        -- Style the separator and text
        ImGui.PushStyleColor(ImGuiCol.Separator, COLORS.SEPARATOR[1], COLORS.SEPARATOR[2], COLORS.SEPARATOR[3],
            COLORS.SEPARATOR[4])
        ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.TITLE[1], COLORS.TEXT.TITLE[2], COLORS.TEXT.TITLE[3],
            COLORS.TEXT.TITLE[4])

        -- Add left padding for the content
        ImGui.Indent(WINDOW_STYLE.MAIN.INDENT.CONTENT)

        -- Show each section
        ImGui.PushFont(ImGui.GetFont())
        ImGui.SetWindowFontScale(WINDOW_STYLE.MAIN.FONT_SCALE.HEADER)

        showMergingArmiesSection()
        showReplenishmentSection()
        showPostBattleLootSection()
        showArmySortingSection()
        if ELVEN_FACTIONS[CampaignState.PlayerFactionName] then
            showElvenPassingSection()
        end

        ImGui.SetWindowFontScale(1.0)
        ImGui.PopFont()

        ImGui.Spacing()
        ImGui.Spacing()
        ImGui.Spacing()
        ImGui.Spacing()

        -- Center the Accept button
        local buttonWidth = 120
        local buttonHeight = 30
        ImGui.SetCursorPosX((windowWidth - buttonWidth) * 0.5)

        ImGui.PushStyleColor(ImGuiCol.Button, COLORS.BUTTON.ACCEPT[1], COLORS.BUTTON.ACCEPT[2], COLORS.BUTTON.ACCEPT[3],
            COLORS.BUTTON.ACCEPT[4])
        if ImGui.Button(TextRes.Window.AcceptButton, buttonWidth, buttonHeight) then
            UIState.CampaignSettingsWindow.IsOpen = false
            UIState.CampaignSettingsConfirmationWindow.IsOpen = true
            M2TWEOP.logGame("Opening confirmation window")
        end
        ImGui.PopStyleColor()

        -- Manual UI Swap Section
        ImGui.Spacing()
        local swapOptions = {
            { label = "Default", value = "default" },
            { label = "Eregion Imladris", value = "Eregion_Imladris" },
            { label = "Eregion Lindon", value = "Eregion_Lindon" },
            { label = "Noldor Imladris", value = "Noldor_Imladris" },
            { label = "Noldor Lindon", value = "Noldor_Lindon" },
        }
        -- Pre-extract labels into a table for ImGui.Combo
        local swapLabels = {}
        for i, option in ipairs(swapOptions) do
            swapLabels[i] = option.label
        end
        local comboWidth = 200
        local totalWidth = comboWidth + buttonWidth + 10
        ImGui.SetCursorPosX((windowWidth - totalWidth) * 0.5)
        ImGui.PushStyleColor(ImGuiCol.FrameBg, COLORS.BUTTON.NORMAL[1], COLORS.BUTTON.NORMAL[2], COLORS.BUTTON.NORMAL[3],
            COLORS.BUTTON.NORMAL[4])
        ImGui.SetNextItemWidth(comboWidth)
        local newSelectedOption, changed = ImGui.Combo("##UISwapOptions", UIState.SelectedUISwapOption - 1, swapLabels, #swapLabels)
        if changed then
            UIState.SelectedUISwapOption = newSelectedOption + 1 -- Convert back to 1-indexed
            M2TWEOP.logGame("Selected UI swap option: " .. swapOptions[UIState.SelectedUISwapOption].label)
        end
        ImGui.PopStyleColor()
        ImGui.SameLine()
        ImGui.PushStyleColor(ImGuiCol.Button, COLORS.BUTTON.NORMAL[1], COLORS.BUTTON.NORMAL[2], COLORS.BUTTON.NORMAL[3],
            COLORS.BUTTON.NORMAL[4])
        if ImGui.Button("Manual UI Swap", buttonWidth, buttonHeight) and not UIState.IsUISwapInProgress then
            UIState.IsUISwapInProgress = true -- Set flag to show the "Please wait" message
            local factionName = CampaignState.PlayerFactionName or stratmap.game.getFaction(0).name
            local swapValue = swapOptions[UIState.SelectedUISwapOption].value
            
            -- Perform the UI swap
            EUR_UI_Swap.swap_ui(factionName, swapValue, true)
            M2TWEOP.logGame("Manual UI swap triggered for faction: " .. factionName .. " with option: " .. swapOptions[UIState.SelectedUISwapOption].label)
            
            -- Clear NeedResetDisplay to prevent onCampaignMapLoaded from triggering another reset_display
            CampaignState.NeedResetDisplay = false
            M2TWEOP.logGame("CampaignSettings - Cleared NeedResetDisplay before executing reset_display")

            -- Execute reset_display console command with timing
            M2TWEOP.logGame("CampaignSettings - Executing reset_display console command")
            local start_time = os.clock()
            local success, error = pcall(function()
                local result = stratmap.game.callConsole("reset_display")
                if result ~= "" then
                    M2TWEOP.logGame("CampaignSettings - reset_display failed with error: " .. tostring(result))
                else
                    M2TWEOP.logGame("CampaignSettings - reset_display executed successfully")
                    CampaignState.LastAppliedEventType = swapValue
                end
            end)
            local end_time = os.clock()
            M2TWEOP.logGame("CampaignSettings - reset_display took " .. (end_time - start_time) .. " seconds")
            if not success then
                M2TWEOP.logGame("CampaignSettings - reset_display call failed with error: " .. tostring(error))
            end

            UIState.IsUISwapInProgress = false -- Reset the flag after the swap completes
        end
        ImGui.PopStyleColor()

        -- Show a "Please wait" modal popup while the UI swap is in progress
        if UIState.IsUISwapInProgress then
            ImGui.OpenPopup("UI Swap In Progress")
        end
        if ImGui.BeginPopupModal("UI Swap In Progress") then
            ImGui.Text("Please wait while we swap files, it is working...")
            ImGui.EndPopup()
        end
        
        ImGui.Unindent(60)
        ImGui.PopStyleColor() -- Pop text color
        ImGui.PopStyleColor() -- Pop separator color
        ImGui.End()
    end

    -- Pop all style modifications
    ImGui.PopStyleVar(5)    -- Pop the 5 style vars we pushed
    ImGui.PopStyleColor(10) -- Pop the 10 colors we pushed
end

-- Shows a small confirmation window
function ShowConfirmationWindow()
    -- Only show if the confirmation window is open
    if not UIState.CampaignSettingsConfirmationWindow.IsOpen then
        return
    end

    -- Get style constants
    local style = WINDOW_STYLE.CONFIRM
    local buttonWidth = style.BUTTON.WIDTH
    local buttonHeight = style.BUTTON.HEIGHT
    local buttonSpacing = style.BUTTON.SPACING
    local windowPadding = style.PADDING.WINDOW
    local textPadding = style.PADDING.TEXT

    -- Calculate window size based on content
    local text = TextRes.Window.ConfirmationText
    local textWidth = ImGui.CalcTextSize(text)
    local contentWidth = math.max(textWidth, buttonWidth * 2 + buttonSpacing)
    local windowWidth = contentWidth + windowPadding * 2
    local windowHeight = buttonHeight + textPadding * 3 + windowPadding * 2

    -- Center the window
    ImGui.SetNextWindowPos(
        (SCREEN_WIDTH - windowWidth) * 0.5,
        (SCREEN_HEIGHT - windowHeight) * 0.5
    )
    ImGui.SetNextWindowSize(windowWidth, windowHeight)

    -- Apply window styling
    pushWindowStyle()

    -- Begin confirmation window
    local windowFlags = ImGuiWindowFlags.NoCollapse + ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.NoMove +
        ImGuiWindowFlags.NoResize
    if ImGui.Begin("Confirmation##popup", true, windowFlags) then
        ImGui.Spacing()
        ImGui.Spacing()

        -- Center the text
        ImGui.SetCursorPosX((windowWidth - textWidth) * 0.5)
        ImGui.TextColored(COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3], COLORS.TEXT.CONTENT[4],
            text)

        ImGui.Spacing()

        -- Center the buttons
        local totalButtonWidth = buttonWidth * 2 + buttonSpacing
        ImGui.SetCursorPosX((windowWidth - totalButtonWidth) * 0.5)

        if ImGui.Button(TextRes.Window.YesButton, buttonWidth, buttonHeight) then
            UIState.CampaignSettingsConfirmationWindow.IsOpen = false
            CampaignState.IsFirstCampaignLoad = false
            CampaignState.IsSettingsConfirmed = true
            M2TWEOP.logGame("Settings confirmed - closing all windows")
        end

        ImGui.SameLine()

        if ImGui.Button(TextRes.Window.NoButton, buttonWidth, buttonHeight) then
            UIState.CampaignSettingsWindow.IsOpen = true
            UIState.CampaignSettingsConfirmationWindow.IsOpen = false
            M2TWEOP.logGame("Returning to settings")
        end

        ImGui.End()
    end

    -- Pop styles
    ImGui.PopStyleVar(5)
    ImGui.PopStyleColor(5)
end

-- Clean up when module is unloaded
local function cleanup()
    if backgroundImage.img then
        M2TWEOP.unloadTexture(backgroundImage.img)
        backgroundImage.img = nil
    end
end

-- Return the module
return {
    ShowCampaignSettingsWindow = ShowCampaignSettingsWindow,
    ShowConfirmationWindow = ShowConfirmationWindow,
    cleanup = cleanup
}