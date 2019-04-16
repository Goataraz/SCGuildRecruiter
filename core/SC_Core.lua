local L;


function SC:LoadLocale()
	local Locale = GetLocale()
	if SC_Locale[Locale] then 
		SC.L = SC_Locale[Locale]
		L = SC.L;
		SC:print(L["English Locale loaded"]..L["Author"])
		return true
	else
		SC.L = SC_Locale["enGB"]
		SC:print("|cffffff00Locale missing! Loaded English.|r")
		return false
	end

end

function SC:FormatTime2(T)
	local R,S,M,H = ""
	T = floor(T)
	H = floor(T/3600)
	M = floor((T-3600*H)/60)
	S = T-(3600*H + 60*M)
		
	if T <= 0 then
		return L[" < 1 sec"]
	end
		
	if H ~= 0 then
		R =  R..H..L["h "]
	end
	if M ~= 0 then
		R = R..M..L["m "]
	end
	if S ~= 0 then
		R = R..S..L["s"]
	end
	
	return R
end

function SC:FormatTime(T)
	local R,S,M,H = ""
	T = floor(T);
	H = floor(T/3600)
	M = floor((T-3600*H)/60)
	S = T-(3600*H + 60*M)
	
	if (T <= 0) then
		return SC.L[" < 1 sec"];
	end
	
	if (H > 0) then
		R = R..H..":";
	end
	if (M > 9) then
		R = R..M..":";
	elseif (M > 0) then
		R = R.."0"..M..":";
	elseif (M == 0) then
		R = R.."00:";
	end
	if (S > 9) then
		R = R..S;
	elseif (S > 0) then
		R = R.."0"..S;
	elseif (S == 0) then
		R = R.."00";
	end
	
	return R;
end
		

function SC:CountTable(T)
	local i = 0
	if type(T) ~= "table" then
		return i
	end
	for k,_ in pairs(T) do
		i = i + 1
	end
	return i
end

function SC:GetClassColor(classFileName)
	return SC_CLASS_COLORS[classFileName];
end

function SC:CompareVersions(V1, V2)
	local p11 = tonumber(strsub(V1,1,strfind(V1,".",1,true)-1));
	local p12 = tonumber(strsub(V1,strfind(V1,".",1,true)+1));
	local p21 = tonumber(strsub(V2,1,strfind(V2,".",1,true)-1));
	local p22 = tonumber(strsub(V2,strfind(V2,".",1,true)+1));
	
	if (p11 == p21) then
		if (p22 > p12) then
			return V2;
		else 
			return V1;
		end
	elseif (p21 > p11) then
		return V2;
	else
		return V1;
	end
end

function SC:ResetFix()
	if (not SC_DATA.resetFix) then
		SC_DATA = {};
		SC_DATA.resetFix = true;
	end
end

function SC:divideString(str,div)
	local out = {}
	local i = 0
	while strfind(str,div) do
		i = i + 1
		out[i] = strsub(str,1,strfind(str,div)-1)
		str = strsub(str,strfind(str,div)+1)
	end
	out[i+1] = str
	return out
end

local function FrameReset()
	SC_DATA[SC_DATA_INDEX].settings.frames = {}
	ReloadUI();
end

local reloadWarning = true;
local reloadWarning2 = true;
function SlashCmdList.SCGUILDINVITE(msg)

	msg = strlower(msg);

	if msg == "reset" then
		local lock = SC_DATA.lock
		SC_DATA = nil
		SC_EVENTS["PLAYER_LOGIN"]()
		SC_DATA.lock = lock
	elseif (msg == "framereset") then
		if (reloadWarning) then
			SC:print("WARNING: Reseting your frames requires a reload of the User Interface! If you wish to proceed, type \"/sc framereset\" again!");
			reloadWarning = false;
		else
			FrameReset();
		end
	elseif (msg == "opt" or msg == "options" or msp == "config" or msg == "settings" or msg == "show") then
		SC:ShowOptions();
	elseif (msg == "debug") then
		SC_DATA[SC_DATA_INDEX].debug = not SC_DATA[SC_DATA_INDEX].debug;
		if (SC_DATA[SC_DATA_INDEX].debug) then
			SC:print("Activated debugging!");
		else
			SC:print("Deactivated debugging!");
		end
		SC:DebugState(SC_DATA[SC_DATA_INDEX].debug);
	elseif (msg == "changes") then
		SC:ShowChanges();
	elseif (msg == "stats") then
		local amountScanned, amountGuildless, amountQueued, sessionTotal = SC:GetSuperScanStats();
		SC:print("Scanned players this scan: |r|cff0062FF"..amountScanned.."|r");
		SC:print("Guildless players this scan: |r|cff0062FF"..amountGuildless.."|r");
		SC:print("Queued players this scan: |r|cff0062FF"..amountQueued.."|r");
		SC:print("Total players scanned this session: |r|cff0062FF"..sessionTotal.."|r");
	elseif (msg == "unbind" or msg == "removekeybind") then
		SC:print("Cleared SC invite keybind");
		SC_DATA[SC_DATA_INDEX].keyBind = nil;
	elseif (strfind(msg, "lock")) then
		local name = strsub(msg, 6);
		if (name) then
			SC:LockPlayer(name);
		end
	else
		local temp = SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_SC_MUTE"];
		SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_SC_MUTE"] = false;
		SC:print("|cffffff00Commands: |r|cff00A2FF/sc or /shadowcollective|r")
		SC:print("|cff00A2FFreset |r|cffffff00to reset all data except locks|r")
		SC:print("|cff00A2FFframereset|r|cffffff00 resets the positions of the frames |r")
		SC:print("|cff00A2FFunbind|r|cffffff00 removes the saved keybind|r");
		SC:print("|cff00A2FFoptions|r|cffffff00 shows the options. Same effect as clicking the minimap button|r")
		SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_SC_MUTE"] = temp;
	end
end

SC:debug(">> Core.lua");