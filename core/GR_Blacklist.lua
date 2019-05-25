local MessageQueue = {};
GR.ForceStop = {};

CreateFrame("Frame", "GR_MESSAGE_TIMER");
GR_MESSAGE_TIMER.update = 0;
GR_MESSAGE_TIMER:SetScript("OnUpdate", function()
	if (GR_MESSAGE_TIMER.update < GetTime()) then

		for i = 1,5 do
			local key, messageToBeSent = next(MessageQueue);

			if (key and messageToBeSent) then
				if (GR.ForceStop[messageToBeSent.receiver]) then
					MessageQueue[key] = nil;
					GR.ForceStop[messageToBeSent.receiver] = nil;
					GR:print("Forced sendstop!");
					return;
				end
				 C_ChatInfo.SendAddonMessageLogged(ID_MASSLOCK, messageToBeSent.msg, "WHISPER", messageToBeSent.receiver);
				MessageQueue[key] = nil;
				GR:print("Send AddonMessage ("..messageToBeSent.msg..") to "..messageToBeSent.receiver);

			end
		end
		GR_MESSAGE_TIMER.update = GetTime() + 2;
	end
end)

local function AddMessage(message, receiver)
	local newMessage = {
		msg = message,
		receiver = receiver,
	};
	tinsert(MessageQueue, newMessage);
end

function GR:StopMassShare(player)
	GR.ForceStop[player] = true;
end

function GR:IsSharing(player)
	for key, message in pairs(MessageQueue) do
		if (message.receiver == player) then
			return true;
		end
	end
end

local function RemoveLock(name)
	GR_DATA.lock[name] = nil;
end

function GR:IsLocked(name)
	return GR_DATA.lock[name];
end

function GR:LockPlayer(name)
	if (not GR:IsLocked(name)) then
		GR_DATA.lock[name] = tonumber(date("%m"));
	end
end

function GR:UnlockPlayer(name)
	RemoveLock(name);
end

function GR:ShareLocks(name)
	local part = ID_MASSLOCK;

	for k,_ in pairs(GR_DATA.lock) do
		if (strlen(part..":"..k) > 250) then
			AddMessage(part, name);
			part = ID_MASSLOCK;
		end
		part = part..":"..k;
	end

	AddMessage(part, name);
end

function GR:ReceivedNewLocks(rawLocks)
	local locks = GR:divideString(rawLocks, ":");

	for k,_ in pairs(locks) do
		GR:LockPlayer(locks[k]);
	end
	GR:print("Received locks!");
end

function GR:RemoveOutdatedLocks()
	local month = tonumber(date("%m"));

	for k,_ in pairs(GR_DATA.lock) do
		if (month - 1) > GR_DATA.lock[k] or (month < GR_DATA.lock[k] and month > 1) then
			RemoveLock(k);
		end
	end

end














GR:print(">> Blacklist.lua");
