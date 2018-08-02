local NEL = _G.NelUI
local TM = NEL:NewModule("TalentMacro", "AceEvent-3.0")
NelUI.TalentMacro = TM

local MAX_TALENT_TIERS = MAX_TALENT_TIERS

local DEFAULT_MACRO = "#showtooltip\n/cast %n"

function TM:CreateMacro()
	for tier = 1, MAX_TALENT_TIERS do	
		local name = (".T%d"):format(tier)

		if GetMacroIndexByName(name) == 0 then
			CreateMacro(name, "INV_Misc_QuestionMark", "", 1)
		end
	end

	self:UpdateMacros()
end

function TM:DeleteMacro()
	for tier = 1, MAX_TALENT_TIERS do
		local name = (".T%d"):format(tier)

		if GetMacroIndexByName(name) ~= 0 then
			DeleteMacro(name)
		end
	end
end

function TM:UpdateMacros()
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	local spec = GetActiveSpecGroup()

	for tier = 1, MAX_TALENT_TIERS do
		local available, selected = GetTalentTierInfo(tier, spec)

		if available and selected ~= 0 then
			local _, name, iconTexture = GetTalentInfo(tier, selected, spec)
			local body = DEFAULT_MACRO:gsub("%%n", name)

			EditMacro((".T%d"):format(tier), nil, iconTexture, body, 1)
		else
			EditMacro((".T%d"):format(tier), nil, "INV_Misc_QuestionMark", "", 1)
		end
	end
end

function TM:PLAYER_ENTERING_WORLD()
	if not NEL.profile.TM then 
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:DeleteMacro()
		return
	end

	self:CreateMacro()
end

function TM:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UpdateMacros()
end

function TM:PLAYER_TALENT_UPDATE()
	self:UpdateMacros()
end

function TM:PLAYER_LOGOUT()
	for tier = 1, MAX_TALENT_TIERS do
		EditMacro((".T%d"):format(tier), nil, "INV_Misc_QuestionMark", "", 1)
	end
end

function TM:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	if NEL.profile.TM then
		self:RegisterEvent("PLAYER_TALENT_UPDATE")
		self:RegisterEvent("PLAYER_LOGOUT")
	end
end