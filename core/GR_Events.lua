CreateFrame("Frame","GR_EVENT_HANDLER");
GR_EVENTS = {};

function GR_EVENTS:ADDON_LOADED()


	-- Index used to separate settings for different characters.
	GR_DATA_INDEX = UnitName("player").." - "..GetRealmName();



	-- Make sure the saved variables are correct.
	--General settings:
	if (type(GR_DATA) ~= "table") then
		GR_DATA = {};
	end

	-- Fix transition from 6.x to 7.x
	GR:ResetFix()

	if (type(GR_DATA.lock) ~= "table") then
		GR_DATA.lock = {};
	end
	if (type(GR_DATA.guildList) ~= "table") then
		GR_DATA.guildList = {}
	end
	if (type(GR_DATA.guildList[GetRealmName()]) ~= "table") then
		GR_DATA.guildList[GetRealmName()] = {};
	end

	--Character based settings.
	if type(GR_DATA[GR_DATA_INDEX]) ~= "table" then
		GR_DATA[GR_DATA_INDEX] = {}
	end
	if type(GR_DATA[GR_DATA_INDEX].settings) ~= "table" then
		GR_DATA[GR_DATA_INDEX].settings = {
			inviteMode = 2,
			lowLimit = GR_MIN_LEVEL_SUPER_SCAN,
			highLimit = GR_MAX_LEVEL_SUPER_SCAN,
			raceStart = GR_MAX_LEVEL_SUPER_SCAN,
			classStart = GR_MAX_LEVEL_SUPER_SCAN,
			interval = 5,
			checkBox = {},
			dropDown = {},
			frames = {},
			filters = {},
		}
	end
	if type(GR_DATA[GR_DATA_INDEX].settings.whispers) ~= "table" then
		GR_DATA[GR_DATA_INDEX].settings.whispers = {}
	end
	if type(GR_BACKUP) ~= "table" then
		GR_BACKUP = GR_DATA.lock
	end

	-- If there is a saved keybind, activate it.
	if (GR_DATA[GR_DATA_INDEX].keyBind) then
		SetBindingClick(GR_DATA[GR_DATA_INDEX].keyBind,"GR_INVITE_BUTTON");
	end

	-- Anti spam. Users of the AddOn GuildShield are ignored.
--	GuildShield:Initiate(GR.RemoveShielded);
	-- Load locale
	GR:LoadLocale();
	-- Load the minimap button
	if (not GR_DATA[GR_DATA_INDEX].settings.checkBox["CHECKBOX_HIDE_MINIMAP"]) then
		GR:ShowMinimapButton(1);
	end
	if (not GR_DATA[GR_DATA_INDEX].settings.checkBox["CHECKBOX_ADV_SCAN"]) then
		GR_DATA[GR_DATA_INDEX].settings.checkBox["CHECKBOX_ADV_SCAN"] = FALSE;
	end





	-- Removed Keybind button, too dangerous code. 
	-- Activate the keybind, if any.
	if (GR_DATA[GR_DATA_INDEX].keyBind) then
		SetBindingClick(GR_DATA[GR_DATA_INDEX].keyBind, "GR_INVITE_BUTTON2");
	end



	--Debugging, used for development
	--GR:DebugState(GR_DATA[GR_DATA_INDEX].debug);
	--Tell guildies what version you're running
	--GR:BroadcastVersion("GUILD"); legacy
	--Request lock sync from guildies
	--GR:RequestSync();
	--Remove locks that are > 1 months old
	--GR:RemoveOutdatedLocks();

	--GR_DATA[GR_DATA_INDEX].settings.checkBox["Mute GR"]=true
	--GR_DATA[GR_DATA_INDEX].settings.checkBox["CHECKBOX_HIDE_SYSTEM"]=true
	--print(GR_DATA[GR_DATA_INDEX].settings.checkBox["CHECKBOX_HIDE_SYSTEM"]);

	--Chat Intercept
			--ChatIntercept:StateSystem(GR_DATA[GR_DATA_INDEX].settings.checkBox["CHECKBOX_HIDE_SYSTEM"]);
	ChatIntercept:StateSystem(false);


	ChatIntercept:StateWhisper(GR_DATA[GR_DATA_INDEX].settings.checkBox["CHECKBOX_HIDE_WHISPER"]);
	--ChatIntercept:StateRealm(true);

	--Show changes, if needed
	--GR:debug((GR_DATA[GR_DATA_INDEX].settings.checkBox["GR_CHANGES"] and "true" or "nil").." "..(GR_DATA.showChanges and "true" or "nil"));
	if (not GR_DATA[GR_DATA_INDEX].settings.checkBox["GR_CHANGES"] and GR_DATA.showChanges ~= GR.VERSION_MAJOR) then
--		GR:ShowChanges();
--		GR_DATA.showChanges = GR.VERSION_MAJOR;
--		GR:debug("Show changes");
	end
	--Need to load the SuperScan frame for certain functions
	--GR:CreateSmallSuperScanFrame();
	--SuperScanFrame:Hide();

end

function GR_EVENTS:UPDATE_MOUSEOVER_UNIT()
	-- Create a list of players and their guild (if any).
	-- Used to prevent false positives.
	if (UnitIsPlayer("mouseover")) then
		local name = UnitName("mouseover");
		local guild = GetGuildInfo("mouseover");
		local realm = GetRealmName();

		if (not guild or guild == "") then return end

		if (type(GR_DATA.guildList[realm][guild]) ~= "table") then
			GR_DATA.guildList[realm][guild] = {};
		end
		for k,v in pairs(GR_DATA.guildList[realm][guild]) do
			if (v == name) then
				return;
			end
		end
		tinsert(GR_DATA.guildList[realm][guild], name);
		--GR_DATA.guildList[realm][name] = guild;
	end
end

function GR_EVENTS:PLAYER_LOGOUT()
	 C_ChatInfo.SendAddonMessageLogged("GR_STOP", "", "GUILD");
end

function GR_EVENTS:CHAT_MSG_ADDON(event, ...)
	GR:AddonMessage(event, ...);
end

function GR_EVENTS:CHAT_MSG_SYSTEM(event, ...)
	GR:SystemMessage(event,message,...)
end


for event,_ in pairs(GR_EVENTS) do
	GR_EVENT_HANDLER:RegisterEvent(event);
end


GR_EVENT_HANDLER:SetScript("OnEvent", function(self,event,...)
	GR_EVENTS[event](self, event, ...);
end)

GR:debug(">> Events.lua");
