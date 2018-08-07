local NEL = _G.NelUI
local AM = NEL:NewModule("AltManager", "AceEvent-3.0")
NEL.AltManager = AM

local AddOnName = ...

--[[
local DUNGEONS = {
	[244] = "AD", 
	[245] = "FH",
	[246] = "KR",
	[247] = "SotS",
	[248] = "SoB",
	[249] = "ToS",
	[250] = "TM",
	[251] = "TU",
	[252] = "TD",
	[353] = "WM"
--]]

local DUNGEONS = {
	[199] = "BRH", 
	[210] = "CoS",
	[198] = "DHT",
	[197] = "EoA",
	[200] = "HoV",
	[208] = "MoS",
	[206] = "NL",
	[209] = "AW",
	[207] = "VotW",
	[227] = "LK",
	[233] = "CoEN",
	[234] = "UK",
	[239] = "SotT"
}

local EVENTS = {
	["Timewalking Dungeon Event"] = "TW Event",
	["Legion Dungeon Event"] = "LD Event",
	["Battle for Azeroth Dungeon Event"] = "BfA Event",
	["Pet Battle Bonus Event"] = "PB Event",
	["Arena Skirmish Bonus Event"] = "AS Event",
	["World Quest Bonus Event"] = "WQ Event",
	["Battleground Bonus Event"] = "BG Event"
}

local WEEKLYQUESTS = {
	44164,	-- TBC TW Event
	44166,	-- WotLK TW event
	44167,	-- Cata TW Event
	45799,	-- MoP TW Event
	44171,	-- Dungeon Event
	39042,	-- PB Event
	44172,	-- AS Event
	44175,  -- WQ EVENT
	44173	-- BG Event
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

local function EnableAPI()
	if not IsAddOnLoaded("Blizzard_ChallengesUI") then
		UIParentLoadAddOn("Blizzard_ChallengesUI")
	end
   	
   	PVEFrame:Show()
	PVEFrameTab3:Click()
	PVEFrameTab1:Click()
	PVEFrame:Hide()

	if not IsAddOnLoaded("Blizzard_Calendar") then
		UIParentLoadAddOn("Blizzard_Calendar")
	end

	if Calendar_Toggle then Calendar_Toggle() end
	if Calendar_Toggle then Calendar_Toggle() end
end

local function GetCurrentWeeklyEvent ()
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
end

function AM:GetCharacters(filter)
	local db = NelDB.altmanager
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

function AM:ValidateReset()

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

	local keystone = "-"
	local highestmplus, weeklychestloot = C_MythicPlus.GetWeeklyChestRewardLevel()
	if weeklychestloot == -1 then weeklychestloot = 0 end

	if C_MythicPlus.GetOwnedKeystoneChallengeMapID() then
		local dungeon = DUNGEONS[tonumber(C_MythicPlus.GetOwnedKeystoneChallengeMapID())]
		local level = C_MythicPlus.GetOwnedKeystoneLevel()

		keystone = format("%s +%d", dungeon, level)
	end

	-- local _, seals = GetCurrencyInfo(1580)
	local _, seals = GetCurrencyInfo(1273)
	local sealsbought = 0

	local source = {
		43895, 43896, 43897, -- Gold
		43892, 43893, 43894, -- Resources
		47851, 47864, 47865, -- Marks
		43510				 -- Orderhall
	}

	for i = 1, #source do
		if IsQuestFlaggedCompleted(source[i]) then
			sealsbought = sealsbought + 1
		end
	end

	local weekly = GetCurrentWeeklyEvent()
	for i = 1, #WEEKLYQUESTS do
		if IsQuestFlaggedCompleted(WEEKLYQUESTS[i]) then
			weekly = "done"
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

	table.seals = seals
	table.sealsbought = sealsbought
	table.weekly = weekly

	table.expires = self:GetNextWeeklyResetTime()

	return table
end

function AM:StoreData(data)
	if not self.addonLoaded then return end
	if not data or not data.guid then return end

	if UnitLevel("player") < 110 then return end

	local db = NelDB.altmanager or {}
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
		if AddOnName == loaded then
			self:UnregisterEvent("ADDON_LOADED")

			NelDB.altmanager = NelDB.altmanager or self:InitDB()
			self.addonLoaded = true
		end
	end
end

function AM:PLAYER_LOGIN()
	EnableAPI()
	self:ValidateReset()
	self:StoreData(self:CollectData())
end

function AM:CHAT_MSG_CURRENCY()
	self:StoreData(self:CollectData())
end

function AM:BAG_UPDATE_DELAYED()
	self:StoreData(self:CollectData())
end

function AM:OnInitialize()
	NelDB.altmanager = NelDB.altmanager or self:InitDB()

	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("CHAT_MSG_CURRENCY")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
end
-----------------------------------
-- TOOLTIP
-----------------------------------
local LABELTOOLTIP = {
	"Azerite Level:",
	"Highest M+ done:",
	"Keystone:",
	"Seals:",
	"Weekly:"
}

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

local function GetNumCharacters(t)
	local num = 0
	for realm, v in pairs(t) do
		num = num + #t[realm]
    end

    return num
end

local function GetLine(i)
	return -(1/6)*i^4+2*i^3-(25/3)*i^2+(31/2)*i-4
end

local function GetSealInformation(owned, brought)
	local _, _, texture = GetCurrencyInfo(1273)
	texture = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", texture, 12, 12)

	local s = format("%s %s/6", texture, owned)
	local max = 3

	if brought == max then 
		return format("%s |cff6c7378(%s/%s)|r", s, brought, max) 
	else 
		return format("%s (%s/%s)", s, brought, max) 
	end
end

function AM:CreateTooltip(self)
	local REALMS, CHARS = AM:GetCharacters(true)
	local numchars = GetNumCharacters(CHARS)

	if numchars == 0 then return end
	
	if NEL.LQT:IsAcquired("NelUIAltManagerV") then
		tooltip:Clear()
	else
		tooltip = NEL.LQT:Acquire("NelUIAltManagerV", numchars*2+1)

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
	for i = 1, 11 do
		if i == 2 or i == 4 or i == 6 or i == 9 then
			tooltip:AddSeparator(1, 108/255, 115/255, 120/255)
		else
			tooltip:AddLine()
		end
	end

    -- SET LABEL
    for i = 1, 5 do
    	tooltip:SetCell(GetLine(i), 1, LABELTOOLTIP[i], "RIGHT")
    end

    local padding = 4

    local countchars, posirealm = 1, 2
    for i, realm in pairs(REALMS) do
    	tooltip:SetCell(1, posirealm, realm, colorGrey, "LEFT", #CHARS[i]*2, nil, nil, padding)
	 	for j, char in pairs(CHARS[i]) do
	 		local character = NEL.alts[realm][char]
	 		tooltip:SetCell(3, (countchars*2), format("|c%s%s|r", RAID_CLASS_COLORS[character.class].colorStr, character.name), "RIGHT")
	 		tooltip:SetCell(3, (countchars*2)+1, format("ilvl %.2f", character.ilvl), ilvlFont, "LEFT", nil, nil, nil, padding)
	 		tooltip:SetCell(5, (countchars*2), character.azeritelevel, "CENTER", 2, nil, nil, padding)
            tooltip:SetCell(7, (countchars*2), character.highestmplus, "CENTER", 2, nil, nil, padding)
            tooltip:SetCell(8, (countchars*2), character.keystone, "CENTER", 2, nil, nil, padding)
            tooltip:SetCell(10, (countchars*2), GetSealInformation(character.seals, character.sealsbought), "CENTER", 2, nil, nil, padding)
            tooltip:SetCell(11, (countchars*2), character.weekly, "CENTER", 2, nil, nil, padding)
	 		countchars = countchars + 1
	 	end
	 	posirealm = posirealm + #CHARS[i]*2
	 	
	 	if countchars > numchars then return tooltip:Show() end
	end

	tooltip:Show()
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