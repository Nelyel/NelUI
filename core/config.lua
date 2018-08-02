local E, L, V, P, G = unpack(ElvUI)

local NEL = _G.NelUI
local C = NEL:NewModule("NelUI_Config")

NelUI.Config = C

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
	close.Text:SetFont([[Interface\AddOns\AddOnSkins\Media\Fonts\PTSansNarrow.TTF]], 16, "OUTLINE")
	close.Text:SetJustifyH("CENTER")
	close.Text:SetJustifyV("MIDDLE")
	close.Text:SetText("x")
	close.Text:SetPoint("CENTER", 1, 0)

	local menu = CreateFrame("Frame", "NelUIOMenuFrame", frame)
	menu:SetTemplate("Transparent")
	menu:SetWidth(175)
	menu:SetPoint("TOPLEFT", 17, -34)
	menu:SetPoint("BOTTOMLEFT", 17, 17)

	local option = CreateFrame("Frame", "NelUIOptionFrame", frame)
	option:SetTemplate("Transparent")
	option:SetPoint("TOPLEFT", 17 + menu:GetWidth() + 4, -34)
	option:SetPoint("BOTTOMRIGHT", -17, 17)
end

SLASH_NELUICONFIG1 = "/nc"
SlashCmdList["NELUICONFIG"] = function()
	NelUI.Config:BuildOptionFrame()
end