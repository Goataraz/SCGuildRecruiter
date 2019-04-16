local ID_REQUEST = "SC_REQ";
ID_MASSLOCK = "SC_MASS";
local ID_LOCK = "SC_LOCK";
local ID_SHIELD = "I_HAVE_SHIELD";
local ID_VERSION = "SC_VERSION";
local ID_LIVE_SYNC = "SC_LIVE_SYNC";
local ID_PING = "SC_PING";
local ID_PONG = "SC_PONG";
local ID_STOP = "SC_STOP";
RegisterAddonMessagePrefix(ID_REQUEST);
RegisterAddonMessagePrefix(ID_LOCK);
RegisterAddonMessagePrefix(ID_SHIELD);
RegisterAddonMessagePrefix(ID_MASSLOCK);
RegisterAddonMessagePrefix(ID_VERSION);
RegisterAddonMessagePrefix(ID_LIVE_SYNC);
RegisterAddonMessagePrefix(ID_PING);
RegisterAddonMessagePrefix(ID_STOP);


function SC:AddonMessage(event,...)
	local ID, msg, channel, sender = ...;
	if (not SC_DATA[SC_DATA_INDEX].debug and sender == UnitName("player")) then return end
	
	
	if (ID == ID_SHIELD) then
		SC:LockPlayer(sender);
		SC:RemoveShielded(sender);
		SC:debug("SHIELD: "..ID.." "..msg.." "..sender);
	elseif (ID == ID_LOCK) then
		SC:LockPlayer(sender);
		SC:debug("LOCKING: "..ID.." "..msg.." "..sender);
	elseif (ID == ID_REQUEST) then
		SC:ShareLocks(sender);
		SC:debug("SHARING: "..ID.." "..msg.." "..sender);
	elseif (ID == ID_MASSLOCK) then
		SC:ReceivedNewLocks(msg);
		SC:debug("RECEIVING: "..ID.." "..msg.." "..sender);
	elseif (ID == ID_VERSION) then
		SC:debug("VERSION: "..ID.." "..msg.." "..sender);
		local receivedVersion = msg;
		
		if (new == SC:CompareVersions(SC.VERSION_MAJOR, receivedVersion)) then
			SC:print("|cffffff00A new version (|r|cff00A2FF"..new.."|r|cffffff00) of |r|cff16ABB5Shadow Collective Recruiter|r|cffffff00 is available at curse.com!");
			if Alerter and not SC.VERSION_ALERT_COOLDOWN then
				Alerter:SendAlert("|cffffff00A new version (|r|cff00A2FF"..new.."|r|cffffff00) of |r|cff16ABB5Shadow Collective Recruiter|r|cffffff00 is available at curse.com!",1.5)
				SC.VERSION_ALERT_COOLDOWN = true;
			end
		end
		
	elseif (ID == ID_LIVE_SYNC) then
		SC:debug("LIVESYNC: "..ID.." "..msg.." "..sender);
		SC:RemoveQueued(msg);
	elseif (ID == ID_STOP) then
		
	elseif (ID == ID_PING) then
		SC:PingedByJanniie(sender);
	end
end

function SC:LiveSync(player)
	SendAddonMessage(ID_LIVE_SYNC, player, "GUILD");
end

function SC:BroadcastVersion(target)
	if (target == "GUILD") then
		SendAddonMessage(ID_VERSION, SC.VERSION_MAJOR, "GUILD");
	else
		SendAddonMessage(ID_VERSION, SC.VERSION_MAJOR, "WHISPER", target);
	end
end

function SC:PingedByJanniie(sender)
	SendAddonMessage("SC_PONG", SC.VERSION_MAJOR, "WHISPER", sender);
end

function SC:RequestSync()
	SendAddonMessage(ID_REQUEST, "", "GUILD");
end


SC:debug(">> AddOn_Message.lua");
