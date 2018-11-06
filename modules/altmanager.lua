local NEL = _G.NelUI
local AM = NEL:NewModule("AltManager", "AceEvent-3.0")
NEL.AltManager = AM

local AddOnName = ...

local DUNGEONS = {
	[244] = "AD", 
	[245] = "FH",
	[246] = "TD",
	[247] = "ML",
	[248] = "WCM",
	[249] = "KR",
	[250] = "ToS",
	[251] = "UR",
	[252] = "SotS",
	[353] = "SoB"
}

local EVENTS = {
	["Timewalking Dungeon Event"] = "TW Event",
	["Battle for Azeroth Dungeon Event"] = "M0/M+",
	["Pet Battle Bonus Event"] = "PB Event",
	["Arena Skirmish Bonus Event"] = "AS Event",
	["World Quest Bonus Event"] = "WQ Event",
	["Battleground Bonus Event"] = "BG Event"
}

local WEEKLYQUESTS = {
	44164,	-- TW Event TBC
	53033,	-- TW event WotLK
	53034,	-- TW Event Cata
	53035,	-- TW Event MoP
	53037,	-- M0/M+
	53038,	-- PB Event
	53039,	-- AS Event
	53030,  -- WQ EVENT
	53036	-- BG Event
}

local function spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local function RealAbbreviateNumber(num, places)
    local ret
    local placeValue = ("%%.%df"):format(places or 0)
    if not num then
        return 0
    elseif num >= 1000000000000 then
        ret = placeValue:format(num / 1000000000000) .. "T" -- trillion
    elseif num >= 1000000000 then
        ret = placeValue:format(num / 1000000000) .. "B" -- billion
    elseif num >= 1000000 then
        ret = placeValue:format(num / 1000000) .. "M" -- million
    elseif num >= 1000 then
        ret = placeValue:format(num / 1000) .. "k" -- thousand
    else
        ret = num -- hundreds
    end
    return ret
end

local function GetWoWAPI(calendar)
	if C_MythicPlus.IsMythicPlusActive() then
		if not IsAddOnLoaded("Blizzard_ChallengesUI") then
			UIParentLoadAddOn("Blizzard_ChallengesUI")
		end
	   	
	   	PVEFrame:Show()
		PVEFrameTab3:Click()
		PVEFrameTab1:Click()
		PVEFrame:Hide()
	end

	if calendar then
		if not IsAddOnLoaded("Blizzard_Calendar") then
			UIParentLoadAddOn("Blizzard_Calendar")
		end

		if Calendar_Toggle then Calendar_Toggle() end
		if Calendar_Toggle then Calendar_Toggle() end
	end
end

local function GetCurrentWeeklyEvent()
	local curHour, curMinute = GetGameTime()
	local curDate = C_Calendar.GetDate()
	local calDate = C_Calendar.GetMonthInfo()
	local month, day, year = calDate.month, curDate.monthDay, calDate.year
	local curMonth, curYear = curDate.month, curDate.year
	local monthOffset = -12 * (curYear - year) + month - curMonth
	local numEvents = C_Calendar.GetNumDayEvents(monthOffset, day)

	for i = 1, numEvents do
		local event = C_Calendar.GetDayEvent(monthOffset, day, i)
	   
		if event and EVENTS[event.title] then
	    	local ongoing = event.sequenceType == "ONGOING"
	      
	    	if event.sequenceType == "START" then
				ongoing = curHour >= event.startTime.hour and (curHour > event.startTime.hour or curMinute >= event.startTime.minute)
			elseif event.sequenceType == "END" then
				ongoing = curHour <= event.endTime.hour and (curHour < event.endTime.hour or curMinute <= event.endTime.minute)
			end
	      
			if ongoing then
				return EVENTS[event.title]
			end
		end
	end
	return "|cff6c7378none|r"
end

local function GetEmmisaries()
	local emmisaries = {}
	local emmisary = GetQuestBountyInfoForMapID(876)

	for emmisaryindex, emmisaryinfo in ipairs(emmisary) do
	   local title = GetQuestLogTitle(GetQuestLogIndexByID(emmisaryinfo.questID))
	   local timeleft = C_TaskQuest.GetQuestTimeLeftMinutes(emmisaryinfo.questID)
	   local _, _, isfinish, questdone, questneed = GetQuestObjectiveInfo(emmisaryinfo.questID, 1, false)

	   if timeleft then
			if timeleft > 2880 then
				if not emmisaries[3] then emmisaries[3] = {} end
				emmisaries[3].icon = emmisaryinfo.icon
				emmisaries[3].progress = format("%d/%d", questdone, questneed)
			elseif timeleft > 1440 then
				if not emmisaries[2] then emmisaries[2] = {} end
				emmisaries[2].icon = emmisaryinfo.icon
				emmisaries[2].progress = format("%d/%d", questdone, questneed)
			else
				if not emmisaries[1] then emmisaries[1] = {} end
				emmisaries[1].icon = emmisaryinfo.icon
				emmisaries[1].progress = format("%d/%d", questdone, questneed)
			end
	    end
	end

	if IsQuestFlaggedCompleted(51918) or IsQuestFlaggedCompleted(51916) then
		for i = 1, 3 do
			if emmisaries[i] == nil then
				emmisaries[i] = {}
				emmisaries[i].icon, emmisaries[i].progress = 134400, "|cff6c73784/4|r"
			end
		end
	end

	return emmisaries
end

function AM:GetCharacters(filter)
	local db = NEL.alts
	local realms, chars  = {}, {}

	for realm in spairs(db, function(t, a, b) return t[a].order < t[b].order end) do
		table.insert(realms, realm)

		local order = db[realm].order
		db[realm].order = nil

		local temp = {}
		for char in spairs(db[realm], function(t, a, b) return t[a].order < t[b].order end) do
			if filter then
				if db[realm][char].show then table.insert(temp, char) end
			else
				table.insert(temp, char)
			end
		end
		table.insert(chars, temp)

		db[realm].order = order
	end

	return realms, chars
end



function AM:GetNumCharacters(t)
	local num = 0
	for realm, v in pairs(t) do
		num = num + #t[realm]
    end

    return num
end

function AM:ValidateReset()
	if not NEL.alts then return end

	local REALMS, CHARS = AM:GetCharacters()
	local emmisaries = GetEmmisaries()

	for i, realm in pairs(REALMS) do
		for j, char in pairs(CHARS[i]) do
			local table = NEL.alts[realm][char]
			local dailyreset = table.dailyreset or 0
			local weeklyreset = table.weeklyreset or 0

			if time() > dailyreset then
				table.emmisaries[1] = table.emmisaries[2]
				table.emmisaries[2] = table.emmisaries[3]
				table.emmisaries[3] = emmisaries[3]

				table.dailyreset = self:GetNextDailyResetTime()
			end

			if time() > weeklyreset then
				table.highestmplus = 0
				table.keystone = "unk. +?"
				table.sealsbought = 0	
				table.islandexpedition = "0/40.0k"
				table.weekly = GetCurrentWeeklyEvent()

				table.weeklyreset = self:GetNextWeeklyResetTime()
			end
       	end
    end
end

function AM:CollectData()
	local guid = UnitGUID("player")
	local name = UnitName("player")
	local realm = GetRealmName("player")

	local _, ilvl = GetAverageItemLevel()
	local _, class = UnitClass("player")

	local azeritelevel = 0

	if C_AzeriteItem.FindActiveAzeriteItem() then
		local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
		azeritelevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
	end

	local keystone = "unk. +?"
	local highestmplus, weeklychestloot = C_MythicPlus.GetWeeklyChestRewardLevel()
	if weeklychestloot == -1 then weeklychestloot = 0 end

	if C_MythicPlus.GetOwnedKeystoneChallengeMapID() then
		local dungeon = DUNGEONS[tonumber(C_MythicPlus.GetOwnedKeystoneChallengeMapID())]
		local level = C_MythicPlus.GetOwnedKeystoneLevel()

		keystone = format("%s +%d", dungeon, level)
	end

	local emmisaries = GetEmmisaries()

	local _, seals = GetCurrencyInfo(1580)
	local sealsbought = 0

	local source = {
		52834, 52838, -- Gold
		52837, 52840, -- Resources
		52835, 52839, -- Marks
	}

	for i = 1, #source do
		if IsQuestFlaggedCompleted(source[i]) then
			sealsbought = sealsbought + 1
		end
	end

	local islandexpedition = "|cff6c7378done|r"
	local islandexpeditionquest = C_IslandsQueue.GetIslandsWeeklyQuestID()
	
	if not (IsQuestFlaggedCompleted(islandexpeditionquest)) then
		local _, _, _, fulfilled, required = GetQuestObjectiveInfo(islandexpeditionquest, 1, false)
		islandexpedition = format("%s/%s", RealAbbreviateNumber(fulfilled, 1), RealAbbreviateNumber(required, 1))
	end

	local weekly = GetCurrentWeeklyEvent()
	for i = 1, #WEEKLYQUESTS do
		if IsQuestFlaggedCompleted(WEEKLYQUESTS[i]) then
			weekly = "|cff6c7378done|r"
		end
	end

	local table = {}

	table.guid = guid
	table.name = name
	table.realm = realm

	table.ilvl = ilvl
	table.class = class

	table.azeritelevel = azeritelevel

	table.keystone = keystone
	table.highestmplus = highestmplus
	table.weeklychestloot = weeklychestloot

	table.emmisaries = emmisaries

	table.seals = seals
	table.sealsbought = sealsbought
	table.islandexpedition = islandexpedition
	table.weekly = weekly

	table.dailyreset = self:GetNextDailyResetTime()
	table.weeklyreset = self:GetNextWeeklyResetTime()

	return table
end

function AM:StoreData(data)
	if not self.addonLoaded then return end
	if not data or not data.guid then return end

	if UnitLevel("player") < 120 then return end

	local db = NEL.alts
	local realm = data.realm
	local guid = data.guid

	db[realm] = db[realm] or {["order"] = 1}
	
	local update = false
	for k, v in pairs(db[realm]) do
		if k == guid then
			update = true
		end
	end
	
	if not update then
		db[realm][guid] = data
		db[realm][guid].show = true
		db[realm][guid].order = 1
	else
		local show, order = db[realm][guid].show, db[realm][guid].order
		db[realm][guid] = data
		db[realm][guid].show = show
		db[realm][guid].order = order
	end
end

function AM:InitDB()
	return {}
end

function AM:ADDON_LOADED(...)
	local event, loaded = ...
	if event == "ADDON_LOADED" then
		if loaded == AddOnName then
			self:UnregisterEvent("ADDON_LOADED")

			NelDB.altmanager = NelDB.altmanager or self:InitDB()
			self.addonLoaded = true
		end
	end
end

function AM:PLAYER_LOGIN()
	GetWoWAPI(true)
	self:ValidateReset()
	self:StoreData(self:CollectData())
end

function AM:CHAT_MSG_CURRENCY()
	self:StoreData(self:CollectData())
end

function AM:BAG_UPDATE_DELAYED()
	self:StoreData(self:CollectData())
end

function AM:CHALLENGE_MODE_COMPLETED()
	GetWoWAPI()
	self:StoreData(self:CollectData())
end

function AM:OnInitialize()
	NelDB.altmanager = NelDB.altmanager or self:InitDB()
	NEL.alts = NelDB.altmanager

	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("CHAT_MSG_CURRENCY")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
end
-----------------------------------
-- MISC (COPYRIGHT SAVEDINSTANCES)
-----------------------------------
function AM:GetServerOffset()
	local weekday = C_Calendar.GetDate().weekday
	local serverDay = weekday - 1
	local localDay = tonumber(date("%w"))
	local serverHour, serverMinute = GetGameTime()
	local localHour, localMinute = tonumber(date("%H")), tonumber(date("%M"))
	if serverDay == (localDay + 1) % 7 then
		serverHour = serverHour + 24
	elseif localDay == (serverDay + 1) % 7 then
		localHour = localHour + 24
	end
	local server = serverHour + serverMinute / 60
	local localT = localHour + localMinute / 60
	local offset = floor((server - localT) * 2 + 0.5) / 2
	return offset
end

function AM:GetRegion()
	if not self.region then
		local reg
		reg = GetCVar("portal")
		if reg == "public-test" then
			reg = "US"
		end
		if not reg or #reg ~= 2 then
			local gcr = GetCurrentRegion()
			reg = gcr and ({ "US", "KR", "EU", "TW", "CN" })[gcr]
		end
		if not reg or #reg ~= 2 then
			reg = (GetCVar("realmList") or ""):match("^(%a+)%.")
		end
		if not reg or #reg ~= 2 then
			reg = (GetRealmName() or ""):match("%((%a%a)%)")
		end
		reg = reg and reg:upper()
		if reg and #reg == 2 then
			self.region = reg
		end
	end
	return self.region
end

function AM:GetNextDailyResetTime()
	local resettime = GetQuestResetTime()
	if not resettime or resettime <= 0 or
		resettime > 24 * 3600 + 30 then
		return nil
	end
	if false then
		local serverHour, serverMinute = GetGameTime()
		local serverResetTime = (serverHour * 3600 + serverMinute * 60 + resettime) % 86400
		local diff = serverResetTime - 10800
		if math.abs(diff) > 3.5 * 3600
			and self:GetRegion() == "US" then
			local diffhours = math.floor((diff + 1800) / 3600)
			resettime = resettime - diffhours * 3600
			if resettime < -900 then
				resettime = resettime + 86400
				elseif resettime > 86400 + 900 then
				resettime = resettime - 86400
			end
		end
	end
	return time() + resettime
end

function AM:GetNextWeeklyResetTime()
	if not self.resetDays then
		local region = self:GetRegion()
		if not region then return nil end
		self.resetDays = {}
		self.resetDays.DLHoffset = 0
		if region == "US" then
			self.resetDays["2"] = true
			self.resetDays.DLHoffset = -3 
		elseif region == "EU" then
			self.resetDays["3"] = true
		elseif region == "CN" or region == "KR" or region == "TW" then
			self.resetDays["4"] = true
		else
			self.resetDays["2"] = true
		end
	end
	local offset = (self:GetServerOffset() + self.resetDays.DLHoffset) * 3600
	local nightlyReset = self:GetNextDailyResetTime()
	if not nightlyReset then return nil end
	while not self.resetDays[date("%w", nightlyReset + offset)] do
		nightlyReset = nightlyReset + 24 * 3600
	end
	return nightlyReset
end