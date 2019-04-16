CreateFrame("Frame","SC_EVENT_HANDLER");
SC_EVENTS = {};

function SC_EVENTS:PLAYER_LOGIN()
	
	
	
	-- Index used to separate settings for different characters.
	SC_DATA_INDEX = UnitName("player").." - "..GetRealmName();
	
	-- Make sure the saved variables are correct.
	--General settings:
	if (type(SC_DATA) ~= "table") then
		SC_DATA = {};
	end
	
	-- Fix transition from 6.x to 7.x
	SC:ResetFix()
	
	if (type(SC_DATA.lock) ~= "table") then
		SC_DATA.lock = {};
	end
	if (type(SC_DATA.guildList) ~= "table") then
		SC_DATA.guildList = {}
	end
	if (type(SC_DATA.guildList[GetRealmName()]) ~= "table") then
		SC_DATA.guildList[GetRealmName()] = {};
	end
	
	--Character based settings.
	if type(SC_DATA[SC_DATA_INDEX]) ~= "table" then
		SC_DATA[SC_DATA_INDEX] = {}
	end
	if type(SC_DATA[SC_DATA_INDEX].settings) ~= "table" then
		SC_DATA[SC_DATA_INDEX].settings = {
			inviteMode = 1,
			lowLimit = SC_MIN_LEVEL_SUPER_SCAN,
			highLimit = SC_MAX_LEVEL_SUPER_SCAN,
			raceStart = SC_MAX_LEVEL_SUPER_SCAN,
			classStart = SC_MAX_LEVEL_SUPER_SCAN,
			interval = 5,
			checkBox = {},
			dropDown = {},
			frames = {},
			filters = {},
		}
	end
	if type(SC_DATA[SC_DATA_INDEX].settings.whispers) ~= "table" then
		SC_DATA[SC_DATA_INDEX].settings.whispers = {}
	end
	if type(SC_BACKUP) ~= "table" then
		SC_BACKUP = SC_DATA.lock
	end
	
	-- If there is a saved keybind, activate it.
	if (SC_DATA[SC_DATA_INDEX].keyBind) then
		SetBindingClick(SC_DATA[SC_DATA_INDEX].keyBind,"SC_INVITE_BUTTON");
	end
	
	-- Anti spam. Users of the AddOn GuildShield are ignored.
	GuildShield:Initiate(SC.RemoveShielded);
	-- Load locale
	SC:LoadLocale();
	-- Load the minimap button
	if (not SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_HIDE_MINIMAP"]) then
		SC:ShowMinimapButton();
	end
	-- Activate the keybind, if any.
	if (SC_DATA[SC_DATA_INDEX].keyBind) then	
		SetBindingClick(SC_DATA[SC_DATA_INDEX].keyBind, "SC_INVITE_BUTTON2");
	end
	--Debugging, used for development
	SC:DebugState(SC_DATA[SC_DATA_INDEX].debug);
	--Tell guildies what version you're running
	SC:BroadcastVersion("GUILD");
	--Request lock sync from guildies
	SC:RequestSync();
	--Remove locks that are > 2 months old
	SC:RemoveOutdatedLocks();
	--Chat Intercept
	ChatIntercept:StateSystem(SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_HIDE_SYSTEM"]);
	ChatIntercept:StateWhisper(SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_HIDE_WHISPER"]);
	ChatIntercept:StateRealm(true);
	--Show changes, if needed
	--SC:debug((SC_DATA[SC_DATA_INDEX].settings.checkBox["SC_CHANGES"] and "true" or "nil").." "..(SC_DATA.showChanges and "true" or "nil"));
	if (not SC_DATA[SC_DATA_INDEX].settings.checkBox["SC_CHANGES"] and SC_DATA.showChanges ~= SC.VERSION_MAJOR) then
		SC:ShowChanges();
		SC_DATA.showChanges = SC.VERSION_MAJOR;
		SC:debug("Show changes");
	end
	--Need to load the SuperScan frame for certain functions
	SC:CreateSmallSuperScanFrame();
	SuperScanFrame:Hide();
end

function SC_EVENTS:UPDATE_MOUSEOVER_UNIT()
	-- Create a list of players and their guild (if any).
	-- Used to prevent false positives.
	if (UnitIsPlayer("mouseover")) then
		local name = UnitName("mouseover");
		local guild = GetGuildInfo("mouseover");
		local realm = GetRealmName();
		
		if (not guild or guild == "") then return end
		
		if (type(SC_DATA.guildList[realm][guild]) ~= "table") then
			SC_DATA.guildList[realm][guild] = {};
		end
		for k,v in pairs(SC_DATA.guildList[realm][guild]) do
			if (v == name) then
				return;
			end
		end
		tinsert(SC_DATA.guildList[realm][guild], name);
		--SC_DATA.guildList[realm][name] = guild;
	end
end

function SC_EVENTS:PLAYER_LOGOUT()
	SendAddonMessage("SC_STOP", "", "GUILD");
end

function SC_EVENTS:CHAT_MSG_ADDON(event, ...)
	SC:AddonMessage(event, ...);
end

function SC_EVENTS:CHAT_MSG_SYSTEM(event, ...)
	SC:SystemMessage(event,message,...)
end


for event,_ in pairs(SC_EVENTS) do 
	SC_EVENT_HANDLER:RegisterEvent(event);
end


SC_EVENT_HANDLER:SetScript("OnEvent", function(self,event,...)
	SC_EVENTS[event](self, event, ...);
end)

SC:debug(">> Events.lua");