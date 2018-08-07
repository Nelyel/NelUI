local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI

local DT = E:GetModule("DataTexts")

local GUID = UnitGUID("player")
local realm = GetRealmName("player")

local function OnEvent(self)
	local _, amount, texture = GetCurrencyInfo(1220)
	texture = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", texture, 12, 12)

	local keystone = NEL.alts[realm][GUID].keystone
	local currency = format("%s %s", texture, amount)
	local text = format("Keystone: %s | %s", keystone, currency)

	self.text:SetText(text)
end

local function OnEnter(self)
	NEL.AltManager:CreateTooltip(self)
end

local function OnClick(self)
	NEL.Config:BuildOptionFrame()
end

DT:RegisterDatatext("NelUI Alt Manager", {"PLAYER_ENTERING_WORLD", "CHAT_MSG_CURRENCY", "CURRENCY_DISPLAY_UPDATE", "BAG_UPDATE_DELAYED"}, OnEvent, nil, OnClick, OnEnter)