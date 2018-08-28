local NEL = _G.NelUI
local AP = NEL:NewModule("AddOnProfile", "AceEvent-3.0")

NEL.AddOnProfile = AP

function AP:LoadProjectAzilrokaProfile()
	if ProjectAzilrokaDB["profiles"]["NelUI"] == nil then ProjectAzilrokaDB["profiles"]["NelUI"] = {} end
	ProjectAzilrokaDB.profiles["NelUI"] = {
		["BB"] = false,
		["BrokerLDB"] = false,
		["DO"] = false,
		["EFL"] = true,
		["ES"] = false,
		["FG"] = false,
		["LC"] = false,
		["MF"] = false,
		["SMB"] = false,
		["stAM"] = true,
	}
	_G.ProjectAzilroka.data:SetProfile("NelUI")

	if EnhancedFriendsListDB["profiles"]["NelUI"] == nil then EnhancedFriendsListDB["profiles"]["NelUI"] = {} end
	EnhancedFriendsListDB.profiles["NelUI"] = {
		["NameFont"] = "NelUI",
		["NameFontSize"] = 12,
		["NameFontFlag"] = "NONE",
		["InfoFont"] = "NelUI",
		["InfoFontSize"] = 12,
		["InfoFontFlag"] = "NONE",
		["StatusIconPack"] = "Default",
		["Alliance"] = "Launcher",
		["Horde"] = "Launcher",
		["Neutral"] = "Launcher",
		["D3"] = "Launcher",
		["WTCG"] = "Launcher",
		["S1"] = "Launcher",
		["S2"] = "Launcher",
		["App"] = "Flat",
		["BSAp"] = "Flat",
		["Hero"] = "Launcher",
		["Pro"] = "Launcher",
		["DST2"] = "Launcher",
		["VIPR"] = "Launcher",
	}
	_G.EnhancedFriendsList.data:SetProfile("NelUI")

	BigButtonsDB = nil
	DragonOverlayDB = nil
	EnhancedShadowsDB = nil
	FriendGroupsDB = nil
	MovableFramesDB = nil
	SquareMinimapButtonsDB = nil
end