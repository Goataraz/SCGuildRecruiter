SC = {};

-- General
SC.LOGO = "|cffffff00<|r|cff16ABB5SC|r|cffffff00>|r ";
SLASH_SUPERGUILDINVITE1 = "/sc";
SLASH_SUPERGUILDINVITE2 = "/shadowcollective";
SC_DATA_INDEX = UnitName("player").." - "..GetRealmName() or "?";
SC.VERSION_ALERT_COOLDOWN = false;

SC_MAX_LEVEL_SUPER_SCAN = 110;
SC_BREAK_POINT_SUPER_SCAN = 90;
SC_MIN_LEVEL_SUPER_SCAN = 21;

-- Version realted
SC.VERSION_MAJOR = "7.7";
SC.VERSION_MINOR = ".0";
SC.versionChanges = {
	version = "Version |cff55EE55"..SC.VERSION_MAJOR..SC.VERSION_MINOR.."|r",
	items = {
		"Added Races and bug fixes..",
	},
}

SC.CommonIssues = {
	"Please post bug reports to the appropriate channel in our Discord Server: shadowco.io",
	"Test2",
	"Test3",
}

local function defaultFunc(L,key)
	return "857C7C"
end



SC_CLASS_COLORS = {
	["DEATHKNIGHT"] = "C41F3B",
	["DEMONHUNTER"] = "A330C9",
	["DRUID"] = "FF7D0A",
	["HUNTER"] = "ABD473",
	["MAGE"] = "69CCF0",
	["MONK"] = "00FF96",
	["PALADIN"] = "F58CBA",
	["PRIEST"] = "FFFFFF",
	["ROGUE"] = "FFF569",
	["SHAMAN"] = "0070DE",
	["WARLOCK"] = "9482C9",
	["WARRIOR"] = "C79C6E",
}

SC_CLASS_COLORS = setmetatable(SC_CLASS_COLORS, {__index=defaultFunc})


local debugMode = false;
local old = print
function SC:print(...)
	if (SC_DATA_INDEX == "?" or type(SC_DATA) ~= "table") then return end
	if (not SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_SC_MUTE"]) then
		old("|cffffff00<|r|cff16ABB5SC|r|cffffff00>|r|cffffff00",...,"|r")
	end
end
function SC:debug(...)
	if (debugMode) then
		old("|cffffff00<|r|cff16ABB5SC|r|cffffff00>|r|cffff3300",...,"|r")
	end
end

function SC:DebugState(state)
	debugMode = state;
end

SC:debug("Loading SC files:");
SC:debug(">> Constants.lua");
