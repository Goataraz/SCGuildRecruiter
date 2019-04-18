local function ProcessSystemMsg(msg)
	local place = strfind(ERR_GUILD_INVITE_S,"%s",1,true)
	if (place) then
		local n = strsub(msg,place)
		local name = strsub(n,1,(strfind(n,"%s") or 2)-1)
		if format(ERR_GUILD_INVITE_S,name) == msg then
			return "invite",name
		end
	end

	place = strfind(ERR_GUILD_DECLINE_S,"%s",1,true)
	if (place) then
		n = strsub(msg,place)
		name = strsub(n,1,(strfind(n,"%s") or 2)-1)
		if format(ERR_GUILD_DECLINE_S,name) == msg then
			return "decline",name
		end
	end

	place = strfind(ERR_ALREADY_IN_GUILD_S,"%s",1,true)
	if (place) then
		n = strsub(msg,place)
		name = strsub(n,1,(strfind(n,"%s") or 2)-1)
		if format(ERR_ALREADY_IN_GUILD_S,name) == msg then
			return "guilded",name
		end
	end

	place = strfind(ERR_ALREADY_INVITED_TO_GUILD_S,"%s",1,true)
	if (place) then
		n = strsub(msg,place)
		name = strsub(n,1,(strfind(n,"%s") or 2)-1)
		if format(ERR_ALREADY_INVITED_TO_GUILD_S,name) == msg then
			return "already",name
		end
	end

	place = strfind(ERR_GUILD_DECLINE_AUTO_S,"%s",1,true)
	if (place) then
		n = strsub(msg,place)
		name = strsub(n,1,(strfind(n,"%s") or 2)-1)
		if format(ERR_GUILD_DECLINE_AUTO_S,name) == msg then
			return "auto",name
		end
	end

	place = strfind(ERR_GUILD_JOIN_S,"%s",1,true)
	if (place) then
		n = strsub(msg,place)
		name = strsub(n,1,(strfind(n,"%s") or 2)-1)
		if format(ERR_GUILD_JOIN_S,name) == msg then
			return "join",name
		end
	end

	place = strfind(ERR_GUILD_PLAYER_NOT_FOUND_S,"%s",1,true)
	if (place) then
		n = strsub(msg,place)
		name = strsub(n,1,(strfind(n,"%s") or 2)-2)
		if format(ERR_GUILD_PLAYER_NOT_FOUND_S,name) == msg then
			return "miss",name
		end
	end

	place = strfind(ERR_CHAT_PLAYER_NOT_FOUND_S,"%s",1,true)
	if (place) then
		n = strsub(msg,place)
		name = strsub(n,1,(strfind(n,"%s") or 2)-2)
		if format(ERR_CHAT_PLAYER_NOT_FOUND_S,name) == msg then
			return "out",name
		end
	end

	return "unregistered message", "N/A";
end

function GR:SystemMessage(event,_,message,...)

	local type, name = ProcessSystemMsg(message);
	GR:debug("Type: "..type.." Name: "..name);

	if (type == "invite") then
		if (GR:IsRegisteredForWhisper(name)) then
			GR:SendWhisper(GR:FormatWhisper(GR:PickRandomWhisper(), name), name, 1);
		end
	elseif (type == "decline") then
		GR:UnregisterForWhisper(name);
	elseif (type == "auto") then
		GR:LockPlayer(name);
		GR:UnregisterForWhisper(name);
	elseif (type == "guilded") then
		GR:LockPlayer(name);
		GR:UnregisterForWhisper(name);
	elseif (type == "already") then
		GR:LockPlayer(name);
		GR:UnregisterForWhisper(name);
--[[	elseif (type == "join") then

		if (CanEditOfficerNote()) then
			for i = 1,GetNumGuildMembers() do
				local n = GetGuildRosterInfo(i);
				if (n == name) then
					GuildRosterSetOfficerNote(i, date());
				end
			end
		elseif (CanEditPublicNote()) then
			for i = 1,GetNumGuildMembers() do
				local n = GetGuildRosterInfo(i);
				if (n == name) then
					GuildRosterSetPublicNote(i, date());
				end
			end
		end
]]-- Optional, could cause disconnects if large guild.
	elseif (type == "miss") then
		if (GR:IsSharing(name)) then
			GR:StopMassShare(name);
			debug("Stopped mass share!");
		end
		GR:print(format(GR.L["Unable to invite %s. They will not be locked."],name));
		GR:UnlockPlayer(name);
		GR:UnregisterForWhisper(name);
	elseif (type == "out") then
		-- hmm...
		if (GR:IsSharing(name)) then
			GR:StopMassShare(name);
			debug("Stopped mass share!");
		end
		GR:RemoveQueued(name);
	end

end

GR:debug(">> System_Message.lua");
