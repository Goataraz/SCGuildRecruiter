GR.superScan = {};
GR.libWho = {};


CreateFrame("Frame", "GR_SUPER_SCAN");
CreateFrame("Frame", "GR_ANTI_SPAM_FRAME");
CreateFrame("Frame", "GR_WHISPER_QUEUE_FRAME");

LibStub:GetLibrary("LibWho-2.0"):Embed(GR.libWho);

local start-- = GR_DATA.settings.lowLimit;
local stop-- = GR_DATA.settings.highLimit;
local race-- = GR_DATA.settings.raceStart;
local class-- = GR_DATA.settings.classStart;
local interval-- = GR_DATA.settings.interval;

-- Fix for WhoLib bug
local oldFlags;

local superScanIntervalTime = 4;
local superScanLast = 0;
local superScanProgress = 1;
local whoQueryList;
local whoSent = false;
local whoMaster = false;
local scanInProgress = false;
local shouldHideFriendsFrame = false;
local GR_QUEUE = {};
local GR_ANTI_SPAM = {};
local GR_TEMP_BAN = {};
local whisperWaiting = {};
local whisperQueue = {};
local sessionTotal = 0;
local amountScanned = 0;
local amountGuildless = 0;
local amountQueued = 0;
local superScanLap = 1;

local raceClassCombos = {
	["Alliance"] = {
		["Human"] = {
			"Paladin",
			"Hunter",
			"Mage",
			"Priest",
			"Rogue",
			"Warrior",
			"Warlock",
			"Death Knight",
			"Monk",
		},
		["Draenei"] = {
			"Hunter",
			"Mage",
			"Paladin",
			"Priest",
			"Shaman",
			"Death Knight",
			"Warrior",
			"Monk",
		},
		["Gnome"] = {
			"Mage",
			"Priest",
			"Rogue",
			"Warlock",
			"Warrior",
			"Death Knight",
			"Monk",
		},
		["Dwarf"] = {
			"Hunter",
			"Mage",
			"Paladin",
			"Priest",
			"Rogue",
			"Shaman",
			"Warlock",
			"Warrior",
			"Death Knight",
			"Monk",
		},
		["Night Elf"] = {
			"Druid",
			"Hunter",
			"Mage",
			"Priest",
			"Rogue",
			"Warrior",
			"Death Knight",
			"Demon Hunter",
			"Monk",
		},
		["Worgen"] = {
			"Druid",
			"Hunter",
			"Mage",
			"Priest",
			"Rogue",
			"Warlock",
			"Warrior",
			"Death Knight",
		},
		["Pandaren"] = {
			"Hunter",
			"Mage",
			"Priest",
			"Rogue",
			"Shaman",
			"Warrior",
			"Monk",
		},
		["Void Elf"] = {
			"Hunter",
			"Mage",
			"Monk",
			"Priest",
			"Rogue",
			"Warlock",
			"Warrior",
		},
		["Lightforged Draenei"] = {
			"Hunter",
			"Mage",
			"Paladin",
			"Priest",
			"Warrior",
		},
		["Dark Iron Dwarf"] = {
			"Hunter",
			"Mage",
			"Monk",
			"Paladin",
			"Priest",
			"Rogue",
			"Shaman",
			"Warlock",
			"Warrior",
		},
		["Kul'Tiran Human"] = { --not sure if this is correct naming
			"Druid",
			"Hunter",
			"Mage",
			"Priest",
			"Rogue",
			"Shaman",
			"Warrior",
			"Monk",
		},
	},
	["Horde"] = {
		["Blood Elf"] = {
			"Paladin",
			"Hunter",
			"Mage",
			"Priest",
			"Rogue",
			"Warlock",
			"Warrior",
			"Death Knight",
			"Demon Hunter",
			"Monk",
		},
		["Orc"] = {
			"Hunter",
			"Mage",
			"Rogue",
			"Shaman",
			"Warlock",
			"Warrior",
			"Death Knight",
			"Monk",
		},
		["Goblin"] = {
			"Hunter",
			"Mage",
			"Priest",
			"Rogue",
			"Shaman",
			"Warlock",
			"Warrior",
			"Death Knight",
		},
		["Tauren"] = {
			"Druid",
			"Hunter",
			"Paladin",
			"Priest",
			"Shaman",
			"Warrior",
			"Death Knight",
			"Monk",
		},
		["Troll"] = {
			"Druid",
			"Hunter",
			"Mage",
			"Priest",
			"Rogue",
			"Shaman",
			"Warlock",
			"Warrior",
			"Death Knight",
			"Monk",
		},
		["Undead"] = {
			"Hunter",
			"Mage",
			"Priest",
			"Rogue",
			"Warlock",
			"Warrior",
			"Death Knight",
			"Monk",
		},
		["Pandaren"] = {
			"Hunter",
			"Mage",
			"Priest",
			"Rogue",
			"Shaman",
			"Warrior",
			"Monk",
		},
		["Highmountain Tauren"] = {
			"Druid",
			"Hunter",
			"Monk",
			"Shaman",
			"Warrior",
		},
		["Nightborne"] = {
			"Hunter",
			"Mage",
			"Monk",
			"Priest",
			"Rogue",
			"Warlock",
			"Warrior",
		},
		["Mag'har Orc"] = {
			"Hunter",
			"Mage",
			"Monk",
			"Priest",
			"Rogue",
			"Shaman",
			"Warrior",
		},
		["Zandalari Troll"] = {
			"Druid",
			"Hunter",
			"Mage",
			"Paladin",
			"Priest",
			"Rogue",
			"Shaman",
			"Warrior",
			"Monk",
		},
	},
}

local GetTime = GetTime;
local strfind = strfind;
local strsub = strsub;
local tonumber = tonumber;

local L = GR.L;

function GR:PickRandomWhisper()
	local i = 0
	local tbl = {}
	for k,_ in pairs(GR_DATA.settings.whispers) do
		i = i + 1
		tbl[i] = GR_DATA.settings.whispers[k]
	end
	if #tbl == 0 then
		return GR_DATA.settings.whisper
	end
	return tbl[random(#tbl)]
end

function GR:FormatWhisper(msg, name)
	local whisper = msg
	if not msg then GR:print("You have not set your whispers!") msg = "Hey! Do you want to join a guild?" whisper = "Hey! Do you want to join a guild?" end
	if not name then name = "ExampleName" end
	local guildName,guildLevel = GetGuildInfo(UnitName("Player"))
	if not guildName then guildName = "<InvalidName>" end
	if not guildLevel then guildLevel = "<InvalidLevel>" end
	if strfind(msg,"PLAYER") then
		whisper = strsub(msg,1,strfind(msg,"PLAYER")-1)..name..strsub(msg,strfind(msg,"PLAYER")+6)
	end
	if strfind(whisper,"NAME") then
		whisper = strsub(whisper,1,strfind(whisper,"NAME")-1)..guildName..strsub(whisper,strfind(whisper,"NAME")+4)
	end
	if strfind(whisper,"LEVEL") then
		whisper = strsub(whisper,1,strfind(whisper,"LEVEL")-1)..guildLevel..strsub(whisper,strfind(whisper,"LEVEL")+5)
	end
	return whisper
end

local function QueueInvite(name,level,classFile,race,class,found)
	GR_QUEUE[name] = {
		level = level,
		class = class,
		classFile = classFile,
		race = race,
		found = found,
	}
	
end

local function PutOnHold(name,level,classFile,race,class,found)
	GR_ANTI_SPAM[name] = {
		level = level,
		class = class,
		classFile = classFile,
		race = race,
		found = found,
	}
	--GuildShield:IsShielded(name)
end

GR_ANTI_SPAM_FRAME.t = 0;
GR_ANTI_SPAM_FRAME:SetScript("OnUpdate", function()
	if (GR_ANTI_SPAM_FRAME.t < GetTime()) then
		for k,_ in pairs(GR_ANTI_SPAM) do
			if (GR_ANTI_SPAM[k].found + 4 < GetTime()) then
				GR_QUEUE[k] = GR_ANTI_SPAM[k];
				GR_ANTI_SPAM[k] = nil;
				amountQueued = amountQueued + 1;
			end
		end
		GR_ANTI_SPAM_FRAME.t = GetTime() + 0.5;
	end
end)

GR_WHISPER_QUEUE_FRAME.t = 0;
GR_WHISPER_QUEUE_FRAME:SetScript("OnUpdate", function()
	if (GR_WHISPER_QUEUE_FRAME.t < GetTime()) then

		for k,_ in pairs(whisperQueue) do
			if (whisperQueue[k].t < GetTime()) then
				ChatIntercept:InterceptNextWhisper();
				SendChatMessage(whisperQueue[k].msg, "WHISPER", nil, k);
				whisperQueue[k] = nil;
			end
		end

		GR_WHISPER_QUEUE_FRAME.t = GetTime() + 0.5;

	end
end)

local function ValidateName(player)
	--Check:
	-- Lock
	-- filter
	-- guild list

	if (GR_DATA.lock[player.name]) then
		return false;
	end

	if (GR_DATA.guildList[GetRealmName()][player.name]) then
		return false;
	end

	if (GR_DATA.settings.checkBox["CHECKBOX_ENABLE_FILTERS"] and not GR:FilterPlayer(player)) then
		return false;
	end

	return true;
end

local function TrimRealmName(name)
	if (type(name) ~= "string") then GR:debug("TrimRealmName: No name!") return end

	local myRealm = GetRealmName();

	if (type(myRealm) ~= "string") then GR:debug("TrimRealmName: No realmName!") return end

	if (strfind(name, myRealm)) then
		if (strfind(name, "-")) then
			local n = strsub(name,1,strfind(name,"-")-1);
			return n;
		end
	end
	return name;
end

local function WhoResultCallback(query, results, complete)
	if (whoSent) then
		whoSent = false;
		GR:debug("...got reply");

		flags = oldFlags;

		superScanProgress = superScanProgress + 1;
		local ETR = (#whoQueryList - superScanProgress + 1) * superScanIntervalTime;
		if (SuperScanFrame) then
			SuperScanFrame.ETR = ETR;
			SuperScanFrame.lastETR = GetTime();
		end

		local numResults = 0;

		for _, result in pairs(results) do
			amountScanned = amountScanned + 1;
			numResults = numResults + 1;

			result.Name = TrimRealmName(result.Name);

			GR:BroadcastVersion(result.Name)

			if (result.Guild == "") then
				local player = {
					name = result.Name,
					level = result.Level,
					race = result.Race,
					class = result.NoLocaleClass,
				}
				amountGuildless = amountGuildless + 1;
				if (ValidateName(player)) then
					PutOnHold(result.Name, result.Level, result.NoLocaleClass, result.Race, result.Class, GetTime());
				end
			end
		end
		GR:debug("Scan result: "..numResults);
	end
end

local function SuperScan()
	if (GetTime() > superScanLast + superScanIntervalTime) then
		if (superScanProgress == (#whoQueryList + 1)) then
			superScanProgress = 1;
			superScanLast = GetTime();
			amountGuildless = 0;
			sessionTotal = sessionTotal + amountScanned;
			amountScanned = 0;
		else
			oldFlags = flags;
			flags = nil;
			--SendWho(tostring(whoQueryList[superScanProgress]))
			GR.libWho:Who(tostring(whoQueryList[superScanProgress]),{queue = GR.libWho.WHOLIB_QUERY_QUIET, callback = WhoResultCallback});
			whoSent = true;
			superScanLast = GetTime();
			GR:debug("Sent query: "..whoQueryList[superScanProgress].."...");
		end
		superScanLast = GetTime();	
	end

end

local function CreateSuperScanQuery(start, stop, interval, class, race)

	if (not GR_DATA.settings.checkBox["CHECKBOX_ADV_SCAN"]) then
		interval = 5;
		class = 999;
		race = 999;
	end

	local GR_BREAK_POINT_SUPER_SCAN = 90;

	whoQueryList = {};
	local current = start;
	local Classes = {
			GR.L["Death Knight"],
			GR.L["Demon Hunter"],
			GR.L["Druid"],
			GR.L["Hunter"],
			GR.L["Mage"],
			GR.L["Monk"],
			GR.L["Paladin"],
			GR.L["Priest"],
			GR.L["Rogue"],
			GR.L["Shaman"],
			GR.L["Warlock"],
			GR.L["Warrior"],
	}
	local Races = {}
	if UnitFactionGroup("player") == "Horde" then
		Races = {
			GR.L["Orc"],
			GR.L["Blood Elf"],
			GR.L["Undead"],
			GR.L["Troll"],
			GR.L["Goblin"],
			GR.L["Tauren"],
			GR.L["Pandaren"],
			GR.L["Nightborne"],
			GR.L["Highmountain Tauren"],
			GR.L["Mag'har Orc"],
			GR.L["Zandalari Troll"],
		}
	else
		Races = {
			GR.L["Human"],
			GR.L["Dwarf"],
			GR.L["Worgen"],
			GR.L["Draenei"],
			GR.L["Night Elf"],
			GR.L["Gnome"],
			GR.L["Pandaren"],
			GR.L["Void Elf"],
			GR.L["Lightforged Draenei"],
			GR.L["Dark Iron Dwarf"],
			GR.L["Kul Tiran Human"],
		}
	end

	if (start < GR_BREAK_POINT_SUPER_SCAN) then
		while (current + interval < ( (GR_BREAK_POINT_SUPER_SCAN > stop) and stop or GR_BREAK_POINT_SUPER_SCAN)) do

			if (current + interval >= race and current + interval >= class) then
				for k,_ in pairs(raceClassCombos[UnitFactionGroup("player")]) do
					for j,_ in pairs(raceClassCombos[UnitFactionGroup("player")][k]) do
						tinsert(whoQueryList, current.."- -"..(current + interval - 1).." r-"..GR.L[k].." c-"..GR.L[raceClassCombos[UnitFactionGroup("player")][k][j]]);
					end
				end
			elseif (current + interval >= race) then
				for k, _ in pairs(Races) do
					tinsert(whoQueryList, current.."- -"..(current + interval - 1).." r-"..Races[k]);
				end
			elseif (current + interval >= class) then
				for k, _ in pairs(Classes) do
					tinsert(whoQueryList, current.."- -"..(current + interval - 1).." c-"..Classes[k]);
				end
			else
				tinsert(whoQueryList, current.."- -"..(current + interval - 1));
			end

			current = current + interval;
		end

		if ( current < ( (GR_BREAK_POINT_SUPER_SCAN > stop) and stop or GR_BREAK_POINT_SUPER_SCAN ) ) then
			local t_stop = (GR_BREAK_POINT_SUPER_SCAN > stop) and stop or GR_BREAK_POINT_SUPER_SCAN;
			if (t_stop >= race and t_stop >= class) then
				for k,_ in pairs(raceClassCombos[UnitFactionGroup("player")]) do
					for j,_ in pairs(raceClassCombos[UnitFactionGroup("player")][k]) do
						tinsert(whoQueryList, current.."- -"..(t_stop).." r-"..GR.L[k].." c-"..GR.L[raceClassCombos[UnitFactionGroup("player")][k][j]]);
					end
				end
			elseif (t_stop >= race) then
				for k, _ in pairs(Races) do
					tinsert(whoQueryList, current.."- -"..(t_stop).." r-"..Races[k]);
				end
			elseif (t_stop >= class) then
				for k, _ in pairs(Classes) do
					tinsert(whoQueryList, current.."- -"..(t_stop).." c-"..Classes[k]);
				end
			else
				tinsert(whoQueryList, current.."- -"..(t_stop));
			end
			current = t_stop + 1;
		end
	end
	if (stop < current) then return end;

	while (current <= stop) do
		if (current >= race and current >= class) then
			for k,_ in pairs(raceClassCombos[UnitFactionGroup("player")]) do
				for j,_ in pairs(raceClassCombos[UnitFactionGroup("player")][k]) do
					tinsert(whoQueryList, current.." r-"..GR.L[k].." c-"..GR.L[raceClassCombos[UnitFactionGroup("player")][k][j]]);
				end
			end
		elseif (current >= race) then
			for k,_ in pairs(Races) do
				tinsert(whoQueryList, current.." r-"..Races[k]);
			end
		elseif (current >= class) then
			for k,_ in pairs(Classes) do
				tinsert(whoQueryList, current.." c-"..Classes[k]);
			end
		else
			tinsert(whoQueryList, current);
		end
		current = current + 1;
	end
end

local function CanResume()
	local s = GR_DATA.settings;
	return (start == s.lowLimit and stop == s.highLimit and race == s.raceStart and class == s.classStart and interval == s.interval);
end

local function ResetSuperScan()
	start = GR_DATA.settings.lowLimit;
	stop = GR_DATA.settings.highLimit;
	race = GR_DATA.settings.raceStart;
	class = GR_DATA.settings.classStart;
	interval = GR_DATA.settings.interval;

	amountGuildless = 0;
	sessionTotal = sessionTotal + amountScanned;
	amountScanned = 0;
	superScanProgress = 1;
	CreateSuperScanQuery(start, stop, interval, class, race);
end

function GR:StartSuperScan()
	if (not CanResume()) then
		ResetSuperScan();
	end

	if (SuperScanFrame) then
		SuperScanFrame.lastETR = GetTime();
	end

	scanInProgress = true;
	GR_SUPER_SCAN:SetScript("OnUpdate", SuperScan);
end

function GR:StopSuperScan()

	scanInProgress = false;
	GR_SUPER_SCAN:SetScript("OnUpdate", nil);
	GR:debug(FriendsFrame:IsShown());
	--FriendsMicroButton:Click();
	--FriendsFrameCloseButton:Click();
end

function GR:RemoveQueued(name)
	GR:LockPlayer(name);
	GR_QUEUE[name] = nil;
	GR_ANTI_SPAM[name] = nil;

	local nameTrim = TrimRealmName(name);

	GR_ANTI_SPAM[nameTrim] = nil
	GR_QUEUE[nameTrim] = nil;

	GR:debug("RemoveQueued(name) removed "..nameTrim);
end

function GR:UnregisterForWhisper(name)
	whisperWaiting[name] = nil;
	whisperQueue[name] = nil;
end

function GR:SendWhisper(message, name, delay)
	whisperQueue[name] = {msg = message, t = delay + GetTime()};
	whisperWaiting[name] = nil;
end

function GR:RegisterForWhisper(name)
	whisperWaiting[name] = true;
end

function GR:IsRegisteredForWhisper(name)
	return whisperWaiting[name];
end



function GR:SendGuildInvite(button)
	local name = self.player
	if not name then name = next(GR_QUEUE) button = "LeftButton" end
	if not name then return end

	if (GR:IsLocked(name)) then
		GR:RemoveQueued(name);
		return;
	end

	if (UnitIsInMyGuild(name)) then
		GR:LockPlayer(name);
		GR:RemoveQueued(name);
		return;
	end

	if (button == "LeftButton") then

		if (GR_DATA.settings.dropDown["DROPDOWN_INVITE_MODE"] == 1) then

			GR:SendWhisper(GR:FormatWhisper(GR:PickRandomWhisper(), name), name, 4);
			GR:LockPlayer(name);
			--GR:print("Only Invite: "..name);

		elseif (GR_DATA.settings.dropDown["DROPDOWN_INVITE_MODE"] == 2) then

			GR:SendWhisper(GR:FormatWhisper(GR:PickRandomWhisper(), name), name, 4);
			GR:LockPlayer(name);
			--GR:print("Invite, then whisper: "..name);

		elseif (GR_DATA.settings.dropDown["DROPDOWN_INVITE_MODE"] == 3) then

			GR:SendWhisper(GR:FormatWhisper(GR:PickRandomWhisper(), name), name, 4);
			GR:LockPlayer(name);
			--GR:print("Only whisper: "..name);

		else
			GR:SendWhisper(GR:FormatWhisper(GR:PickRandomWhisper(), name), name, 4);
			GR:LockPlayer(name);
			--GR:print("Only whisper: "..name);
		end
		--GuildShield:IsShielded(name);
		GR:LiveSync(name)
	end

	GR:RemoveQueued(name);
end

function GR:RemoveShielded(player)
	GR:debug(player);
	if (not player) then  GR:debug("Error: No player name provided!") return end

	local playerTrim = TrimRealmName(player);

	GR_ANTI_SPAM[playerTrim] = nil
	GR_QUEUE[playerTrim] = nil;
	GR:LockPlayer(playerTrim);

	GR_ANTI_SPAM[player] = nil
	GR_QUEUE[player] = nil;
	GR:LockPlayer(player);
	GR:print("|cffffff00Removed |r|cff00A2FF"..player.."|r|cffffff00 because they are shielded.|r")
end

function GR:GetNumQueued()
	return GR:CountTable(GR_QUEUE);
end

function GR:PurgeQueue()
	GR_QUEUE = {};
	GR_ANTI_SPAM = {};
end

function GR:GetSuperScanETR()
	if (whoQueryList) then
		return GR:FormatTime((#whoQueryList - superScanProgress + 1) * superScanIntervalTime);
	else
		return 0;
	end
end

function GR:GetSuperScanProgress()
	return floor((superScanProgress - 1) / #whoQueryList);
end

function GR:GetTotalScanTime()
	return ((#whoQueryList - 1) * superScanIntervalTime);
end

function GR:IsScanning()
	return scanInProgress;
end

function GR:GetInviteQueue()
	return GR_QUEUE;
end

function GR:GetSuperScanStats()
	return amountScanned, amountGuildless, amountQueued, sessionTotal;
end



GR:debug(">> SuperScan.lua");
