local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI

local DT = E:GetModule("DataTexts")

local LABELTOOLTIP = {
	"Azerite Level:",
	"Highest M+ done:",
	"Keystone:",
	"Seals:",
	"Island Expedition:", 
	"Weekly:"
}

local function FormatNUM(amount)
	local formatted = amount
  		while true do  
    		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    		if k == 0 then
      			break
    		end
  		end
  	return formatted
end

local GUID = UnitGUID("player")
local realm = GetRealmName("player")

local TitleFont = CreateFont("NelUITitleFont")
TitleFont:SetTextColor(255/255, 210/255, 0/255)

local HeaderFont = CreateFont("NelUIHeaderFont")
HeaderFont:SetTextColor(255/255, 210/255, 0/255)

local RegFont = CreateFont("NelUIRegFont")
RegFont:SetTextColor(255/255, 255/255, 255/255)

local colorGrey = CreateFont("colorGrey")
colorGrey:SetFont(GameTooltipText:GetFont(), 12)
colorGrey:SetTextColor(108/255, 115/255, 120/255)

local ilvlFont = CreateFont("NelUIilvlFont")
ilvlFont:SetFont(GameTooltipText:GetFont(), 11)
ilvlFont:SetTextColor(108/255, 115/255, 120/255)

local function GetLine(i)
	return unpack(i == 1 and {5} or i == 2 and {7} or i == 3 and {8} or i == 4 and {10} or i == 5 and {11} or i == 6 and {12})
end

local function GetSealInformation(owned, brought)
	local _, _, texture = GetCurrencyInfo(1580)
	texture = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", texture, 12, 12)

	local s = format("%s %s/5", texture, owned)
	local max = 2

	if brought == max then 
		return format("%s |cff6c7378(%s/%s)|r", s, brought, max) 
	else 
		return format("%s (%s/%s)", s, brought, max) 
	end
end

local function CreateTooltip(self)
	local data = NEL.AltManager:CollectData()
	NEL.AltManager:StoreData(data)
	
	local REALMS, CHARS = NEL.AltManager:GetCharacters(true)
	local numchars = NEL.AltManager:GetNumCharacters(CHARS)

	if numchars == 0 then return end
	
	if NEL.LQT:IsAcquired("NelUIAltManager") then
		tooltip:Clear()
	else
		tooltip = NEL.LQT:Acquire("NelUIAltManager", numchars*2+1)

		tooltip:SetBackdropColor(0,0,0,1)

		HeaderFont:SetFont(GameTooltipHeaderText:GetFont())
		RegFont:SetFont(GameTooltipText:GetFont())
		tooltip:SetHeaderFont(HeaderFont)
		tooltip:SetFont(RegFont)

		tooltip:SmartAnchorTo(self)

		tooltip:ClearAllPoints()
		tooltip:SetPoint("BOTTOM", self, "TOP", 0, 2)

		tooltip:SetAutoHideDelay(0.1, self)
		tooltip:SetScript("OnShow", function(ttskinself) ttskinself:SetTemplate('Transparent') end)
	end

	-- CREATE LINES
	for i = 1, 12 do
		if i == 2 or i == 4 or i == 6 or i == 9 then
			tooltip:AddSeparator(1, 108/255, 115/255, 120/255)
		else
			tooltip:AddLine()
		end
	end

    -- SET LABEL
    for i = 1, 6 do
    	tooltip:SetCell(GetLine(i), 1, LABELTOOLTIP[i], "RIGHT")
    end

    local padding = 4

    local countchars, posirealm = 1, 2
    for i, realm in pairs(REALMS) do
    	tooltip:SetCell(1, posirealm, realm, colorGrey, "LEFT", #CHARS[i]*2, nil, nil, padding)
	 	for j, char in pairs(CHARS[i]) do
	 		local character = NEL.alts[realm][char]
	 		if countchars == numchars then padding = 0 end
	 		tooltip:SetCell(3, (countchars*2), format("|c%s%s|r", RAID_CLASS_COLORS[character.class].colorStr, character.name), "RIGHT")
	 		tooltip:SetCell(3, (countchars*2)+1, format("ilvl %.2f", character.ilvl), ilvlFont, "LEFT", nil, nil, nil, padding)
	 		tooltip:SetCell(5, (countchars*2), character.azeritelevel, "CENTER", 2, nil, nil, padding)
            tooltip:SetCell(7, (countchars*2), character.highestmplus, "CENTER", 2, nil, nil, padding)
            tooltip:SetCell(8, (countchars*2), character.keystone, "CENTER", 2, nil, nil, padding)
            tooltip:SetCell(10, (countchars*2), GetSealInformation(character.seals, character.sealsbought), "CENTER", 2, nil, nil, padding)
            tooltip:SetCell(11, (countchars*2), character.islandexpedition, "CENTER", 2, nil, nil, padding)
            tooltip:SetCell(12, (countchars*2), character.weekly, "CENTER", 2, nil, nil, padding)
	 		countchars = countchars + 1
	 	end
	 	posirealm = posirealm + #CHARS[i]*2

	 	if countchars > numchars then return tooltip:Show() end
	end

	tooltip:Show()
end

local function OnEvent(self)
	local _, amount, texture = GetCurrencyInfo(1560)
	texture = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", texture, 12, 12)

	local keystone = NEL.alts[realm][GUID].keystone
	local currency = format("%s %s", texture, FormatNUM(amount))
	local text = format("Keystone: %s | %s", keystone, currency)

	self.text:SetText(text)
end

local function OnEnter(self)
	CreateTooltip(self)
end

local function OnClick(self, button)
	if button == "RightButton" then
		NEL.Config:BuildOptionFrame("alt_manager")
	end
end

DT:RegisterDatatext("NelUI Alt Manager", {"PLAYER_ENTERING_WORLD", "CHAT_MSG_CURRENCY", "CURRENCY_DISPLAY_UPDATE", "BAG_UPDATE_DELAYED"}, OnEvent, nil, OnClick, OnEnter)