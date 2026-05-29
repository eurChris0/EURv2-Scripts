---@diagnostic disable: lowercase-global
-- Pre-battle options UI module for EUR mod
-- Handles the UI for unit splitting functionality
local PreBattleOptionsWindow = {}

-- UI constants
local BUTTON_SIZE = { width = 120, height = 50 }
local WINDOW_SIZE = { width = 840, height = 640 }

-- UI styling constants
local COLORS = {
    WINDOW = {
        BACKGROUND = { 0.95, 0.94, 0.92, 0.95 }, -- Lighter beige parchment with some transparency
        BORDER = { 0.4, 0.35, 0.3, 1.0 },        -- Darker border
        TITLE = { 0.3, 0.25, 0.2, 1.0 },         -- Dark brown title bar
        TITLE_ACTIVE = { 0.35, 0.3, 0.25, 1.0 }
    },
    BUTTON = {
        NORMAL = { 0.85, 0.82, 0.78, 1.0 }, -- Light beige
        HOVER = { 0.9, 0.87, 0.83, 1.0 },   -- Lighter on hover
        ACTIVE = { 0.8, 0.77, 0.73, 1.0 },  -- Slightly darker when clicked
        TEXT = { 0.2, 0.15, 0.1, 1.0 }      -- Dark brown text
    },
    TEXT = {
        TITLE = { 0.2, 0.15, 0.1, 1.0 }, -- Dark brown for title
        CONTENT = { 0.1, 0.1, 0.1, 1.0 } -- Almost black for content
    },
    COMBO = {
        BACKGROUND = { 0.9, 0.89, 0.87, 1.0 },    -- Light background for combo and slider
        TEXT = { 0.1, 0.1, 0.1, 1.0 },            -- Dark text for combo and slider
        POPUP_BG = { 1.0, 1.0, 1.0, 1.0 },        -- Pure white background for dropdown
        HEADER = { 0.85, 0.82, 0.78, 1.0 },       -- Same as button normal
        HEADER_HOVER = { 0.9, 0.87, 0.83, 1.0 },  -- Same as button hover
        HEADER_ACTIVE = { 0.8, 0.77, 0.73, 1.0 }, -- Same as button active
        BORDER = { 0.4, 0.35, 0.3, 1.0 }          -- Same as window border
    }
}

-- Background image for the window
local backgroundImage = {
    x = 0,
    y = 0,
    img = nil
}

-- Screen dimensions
local screenWidth = 1920  -- Default value
local screenHeight = 1080 -- Default value

-- Initialize screen dimensions
local function initializeScreenDimensions()
    screenWidth = ImGui.GetWindowWidth()
    screenHeight = ImGui.GetWindowHeight()
end

-- Calculate scaled positions
local function getScaledPositions()
    return {
        buttonPos = {
            x = 400 * (screenWidth / 1920),
            y = 170 * (screenHeight / 1080)
        },
        windowPos = {
            x = 1075 * (screenWidth / 1920),
            y = 150 * (screenHeight / 1080)
        }
    }
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
        [3],
        COLORS.BUTTON.ACTIVE[4])

    -- Combo and slider colors
    ImGui.PushStyleColor(ImGuiCol.FrameBg, COLORS.COMBO.BACKGROUND[1], COLORS.COMBO.BACKGROUND[2],
        COLORS.COMBO.BACKGROUND[3], COLORS.COMBO.BACKGROUND[4])
    ImGui.PushStyleColor(ImGuiCol.FrameBgHovered, COLORS.BUTTON.HOVER[1], COLORS.BUTTON.HOVER[2],
        COLORS.BUTTON.HOVER[3], COLORS.BUTTON.HOVER[4])
    ImGui.PushStyleColor(ImGuiCol.FrameBgActive, COLORS.BUTTON.ACTIVE[1], COLORS.BUTTON.ACTIVE[2],
        COLORS.BUTTON.ACTIVE[3], COLORS.BUTTON.ACTIVE[4])

    -- Popup/Dropdown colors
    ImGui.PushStyleColor(ImGuiCol.PopupBg, COLORS.COMBO.POPUP_BG[1], COLORS.COMBO.POPUP_BG[2],
        COLORS.COMBO.POPUP_BG[3], COLORS.COMBO.POPUP_BG[4])
    ImGui.PushStyleColor(ImGuiCol.Header, COLORS.COMBO.HEADER[1], COLORS.COMBO.HEADER[2],
        COLORS.COMBO.HEADER[3], COLORS.COMBO.HEADER[4])
    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, COLORS.COMBO.HEADER_HOVER[1], COLORS.COMBO.HEADER_HOVER[2],
        COLORS.COMBO.HEADER_HOVER[3], COLORS.COMBO.HEADER_HOVER[4])
    ImGui.PushStyleColor(ImGuiCol.HeaderActive, COLORS.COMBO.HEADER_ACTIVE[1], COLORS.COMBO.HEADER_ACTIVE[2],
        COLORS.COMBO.HEADER_ACTIVE[3], COLORS.COMBO.HEADER_ACTIVE[4])
    ImGui.PushStyleColor(ImGuiCol.Border, COLORS.COMBO.BORDER[1], COLORS.COMBO.BORDER[2],
        COLORS.COMBO.BORDER[3], COLORS.COMBO.BORDER[4])

    -- Style variables
    ImGui.PushStyleVar(ImGuiStyleVar.WindowBorderSize, 2.0) -- Slightly thinner border
    ImGui.PushStyleVar(ImGuiStyleVar.PopupBorderSize, 1.0)  -- Border for dropdowns
    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 6.0)   -- Less rounded corners
    ImGui.PushStyleVar(ImGuiStyleVar.PopupRounding, 4.0)    -- Rounded corners for dropdowns
    ImGui.PushStyleVar(ImGuiStyleVar.FrameRounding, 4.0)    -- Rounded buttons and frames
    ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, 12, 8)    -- More space between items
    ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 8, 6)    -- More padding inside frames
end

-- Show the pre-battle button
function PreBattleOptionsWindow.showButton()
    if not UIState.PreBattleUI.IsButtonVisible then return end

    initializeScreenDimensions()
    local positions = getScaledPositions()

    ImGui.SetNextWindowPos(positions.buttonPos.x, positions.buttonPos.y)
    ImGui.SetNextWindowBgAlpha(0.0)
    ImGui.SetNextWindowSize(BUTTON_SIZE.width, BUTTON_SIZE.height)

    pushWindowStyle()
    windowFlags = ImGuiWindowFlags.NoDecoration + ImGuiWindowFlags.NoBackground
    if ImGui.Begin("pre_battle_button", true, windowFlags) then
        ImGui.PushStyleColor(ImGuiCol.Text, COLORS.BUTTON.TEXT[1], COLORS.BUTTON.TEXT[2], COLORS.BUTTON.TEXT[3],
            COLORS.BUTTON.TEXT[4])
        if ImGui.Button("Split Units", BUTTON_SIZE.width - 10, BUTTON_SIZE.height - 10) then
            UIState.PreBattleUI.IsWindowOpen = not UIState.PreBattleUI.IsWindowOpen
        end
        ImGui.PopStyleColor()
        ImGui.End()
    end

    -- Pop styles
    ImGui.PopStyleVar(7)
    ImGui.PopStyleColor(12)
end

-- Show the pre-battle options window
function PreBattleOptionsWindow.showWindow()
    if not UIState.PreBattleUI.IsWindowOpen then return end

    initializeScreenDimensions()
    local positions = getScaledPositions()

    -- Load background texture if not loaded yet
    if backgroundImage.img == nil then
        backgroundImage.x, backgroundImage.y, backgroundImage.img = M2TWEOP.loadTexture(M2TWEOP.getModPath() ..
            "/eopData/resources/images/SCROLL_BACKGROUND.png")
    end

    ImGui.SetNextWindowPos(positions.windowPos.x, positions.windowPos.y)
    ImGui.SetNextWindowSize(WINDOW_SIZE.width, WINDOW_SIZE.height)

    pushWindowStyle()

    windowFlags = ImGuiWindowFlags.NoCollapse + ImGuiWindowFlags.NoScrollbar + ImGuiWindowFlags.NoTitleBar
    if ImGui.Begin("Pre-Battle Options", true, windowFlags) then
        -- Draw background image with reduced alpha
        local cursorX, cursorY = ImGui.GetCursorPos()
        ImGui.SetNextWindowBgAlpha(0.7)
        ImGui.Image(backgroundImage.img, ImGui.GetWindowWidth(), ImGui.GetWindowHeight())
        ImGui.SetCursorPos(cursorX, cursorY)

        -- Title
        ImGui.PushFont(ImGui.GetFont())
        ImGui.Spacing()
        ImGui.Spacing()
        ImGui.Spacing()
        ImGui.Spacing()
        ImGui.Spacing()
        ImGui.Spacing()
        ImGui.Indent(60)
        ImGui.SetWindowFontScale(1.5) -- Slightly smaller title
        local titleText = "Pre-Battle Options"
        local titleWidth = ImGui.CalcTextSize(titleText)
        ImGui.SetCursorPosX((WINDOW_SIZE.width - titleWidth) * 0.5)
        ImGui.TextColored(COLORS.TEXT.TITLE[1], COLORS.TEXT.TITLE[2], COLORS.TEXT.TITLE[3], COLORS.TEXT.TITLE[4],
            titleText)
        ImGui.SetWindowFontScale(1.1) -- Slightly larger content text
        ImGui.PopFont()

        ImGui.Spacing()
        ImGui.Spacing()


        -- Get list of splittable units
        local splittableUnits, splittableUnitNames = SplitUnitsPreBattle.GetSplittableUnits()

        ImGui.PushStyleColor(ImGuiCol.Text, COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3],
            COLORS.TEXT.CONTENT[4])

        -- Unit selection combo
        local selectedIndex = 0
        ImGui.TextColored(COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3], COLORS.TEXT.CONTENT[4],
            "Select Unit")
        ImGui.Spacing()
        newIndex, pressed = ImGui.Combo("##Select Unit", TemporaryState.SplitUnit.selectedUnitIndex, splittableUnitNames, #splittableUnitNames)
        if pressed then
            TemporaryState.SplitUnit.selectedUnitIndex = newIndex
            -- ---@type unit
            -- local testUnit = splittableUnits[newIndex + 1]
            -- print(testUnit.eduEntry.eduType)
            -- print(testUnit.ID)
            -- print(testUnit.soldierCountStratMap)
            -- print(testUnit.soldierCountStratMapMax)
            -- print(testUnit.soldierCountBattleMap)
        end

        ImGui.Spacing()
        ImGui.Spacing()

        -- Split amount slider
        local splitAmount = 20
        ImGui.TextColored(COLORS.TEXT.CONTENT[1], COLORS.TEXT.CONTENT[2], COLORS.TEXT.CONTENT[3], COLORS.TEXT.CONTENT[4],
            "Split Amount")
        ImGui.Spacing()
        newAmount, pressed = ImGui.SliderInt("##Split Amount", TemporaryState.SplitUnit.splitAmount, 20, 100, "%d soldiers")
        if pressed then
            TemporaryState.SplitUnit.splitAmount = newAmount
        end

        ImGui.Spacing()
        ImGui.Spacing()

        -- Center the Split and Close buttons
        local buttonWidth = 120
        local buttonHeight = 30
        local totalWidth = buttonWidth * 2 + 20 -- Total width of both buttons plus spacing
        ImGui.SetCursorPosX((WINDOW_SIZE.width - totalWidth) * 0.5)

        -- Split button
        if ImGui.Button("Split Unit", buttonWidth, buttonHeight) and TemporaryState.SplitUnit.selectedUnitIndex >= 0 and TemporaryState.SplitUnit.selectedUnitIndex < #splittableUnits then
            local selectedUnit = splittableUnits[TemporaryState.SplitUnit.selectedUnitIndex + 1]
            if selectedUnit then
                SplitUnitsPreBattle.SplitUnit(selectedUnit, TemporaryState.SplitUnit.splitAmount)
            end
        end

        ImGui.SameLine()

        -- Close button
        if ImGui.Button("Close", buttonWidth, buttonHeight) then
            UIState.PreBattleUI.IsWindowOpen = false
        end

        ImGui.PopStyleColor()
        ImGui.Unindent(60)
        ImGui.End()
    end

    -- Pop styles
    ImGui.PopStyleVar(7)
    ImGui.PopStyleColor(12)
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
    showButton = PreBattleOptionsWindow.showButton,
    showWindow = PreBattleOptionsWindow.showWindow,
    cleanup = cleanup
}
