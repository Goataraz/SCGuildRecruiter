local ID_REQUEST = "GR_REQ";
ID_MASSLOCK = "GR_MASS";
local ID_LOCK = "GR_LOCK";
local ID_SHIELD = "I_HAVE_SHIELD";
local ID_VERSION = "GR_VERSION";
local ID_LIVE_SYNC = "GR_LIVE_SYNC";
local ID_PING = "GR_PING";
local ID_PONG = "GR_PONG";
local ID_STOP = "GR_STOP";
C_ChatInfo.RegisterAddonMessagePrefix(ID_REQUEST);
C_ChatInfo.RegisterAddonMessagePrefix(ID_LOCK);
C_ChatInfo.RegisterAddonMessagePrefix(ID_SHIELD);
C_ChatInfo.RegisterAddonMessagePrefix(ID_MASSLOCK);
C_ChatInfo.RegisterAddonMessagePrefix(ID_VERSION);
C_ChatInfo.RegisterAddonMessagePrefix(ID_LIVE_SYNC);
C_ChatInfo.RegisterAddonMessagePrefix(ID_PING);
C_ChatInfo.RegisterAddonMessagePrefix(ID_STOP);


function GR:AddonMessage(event,...)
	local ID, msg, channel, sender = ...;
	if (not GR_DATA[GR_DATA_INDEX].debug and sender == UnitName("player")) then return end
	
	
	if (ID == ID_SHIELD) then
		GR:LockPlayer(sender);
		GR:RemoveShielded(sender);
		GR:debug("SHIELD: "..ID.." "..msg.." "..sender);
	elseif (ID == ID_LOCK) then
		GR:LockPlayer(sender);
		GR:debug("LOCKING: "..ID.." "..msg.." "..sender);
	elseif (ID == ID_REQUEST) then
		GR:ShareLocks(sender);
		GR:debug("SHARING: "..ID.." "..msg.." "..sender);
	elseif (ID == ID_MASSLOCK) then
		GR:ReceivedNewLocks(msg);
		GR:debug("RECEIVING: "..ID.." "..msg.." "..sender);
	elseif (ID == ID_VERSION) then
		GR:debug("VERSION: "..ID.." "..msg.." "..sender);
		local receivedVersion = msg;
		
		if (new == GR:CompareVersions(GR.VERSION_MAJOR, receivedVersion)) then
			GR:print("|cffffff00A new version (|r|cff00A2FF"..new.."|r|cffffff00) of |r|cff16ABB5GuildRecruiter|r|cffffff00 is available in the Twitch App!");
			if Alerter and not GR.VERSION_ALERT_COOLDOWN then
				Alerter:SendAlert("|cffffff00A new version (|r|cff00A2FF"..new.."|r|cffffff00) of |r|cff16ABB5Guild Recruiter|r|cffffff00 is available in the Twitch App!",1.5)
				GR.VERSION_ALERT_COOLDOWN = true;
			end
		end
		
	elseif (ID == ID_LIVE_SYNC) then
		GR:debug("LIVESYNC: "..ID.." "..msg.." "..sender);
		GR:RemoveQueued(msg);
	elseif (ID == ID_STOP) then
		
	elseif (ID == ID_PING) then
		GR:PingedByGoat(sender);
	end
end

function GR:LiveSync(player)
	C_ChatInfo.SendAddonMessageLogged(ID_LIVE_SYNC, player, "GUILD");
end

function GR:BroadcastVersion(target)
	if (target == "GUILD") then
		C_ChatInfo.SendAddonMessageLogged(ID_VERSION, GR.VERSION_MAJOR, "GUILD");
	else
		C_ChatInfo.SendAddonMessageLogged(ID_VERSION, GR.VERSION_MAJOR, "WHISPER", target);
	end
end

function GR:PingedByGoat(sender)
	C_ChatInfo.SendAddonMessageLogged("GR_PONG", GR.VERSION_MAJOR, "WHISPER", sender);
end

function GR:RequestSync()
	C_ChatInfo.SendAddonMessageLogged(ID_REQUEST, "", "GUILD");
end


GR:debug(">> AddOn_Message.lua");
