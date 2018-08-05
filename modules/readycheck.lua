local NEL = _G.NelUI
local RC = NEL:NewModule("ReadyCheck", "AceEvent-3.0")
NelUI.ReadyCheck = RC

local format = string.format

local CONSUMABLES = {	
  -- Stamina,	Int,		Agi,		Str
	{188035,	188031,		188033,		188034,  -- LEGION FLASK
	 251838,	251837,		251836,		251839}, -- BFA FLASK

  -- Stamina,	Int,		Agi,		Str 		DMF			Crit 		Haste 		Mastery 	Versatility
	{201641,	201640,		201639,		201638,		185736,		225602,		225603, 	225604,		225605, 	-- LEGION MAX FOOD
	 259453,	259449,		259448,		259452,					257408,		257413,		257418,		257422,		-- BFA FOOD
	 259457,	259455,		259454,		259456,					257410,		257415,		257420,		257424},	-- BFA MAX FOOD

	{224001,  -- LEGION RUNE
	 270058}, -- BFA RUNE

	{5512,    -- HEALTHSTONE
	 152615,  -- LEGION MAX HEALTHPOTION
	 152494}  -- BFA MAX HEALTHPOTION
}

local ICONS = {
	{"NelUIReadyCheckFlask", 1385241},
	{"NelUIReadyCheckFood", 136000},
	{"NelUIReadyCheckRune", 1118739},
	{"NelUIReadyCheckHealthstone", 538745},
	{"NelUIReadyCheckDurability", 1020356}
}

local function GetFontColor(value, th_1, th_2, th_3)
	if value < th_1 then
		return "|cffff0000"
	elseif value < th_2 then
		return "|cffffff00"
	elseif th_3 or value < th_3 then
		return "|cffffffff"
	end
end

local function SetTimeFormat(frame, expTime)
	local time = GetTime()
	local minute = (expTime - time) / 60
	local secound = (expTime - time) % 60

	if minute > 99 or minute < 10 then
		frame.text:SetJustifyH("CENTER")
	else
		frame.text:SetJustifyH("LEFT")
	end

	return format("%s%d:%02d|r", GetFontColor(minute, 1, 10, true), minute, secound)
end

local function GetConsumables(c)
	for i = 1, 40 do
		local _, texture, _, _, _, expTime, _, _, _, spellID = UnitAura("player", i, "HELPFUL|PLAYER")
		for _, consumableID in pairs(CONSUMABLES[c]) do
		   if consumableID == spellID then
		      return texture, expTime
		   end
		end
	end
end

local function GetHealthstone()
	for _, consumableID in pairs(CONSUMABLES[4]) do
		if GetItemCount(consumableID) > 0 then
			local texture, count = GetItemIcon(consumableID), GetItemCount(consumableID, nil, true)
			return texture, count
		end
	end
end

local function GetDurability()
	local slots = { 
		"SecondaryHandSlot",
		"MainHandSlot",
		"FeetSlot",
		"LegsSlot",
		"HandsSlot",
		"WristSlot",
		"WaistSlot",
		"ChestSlot",
		"ShoulderSlot",
		"HeadSlot"
	}

	local totalDurability = 100

	for _, value in pairs(slots) do
		local slot = GetInventorySlotInfo(value)
		local current, max = GetInventoryItemDurability(slot)

		if current then
			if ((current / max) * 100) < totalDurability then
				totalDurability = (current / max) * 100
			end
		end
	end

	if totalDurability < 60 then
		return format("%s%.f%s|r", GetFontColor(totalDurability, 10, 30, 60), totalDurability, "%")
	end
end

function RC:CreateMainFrame()
	local frame = CreateFrame("Frame", "NelUIReadyCheckFrame", ReadyCheckFrame)
	frame:SetTemplate("Transparent")
	frame:SetSize(ReadyCheckFrame:GetWidth(), 75)
	frame:SetPoint("BOTTOM", ReadyCheckFrame, "TOP", 0, 2)
	
	local previous = nil
	for i, v in ipairs(ICONS) do
		local name, texture = v[1], v[2]

		local icon = CreateFrame("Frame", name, frame)
		icon:SetTemplate("Transparent")
		icon:SetSize(49, 49)
		icon:SetPoint(unpack(i == 1 and {"LEFT", 13, 0} or {"LEFT", previous, "RIGHT", 13, 0}))

		icon.texture = icon:CreateTexture(nil, "ARTWORK")
		icon.texture:SetPoint("TOPLEFT", 1, -1)
		icon.texture:SetPoint("BOTTOMRIGHT", -1, 1)
		icon.texture:SetTexCoord(.08, .92, .08, .92)
		icon.texture:SetTexture(texture)

		icon.text = icon:CreateFontString(nil, "OVERLAY")
		icon.text:SetFont(NEL.LSM:Fetch("font", "NelUI"), unpack(i == 4 and {20} or i == 5 and {26} or {14}), "OUTLINE")
		icon.text:SetJustifyH("CENTER")
		icon.text:SetJustifyV("MIDDLE")
		icon.text:SetText("")
		icon.text:SetPoint(unpack(i == 4 and {"BOTTOM", 1, 2} or i == 5 and {"CENTER", 0, -2} or {"BOTTOM", 1, 6}))

		if i ~= 5 then
			icon.cross = icon:CreateTexture(nil, "OVERLAY")
			icon.cross:SetPoint("TOPLEFT", 5, -6)
			icon.cross:SetPoint("BOTTOMRIGHT", -7, 6)
			icon.cross:SetTexture(NEL.TexturePath.."cross")
		end

		icon.check = icon:CreateTexture(nil, "OVERLAY")
		icon.check:SetPoint("TOP", 0, -1)
		icon.check:SetSize(25, 25)
		icon.check:SetTexture(NEL.TexturePath.."check")

		previous = name
	end
end

function RC:UpdateConsumables()
	for i = 1, 3 do
		local icon = _G[ICONS[i][1]]

		if GetConsumables(i) then
			local texture, expTime = GetConsumables(i)
			icon.check:Show()
			icon.cross:Hide()
			if i == 1 then icon.texture:SetTexture(texture) end
			icon.texture:SetDesaturated(false)
			icon.text:SetText(SetTimeFormat(icon, expTime))
		else
			icon.check:Hide()
			icon.cross:Show()
			icon.texture:SetDesaturated(true)
			icon.text:SetText("")
		end
	end
end

function RC:UpdateHealthstone()
	local icon = _G[ICONS[4][1]]

	if GetHealthstone() then
		local texture, count = GetHealthstone(icon)
		icon.check:Show()
		icon.cross:Hide()
		icon.texture:SetTexture(texture)
		icon.texture:SetDesaturated(false)
		icon.text:SetText(count)
	else
		icon.check:Hide()
		icon.cross:Show()
		icon.texture:SetTexture(538745)
		icon.texture:SetDesaturated(true)
		icon.text:SetText("")
	end
end

function RC:UpdateDurability()
	local icon = _G[ICONS[5][1]]

	icon.check:SetPoint("TOPLEFT", 6, -6)
	icon.check:SetPoint("BOTTOMRIGHT", -6, 6)

	if GetDurability() then
		icon.check:Hide()
		icon.texture:SetDesaturated(true)
		icon.text:SetText(GetDurability())
	else
		icon.check:Show()
		icon.texture:SetDesaturated(false)
		icon.text:SetText("")
	end
end

function RC:UNIT_AURA(event, unit)
	if unit == "player" then
		self:UpdateConsumables()
	end
end

function RC:BAG_UPDATE_DELAYED()
	self:UpdateHealthstone()
end

function RC:UPDATE_INVENTORY_DURABILITY()
	self:UpdateDurability()
end

function RC:READY_CHECK()
	PlaySound(SOUNDKIT.READY_CHECK, "master")
	
	if NEL.profile.RC.enable then
		local _, _, id = GetInstanceInfo()

		if ((NEL.profile.RC.DN and id == 1) or (NEL.profile.RC.DH and id == 2) or (NEL.profile.RC.DM and id == 23) or
		   (NEL.profile.RC.RN and id == 14) or (NEL.profile.RC.RH and id == 15) or (NEL.profile.RC.RM and id == 16)) then
		   	NelUIReadyCheckFrame:Show()

			self:UpdateConsumables()
			self:UpdateHealthstone()
			self:UpdateDurability()
			RC.ticker = C_Timer.NewTicker(1, function() self:UpdateConsumables() end)
				
			self:RegisterEvent("UNIT_AURA")
			self:RegisterEvent("BAG_UPDATE_DELAYED")
			self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
		else 
			NelUIReadyCheckFrame:Hide()
		end
	else
		NelUIReadyCheckFrame:Hide()
	end
end

function RC:READY_CHECK_CONFIRM(event, unit)
	if unit == "player" then
		self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
		self:UnregisterEvent("BAG_UPDATE_DELAYED")
		self:UnregisterEvent("UNIT_AURA")
		if RC.ticker then
			RC.ticker:Cancel()
			RC.ticker = nil
		end
	end
end

function RC:READY_CHECK_FINISHED()
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:UnregisterEvent("BAG_UPDATE_DELAYED")
	self:UnregisterEvent("UNIT_AURA")
	if RC.ticker then
		RC.ticker:Cancel()
		RC.ticker = nil
	end
end

function RC:OnInitialize()
	self:CreateMainFrame()
	self:RegisterEvent("READY_CHECK")
	self:RegisterEvent("READY_CHECK_CONFIRM")
	self:RegisterEvent("READY_CHECK_FINISHED")
end