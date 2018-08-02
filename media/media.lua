local NEL = _G.NelUI

local AddOnName = ...
local path = [[Interface\AddOns\]]..AddOnName..[[\media\]]

NEL.LSM:Register("font","NelUI", path..[[fonts\PT_Sans_Narrow.ttf]])
NEL.LSM:Register("statusbar", "NelUI Flat", path..[[textures\flat.tga]])