local _G = _G

local AddOnName = ...
local LibStub = LibStub

local NEL = LibStub("AceAddon-3.0"):NewAddon(AddOnName)

_G.NelUI = NEL

NEL.LSM = LibStub("LibSharedMedia-3.0")

NEL.TexturePath = "Interface\\AddOns\\NelUI\\media\\textures\\"
NEL.Character = string.format("%s - %s", UnitName("player"), GetRealmName())


function NEL:InitDB()
	return {["profile"] = {}}
end

function NEL:InitProfile()
	local t = {
		["modules"] = {
			["RC"] = true,
			["TM"] = true
		}
	}

	return t
end

function NEL:OnInitialize()
	NelDB = NelDB or self:InitDB()
	NelDB.profile[NEL.Character] = NelDB.profile[NEL.Character] or self:InitProfile()

	NEL.profile = NelDB.profile[NEL.Character].modules
end