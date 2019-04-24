local L;


function GR:LoadLocale()
	local Locale = GetLocale()
	if GR_Locale[Locale] then
		GR.L = GR_Locale[Locale]
		L = GR.L;
--		GR:print(L["English Locale loaded"]..L["Author"])
		return true
	else
		GR.L = GR_Locale["enGB"]
--		GR:print("|cffffff00Locale missing! Loaded English.|r")
		return false
	end

end

function GR:FormatTime2(T)
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

function GR:FormatTime(T)
	local R,S,M,H = ""
	T = floor(T);
	H = floor(T/3600)
	M = floor((T-3600*H)/60)
	S = T-(3600*H + 60*M)

	if (T <= 0) then
		return GR.L[" < 1 sec"];
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


function GR:CountTable(T)
	local i = 0
	if type(T) ~= "table" then
		return i
	end
	for k,_ in pairs(T) do
		i = i + 1
	end
	return i
end

function GR:GetClassColor(classFileName)
	return GR_CLASS_COLORS[classFileName];
end

function GR:CompareVersions(V1, V2)
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

function GR:ResetFix()
	if (not GR_DATA.resetFix) then
		GR_DATA = {};
		GR_DATA.resetFix = true;
	end
end

function GR:divideString(str,div)
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
	GR_DATA.settings.frames = {}
	ReloadUI();
end

local reloadWarning = true;
local reloadWarning2 = true;
function SlashCmdList.GUILDRECRUITER(msg)

	msg = strlower(msg);

	if msg == "reset" then
		local lock = GR_DATA.lock
		GR_DATA = nil
		GR_EVENTS["ADDON_LOADED"]()
		GR_DATA.lock = lock
	elseif (msg == "framereset") then
		if (reloadWarning) then
			GR:print("WARNING: Reseting your frames requires a reload of the User Interface! If you wish to proceed, type \"/gr framereset\" again!");
			reloadWarning = false;
		else
			FrameReset();
		end
	elseif (msg == "opt" or msg == "options" or msp == "config" or msg == "settings" or msg == "show") then
		GR:ShowOptions();
	elseif (msg == "debug") then
		GR_DATA.debug = not GR_DATA.debug;
		if (GR_DATA.debug) then
			GR:print("Activated debugging!");
		else
			GR:print("Deactivated debugging!");
		end
		GR:DebugState(GR_DATA.debug);
	elseif (msg == "changes") then
		GR:ShowChanges();
	elseif (msg == "stats") then
		local amountScanned, amountGuildless, amountQueued, sessionTotal = GR:GetSuperScanStats();
		GR:print("Scanned players this scan: |r|cff0062FF"..amountScanned.."|r");
		GR:print("Guildless players this scan: |r|cff0062FF"..amountGuildless.."|r");
		GR:print("Queued players this scan: |r|cff0062FF"..amountQueued.."|r");
		GR:print("Total players scanned this session: |r|cff0062FF"..sessionTotal.."|r");
	elseif (msg == "unbind" or msg == "removekeybind") then
		GR:print("Cleared GR invite keybind");
		GR_DATA.keyBind = nil;
	elseif (strfind(msg, "lock")) then
		local name = strsub(msg, 6);
		if (name) then
			GR:LockPlayer(name);
		end
	else
		local temp = GR_DATA.settings.checkBox["CHECKBOX_GR_MUTE"];
		GR_DATA.settings.checkBox["CHECKBOX_GR_MUTE"] = false;
		GR:print("|cffffff00Commands: |r|cff00A2FF/gr or /guildrecruiter|r")
		GR:print("|cff00A2FFreset |r|cffffff00to reset all data except locks|r")
		GR:print("|cff00A2FFframereset|r|cffffff00 resets the positions of the frames |r")
		GR:print("|cff00A2FFunbind|r|cffffff00 removes the saved keybind|r");
		GR:print("|cff00A2FFoptions|r|cffffff00 shows the options. Same effect as clicking the minimap button|r")
		GR_DATA.settings.checkBox["CHECKBOX_GR_MUTE"] = temp;
	end
end

local SCGInv = CreateFrame("Frame","SCGInvFrame")
SCGInv:SetScript("OnEvent", function() hooksecurefunc("UnitPopup_OnClick", SCGuildInvite) end)
SCGInv:RegisterEvent("PLAYER_LOGIN")


local PopupUnits = {}


UnitPopupButtons["GUILDINVITE"] = { text = "Invite to Guild", }

table.insert( UnitPopupMenus["SELF"] ,1 , "GUILDINVITE" )


for i,UPMenus in pairs(UnitPopupMenus) do
  for j=1, #UPMenus do
    if UPMenus[j] == "WHISPER" then
--      print ("-- i,j: "..i.." "..j)
      PopupUnits[#PopupUnits + 1] = i
      pos = j + 1
      table.insert( UnitPopupMenus[i] ,pos , "GUILDINVITE" )
      break
    end
  end
end

function SCGuildInvite (self)
 local button = self.value;
 if ( button == "GUILDINVITE" ) then
  local dropdownFrame = UIDROPDOWNMENU_INIT_MENU;
  local unit = dropdownFrame.unit;
  local name = dropdownFrame.name;
  local server = dropdownFrame.server;
  local fullname = name;

  if ( server and ((not unit and GetNormalizedRealmName() ~= server) or (unit and UnitRealmRelationship(unit) ~= LE_REALM_RELATION_SAME)) ) then
   fullname = name.."-"..server;
  end

  print("SC /ginvite",fullname);
  GuildInvite(fullname);
 end
end
GR:debug(">> Core.lua");
