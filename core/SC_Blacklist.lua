local MessageQueue = {};
SC.ForceStop = {};

CreateFrame("Frame", "SC_MESSAGE_TIMER");
SC_MESSAGE_TIMER.update = 0;
SC_MESSAGE_TIMER:SetScript("OnUpdate", function()
	if (SC_MESSAGE_TIMER.update < GetTime()) then
		
		for i = 1,5 do
			local key, messageToBeSent = next(MessageQueue);
		
			if (key and messageToBeSent) then
				if (SC.ForceStop[messageToBeSent.receiver]) then
					MessageQueue[key] = nil;
					SC.ForceStop[messageToBeSent.receiver] = nil;
					SC:debug("Forced sendstop!");
					return;
				end
				SendAddonMessage(ID_MASSLOCK, messageToBeSent.msg, "WHISPER", messageToBeSent.receiver);
				MessageQueue[key] = nil;
				SC:debug("Send AddonMessage ("..messageToBeSent.msg..") to "..messageToBeSent.receiver);
			
			end
		end
		SC_MESSAGE_TIMER.update = GetTime() + 2;
	end
end)

local function AddMessage(message, receiver)
	local newMessage = {
		msg = message,
		receiver = receiver,
	};
	tinsert(MessageQueue, newMessage);
end

function SC:StopMassShare(player)
	SC.ForceStop[player] = true;
end

function SC:IsSharing(player)
	for key, message in pairs(MessageQueue) do
		if (message.receiver == player) then
			return true;
		end
	end
end

local function RemoveLock(name)
	SC_DATA.lock[name] = nil;
end

function SC:IsLocked(name)
	return SC_DATA.lock[name];
end

function SC:LockPlayer(name)
	if (not SC:IsLocked(name)) then
		SC_DATA.lock[name] = tonumber(date("%m"));
	end
end

function SC:UnlockPlayer(name)
	RemoveLock(name);
end

function SC:ShareLocks(name)
	local part = ID_MASSLOCK;
	
	for k,_ in pairs(SC_DATA.lock) do
		if (strlen(part..":"..k) > 250) then
			AddMessage(part, name);
			part = ID_MASSLOCK;
		end
		part = part..":"..k;
	end
	
	AddMessage(part, name);
end

function SC:ReceivedNewLocks(rawLocks)
	local locks = SC:divideString(rawLocks, ":");
	
	for k,_ in pairs(locks) do
		SC:LockPlayer(locks[k]);
	end
	SC:debug("Received locks!");
end

function SC:RemoveOutdatedLocks()
	local month = tonumber(date("%m"));
	
	for k,_ in pairs(SC_DATA.lock) do
		if (month - 1) > SC_DATA.lock[k] or (month < SC_DATA.lock[k] and month > 1) then
			RemoveLock(k);
		end
	end
	
end














SC:debug(">> Blacklist.lua");