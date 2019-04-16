SC.superScan = {};
SC.libWho = {};


CreateFrame("Frame", "SC_SUPER_SCAN");
CreateFrame("Frame", "SC_ANTI_SPAM_FRAME");
CreateFrame("Frame", "SC_WHISPER_QUEUE_FRAME");

LibStub:GetLibrary("LibWho-2.0"):Embed(SC.libWho);

local start-- = SC_DATA[SC_DATA_INDEX].settings.lowLimit;
local stop-- = SC_DATA[SC_DATA_INDEX].settings.highLimit;
local race-- = SC_DATA[SC_DATA_INDEX].settings.raceStart;
local class-- = SC_DATA[SC_DATA_INDEX].settings.classStart;
local interval-- = SC_DATA[SC_DATA_INDEX].settings.interval;

-- Fix for WhoLib bug
local oldFlags;

local superScanIntervalTime = 8;
local superScanLast = 0;
local superScanProgress = 1;
local whoQueryList;
local whoSent = false;
local whoMaster = false;
local scanInProgress = false;
local shouldHideFriendsFrame = false;
local SC_QUEUE = {};
local SC_ANTI_SPAM = {};
local SC_TEMP_BAN = {};
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
	},
}

local GetTime = GetTime;
local strfind = strfind;
local strsub = strsub;
local tonumber = tonumber;

local L = SC.L;

function SC:PickRandomWhisper()
	local i = 0
	local tbl = {}
	for k,_ in pairs(SC_DATA[SC_DATA_INDEX].settings.whispers) do
		i = i + 1
		tbl[i] = SC_DATA[SC_DATA_INDEX].settings.whispers[k]
	end
	if #tbl == 0 then
		return SC_DATA[SC_DATA_INDEX].settings.whisper
	end
	return tbl[random(#tbl)]
end

function SC:FormatWhisper(msg, name)
	local whisper = msg
	if not msg then SC:print("You have not set your whispers!") msg = "<NO WHISPER SET>" whisper = "<NO WHISPER SET>" end
	if not name then name = "ExampleName" end
	local guildName,guildLevel = GetGuildInfo(UnitName("Player"))--,GetGuildLevel()
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
	SC_QUEUE[name] = {
		level = level,
		class = class,
		classFile = classFile,
		race = race,
		found = found,
	}
	GuildShield:IsShielded(name)
end

local function PutOnHold(name,level,classFile,race,class,found)
	SC_ANTI_SPAM[name] = {
		level = level,
		class = class,
		classFile = classFile,
		race = race,
		found = found,
	}
	GuildShield:IsShielded(name)
end

SC_ANTI_SPAM_FRAME.t = 0;
SC_ANTI_SPAM_FRAME:SetScript("OnUpdate", function()
	if (SC_ANTI_SPAM_FRAME.t < GetTime()) then
		for k,_ in pairs(SC_ANTI_SPAM) do
			if (SC_ANTI_SPAM[k].found + 4 < GetTime()) then
				SC_QUEUE[k] = SC_ANTI_SPAM[k];
				SC_ANTI_SPAM[k] = nil;
				amountQueued = amountQueued + 1;
			end
		end
		SC_ANTI_SPAM_FRAME.t = GetTime() + 0.5;
	end
end)

SC_WHISPER_QUEUE_FRAME.t = 0;
SC_WHISPER_QUEUE_FRAME:SetScript("OnUpdate", function()
	if (SC_WHISPER_QUEUE_FRAME.t < GetTime()) then
	
		for k,_ in pairs(whisperQueue) do
			if (whisperQueue[k].t < GetTime()) then
				ChatIntercept:InterceptNextWhisper();
				SendChatMessage(whisperQueue[k].msg, "WHISPER", nil, k);
				whisperQueue[k] = nil;
			end
		end
	
		SC_WHISPER_QUEUE_FRAME.t = GetTime() + 0.5;
		
	end
end)

local function ValidateName(player)
	--Check:
	-- Lock
	-- filter
	-- guild list
	
	if (SC_DATA.lock[player.name]) then
		return false;
	end
	
	if (SC_DATA.guildList[GetRealmName()][player.name]) then
		return false;
	end
	
	if (SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_ENABLE_FILTERS"] and not SC:FilterPlayer(player)) then
		return false;
	end
	
	return true;
end

local function TrimRealmName(name)
	if (type(name) ~= "string") then SC:debug("TrimRealmName: No name!") return end
	
	local myRealm = GetRealmName();
	
	if (type(myRealm) ~= "string") then SC:debug("TrimRealmName: No realmName!") return end
	
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
		SC:debug("...got reply");
		
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
			
			SC:BroadcastVersion(result.Name)
			
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
		SC:debug("Scan result: "..numResults);
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
			SC.libWho:Who(tostring(whoQueryList[superScanProgress]),{queue = SC.libWho.WHOLIB_QUERY_QUIET, callback = WhoResultCallback});
			whoSent = true;
			superScanLast = GetTime();
			SC:debug("Sent query: "..whoQueryList[superScanProgress].."...");
		end
	end
end

local function CreateSuperScanQuery(start, stop, interval, class, race)

	if (not SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_ADV_SCAN"]) then
		interval = 5;
		class = 999;
		race = 999;
	end
	
	local SC_BREAK_POINT_SUPER_SCAN = 90;
	
	whoQueryList = {};
	local current = start;
	local Classes = {
			SC.L["Death Knight"],
			SC.L["Demon Hunter"],
			SC.L["Druid"],
			SC.L["Hunter"],
			SC.L["Mage"],
			SC.L["Monk"],
			SC.L["Paladin"],
			SC.L["Priest"],
			SC.L["Rogue"],
			SC.L["Shaman"],
			SC.L["Warlock"],
			SC.L["Warrior"],
	}
	local Races = {}
	if UnitFactionGroup("player") == "Horde" then
		Races = {
			SC.L["Orc"],
			SC.L["Blood Elf"],
			SC.L["Undead"],
			SC.L["Troll"],
			SC.L["Goblin"],
			SC.L["Tauren"],
			SC.L["Pandaren"],
		}
	else
		Races = {
			SC.L["Human"],
			SC.L["Dwarf"],
			SC.L["Worgen"],
			SC.L["Draenei"],
			SC.L["Night Elf"],
			SC.L["Gnome"],
			SC.L["Pandaren"],
		}
	end
	
	if (start < SC_BREAK_POINT_SUPER_SCAN) then
		while (current + interval < ( (SC_BREAK_POINT_SUPER_SCAN > stop) and stop or SC_BREAK_POINT_SUPER_SCAN)) do
		
			if (current + interval >= race and current + interval >= class) then
				for k,_ in pairs(raceClassCombos[UnitFactionGroup("player")]) do
					for j,_ in pairs(raceClassCombos[UnitFactionGroup("player")][k]) do
						tinsert(whoQueryList, current.."- -"..(current + interval - 1).." r-"..SC.L[k].." c-"..SC.L[raceClassCombos[UnitFactionGroup("player")][k][j]]);
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
		
		if ( current < ( (SC_BREAK_POINT_SUPER_SCAN > stop) and stop or SC_BREAK_POINT_SUPER_SCAN ) ) then
			local t_stop = (SC_BREAK_POINT_SUPER_SCAN > stop) and stop or SC_BREAK_POINT_SUPER_SCAN;
			if (t_stop >= race and t_stop >= class) then
				for k,_ in pairs(raceClassCombos[UnitFactionGroup("player")]) do
					for j,_ in pairs(raceClassCombos[UnitFactionGroup("player")][k]) do
						tinsert(whoQueryList, current.."- -"..(t_stop).." r-"..SC.L[k].." c-"..SC.L[raceClassCombos[UnitFactionGroup("player")][k][j]]);
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
					tinsert(whoQueryList, current.." r-"..SC.L[k].." c-"..SC.L[raceClassCombos[UnitFactionGroup("player")][k][j]]);
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
	local s = SC_DATA[SC_DATA_INDEX].settings;
	return (start == s.lowLimit and stop == s.highLimit and race == s.raceStart and class == s.classStart and interval == s.interval);
end

local function ResetSuperScan()
	start = SC_DATA[SC_DATA_INDEX].settings.lowLimit;
	stop = SC_DATA[SC_DATA_INDEX].settings.highLimit;
	race = SC_DATA[SC_DATA_INDEX].settings.raceStart;
	class = SC_DATA[SC_DATA_INDEX].settings.classStart;
	interval = SC_DATA[SC_DATA_INDEX].settings.interval;
	
	amountGuildless = 0;
	sessionTotal = sessionTotal + amountScanned;
	amountScanned = 0;
	superScanProgress = 1;
	CreateSuperScanQuery(start, stop, interval, class, race);
end

function SC:StartSuperScan()
	if (not CanResume()) then
		ResetSuperScan();
	end
	
	if (SuperScanFrame) then
		SuperScanFrame.lastETR = GetTime();
	end
	
	scanInProgress = true;
	SC_SUPER_SCAN:SetScript("OnUpdate", SuperScan);
end

function SC:StopSuperScan()
	
	scanInProgress = false;
	SC_SUPER_SCAN:SetScript("OnUpdate", nil);
	SC:debug(FriendsFrame:IsShown());
	--FriendsMicroButton:Click();
	--FriendsFrameCloseButton:Click();
end

function SC:RemoveQueued(name)
	SC:LockPlayer(name);
	SC_QUEUE[name] = nil;
	SC_ANTI_SPAM[name] = nil;
	
	local nameTrim = TrimRealmName(name);
	
	SC_ANTI_SPAM[nameTrim] = nil
	SC_QUEUE[nameTrim] = nil;
	
	SC:debug("RemoveQueued(name) removed "..nameTrim);
end

function SC:UnregisterForWhisper(name)
	whisperWaiting[name] = nil;
	whisperQueue[name] = nil;
end

function SC:SendWhisper(message, name, delay)
	whisperQueue[name] = {msg = message, t = delay + GetTime()};
	whisperWaiting[name] = nil;
end

function SC:RegisterForWhisper(name)
	whisperWaiting[name] = true;
end

function SC:IsRegisteredForWhisper(name)
	return whisperWaiting[name];
end



function SC:SendGuildInvite(button)
	local name = self.player
	if not name then name = next(SC_QUEUE) button = "LeftButton" end
	if not name then return end
	
	if (SC:IsLocked(name)) then
		SC:RemoveQueued(name);
		return;
	end
	
	if (UnitIsInMyGuild(name)) then
		SC:LockPlayer(name);
		SC:RemoveQueued(name);
		return;
	end
	
	if (button == "LeftButton") then
		
		if (SC_DATA[SC_DATA_INDEX].settings.dropDown["DROPDOWN_INVITE_MODE"] == 1) then
			
			GuildInvite(name);
			SC:LockPlayer(name);
			--SC:print("Only Invite: "..name);
			
		elseif (SC_DATA[SC_DATA_INDEX].settings.dropDown["DROPDOWN_INVITE_MODE"] == 2) then
			
			GuildInvite(name);
			SC:RegisterForWhisper(name);
			SC:LockPlayer(name);
			--SC:print("Invite, then whisper: "..name);
		
		elseif (SC_DATA[SC_DATA_INDEX].settings.dropDown["DROPDOWN_INVITE_MODE"] == 3) then
			
			SC:SendWhisper(SC:FormatWhisper(SC:PickRandomWhisper(), name), name, 4);
			SC:LockPlayer(name);
			--SC:print("Only whisper: "..name);
		
		else
			SC:print(SC.L["You need to specify the mode in which you wish to invite"])
			SC:print(SC.L["Go to Options and select your Invite Mode"])
		end
		GuildShield:IsShielded(name);
		SC:LiveSync(name)
	end
	
	SC:RemoveQueued(name);
end

function SC:RemoveShielded(player)
	SC:debug(player);
	if (not player) then  SC:debug("Error: No player name provided!") return end
	
	local playerTrim = TrimRealmName(player);
	
	SC_ANTI_SPAM[playerTrim] = nil
	SC_QUEUE[playerTrim] = nil;
	SC:LockPlayer(playerTrim);
	
	SC_ANTI_SPAM[player] = nil
	SC_QUEUE[player] = nil;
	SC:LockPlayer(player);
	SC:print("|cffffff00Removed |r|cff00A2FF"..player.."|r|cffffff00 because they are shielded.|r")
end

function SC:GetNumQueued()
	return SC:CountTable(SC_QUEUE);
end

function SC:PurgeQueue()
	SC_QUEUE = {};
	SC_ANTI_SPAM = {};
end

function SC:GetSuperScanETR()
	if (whoQueryList) then
		return SC:FormatTime((#whoQueryList - superScanProgress + 1) * superScanIntervalTime);
	else
		return 0;
	end
end

function SC:GetSuperScanProgress()
	return floor((superScanProgress - 1) / #whoQueryList);
end

function SC:GetTotalScanTime()
	return ((#whoQueryList - 1) * superScanIntervalTime);
end

function SC:IsScanning()
	return scanInProgress;
end

function SC:GetInviteQueue()
	return SC_QUEUE;
end

function SC:GetSuperScanStats()
	return amountScanned, amountGuildless, amountQueued, sessionTotal;
end



SC:debug(">> SuperScan.lua");