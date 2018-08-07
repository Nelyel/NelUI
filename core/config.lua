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

local function MoveScroll(frame, value)
	local status = frame.status or frame.localstatus
	local height, viewheight = frame.scrollframe:GetHeight(), frame.content:GetHeight()
		
	if frame.scrollBarShown then
		local diff = height - viewheight
		local delta = 1
		if value < 0 then
			delta = -1
		end
		frame.scrollbar:SetValue(min(max(status.scrollvalue + delta*(1000/(diff/45)),0), 1000))
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
	option:SetPoint("TOPLEFT", 17 + 176, -34)
	option:SetPoint("BOTTOMRIGHT", -17, 17)

	for i, label in ipairs(LABEL) do
		local menu = CreateFrame("Button", "MenuButton"..i, frame)
		menu:SetTemplate("Transparent")
		menu:SetPoint(unpack(i == 1 and {"TOPLEFT", 17, -34} or {"TOP", "MenuButton"..i-1, "BOTTOM", 0, -1}))
		menu:SetSize(175, 20)
		menu:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor)) end)
		menu:SetScript("OnLeave", function(self) self:SetTemplate("Transparent") end)
		menu:SetScript("OnClick", function(self) 
			if label == "Alt Manager" then
				ReleaseChildren(NelUIOptionFrame)
				C.BuildAltManagerOption()
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

function C:BuildAltManagerOption()
	local REALMS, CHARS = NEL.AltManager.GetCharacters()

	local scrollOffset = 0
	local OnScroll = function(self, delta)
		if delta == 1 and scrollOffset > 0 then
			scrollOffset = scrollOffset - 20
		elseif delta == -1 then
			if scrollOffset < (50 * 20 - scrollframe:GetHeight()) then
				scrollOffset = scrollOffset + 20
			end
		end

		scrollbar:SetValue(scrollOffset)
		scrollbar:SetMinMaxValues(0, (50 * 20 - scrollframe:GetHeight()))
	end

	local frame = CreateFrame("Frame", nil, NelUIOptionFrame)
	frame:SetPoint("TOP", 0, -5)
	frame:SetSize(NelUIOptionFrame:GetWidth(), 18)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetPoint("TOP")
	label:SetPoint("BOTTOM")
	label:SetJustifyH("CENTER")
	label:SetText("Alt Manager Options")

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

	local enable = CreateFrame("CheckButton", "AMCheckButtonEnable", NelUIOptionFrame, "ChatConfigCheckButtonTemplate")
	enable:SetPoint("TOPLEFT", 15, -26)
	enable:SetChecked(NEL.profile.AM)
	enable:SetScript("OnClick", function(self) NEL.profile.AM = self:GetChecked() end)
	enable.Text:SetText("Enable")
	enable.Text:SetPoint("LEFT", enable:GetWidth() + 2, 0)

	local frame = CreateFrame("Frame", "AMLabelRealms", NelUIOptionFrame)
	frame:SetPoint("TOP", 0, -58)
	frame:SetSize(NelUIOptionFrame:GetWidth(), 18)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetPoint("LEFT", 13, 0)
	label:SetJustifyH("LEFT")
	label:SetText("Realms")

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetPoint("LEFT", 13 + 185, 0)
	label:SetJustifyH("LEFT")
	label:SetText("Character")

	local realms = CreateFrame("Frame", "AMLabelRealmsList", NelUIOptionFrame)
	realms:SetTemplate("Transparent")
	realms:SetPoint("TOPLEFT", 12, -77)
	realms:SetPoint("BOTTOMRIGHT", -(NelUIOptionFrame:GetWidth() - 185 - 12), 12)

	realmsSF = CreateFrame("ScrollFrame", nil, realms) 
	realmsSF:SetPoint("TOPLEFT", 8, -8) 
	realmsSF:SetPoint("BOTTOMRIGHT", -8, 8)
	realmsSF:EnableMouseWheel(true)
	realmsSF:SetScript("OnMouseWheel", OnScroll)
	realms.realmsSF = realmsSF

	realmsSB = CreateFrame("Slider", nil, realmsSF, "UIPanelScrollBarTemplate") 
	realmsSB:SetPoint("TOPLEFT", realmsSF, "TOPRIGHT", 4, -16) 
	realmsSB:SetPoint("BOTTOMLEFT", realmsSF, "BOTTOMRIGHT", 4, 16) 
	realmsSB:SetValue(0) 
	realmsSB:SetWidth(16)
	realmsSB:SetScript("OnValueChanged", function (self, value) 
		self:GetParent():SetVerticalScroll(value) 
	end) 

	realms.realmsSB = realmsSB

	if #REALMS < 26 then
		realmsSF:EnableMouseWheel(false)
		realmsSB:Hide()
	end

	local realmC = CreateFrame("Frame", "AMLabelRealmsListContent", realmsSF) 
	realmC:SetSize(realmsSF:GetWidth(), realmsSF:GetHeight()) 

	realmsSF.realmC = realmC 
	realmsSF:SetScrollChild(realmC)

	local chars = CreateFrame("Frame", "AMLabelCharacterList", NelUIOptionFrame)
	chars:SetTemplate("Transparent")
	chars:SetPoint("TOPLEFT", 13 + AMLabelRealmsList:GetWidth(), -77)
	chars:SetPoint("BOTTOMRIGHT", -12, 12)

	charsSF = CreateFrame("ScrollFrame", nil, chars) 
	charsSF:SetPoint("TOPLEFT", 8, -8) 
	charsSF:SetPoint("BOTTOMRIGHT", -8, 8)
	charsSF:EnableMouseWheel(true)
	charsSF:SetScript("OnMouseWheel", OnScroll)
	chars.charsSF = charsSF

	charsSB = CreateFrame("Slider", nil, charsSF, "UIPanelScrollBarTemplate") 
	charsSB:SetPoint("TOPLEFT", charsSF, "TOPRIGHT", 4, -16) 
	charsSB:SetPoint("BOTTOMLEFT", charsSF, "BOTTOMRIGHT", 4, 16) 
	charsSB:SetValue(0) 
	charsSB:SetWidth(16)
	charsSB:SetScript("OnValueChanged", function (self, value) 
		self:GetParent():SetVerticalScroll(value) 
	end) 

	chars.charsSB = charsSB

	if #CHARS < 26 then
		charsSF:EnableMouseWheel(false)
		charsSB:Hide()
	end

	local content = CreateFrame("Frame", "AMLabelCharacterListContent", charsSF) 
	content:SetSize(charsSF:GetWidth(), charsSF:GetHeight()) 

	charsSF.content = content 
	charsSF:SetScrollChild(content)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetText("Shown")
	label:SetPoint("CENTER", (185/2), 0)
	label:SetJustifyH("LEFT")
	label:SetText("Shown")

	local function CreateCharakterFrame(activerealm)
		local REALMS, CHARS = NEL.AltManager.GetCharacters()

		for i, realm in pairs(REALMS) do
			if activerealm == realm then
				for j, char in pairs(CHARS[i]) do
					local character = NEL.alts[realm][char]
					local frame = CreateFrame("Frame", "NelUIOAMCharacterFrame"..j, AMLabelCharacterListContent)
					local button = CreateFrame("Button", "NelUIOAMCharacterFrameButton"..j, frame)
					local editbox = CreateFrame("EditBox", "NelUIOAMCharacterFrameEditBox"..j, frame)
					local checkbutton = CreateFrame("CheckButton", "NelUIOAMCharacterFrameCheckButton"..j, frame, "ChatConfigCheckButtonTemplate")

					frame:SetSize(AMLabelCharacterListContent:GetWidth(), 18)
					frame:SetPoint(unpack(j == 1 and {"TOPLEFT", 0, -1} or {"TOP", "NelUIOAMCharacterFrame"..j-1, "BOTTOM", 0, -3}))

					frame.Text = frame:CreateFontString(nil, "OVERLAY")
					frame.Text:SetFont(NEL.LSM:Fetch("font", "NelUI"), 12, "NONE")
					frame.Text:SetText(format("|c%s%s|r", RAID_CLASS_COLORS[character.class].colorStr, character.name))
					frame.Text:SetPoint("LEFT", 6, 0)

					button:SetTemplate()
					button:SetSize(70, 20)
					button:SetPoint('RIGHT', 0, 0)
					button:SetScript('OnEnter', function(self) self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor)) end)
					button:SetScript('OnLeave', function(self) self:SetTemplate() end)
					button:SetScript('OnClick', function(self) 
						NEL.alts[realm][char] = nil
						ReleaseChildren(AMLabelCharacterListContent)
						CreateCharakterFrame(realm)
					end)
					button.Text = button:CreateFontString(nil, "OVERLAY")
					button.Text:SetFont(NEL.LSM:Fetch("font", "NelUI"), 12, "NONE")
					button.Text:SetText("Delete")
					button.Text:SetPoint('CENTER', 0, 0)
					button.Text:SetJustifyH('CENTER')

					editbox:SetTemplate()
					editbox:SetSize(35, 20)
					editbox:SetPoint('RIGHT', "NelUIOAMCharacterFrameButton"..j, 'LEFT', -1, 0)
					editbox:SetAutoFocus(false)
					editbox:SetTextInsets(6, 6, 0, 0)
					editbox:SetJustifyH("RIGHT")
					editbox:SetTextColor(1, 1, 1)
					editbox:SetFont([[Interface\AddOns\AddOnSkins\Media\Fonts\PTSansNarrow.TTF]], 12)
					editbox:SetShadowOffset(0,0)
					editbox:SetText(NEL.alts[realm][char].order)
					editbox:HookScript('OnEscapePressed', function(self) self:SetText(NEL.alts[realm][char].order) self:ClearFocus() end)
					editbox:HookScript('OnEnterPressed', function(self)
						NEL.alts[realm][char].order = tonumber(self:GetText())
						ReleaseChildren(AMLabelCharacterListContent)
						CreateCharakterFrame(realm)
					end)

					checkbutton:SetPoint('CENTER', "NelUIOAMCharacterFrame"..j, "CENTER", 0, 0)
					checkbutton:SetChecked(NEL.alts[realm][char].show)
					checkbutton:SetScript("OnClick", function(self) NEL.alts[realm][char].show = self:GetChecked() end)

					S:HandleCheckBox(checkbutton)
				end
			end
		end
	end

	local function CreateRealmFrame(active)
		local REALMS, CHARS = NEL.AltManager.GetCharacters()

		for i, realm in pairs(REALMS) do
			local frame = CreateFrame("Frame", "NelUIOAMRealmFrame"..i, AMLabelRealmsListContent)
			local button = CreateFrame("Button", "NelUIOAMRealmFrameButton"..i, frame)
			local highlight = button:CreateTexture(nil, "BACKGROUND")
			local editbox = CreateFrame("EditBox", "NelUIOAMRealmFrameEditBox"..i, frame)

			frame:SetPoint(unpack(i == 1 and {"TOPLEFT", 0, -1} or {"TOP", "NelUIOAMRealmFrame"..i-1, "BOTTOM", 0, -3}))
			frame:SetSize(AMLabelRealmsListContent:GetWidth(), 18)

			button:SetPoint("TOPLEFT", 0, 0)
			button:SetPoint("BOTTOMRIGHT", -35, 0)

			button.Text = button:CreateFontString(nil, "OVERLAY")
			button.Text:SetFont(NEL.LSM:Fetch("font", "NelUI"), 12, "NONE")
			button.Text:SetJustifyH("LEFT")
			button.Text:SetJustifyV("MIDDLE")
			button.Text:SetText(realm)
			button.Text:SetPoint("LEFT", 6, 0)

			highlight:SetTexture(nil)
			highlight:SetAllPoints()
			highlight:SetTexCoord(0, 1, 0, 1)
			highlight:SetBlendMode("ADD")
			highlight:SetColorTexture(0, 51/255, 204/255, 0.3)
			highlight:Hide()
			button.highlight = highlight

			editbox:SetTemplate()
			editbox:SetSize(35, 20)
			editbox:SetPoint('LEFT', "NelUIOAMRealmFrameButton"..i, 'RIGHT', 0, 0)
			editbox:SetAutoFocus(false)
			editbox:SetTextInsets(6, 6, 0, 0)
			editbox:SetJustifyH("RIGHT")
			editbox:SetTextColor(1, 1, 1)
			editbox:SetFont([[Interface\AddOns\AddOnSkins\Media\Fonts\PTSansNarrow.TTF]], 12)
			editbox:SetShadowOffset(0,0)
			editbox:SetText(NEL.alts[realm].order)
			editbox:HookScript('OnEscapePressed', function(self) self:SetText(NEL.alts[realm].order) self:ClearFocus() end)
			editbox:HookScript('OnEnterPressed', function(self)
				NEL.alts[realm].order = tonumber(self:GetText())
				ReleaseChildren(AMLabelRealmsListContent)
				CreateRealmFrame(1)
				_G["NelUIOAMRealmFrameButton"..active]:Click()
			end)

			button:SetScript("OnEnter", function(self) self.highlight:Show() end)
			button:SetScript("OnLeave", function(self) self.highlight:Hide() end)
			button:SetScript("OnClick", function(self)
				for j = 1, #REALMS do
					_G["NelUIOAMRealmFrameButton"..j].highlight:Hide()
					_G["NelUIOAMRealmFrameButton"..j]:SetScript("OnEnter", function(self) self.highlight:Show() end)
					_G["NelUIOAMRealmFrameButton"..j]:SetScript("OnLeave", function(self) self.highlight:Hide() end)
				end

				self:SetScript("OnEnter", nil)
				self:SetScript("OnLeave", nil)
				self.highlight:Show()
				ReleaseChildren(AMLabelCharacterListContent)
				CreateCharakterFrame(realm)
			end)
		end
	end

	CreateRealmFrame(1)
	_G["NelUIOAMRealmFrameButton1"]:Click()
	S:HandleCheckBox(AMCheckButtonEnable)
end

function C:BuildReadyCheckOption()
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
	
function C:BuildTalentMacroOption()
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