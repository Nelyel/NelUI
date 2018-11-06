local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI
local NC = NEL:NewModule("Calendar", "AceEvent-3.0")
NelUI.Calendar = NC

local CALENDAR_MONTH = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
}

local function GetWeekday(day, month, year) 
   weekday = date('*t', time{year = year, month = month, day = day}) ['wday']
   return ({"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}) [weekday]
end

local function GetDaysInMonth(month, year)
  return date('*t', time{year = year, month = month + 1, day = 0}) ['day']
end

function NC:CreateCalendarEventFrame()
	local frame = CreateFrame("Frame", "NelUICalendarEventFrame", NelUICalendarFrame)
	frame:SetPoint("TOPLEFT", 5, -35)
	frame:SetPoint("BOTTOMRIGHT", -5, 5)

	local date = C_Calendar.GetDate()
	local day, month, year = date.monthDay, date.month, date.year

	for i = 1, GetDaysInMonth(month, year) do
		local numEvents = C_Calendar.GetNumDayEvents(0, i)
		for j = 1, numEvents do
	    	local event = C_Calendar.GetDayEvent(0, i, j)
	    	if event.calendarType == "PLAYER" then
	    		local eventday = CreateFrame("Frame", "NelUICalendarEventDay"..numday, NelUICalendarFrame)
	    		eventday:SetPoint()
			end
		end	
	end
end

function NC:CreateCalendarFrame()
	if NelUICalendarFrame and NelUICalendarFrame:IsShown() then
		NelUICalendarFrame:Hide()
		return
	elseif NelUICalendarFrame then
		NelUICalendarFrame:Show()
		return
	end

	local date = C_Calendar.GetDate()
	local day, month, year = date.day, date.month, date.year

	local frame = CreateFrame("Frame", "NelUICalendarFrame", UIParent)
	local close = CreateFrame("Button", "NelUICalendarCloseButton", frame)
	local prevmonth = CreateFrame("Button", "NelUICalendarPreviousButton", frame)
	local nextmonth = CreateFrame("Button", "NelUICalendarNextMonthButton", frame)

	frame:SetTemplate("Transparent")
	frame:SetSize(445, 550)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame:SetFrameStrata("HIGH")
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

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

	frame.month = frame:CreateFontString(nil, "OVERLAY")
	frame.month:SetFont(NEL.LSM:Fetch("font", "NelUI"), 16, "OUTLINE")
	frame.month:SetPoint("TOP", 0, -5)
	frame.month:SetText(CALENDAR_MONTH[month])
	frame.month:SetJustifyH("CENTER")
	frame.month:SetJustifyV("MIDDLE")

	frame.year = frame:CreateFontString(nil, "OVERLAY")
	frame.year:SetFont(NEL.LSM:Fetch("font", "NelUI"), 12, "OUTLINE")
	frame.year:SetPoint("TOP", 0, -20)
	frame.year:SetText(year)
	frame.year:SetJustifyH("CENTER")
	frame.year:SetJustifyV("MIDDLE")

	prevmonth:SetTemplate()
	prevmonth:SetPoint("TOP", -60, -5)
	prevmonth:SetSize(25, 25)
	prevmonth:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor)) end)
	prevmonth:SetScript("OnLeave", function(self) self:SetTemplate() end)
	prevmonth:SetScript("OnClick", function(self)
		month = month - 1

		if month == 0 then 
			month = 12
			year = year - 1
		end

		NC:UpdateCalendarFrame(month, year) 
	end)

	prevmonth.Text = prevmonth:CreateFontString(nil, "OVERLAY")
	prevmonth.Text:SetFont(NEL.LSM:Fetch("font", "NelUI"), 16, "OUTLINE")
	prevmonth.Text:SetJustifyH("CENTER")
	prevmonth.Text:SetJustifyV("MIDDLE")
	prevmonth.Text:SetText("<")
	prevmonth.Text:SetPoint("CENTER", 1, 0)

	nextmonth:SetTemplate()
	nextmonth:SetPoint("TOP", 60, -5)
	nextmonth:SetSize(25, 25)
	nextmonth:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor)) end)
	nextmonth:SetScript("OnLeave", function(self) self:SetTemplate() end)
	nextmonth:SetScript("OnClick", function(self) 
		month = month + 1

		if month == 13 then 
			month = 1
			year = year + 1
		end

		NC:UpdateCalendarFrame(month, year)
	end)

	nextmonth.Text = nextmonth:CreateFontString(nil, "OVERLAY")
	nextmonth.Text:SetFont(NEL.LSM:Fetch("font", "NelUI"), 16, "OUTLINE")
	nextmonth.Text:SetJustifyH("CENTER")
	nextmonth.Text:SetJustifyV("MIDDLE")
	nextmonth.Text:SetText(">")
	nextmonth.Text:SetPoint("CENTER", 1, 0)

	NC.CreateCalendarEventFrame()
end

function NC:UpdateCalendarFrame(month, year)
	NelUICalendarFrame.month:SetText(CALENDAR_MONTH[month])
	NelUICalendarFrame.year:SetText(year)
end

SLASH_NELUICALENDAR1 = "/nelcalendar"
SlashCmdList["NELUICALENDAR"] = function()
	NC.CreateCalendarFrame()
end