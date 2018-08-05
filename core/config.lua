local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI
local C = NEL:NewModule("NelUI_Config")
NelUI.Config = C

local S = E:GetModule('Skins')

local function ReleaseChildren(frame)
	local scripts = {
	        OnDragStart = true,
	        OnDragStop = true,
	        OnEnter = true,
	        OnEvent = true,
	        OnKeyDown = true,
	        OnKeyUp = true,
	        OnLeave = true,
	        OnLoad = true,
	        OnMouseDown = true,
	        OnMouseUp = true,
	        OnMouseWheel = true,
	        OnReceiveDrag = true,
	        OnSizeChanged = true,
	        OnUpdate = true,
	}

	if frame.elements then frame.elements = nil end
	if frame.ScrollBar then frame.ScrollBar = nil end

	local childs = {frame:GetChildren()}
	for _, child in ipairs(childs) do
		local name = child:GetName()

		if child:GetChildren() then
			ReleaseChildren(child)
		end

    	child:Hide()
    	child:SetParent(nil)
    	child:UnregisterAllEvents()
    	child:SetID(0)
    	child:ClearAllPoints()
    	for script, _ in pairs(scripts) do
    	   child:SetScript(script, nil)
    	end
    	if name then _G[name] = nil end
	end
end

local LABEL = {
	"Alt Manager",
	"Ready Check",
	"Talent Macro"
}

function C:BuildOptionFrame()
	if NelUIMainFrame and NelUIMainFrame:IsShown() then
		NelUIMainFrame:Hide()
		return
	elseif NelUIMainFrame then
		NelUIMainFrame:Show()
		return
	end

	local frame = CreateFrame("Frame", "NelUIMainFrame", UIParent)
	local close = CreateFrame("Button", "NelUIOCloseButton", frame)
	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	local option = CreateFrame("Frame", "NelUIOptionFrame", frame)

	frame:SetTemplate("Transparent")
	frame:SetSize(890, 651)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame:SetFrameStrata("HIGH")
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

	title:SetPoint("TOPLEFT", 0, -5)
	title:SetPoint("TOPRIGHT", 0, -5)
	title:SetText("NelUI Options")
	title:SetJustifyH("CENTER")
	title:SetJustifyV("MIDDLE")

	close:SetTemplate()
	close:SetPoint("TOPRIGHT", -4, -5)
	close:SetSize(16, 16)
	close:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor)) end)
	close:SetScript("OnLeave", function(self) self:SetTemplate() end)
	close:SetScript("OnClick", function(self) frame:Hide() end)

	close.Text = close:CreateFontString(nil, "OVERLAY")
	close.Text:SetFont(NEL.LSM:Fetch("font", "NelUI"), 16, "OUTLINE")
	close.Text:SetJustifyH("CENTER")
	close.Text:SetJustifyV("MIDDLE")
	close.Text:SetText("x")
	close.Text:SetPoint("CENTER", 1, 0)

	option:SetTemplate("Transparent")
	option:SetPoint("TOPLEFT", 17 + 175 + 4, -34)
	option:SetPoint("BOTTOMRIGHT", -17, 17)

	for i, label in ipairs(LABEL) do
		local menu = CreateFrame("Button", "MenuButton"..i, frame)
		menu:SetTemplate("Transparent")
		menu:SetPoint(unpack(i == 1 and {"TOPLEFT", 17, -34} or {"TOP", "MenuButton"..i-1, "BOTTOM", 0, -2}))
		menu:SetSize(175, 20)
		menu:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor)) end)
		menu:SetScript("OnLeave", function(self) self:SetTemplate("Transparent") end)
		menu:SetScript("OnClick", function(self) 
			if label == "Alt Manager" then
				ReleaseChildren(NelUIOptionFrame)
			elseif label == "Ready Check" then
				ReleaseChildren(NelUIOptionFrame)
				C.BuildReadyCheckOption()
			elseif label == "Talent Macro" then
				ReleaseChildren(NelUIOptionFrame)
				C.BuildTalentMacroOption()
			end
		end)

		menu.Text = menu:CreateFontString(nil, "OVERLAY")
		menu.Text:SetFont(NEL.LSM:Fetch("font", "NelUI"), 12, "NONE")
		menu.Text:SetJustifyH("LEFT")
		menu.Text:SetJustifyV("MIDDLE")
		menu.Text:SetText(label)
		menu.Text:SetPoint("LEFT", 6, 0)
	end
end

function C.BuildReadyCheckOption()
	local frame = CreateFrame("Frame", nil, NelUIOptionFrame)
	frame:SetPoint("TOP", 0, -5)
	frame:SetSize(NelUIOptionFrame:GetWidth(), 18)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetPoint("TOP")
	label:SetPoint("BOTTOM")
	label:SetJustifyH("CENTER")
	label:SetText("Ready Check Options")

	local left = frame:CreateTexture(nil, "BACKGROUND")
	left:SetHeight(1)
	left:SetPoint("LEFT", 13, 0)
	left:SetPoint("RIGHT", label, "LEFT", -5, 0)
	left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	left:SetTexCoord(0.81, 0.94, 0.5, 1)
	left:SetColorTexture(156/255, 154/255, 156/255)

	local right = frame:CreateTexture(nil, "BACKGROUND")
	right:SetHeight(1)
	right:SetPoint("RIGHT", -13, 0)
	right:SetPoint("LEFT", label, "RIGHT", 5, 0)
	right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	right:SetTexCoord(0.81, 0.94, 0.5, 1)
	right:SetColorTexture(156/255, 154/255, 156/255)

	local enable = CreateFrame("CheckButton", "RCCheckButtonEnable", NelUIOptionFrame, "ChatConfigCheckButtonTemplate")
	enable:SetPoint("TOPLEFT", 15, -26)
	enable:SetChecked(NEL.profile.RC.enable)
	enable:SetScript("OnClick", function(self) NEL.profile.RC.enable = self:GetChecked() end)
	enable.Text:SetText("Enable")
	enable.Text:SetPoint("LEFT", enable:GetWidth() + 2, 0)

	local frame = CreateFrame("Frame", "NelUIReadyCheckOptionDungeons", NelUIOptionFrame)
	frame:SetPoint("TOP", 0, -58)
	frame:SetSize(NelUIOptionFrame:GetWidth(), 18)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetPoint("TOPLEFT", 13, 0)
	label:SetPoint("BOTTOMRIGHT", -13, 0)
	label:SetJustifyH("LEFT")
	label:SetText("Dungeon")

	local dungeonN = CreateFrame("CheckButton", "RCCheckButtonDungeonNormal", NelUIReadyCheckOptionDungeons, "ChatConfigCheckButtonTemplate")
	dungeonN:SetPoint("TOPLEFT", 15, -16)
	dungeonN:SetChecked(NEL.profile.RC.DN)
	dungeonN:SetScript("OnClick", function(self) NEL.profile.RC.DN = self:GetChecked() end)
	dungeonN.Text:SetText("Normal")
	dungeonN.Text:SetPoint("LEFT", dungeonN:GetWidth() + 2, 0)

	local dungeonH = CreateFrame("CheckButton", "RCCheckButtonDungeonHeroic", NelUIReadyCheckOptionDungeons, "ChatConfigCheckButtonTemplate")
	dungeonH:SetPoint("TOPLEFT", NelUIReadyCheckOptionDungeons:GetWidth() / 3, -16)
	dungeonH:SetChecked(NEL.profile.RC.DH)
	dungeonH:SetScript("OnClick", function(self) NEL.profile.RC.DH = self:GetChecked() end)
	dungeonH.Text:SetText("Heroic")
	dungeonH.Text:SetPoint("LEFT", dungeonN:GetWidth() + 2, 0)

	local dungeonM = CreateFrame("CheckButton", "RCCheckButtonDungeonMythic", NelUIReadyCheckOptionDungeons, "ChatConfigCheckButtonTemplate")
	dungeonM:SetPoint("TOPLEFT", (NelUIReadyCheckOptionDungeons:GetWidth() / 3) * 2, -16)
	dungeonM:SetChecked(NEL.profile.RC.DM)
	dungeonM:SetScript("OnClick", function(self) NEL.profile.RC.DM = self:GetChecked() end)
	dungeonM.Text:SetText("Mythic/Mythic+")
	dungeonM.Text:SetPoint("LEFT", dungeonN:GetWidth() + 2, 0)

	local frame = CreateFrame("Frame", "NelUIReadyCheckOptionRaid", NelUIReadyCheckOptionDungeons)
	frame:SetPoint("TOP", 0, -49)
	frame:SetSize(NelUIOptionFrame:GetWidth(), 18)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetPoint("TOPLEFT", 13, 0)
	label:SetPoint("BOTTOMRIGHT", -13, 0)
	label:SetJustifyH("LEFT")
	label:SetText("Raid")

	local raidN = CreateFrame("CheckButton", "RCCheckButtonRaidNormal", NelUIReadyCheckOptionRaid, "ChatConfigCheckButtonTemplate")
	raidN:SetPoint("TOPLEFT", 15, -16)
	raidN:SetChecked(NEL.profile.RC.RN)
	raidN:SetScript("OnClick", function(self) NEL.profile.RC.RN = self:GetChecked() end)
	raidN.Text:SetText("Normal")
	raidN.Text:SetPoint("LEFT", raidN:GetWidth() + 2, 0)

	local raidH = CreateFrame("CheckButton", "RCCheckButtonRaidHeroic", NelUIReadyCheckOptionRaid, "ChatConfigCheckButtonTemplate")
	raidH:SetPoint("TOPLEFT", NelUIReadyCheckOptionRaid:GetWidth() / 3, -16)
	raidH:SetChecked(NEL.profile.RC.RH)
	raidH:SetScript("OnClick", function(self) NEL.profile.RC.RH = self:GetChecked() end)
	raidH.Text:SetText("Heroic")
	raidH.Text:SetPoint("LEFT", raidH:GetWidth() + 2, 0)

	local raidM = CreateFrame("CheckButton", "RCCheckButtonRaidMythic", NelUIReadyCheckOptionRaid, "ChatConfigCheckButtonTemplate")
	raidM:SetPoint("TOPLEFT", (NelUIReadyCheckOptionRaid:GetWidth() / 3) * 2, -16)
	raidM:SetChecked(NEL.profile.RC.RM)
	raidM:SetScript("OnClick", function(self) NEL.profile.RC.RM = self:GetChecked() end)
	raidM.Text:SetText("Mythic")
	raidM.Text:SetPoint("LEFT", raidM:GetWidth() + 2, 0)

	local checkbuttons = {
		RCCheckButtonEnable,
		RCCheckButtonDungeonNormal,
		RCCheckButtonDungeonHeroic,
		RCCheckButtonDungeonMythic,
		RCCheckButtonRaidNormal,
		RCCheckButtonRaidHeroic,
		RCCheckButtonRaidMythic
	}

	for _, frame in pairs(checkbuttons) do
		S:HandleCheckBox(frame)
	end
end
	
function C.BuildTalentMacroOption()
	local frame = CreateFrame("Frame", nil, NelUIOptionFrame)
	frame:SetPoint("TOP", 0, -5)
	frame:SetSize(NelUIOptionFrame:GetWidth(), 18)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetPoint("TOP")
	label:SetPoint("BOTTOM")
	label:SetJustifyH("CENTER")
	label:SetText("Talent Macro Options")

	local left = frame:CreateTexture(nil, "BACKGROUND")
	left:SetHeight(1)
	left:SetPoint("LEFT", 13, 0)
	left:SetPoint("RIGHT", label, "LEFT", -5, 0)
	left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	left:SetTexCoord(0.81, 0.94, 0.5, 1)
	left:SetColorTexture(156/255, 154/255, 156/255)

	local right = frame:CreateTexture(nil, "BACKGROUND")
	right:SetHeight(1)
	right:SetPoint("RIGHT", -13, 0)
	right:SetPoint("LEFT", label, "RIGHT", 5, 0)
	right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	right:SetTexCoord(0.81, 0.94, 0.5, 1)
	right:SetColorTexture(156/255, 154/255, 156/255)

	local enable = CreateFrame("CheckButton", "TMCheckButtonEnable", NelUIOptionFrame, "ChatConfigCheckButtonTemplate")

	enable:SetPoint("TOPLEFT", 15, -26)
	enable:SetChecked(NEL.profile.TM)
	enable:SetScript("OnClick", function(self) 
		NEL.profile.TM = self:GetChecked() 
		ReloadUI()
		end)
	enable.Text:SetText("Enable")
	enable.Text:SetPoint("LEFT", enable:GetWidth() + 2, 0)
	
	S:HandleCheckBox(TMCheckButtonEnable)
end

SLASH_NELUICONFIG1 = "/nc"
SlashCmdList["NELUICONFIG"] = function()
	C.BuildOptionFrame()
end