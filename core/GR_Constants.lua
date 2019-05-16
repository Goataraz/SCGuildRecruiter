GR = {};

-- General
GR.LOGO = "|cffffff00<|r|cff16ABB5GR|r|cffffff00>|r ";
SLASH_GUILDRECRUITER1 = "/gr";
SLASH_GUILDRECRUITER2 = "/guildrecruiter";
GR_DATA_INDEX = UnitName("player").." - "..GetRealmName() or "?";
GR.VERSION_ALERT_COOLDOWN = false;

GR_MAX_LEVEL_SUPER_SCAN = 120;
GR_BREAK_POINT_SUPER_SCAN = 90;
GR_MIN_LEVEL_SUPER_SCAN = 1;

-- Version realted
GR.VERSION_MAJOR = "2.0";
GR.VERSION_MINOR = ".6";
GR.versionChanges = {
	version = "Version |cff55EE55"..GR.VERSION_MAJOR..GR.VERSION_MINOR.."|r",
	items = {
		"Guild Sync",
	},
}

GR.CommonIssues = {
	"Please post bug reports on #bugs channel in our Discord at https://discord.gg/x4tR4sX and I'll try to fix them.",
	"Test2",
	"Test3",
}

local function defaultFunc(L,key)
	return "857C7C"
end



GR_CLASS_COLORS = {
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

GR_CLASS_COLORS = setmetatable(GR_CLASS_COLORS, {__index=defaultFunc})


local debugMode = false;
local old = print
function GR:print(...)
	if (GR_DATA_INDEX == "?" or type(GR_DATA) ~= "table") then return end
	if (not GR_DATA.settings.checkBox["CHECKBOX_GR_MUTE"]) then
		old("|cffffff00<|r|cff16ABB5GR|r|cffffff00>|r|cffffff00",...,"|r")
	end
end
function GR:debug(...)
	if (debugMode) then
		old("|cffffff00<|r|cff16ABB5GR|r|cffffff00>|r|cffff3300",...,"|r")
	end
end

function GR:DebugState(state)
	debugMode = state;
end

GR:debug("Loading GR files:");
GR:debug(">> Constants.lua");
