
local function onClickTester(self)
	if self then
		SC:print("Click on "..self:GetName());
	end
end

local function CreateButton(name, parent, width, height, label, anchor, onClick)
	local f = CreateFrame("Button", name, parent, "UIPanelButtonTemplate");
	f:SetWidth(width);
	f:SetHeight(height);
	f.label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	f.label:SetText(label);
	f.label:SetPoint("CENTER");
	f:SetWidth(width - 10);

	if (type(anchor) == "table") then
		f:SetPoint(anchor.point,parent,anchor.relativePoint,anchor.xOfs,anchor.yOfs);
	end

	f:SetScript("OnClick", onClick);
	return f;
end

local function CreateCheckbox(name, parent, label, anchor)
	local f = CreateFrame("CheckButton", name, parent, "OptionsBaseCheckButtonTemplate");
	f.label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	f.label:SetText(label);
	f.label:SetPoint("LEFT", f, "RIGHT", 5, 1);

	if (type(anchor) == "table") then
		f:SetPoint(anchor.point,parent,anchor.relativePoint,anchor.xOfs,anchor.yOfs);
	end

	f:HookScript("OnClick", function(self)
		SC_DATA[SC_DATA_INDEX].settings.checkBox[name] = self:GetChecked()
	end)
	if SC_DATA[SC_DATA_INDEX].settings.checkBox[name] then
		f:SetChecked()
	end
	return f;
end

local function CreateDropDown(name, parent, label, items, anchor)
	local f = CreateFrame("Button", name, parent, "UIDropDownMenuTemplate");
	f:ClearAllPoints();
	f:SetPoint(anchor.point,parent,anchor.relativePoint,anchor.xOfs,anchor.yOfs)
	f:Show()

	f.label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	f.label:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 20, 5);
	f.label:SetText(label);

	local function OnClick(self)
		UIDropDownMenu_SetSelectedID(f, self:GetID());
		SC_DATA[SC_DATA_INDEX].settings.dropDown[name] = self:GetID();
	end

	local function initialize(self, level)
		local info = UIDropDownMenu_CreateInfo();
		for k,v in pairs(items) do
			info = UIDropDownMenu_CreateInfo();
			info.text = v;
			info.value = v;
			info.func = OnClick;
			UIDropDownMenu_AddButton(info, level);
		end
	end

	UIDropDownMenu_Initialize(f, initialize)
	UIDropDownMenu_SetWidth(f, 100);
	UIDropDownMenu_SetButtonWidth(f, 124)
	SC_DATA[SC_DATA_INDEX].settings.dropDown[name] = SC_DATA[SC_DATA_INDEX].settings.dropDown[name] or 1
	UIDropDownMenu_SetSelectedID(f, SC_DATA[SC_DATA_INDEX].settings.dropDown[name] or 1)
	UIDropDownMenu_JustifyText(f, "LEFT")
	return f
end

local function SetFramePosition(frame)
	if (type(SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()]) ~= "table") then
		if (frame:GetName() == "SC_MiniMapButton") then
			SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()] = {point = "CENTER", relativePoint = "CENTER", xOfs = -71, yOfs = -31};
		else
			frame:SetPoint("CENTER");
			SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()] = {point = "CENTER", relativePoint = "CENTER", xOfs = 0, yOfs = 0};
			return;
		end
	end
	if (frame:GetName() == "SC_MiniMapButton") then
		frame:SetPoint(
			SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()].point,
			Minimap,
			SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()].relativePoint,
			SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()].xOfs,
			SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()].yOfs
		);
	else
		frame:SetPoint(
			SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()].point,
			UIParent,
			SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()].relativePoint,
			SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()].xOfs,
			SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()].yOfs
		);
	end
end

local function SaveFramePosition(frame)
	if (type(SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()]) ~= "table") then
		SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()] = {};
	end
	local point, parent, relativePoint, xOfs, yOfs = frame:GetPoint();
	SC_DATA[SC_DATA_INDEX].settings.frames[frame:GetName()] = {point = point, relativePoint = relativePoint, xOfs = xOfs, yOfs = yOfs};
end


local function CreateInviteListFrame()
	CreateFrame("Frame","SC_Invites")
	local SC_QUEUE = SC:GetInviteQueue();
	SC_Invites:SetWidth(370)
	SC_Invites:SetHeight(20*SC:CountTable(SC_QUEUE) + 40)
	SC_Invites:SetMovable(true)
	SetFramePosition(SC_Invites)
	SC_Invites:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SC_Invites:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(SC_Invites)
	end)
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SC_Invites:SetBackdrop(backdrop)

	SC_Invites.text = SC_Invites:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Invites.text:SetPoint("TOP",SC_Invites,"TOP",-15,-15)
	SC_Invites.text:SetText(SC.L["Click on the players you wish to invite"])
	SC_Invites.tooltip = CreateFrame("Frame","InviteTime",SC_Invites,"GameTooltipTemplate")
	SC_Invites.tooltip.text = SC_Invites.tooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Invites.tooltip:SetPoint("TOP",SC_Invites,"BOTTOM",0,-2)
	SC_Invites.tooltip.text:SetText("Unknown")
	SC_Invites.tooltip.text:SetPoint("CENTER")

	local close = CreateFrame("Button",nil,SC_Invites,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SC_Invites,"TOPRIGHT",-4,-4)

	SC_Invites.items = {}
	local update = 0
	local toolUpdate = 0
	SC_Invites:SetScript("OnUpdate",function()
		if (not SC_Invites:IsShown() or GetTime() < update) then return end

		SC_QUEUE = SC:GetInviteQueue();

		for k,_ in pairs(SC_Invites.items) do
			SC_Invites.items[k]:Hide()
		end

		local i = 0
		local x,y = 10,-30
		for i = 1,30 do
			if not SC_Invites.items[i] then
				SC_Invites.items[i] = CreateFrame("Button","InviteBar"..i,SC_Invites)
				SC_Invites.items[i]:SetWidth(350)
				SC_Invites.items[i]:SetHeight(20)
				SC_Invites.items[i]:EnableMouse(true)
				SC_Invites.items[i]:SetPoint("TOP",SC_Invites,"TOP",0,y)
				SC_Invites.items[i].text = SC_Invites.items[i]:CreateFontString(nil,"OVERLAY","GameFontNormal")
				SC_Invites.items[i].text:SetPoint("LEFT",SC_Invites.items[i],"LEFT",3,0)
				SC_Invites.items[i].text:SetJustifyH("LEFT")
				SC_Invites.items[i].text:SetWidth(SC_Invites.items[i]:GetWidth()-10);
				SC_Invites.items[i].player = "unknown"
				SC_Invites.items[i]:RegisterForClicks("LeftButtonDown","RightButtonDown")
				SC_Invites.items[i]:SetScript("OnClick",SC.SendGuildInvite)

				SC_Invites.items[i].highlight = SC_Invites.items[i]:CreateTexture()
				SC_Invites.items[i].highlight:SetAllPoints()
				SC_Invites.items[i].highlight:SetTexture(1,1,0,0.2)
				SC_Invites.items[i].highlight:Hide()

				SC_Invites.items[i]:SetScript("OnEnter",function()
					SC_Invites.items[i].highlight:Show()
					SC_Invites.tooltip:Show()
					SC_Invites.items[i]:SetScript("OnUpdate",function()
						if GetTime() > toolUpdate and SC_QUEUE[SC_Invites.items[i].player] then
							SC_Invites.tooltip.text:SetText("Found |cff"..SC:GetClassColor(SC_QUEUE[SC_Invites.items[i].player].classFile)..SC_Invites.items[i].player.."|r "..SC:FormatTime(floor(GetTime()-SC_QUEUE[SC_Invites.items[i].player].found)).." ago")
							local h,w = SC_Invites.tooltip.text:GetHeight(),SC_Invites.tooltip.text:GetWidth()
							SC_Invites.tooltip:SetWidth(w+20)
							SC_Invites.tooltip:SetHeight(h+20)
							toolUpdate = GetTime() + 0.1
						end
					end)
				end)
				SC_Invites.items[i]:SetScript("OnLeave",function()
					SC_Invites.items[i].highlight:Hide()
					SC_Invites.tooltip:Hide()
					SC_Invites.items[i]:SetScript("OnUpdate",nil)
				end)
			end
			y = y - 20
		end
		i = 0
		for k,_ in pairs(SC_QUEUE) do
			i = i + 1
			local level,classFile,race,class,found = SC_QUEUE[k].level, SC_QUEUE[k].classFile, SC_QUEUE[k].race, SC_QUEUE[k].class, SC_QUEUE[k].found
			local Text = i..". |cff"..SC:GetClassColor(classFile)..k.."|r Lvl "..level.." "..race.." |cff"..SC:GetClassColor(classFile)..class.."|r"
			SC_Invites.items[i].text:SetText(Text)
			SC_Invites.items[i].player = k
			SC_Invites.items[i]:Show()
			if i >= 30 then break end
		end
		SC_Invites:SetHeight(i * 20 + 40)
		update = GetTime() + 0.5
	end)
end


function SC:ShowInviteList()
	if (not SC_Invites) then
		CreateInviteListFrame();
	end
	SC_Invites:Show();
end

function SC:HideInviteList()
	if (SC_Invites) then
		SC_Invites:Hide();
	end
end


local function SSBtn3_OnClick(self)
	if (SC:IsScanning()) then
		SC:StopSuperScan();
		self:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
	else
		SC:StartSuperScan();
		self:SetNormalTexture("Interface\\TimeManager\\PauseButton");
	end
end

function SC:CreateSmallSuperScanFrame()
	CreateFrame("Frame", "SuperScanFrame");
	SuperScanFrame:SetWidth(130);
	SuperScanFrame:SetHeight(30);
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SetFramePosition(SuperScanFrame)
	SuperScanFrame:SetMovable(true)
	SuperScanFrame:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SuperScanFrame:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(self)
	end)
	SuperScanFrame:SetBackdrop(backdrop)

	local close = CreateFrame("Button",nil,SuperScanFrame,"UIPanelCloseButton")
	close:SetPoint("LEFT",SuperScanFrame,"RIGHT",-5,0)

	SuperScanFrame.time = SuperScanFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SuperScanFrame.time:SetPoint("CENTER")
	SuperScanFrame.time:SetText(format("|cff00ff00%d%%|r|cffffff00 %s|r",0,SC:GetSuperScanETR()))

	SuperScanFrame.progressTexture = SuperScanFrame:CreateTexture();
	SuperScanFrame.progressTexture:SetPoint("LEFT", 5, 0);
	SuperScanFrame.progressTexture:SetHeight(18);
	SuperScanFrame.progressTexture:SetWidth(120);
	SuperScanFrame.progressTexture:SetTexture(1,0.5,0,0.4);

	local anchor = {
		point = "TOPLEFT",
		relativePoint = "BOTTOMLEFT",
		xOfs = 0,
		yOfs = 0,
	}

	SuperScanFrame.button1 = CreateButton("SC_INVITE_BUTTON2", SuperScanFrame, 70, 30, format("Invite: %d",SC:GetNumQueued()), anchor, SC.SendGuildInvite)
		anchor.xOfs = 85;
	SuperScanFrame.button2 = CreateButton("SC_PURGE_QUEUE", SuperScanFrame, 55, 30, "Purge", anchor, SC.PurgeQueue);
		anchor.xOfs = 57;
	SuperScanFrame.button2 = CreateButton("SC_SUPERSCAN_PLAYPAUSE", SuperScanFrame, 40,30,"",anchor,SSBtn3_OnClick);
	SC_SUPERSCAN_PLAYPAUSE:SetNormalTexture("Interface\\TimeManager\\PauseButton");

	SuperScanFrame.nextUpdate = 0;
	SuperScanFrame:SetScript("OnUpdate", function()
		if (SuperScanFrame.nextUpdate < GetTime()) then

			SuperScanFrame.button1.label:SetText(format("Invite: %d",SC:GetNumQueued()));

			if (SC:IsScanning() and SuperScanFrame.ETR and SuperScanFrame.lastETR) then
				local remainingTime = SuperScanFrame.ETR - (GetTime() - SuperScanFrame.lastETR);
				local totalScanTime = SC:GetTotalScanTime();
				local percentageDone = (totalScanTime - remainingTime) / totalScanTime;
				SuperScanFrame.time:SetText(format("|cff00ff00%d%%|r|cffffff00 %s|r",100*(percentageDone > 1 and 1 or percentageDone),SC:FormatTime(remainingTime)))
				SuperScanFrame.progressTexture:SetWidth(120 * (percentageDone > 1 and 1 or percentageDone));
			end

			SuperScanFrame.nextUpdate = GetTime() + 0.2;
		end
	end)


	SuperScanFrame:Hide();
	-- Interface\Buttons\UI-SpellbookIcon-NextPage-Up
	-- Interface\TimeManager\PauseButton
end

function SC:GetPercentageDone()
	if (SC:IsScanning() and SuperScanFrame.ETR and SuperScanFrame.lastETR) then
		local remainingTime = SuperScanFrame.ETR - (GetTime() - SuperScanFrame.lastETR);
		local totalScanTime = SC:GetTotalScanTime();
		local percentageDone = (totalScanTime - remainingTime) / totalScanTime;
		return percentageDone * 100;
	end
	return 0;
end

function SC:GetSuperScanTimeLeft()
	if (SC:IsScanning() and SuperScanFrame.ETR and SuperScanFrame.lastETR) then
		return SC:FormatTime(SuperScanFrame.ETR - (GetTime() - SuperScanFrame.lastETR));
	end
	return 0;
end


function SC:ShowSuperScanFrame()
	if (SuperScanFrame and not (SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_BACKGROUND_MODE"])) then
		SuperScanFrame:Show();
	else
		if (SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_BACKGROUND_MODE"]) then
			SC:CreateSmallSuperScanFrame();
			SuperScanFrame:Hide();
			return;
		else
			SC:CreateSmallSuperScanFrame();
			SuperScanFrame:Show();
		end

	end
end

function SC:HideSuperScanFrame()
	if (SuperScanFrame) then
		SuperScanFrame:Hide();
	end
end

local function CreateWhisperDefineFrame()

end




local KeyHarvestFrame = CreateFrame("Frame", "SC_KeyHarvestFrame");
KeyHarvestFrame:SetPoint("CENTER",0,200);
KeyHarvestFrame:SetWidth(10);
KeyHarvestFrame:SetHeight(10);
KeyHarvestFrame.text = KeyHarvestFrame:CreateFontString(nil, "OVERLAY", "MovieSubtitleFont");
KeyHarvestFrame.text:SetPoint("CENTER");
KeyHarvestFrame.text:SetText("|cff00ff00Press the KEY you wish to bind now!|r");
KeyHarvestFrame:Hide();

function KeyHarvestFrame:GetNewKeybindKey()
	KeyHarvestFrame:Show();
	self:SetScript("OnKeyDown", function(self, key)
		if (SetBindingClick(key, "SC_INVITE_BUTTON2")) then
			Alerter:SendAlert("|cff00ff00Successfully bound "..key.." to InviteButton!|r",1.5);
			SC:print("Successfully bound "..key.." to InviteButton!");
			SC_DATA[SC_DATA_INDEX].keyBind = key;
			BUTTON_KEYBIND.label:SetText("Set Keybind ("..key..")");
		else
			Alerter:SendAlert("|cffff0000Error binding "..key.." to InviteButton!|r",1.5);
			SC:print("Error binding "..key.." to InviteButton!");
		end
		self:EnableKeyboard(false);
		KeyHarvestFrame:Hide();
	end)
	self:EnableKeyboard(true);

end

local function CreateWhisperDefineFrame()
	CreateFrame("Frame","SC_Whisper")
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SC_Whisper:SetWidth(500)
	SC_Whisper:SetHeight(365)
	SC_Whisper:SetBackdrop(backdrop)
	SetFramePosition(SC_Whisper)
	SC_Whisper:SetMovable(true)
	SC_Whisper:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SC_Whisper:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(SC_Whisper)
	end)

	local close = CreateFrame("Button",nil,SC_Whisper,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SC_Whisper,"TOPRIGHT",-4,-4)

	SC_Whisper.title = SC_Whisper:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SC_Whisper.title:SetText(SC.L["SuperGuildInvite Custom Whisper"])
	SC_Whisper.title:SetPoint("TOP",SC_Whisper,"TOP",0,-20)

	SC_Whisper.info = SC_Whisper:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Whisper.info:SetPoint("TOPLEFT",SC_Whisper,"TOPLEFT",33,-55)
	SC_Whisper.info:SetText(SC.L["WhisperInstructions"])
	SC_Whisper.info:SetWidth(450)
	SC_Whisper.info:SetJustifyH("LEFT")

	SC_Whisper.edit = CreateFrame("EditBox",nil,SC_Whisper)
	SC_Whisper.edit:SetWidth(450)
	SC_Whisper.edit:SetHeight(65)
	SC_Whisper.edit:SetMultiLine(true)
	SC_Whisper.edit:SetPoint("TOPLEFT",SC_Whisper,"TOPLEFT",35,-110)
	SC_Whisper.edit:SetFontObject("GameFontNormal")
	SC_Whisper.edit:SetTextInsets(10,10,10,10)
	SC_Whisper.edit:SetMaxLetters(256)
	SC_Whisper.edit:SetBackdrop(backdrop)
	SC_Whisper.edit:SetText(SC_DATA[SC_DATA_INDEX].settings.whispers[SC_DATA[SC_DATA_INDEX].settings.dropDown["SC_WHISPER_DROP"] or 1] or "")
	SC_Whisper.edit:SetScript("OnHide",function()
		SC_Whisper.edit:SetText(SC_DATA[SC_DATA_INDEX].settings.whispers[SC_DATA[SC_DATA_INDEX].settings.dropDown["SC_WHISPER_DROP"] or 1] or "")
	end)
	SC_Whisper.edit.text = SC_Whisper.edit:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Whisper.edit.text:SetPoint("TOPLEFT",SC_Whisper.edit,"TOPLEFT",10,13)
	SC_Whisper.edit.text:SetText(SC.L["Enter your whisper"])

	local yOfs = -20
	SC_Whisper.status = {}
	for i = 1,6 do
		SC_Whisper.status[i] = {}
		SC_Whisper.status[i].box = CreateFrame("Frame",nil,SC_Whisper)
		SC_Whisper.status[i].box:SetWidth(170)
		SC_Whisper.status[i].box:SetHeight(18)
		SC_Whisper.status[i].box:SetFrameStrata("HIGH")
		SC_Whisper.status[i].box.index = i
		SC_Whisper.status[i].box:SetPoint("LEFT",SC_Whisper,"CENTER",50,yOfs)
		SC_Whisper.status[i].box:SetScript("OnEnter",function(self)
			if SC_DATA[SC_DATA_INDEX].settings.whispers[self.index] then
				GameTooltip:SetOwner(self,"ANCHOR_CURSOR")
				GameTooltip:SetText(SC:FormatWhisper(SC_DATA[SC_DATA_INDEX].settings.whispers[self.index],UnitName("Player")))
			end
		end)
		SC_Whisper.status[i].box:SetScript("OnLeave",function(self)
			GameTooltip:Hide()
		end)
		SC_Whisper.status[i].text = SC_Whisper:CreateFontString(nil,nil,"GameFontNormal")
		SC_Whisper.status[i].text:SetText("Whisper #"..i.." status: ")
		SC_Whisper.status[i].text:SetWidth(200)
		SC_Whisper.status[i].text:SetJustifyH("LEFT")
		SC_Whisper.status[i].text:SetPoint("LEFT",SC_Whisper,"CENTER",50,yOfs)
		yOfs = yOfs - 18
	end
	local whispers = {
		"Whisper #1",
		"Whisper #2",
		"Whisper #3",
		"Whisper #4",
		"Whisper #5",
		"Whisper #6",
	}

	anchor = {}
		anchor.point = "BOTTOMLEFT"
		anchor.relativePoint = "BOTTOMLEFT"
		anchor.xOfs = 50
		anchor.yOfs = 120

	--CreateDropDown(name, parent, label, items, anchor)
	SC_Whisper.drop = CreateDropDown("SC_WHISPER_DROP",SC_Whisper,SC.L["Select whisper"],whispers,anchor)

		anchor.xOfs = 100
		anchor.yOfs = 20
	--CreateButton(name, parent, width, height, label, anchor, onClick)
	CreateButton("SC_SAVEWHISPER",SC_Whisper,120,30,SC.L["Save"],anchor,function()
		local text = SC_Whisper.edit:GetText()
		local ID = SC_DATA[SC_DATA_INDEX].settings.dropDown["SC_WHISPER_DROP"]
		SC_DATA[SC_DATA_INDEX].settings.whispers[ID] = text
		SC_Whisper.edit:SetText("")
	end)
	anchor.xOfs = 280
	CreateButton("SC_CANCELWHISPER",SC_Whisper,120,30,SC.L["Cancel"],anchor,function()
		SC_Whisper:Hide()
	end)

	SC_Whisper.update = 0
	SC_Whisper.changed = false
	SC_Whisper:SetScript("OnUpdate",function()
		if GetTime() > SC_Whisper.update then
			for i = 1,6 do
				if type(SC_DATA[SC_DATA_INDEX].settings.whispers[i]) == "string" then
					SC_Whisper.status[i].text:SetText("Whisper #"..i.." status: |cff00ff00Good|r")
				else
					SC_Whisper.status[i].text:SetText("Whisper #"..i.." status: |cffff0000Undefined|r")
				end
			end
			local ID = SC_DATA[SC_DATA_INDEX].settings.dropDown["SC_WHISPER_DROP"]
			SC_Whisper.status[ID].text:SetText("Whisper #"..ID.." status: |cffff8800Editing...|r")

			if ID ~= SC_Whisper.changed then
				SC_Whisper.changed = ID
				SC_Whisper.edit:SetText(SC_DATA[SC_DATA_INDEX].settings.whispers[SC_DATA[SC_DATA_INDEX].settings.dropDown["SC_WHISPER_DROP"] or 1] or "")
			end

			SC_Whisper.update = GetTime() + 0.5
		end
	end)

	SC_Whisper:HookScript("OnHide", function() if (SC_Options.showAgain) then SC:ShowOptions() SC_Options.showAgain = false end end)
end

local function ShowWhisperFrame()
	if SC_Whisper then
		SC_Whisper:Show()
	else
		CreateWhisperDefineFrame()
		SC_Whisper:Show()
	end
end

local function HideWhisperFrame()
	if SC_Whisper then
		SC_Whisper:Hide()
	end
end

local function CreateFilterFrame()
	CreateFrame("Frame","SC_Filters")
	SC_Filters:SetWidth(550)
	SC_Filters:SetHeight(380)
	SetFramePosition(SC_Filters)
	SC_Filters:SetMovable(true)
	SC_Filters:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SC_Filters:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(SC_Filters)
	end)
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SC_Filters:SetBackdrop(backdrop)
	local close = CreateFrame("Button",nil,SC_Filters,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SC_Filters,"TOPRIGHT",-4,-4)

	SC_Filters.title = SC_Filters:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	SC_Filters.title:SetPoint("TOP", SC_Filters, "TOP", 0, -15);
	SC_Filters.title:SetText("Edit filters");
	SC_Filters.underTitle = SC_Filters:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	SC_Filters.underTitle:SetPoint("TOP", SC_Filters, "TOP", 0, -38);
	SC_Filters.underTitle:SetText("|cffff3300Any textbox left empty, except \"Filter name\" will be excluded from the filter|r");
	SC_Filters.underTitle:SetWidth(400);
	SC_Filters.bottomText = SC_Filters:CreateFontString(nil, "OVERLAY", "GameFOntNormal");
	SC_Filters.bottomText:SetPoint("BOTTOM", SC_Filters, "BOTTOM", 0, 60);
	SC_Filters.bottomText:SetText("|cff00ff00In order to be filtered, a player has to match |r|cffFF3300ALL|r |cff00ff00criterias|r");

	SC_Filters.tooltip = CreateFrame("Frame", "FilterTooltip", SC_Filters.tooltip, "GameTooltipTemplate");
	SC_Filters.tooltip:SetWidth(150);
	SC_Filters.tooltip.text = SC_Filters.tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	SC_Filters.tooltip.text:SetPoint("CENTER", SC_Filters.tooltip, "CENTER", 0, 0);
	SC_Filters.tooltip.text:SetJustifyH("LEFT");

	SC_Filters.editBoxName = CreateFrame("EditBox", "SC_EditBoxName", SC_Filters);
	SC_Filters.editBoxName:SetWidth(150);
	SC_Filters.editBoxName:SetHeight(30);
	SC_Filters.editBoxName:SetPoint("TOPRIGHT", SC_Filters, "TOPRIGHT", -40, -90);
	SC_Filters.editBoxName:SetFontObject("GameFontNormal");
	SC_Filters.editBoxName:SetMaxLetters(65);
	SC_Filters.editBoxName:SetBackdrop(backdrop);
	SC_Filters.editBoxName:SetText("");
	SC_Filters.editBoxName:SetTextInsets(10,10,10,10);
	SC_Filters.editBoxName:SetScript("OnHide",function(self)
		self:SetText("");
	end)
	SC_Filters.editBoxName.title = SC_Filters.editBoxName:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	SC_Filters.editBoxName.title:SetPoint("BOTTOMLEFT", SC_Filters.editBoxName,"TOPLEFT", 0, 5);
	SC_Filters.editBoxName.title:SetText("Filter name");

	SC_Filters.editBoxNameFilter = CreateFrame("EditBox", "SC_EditBoxNameFilter", SC_Filters);
	SC_Filters.editBoxNameFilter:SetWidth(150);
	SC_Filters.editBoxNameFilter:SetHeight(30);
	SC_Filters.editBoxNameFilter:SetPoint("TOPRIGHT", SC_Filters, "TOPRIGHT", -40, -150);
	SC_Filters.editBoxNameFilter:SetFontObject("GameFontNormal");
	SC_Filters.editBoxNameFilter:SetMaxLetters(65);
	SC_Filters.editBoxNameFilter:SetBackdrop(backdrop);
	SC_Filters.editBoxNameFilter:SetText("");
	SC_Filters.editBoxNameFilter:SetTextInsets(10,10,10,10);
	SC_Filters.editBoxNameFilter:SetScript("OnHide",function(self)
		self:SetText("");
	end)
	SC_Filters.editBoxNameFilter:SetScript("OnEnter", function(self)
		SC_Filters.tooltip.text:SetText(SC.L["Enter a phrase which you wish to include in the filter. If a player's name contains the phrase, they will not be queued"]);
		SC_Filters.tooltip.text:SetWidth(135);
		SC_Filters.tooltip:SetHeight(SC_Filters.tooltip.text:GetHeight() + 12);
		SC_Filters.tooltip:SetPoint("TOP", self, "BOTTOM", 0, -5);
		SC_Filters.tooltip:Show();
	end)
	SC_Filters.editBoxNameFilter:SetScript("OnLeave", function()
		SC_Filters.tooltip:Hide()
	end)

	SC_Filters.editBoxNameFilter.title = SC_Filters.editBoxNameFilter:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	SC_Filters.editBoxNameFilter.title:SetPoint("BOTTOMLEFT", SC_Filters.editBoxNameFilter,"TOPLEFT", 0, 5);
	SC_Filters.editBoxNameFilter.title:SetText("Name exceptions");

	SC_Filters.editBoxLvl = CreateFrame("EditBox", "SC_EditBoxLvl", SC_Filters);
	SC_Filters.editBoxLvl:SetWidth(150);
	SC_Filters.editBoxLvl:SetHeight(30);
	SC_Filters.editBoxLvl:SetPoint("TOPRIGHT", SC_Filters, "TOPRIGHT", -40, -210);
	SC_Filters.editBoxLvl:SetFontObject("GameFontNormal");
	SC_Filters.editBoxLvl:SetMaxLetters(65);
	SC_Filters.editBoxLvl:SetBackdrop(backdrop);
	SC_Filters.editBoxLvl:SetText("");
	SC_Filters.editBoxLvl:SetTextInsets(10,10,10,10);
	SC_Filters.editBoxLvl:SetScript("OnHide",function(self)
		self:SetText("");
	end)
	SC_Filters.editBoxLvl:SetScript("OnEnter", function(self)
		SC_Filters.tooltip.text:SetText(SC.L["Enter the level range for the filter. \n\nExample: |cff00ff0055|r:|cff00A2FF58|r \n\nThis would result in only matching players that range from level |cff00ff0055|r to |cff00A2FF58|r (inclusive)"]);
		SC_Filters.tooltip.text:SetWidth(135);
		SC_Filters.tooltip:SetHeight(SC_Filters.tooltip.text:GetHeight() + 12);
		SC_Filters.tooltip:SetPoint("TOP", self, "BOTTOM", 0, -5);
		SC_Filters.tooltip:Show();
	end)
	SC_Filters.editBoxLvl:SetScript("OnLeave", function()
		SC_Filters.tooltip:Hide()
	end)

	SC_Filters.editBoxLvl.title = SC_Filters.editBoxLvl:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	SC_Filters.editBoxLvl.title:SetPoint("BOTTOMLEFT", SC_Filters.editBoxLvl,"TOPLEFT", 0, 5);
	SC_Filters.editBoxLvl.title:SetText("Level range (Min:Max)");

	SC_Filters.editBoxVC = CreateFrame("EditBox", "SC_EditBoxVC", SC_Filters);
	SC_Filters.editBoxVC:SetWidth(150);
	SC_Filters.editBoxVC:SetHeight(30);
	SC_Filters.editBoxVC:SetPoint("TOPRIGHT", SC_Filters, "TOPRIGHT", -40, -270);
	SC_Filters.editBoxVC:SetFontObject("GameFontNormal");
	SC_Filters.editBoxVC:SetMaxLetters(65);
	SC_Filters.editBoxVC:SetBackdrop(backdrop);
	SC_Filters.editBoxVC:SetText("");
	SC_Filters.editBoxVC:SetTextInsets(10,10,10,10);
	SC_Filters.editBoxVC:SetScript("OnHide",function(self)
		self:SetText("");
	end)

	SC_Filters.editBoxVC:SetScript("OnEnter", function(self)
		SC_Filters.tooltip.text:SetText(SC.L["Enter the maximum amount of consecutive vowels and consonants a player's name can contain.\n\nExample: |cff00ff003|r:|cff00A2FF5|r\n\nThis would cause players with more than |cff00ff003|r vowels in a row or more than |cff00A2FF5|r consonants in a row not to be queued."]);
		SC_Filters.tooltip.text:SetWidth(135);
		SC_Filters.tooltip:SetHeight(SC_Filters.tooltip.text:GetHeight() + 12);
		SC_Filters.tooltip:SetPoint("TOP", self, "BOTTOM", 0, -5);
		SC_Filters.tooltip:Show();
	end)
	SC_Filters.editBoxVC:SetScript("OnLeave", function()
		SC_Filters.tooltip:Hide()
	end)

	SC_Filters.editBoxVC.title = SC_Filters.editBoxVC:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	SC_Filters.editBoxVC.title:SetPoint("BOTTOMLEFT", SC_Filters.editBoxVC,"TOPLEFT", 0, 5);
	SC_Filters.editBoxVC.title:SetText("Max Vowels/Cons (V:C)");

	SC_EditBoxName:SetScript("OnEnterPressed", function()
		SC_EditBoxNameFilter:SetFocus();
	end);
	SC_EditBoxNameFilter:SetScript("OnEnterPressed", function()
		SC_EditBoxLvl:SetFocus();
	end);
	SC_EditBoxLvl:SetScript("OnEnterPressed", function()
		SC_EditBoxVC:SetFocus();
	end);
	SC_EditBoxVC:SetScript("OnEnterPressed", function()
		SC_EditBoxName:SetFocus();
	end);
	SC_EditBoxName:SetScript("OnTabPressed", function()
		SC_EditBoxNameFilter:SetFocus();
	end);
	SC_EditBoxNameFilter:SetScript("OnTabPressed", function()
		SC_EditBoxLvl:SetFocus();
	end);
	SC_EditBoxLvl:SetScript("OnTabPressed", function()
		SC_EditBoxVC:SetFocus();
	end);
	SC_EditBoxVC:SetScript("OnTabPressed", function()
		SC_EditBoxName:SetFocus();
	end);

	local CLASS = {
			[SC.L["Death Knight"]] = "DEATHKNIGHT",
			[SC.L["Demon Hunter"]] = "DEMONHUNTER",
			[SC.L["Druid"]] = "DRUID",
			[SC.L["Hunter"]] = "HUNTER",
			[SC.L["Mage"]] = "MAGE",
			[SC.L["Monk"]] = "MONK",
			[SC.L["Paladin"]] = "PALADIN",
			[SC.L["Priest"]] = "PRIEST",
			[SC.L["Rogue"]] = "ROGUE",
			[SC.L["Shaman"]] = "SHAMAN",
			[SC.L["Warlock"]] = "WARLOCK",
			[SC.L["Warrior"]] = "WARRIOR"
	}
	local Classes = {
			SC.L["Ignore"],
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
			SC.L["Ignore"],
			SC.L["Orc"],
			SC.L["Blood Elf"],
			SC.L["Undead"],
			SC.L["Troll"],
			SC.L["Goblin"],
			SC.L["Tauren"],
			SC.L["Pandaren"],
			SC.L["Highmountain Tauren"],
			SC.L["Nightborne"]
		}
	else
		Races = {
			SC.L["Ignore"],
			SC.L["Human"],
			SC.L["Dwarf"],
			SC.L["Worgen"],
			SC.L["Draenei"],
			SC.L["Night Elf"],
			SC.L["Gnome"],
			SC.L["Pandaren"],
			SC.L["Void Elf"].
			SC.L["Lightforged Draenei"]
		}
	end

	SC_Filters.classText = SC_Filters:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	SC_Filters.raceText = SC_Filters:CreateFontString(nil, "OVERLAY", "GameFontNormal");

	SC_Filters.classCheckBoxes = {};
	local anchor = {
		point = "TOPLEFT",
		relativePoint = "TOPLEFT",
		xOfs = 40,
		yOfs = -90,
	}
	for k,_ in pairs(Classes) do
		SC_Filters.classCheckBoxes[k] = CreateCheckbox("CHECKBOX_FILTERS_CLASS_"..Classes[k], SC_Filters, Classes[k], anchor)

		anchor.yOfs = anchor.yOfs - 18;
	end
	SC_Filters.classText:SetPoint("BOTTOM", SC_Filters.classCheckBoxes[1], "TOP", -5, 3);
	SC_Filters.classText:SetText(SC.L["Classes:"]);

	if (SC_Filters.classCheckBoxes[1]:GetChecked()) then
		for i = 2,12 do
			SC_Filters.classCheckBoxes[i]:Hide();
		end
	else
		for i = 2,12 do
			SC_Filters.classCheckBoxes[i]:Show();
		end
	end

	SC_Filters.classCheckBoxes[1]:HookScript("PostClick", function()
		if (SC_Filters.classCheckBoxes[1]:GetChecked()) then
			for i = 2,12 do
				SC_Filters.classCheckBoxes[i]:Hide();
			end
		else
			for i = 2,12 do
				SC_Filters.classCheckBoxes[i]:Show();
			end
		end
	end)


	SC_Filters.raceCheckBoxes = {};
	anchor = {
		point = "TOPLEFT",
		relativePoint = "TOPLEFT",
		xOfs = 160,
		yOfs = -90,
	}
	for k,_ in pairs(Races) do
		SC_Filters.raceCheckBoxes[k] = CreateCheckbox("CHECKBOX_FILTERS_RACE_"..Races[k], SC_Filters, Races[k], anchor)
		anchor.yOfs = anchor.yOfs - 18;
	end

	SC_Filters.raceText:SetPoint("BOTTOM", SC_Filters.raceCheckBoxes[1], "TOP", -5, 3);
	SC_Filters.raceText:SetText(SC.L["Races:"]);

	if (SC_Filters.raceCheckBoxes[1]:GetChecked()) then
		for i = 2,8 do
			SC_Filters.raceCheckBoxes[i]:Hide();
		end
	else
		for i = 2,8 do
			SC_Filters.raceCheckBoxes[i]:Show();
		end
	end

	SC_Filters.raceCheckBoxes[1]:HookScript("PostClick", function()
		if (SC_Filters.raceCheckBoxes[1]:GetChecked()) then
			for i = 2,8 do
				SC_Filters.raceCheckBoxes[i]:Hide();
			end
		else
			for i = 2,8 do
				SC_Filters.raceCheckBoxes[i]:Show();
			end
		end
	end)


	local function GetFilterData()
		local FilterName = SC_EditBoxName:GetText();
		SC_EditBoxName:SetText("");
		if (not FilterName or strlen(FilterName) < 1) then
			return;
		end
		SC:debug("Filter name: "..FilterName);
		local V,C = SC_EditBoxVC:GetText();
		if (V and strlen(V) > 1) then
			V,C = strsplit(":", V);
			V = tonumber(V);
			C = tonumber(C);
			if (V == "") then V = nil end
			if (C == "") then C = nil end
			SC:debug("Max Vowels: "..(V or "N/A")..", Max Consonants: "..(C or "N/A"));
		end
		SC_EditBoxVC:SetText("");
		local Min,Max = SC_EditBoxLvl:GetText();
		if (Min and strlen(Min) > 1) then
			Min, Max = strsplit(":",Min);
			Min = tonumber(Min);
			Max = tonumber(Max);
			SC:debug("Level range: "..Min.." - "..Max);
		end
		SC_EditBoxLvl:SetText("");

		local ExceptionName = SC_EditBoxNameFilter:GetText()
		if (ExceptionName == "") then
			ExceptionName = nil;
		end
		SC_EditBoxNameFilter:SetText("");



		local classes = {};
		if (not SC_Filters.classCheckBoxes[1]:GetChecked()) then
			for k,_ in pairs(SC_Filters.classCheckBoxes) do
				if (SC_Filters.classCheckBoxes[k]:GetChecked()) then
					classes[CLASS[SC_Filters.classCheckBoxes[k].label:GetText()]] = true;
					SC:debug(CLASS[SC_Filters.classCheckBoxes[k].label:GetText()]);
					SC_Filters.classCheckBoxes[k]:SetChecked(false);
				end
			end
		end

		local races = {}
		if (not SC_Filters.raceCheckBoxes[1]:GetChecked()) then
			for k,_ in pairs(SC_Filters.raceCheckBoxes) do
				if (SC_Filters.raceCheckBoxes[k]:GetChecked()) then
					races[SC_Filters.raceCheckBoxes[k].label:GetText()] = true;
					SC:debug(SC_Filters.raceCheckBoxes[k].label:GetText());
					SC_Filters.raceCheckBoxes[k]:SetChecked(false);
				end
			end
		end
		SC:CreateFilter(FilterName,classes,ExceptionName,Min,Max,races,V,C);
		SC_FilterHandle.needRedraw = true;
		return true;
	end

	anchor = {
		point = "BOTTOM",
		relativePoint = "BOTTOM",
		xOfs = -60,
		yOfs = 20,
	}


	SC_Filters.button1 = CreateButton("BUTTON_SAVE_FILTER", SC_Filters, 120, 30, SC.L["Save"], anchor, GetFilterData);
		anchor.xOfs = 60;
	SC_Filters.button2 = CreateButton("BUTTON_CANCEL_FILTER", SC_Filters, 120, 30, SC.L["Back"], anchor, function() SC_Filters:Hide() end);

	SC_Filters:HookScript("OnHide", function() SC:ShowFilterHandle() SC_FilterHandle.showOpt = true end);

end

local function ShowFilterFrame()
	if (not SC_Filters) then
		CreateFilterFrame();
	end
	SC_Filters:Show();
end


local function CreateFilterHandleFrame()
	CreateFrame("Frame","SC_FilterHandle")
	SC_FilterHandle:SetWidth(450)
	SC_FilterHandle:SetHeight(350)
	SetFramePosition(SC_FilterHandle)
	SC_FilterHandle:SetMovable(true)
	SC_FilterHandle:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SC_FilterHandle:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(SC_FilterHandle)
	end)
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SC_FilterHandle:SetBackdrop(backdrop)
	local close = CreateFrame("Button",nil,SC_FilterHandle,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SC_FilterHandle,"TOPRIGHT",-4,-4)

	SC_FilterHandle.title = SC_FilterHandle:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SC_FilterHandle.title:SetText("Filters")
	SC_FilterHandle.title:SetPoint("TOP",SC_FilterHandle,"TOP",0,-15)
	SC_FilterHandle.underTitle = SC_FilterHandle:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	SC_FilterHandle.underTitle:SetText("Click to toggle");
	SC_FilterHandle.underTitle:SetPoint("TOP", SC_FilterHandle, "TOP", 0, -35);

	local anchor = {}
			anchor.point = "BOTTOM"
			anchor.relativePoint = "BOTTOM"
			anchor.xOfs = -60
			anchor.yOfs = 30

	SC_FilterHandle.button1 = CreateButton("BUTTON_EDIT_FILTERS", SC_FilterHandle, 120, 30, SC.L["Add filters"], anchor, function() ShowFilterFrame() SC_FilterHandle.showOpt = false SC_FilterHandle.showSelf = true SC_FilterHandle:Hide() end);
		anchor.xOfs = 60
	SC_FilterHandle.button2 = CreateButton("BUTTON_EDIT_FILTERS", SC_FilterHandle, 120, 30, SC.L["Back"], anchor, function() close:Click() end);


	SC_FilterHandle.tooltip = CreateFrame("Frame", "SC_HandleTooltip", SC_FilterHandle, "GameTooltipTemplate");
	SC_FilterHandle.tooltip:SetWidth(150);
	SC_FilterHandle.tooltip.text = SC_FilterHandle.tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	SC_FilterHandle.tooltip.text:SetPoint("CENTER", SC_FilterHandle.tooltip, "CENTER", 0, 0);
	SC_FilterHandle.tooltip.text:SetJustifyH("LEFT");

	local function FormatTooltipFilterText(filter)
		local text = "Filter name: "..filter.nameOfFilter.."\n";

		if (filter.active) then
			text = text.."|cff00ff00[ACTIVE]|r\n";
		else
			text = text.."|cffff0000[INACTIVE]|r\n";
		end

		if (filter.class) then
			for k,v in pairs(filter.class) do
				text = text.."|cff"..(SC:GetClassColor(k)..k).."|r\n";
			end
		end

		if (filter.race) then
			for k,v in pairs(filter.race) do
				text = text.."|cff16ABB5"..k.."|r\n";
			end
		end

		if (filter.minLvl and filter.minLvl ~= "") then
			text = text.."|cff00ff00"..filter.minLvl.."|r - ";
			if (filter.maxLvl) then
				text = text.."|cffff0000"..filter.maxLvl.."|r\n";
			else
				text = text.."\n";
			end
		end

		if (filter.maxVowels and filter.maxVowels ~= "") then
			text = text.."Vowels: |cff16ABB5"..filter.maxVowels.."|r\n";
		end

		if (filter.maxConsonants and filter.maxVowels ~= "") then
			text = text.."Consonants: |cff16ABB5"..filter.maxConsonants.."|r\n";
		end

		if (filter.name and filter.name ~= "") then
			text = text.."Name exception: |cff16ABB5"..filter.name.."|r";
		end

		return text;
	end

	SC_FilterHandle.filterFrames = {}
	SC_FilterHandle.update = 0;
	SC_FilterHandle.needRedraw = false;
	SC_FilterHandle:SetScript("OnUpdate", function(self)
		if (SC_FilterHandle.update < GetTime()) then

			local anchor = {}
				anchor.xOfs = -175
				anchor.yOfs = 110

			local F = SC_DATA[SC_DATA_INDEX].settings.filters;

			if (SC_FilterHandle.needRedraw) then
				for k,_ in pairs(SC_FilterHandle.filterFrames) do
					SC_FilterHandle.filterFrames[k]:Hide();
				end
				SC_FilterHandle.filterFrames = {};
				SC_FilterHandle.needRedraw = false;
			end

			for k,_ in pairs(F) do
				if (not SC_FilterHandle.filterFrames[k]) then
					SC_FilterHandle.filterFrames[k] = CreateFrame("Button", "FilterFrame"..k, SC_FilterHandle);
					SC_FilterHandle.filterFrames[k]:SetWidth(80)
					SC_FilterHandle.filterFrames[k]:SetHeight(25);
					SC_FilterHandle.filterFrames[k]:EnableMouse(true);
					SC_FilterHandle.filterFrames[k]:SetPoint("CENTER", SC_FilterHandle, "CENTER", anchor.xOfs, anchor.yOfs);
					if mod(k,5) == 0 then
						anchor.xOfs = -175
						anchor.yOfs = anchor.yOfs - 30
					else
						anchor.xOfs = anchor.xOfs + 85
					end
					SC_FilterHandle.filterFrames[k].text = SC_FilterHandle.filterFrames[k]:CreateFontString(nil, "OVERLAY", "GameFontNormal");
					SC_FilterHandle.filterFrames[k].text:SetPoint("LEFT", SC_FilterHandle.filterFrames[k], "LEFT", 3, 0);
					SC_FilterHandle.filterFrames[k].text:SetJustifyH("LEFT");
					SC_FilterHandle.filterFrames[k].text:SetWidth(75);
					SC_FilterHandle.filterFrames[k]:EnableMouse(true);
					SC_FilterHandle.filterFrames[k]:RegisterForClicks("LeftButtonDown","RightButtonDown");
					SC_FilterHandle.filterFrames[k].highlight = SC_FilterHandle.filterFrames[k]:CreateTexture();
					SC_FilterHandle.filterFrames[k].highlight:SetAllPoints();
					if (SC_DATA[SC_DATA_INDEX].settings.filters[k].active) then
						SC_FilterHandle.filterFrames[k].highlight:SetTexture(0,1,0,0.2);
					else
						SC_FilterHandle.filterFrames[k].highlight:SetTexture(1,0,0,0.2);
					end
					SC_FilterHandle.filterFrames[k]:SetScript("OnEnter", function(self)
						self.highlight:SetTexture(1,1,0,0.2);
						SC:debug("Enter: YELLOW");

						SC_FilterHandle.tooltip.text:SetText(FormatTooltipFilterText(F[k]));
						SC_FilterHandle.tooltip:SetPoint("TOP", self, "BOTTOM", 0, -3);
						SC_FilterHandle.tooltip:SetHeight(SC_FilterHandle.tooltip.text:GetHeight() + 12);
						SC_FilterHandle.tooltip:SetWidth(SC_FilterHandle.tooltip.text:GetWidth() + 10);
						SC_FilterHandle.tooltip:Show();
					end)
					SC_FilterHandle.filterFrames[k]:SetScript("OnLeave", function(self)
						if (F[k] and F[k].active) then--SC_FilterHandle.filterFrames[k].state) then
							SC_FilterHandle.filterFrames[k].highlight:SetTexture(0,1,0,0.2);
							SC:debug("Leave: GREEN");

						else
							SC_FilterHandle.filterFrames[k].highlight:SetTexture(1,0,0,0.2);
							SC:debug("Leave: RED");
						end

						SC_FilterHandle.tooltip:Hide();
					end)
				end

				SC_FilterHandle.filterFrames[k].filter = F[k];
				SC_FilterHandle.filterFrames[k].text:SetText(F[k].nameOfFilter);
				SC_FilterHandle.filterFrames[k]:Show();

				SC_FilterHandle.filterFrames[k]:SetScript("OnClick", function(self, button)
					SC:debug(button);
					if (button == "LeftButton") then
						if (SC_DATA[SC_DATA_INDEX].settings.filters[k].active) then
							SC_DATA[SC_DATA_INDEX].settings.filters[k].active = nil;
							SC_FilterHandle.filterFrames[k].highlight:SetTexture(1,0,0,0.2);
							SC:debug("Click: RED");
						else
							SC_DATA[SC_DATA_INDEX].settings.filters[k].active = true;
							SC_FilterHandle.filterFrames[k].highlight:SetTexture(0,1,0,0.2);
							SC:debug("Click: GREEN");
						end

						SC_FilterHandle.tooltip.text:SetText(FormatTooltipFilterText(F[k]));
						SC_FilterHandle.tooltip:SetPoint("TOP", self, "BOTTOM", 0, -3);
						SC_FilterHandle.tooltip:SetHeight(SC_FilterHandle.tooltip.text:GetHeight() + 12);
						SC_FilterHandle.tooltip:SetWidth(SC_FilterHandle.tooltip.text:GetWidth() + 10);
						SC_FilterHandle.tooltip:Show();
					else
						SC_DATA[SC_DATA_INDEX].settings.filters[k] = nil;
						SC_FilterHandle.needRedraw = true;
					end

				end)

			end

			SC_FilterHandle.update = GetTime() + 1;
		end
	end)
	SC_FilterHandle.showOpt = true;
	SC_FilterHandle:HookScript("OnHide", function() if SC_FilterHandle.showOpt then SC:ShowOptions() end end)
end

function SC:ShowFilterHandle()
	if (not SC_FilterHandle) then
		CreateFilterHandleFrame();
	end
	SC_FilterHandle:Show()
end

local function ChangeLog()
	CreateFrame("Frame","SC_ChangeLog")
	SC_ChangeLog:SetWidth(550)
	SC_ChangeLog:SetHeight(350)
	SC_ChangeLog:SetBackdrop(
	{
		bgFile = "Interface/ACHIEVEMENTFRAME/UI-Achievement-Parchment-Horizontal",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = false,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	)
	SetFramePosition(SC_ChangeLog)

	local anchor = {}
			anchor.point = "BOTTOMRIGHT"
			anchor.relativePoint = "BOTTOMRIGHT"
			anchor.xOfs = -210
			anchor.yOfs = 10

	SC_ChangeLog.check1 = CreateCheckbox("SC_CHANGES",SC_ChangeLog,SC.L["Don't show this after new updates"],anchor)
		anchor.xOfs = -300
	SC_ChangeLog.button1 = CreateButton("SC_CLOSE_CHANGES",SC_ChangeLog,120,30,SC.L["Close"],anchor,function() SC_ChangeLog:Hide() SC_DATA.showChanges = SC.VERSION_MAJOR end)

	SC_ChangeLog.title = SC_ChangeLog:CreateFontString()
	SC_ChangeLog.title:SetFont("Fonts\\FRIZQT__.TTF",22,"OUTLINE")
	SC_ChangeLog.title:SetText("|cffffff00<|r|cff16ABB5Shadow Collective Recruiter|r|cff00ff00 Recent Changes|r|cffffff00>|r|cffffff00")
	SC_ChangeLog.title:SetPoint("TOP",SC_ChangeLog,"TOP",0,-12)

	SC_ChangeLog.version = SC_ChangeLog:CreateFontString()
	SC_ChangeLog.version:SetFont("Fonts\\FRIZQT__.TTF",16,"OUTLINE")
	SC_ChangeLog.version:SetPoint("TOPLEFT",SC_ChangeLog,"TOPLEFT",15,-40)
	SC_ChangeLog.version:SetText("")

	SC_ChangeLog.items = {}
	local y = -65
	for i = 1,10 do
		SC_ChangeLog.items[i] = SC_ChangeLog:CreateFontString()
		SC_ChangeLog.items[i]:SetFont("Fonts\\FRIZQT__.TTF",14,"OUTLINE")
		SC_ChangeLog.items[i]:SetPoint("TOPLEFT",SC_ChangeLog,"TOPLEFT",30,y)
		SC_ChangeLog.items[i]:SetText("")
		SC_ChangeLog.items[i]:SetJustifyH("LEFT")
		SC_ChangeLog.items[i]:SetSpacing(3)
		y = y - 17
	end
	SC_ChangeLog.SetChange = function(changes)
		local Y = -65
		SC_ChangeLog.version:SetText("|cff16ABB5"..changes.version.."|r")
		for k,_ in pairs(changes.items) do
			SC_ChangeLog.items[k]:SetText("|cffffff00"..changes.items[k].."|r")
			SC_ChangeLog.items[k]:SetWidth(490)
			SC_ChangeLog.items[k]:SetPoint("TOPLEFT",SC_ChangeLog,"TOPLEFT",30,Y)
			Y = Y - SC_ChangeLog.items[k]:GetHeight() - 5
		end
	end
end

function SC:ShowChanges()
	if ( SC_ChangeLog ) then
		SC_ChangeLog:Show()
	else
		ChangeLog()
		SC_ChangeLog:Show()
	end
	SC_ChangeLog.SetChange(SC.versionChanges);
end


local function CreateTroubleShooter()
	CreateFrame("Frame","SC_TroubleShooter")
	SC_TroubleShooter:SetWidth(300)
	SC_TroubleShooter:SetHeight(100)
	SetFramePosition(SC_TroubleShooter)
	SC_TroubleShooter:SetMovable(true)
	SC_TroubleShooter:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SC_TroubleShooter:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(SC_TroubleShooter)
	end)
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SC_TroubleShooter:SetBackdrop(backdrop)
	local close = CreateFrame("Button",nil,SC_TroubleShooter,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SC_TroubleShooter,"TOPRIGHT",-4,-4)

	SC_TroubleShooter.title = SC_TroubleShooter:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SC_TroubleShooter.title:SetPoint("TOP",SC_TroubleShooter,"TOP",0,-10)
	SC_TroubleShooter.title:SetText("Common issues")


	local update = 0;

	SC_TroubleShooter.items = {};
	SC_TroubleShooter:SetScript("OnUpdate", function()
		if (update < GetTime()) then




			update = GetTime() + 0.5;
		end
	end)


	SC_TroubleShooter:HookScript("OnHide", function() if (SC_Options.showAgain) then SC_Options:Show() SC_Options.showAgain = false end end);
end

function SC:ShowTroubleShooter()
	if (not SC_TroubleShooter) then
		CreateTroubleShooter();
	end
	SC_TroubleShooter:Show();
end


local function OptBtn2_OnClick()
	SC:ShowSuperScanFrame();
	SSBtn3_OnClick(SC_SUPERSCAN_PLAYPAUSE2);
end


local function CreateOptions()
	CreateFrame("Frame","SC_Options")
	SC_Options:SetWidth(550)
	SC_Options:SetHeight(350)
	SetFramePosition(SC_Options)
	SC_Options:SetMovable(true)
	SC_Options:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SC_Options:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(SC_Options)
	end)
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SC_Options:SetBackdrop(backdrop)
	local close = CreateFrame("Button",nil,SC_Options,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SC_Options,"TOPRIGHT",-4,-4)

	SC_Options.title = SC_Options:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SC_Options.title:SetText("Shadow Collective Recruiter "..SC.VERSION_MAJOR..SC.VERSION_MINOR.." Options")
	SC_Options.title:SetPoint("TOP",SC_Options,"TOP",0,-15)
	SC_Options.bottom = SC_Options:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SC_Options.bottom:SetText("Written by Nimueh - Eldre'Thalas - US")
	SC_Options.bottom:SetPoint("BOTTOM",SC_Options,"BOTTOM",0,1)

	SC_Options.optionHelpText = SC_Options:CreateFontString(nil, "OVERLAY","GameFontNormal");
	SC_Options.optionHelpText:SetText("|cff00D2FFScroll to change levels|r");
	SC_Options.optionHelpText:SetPoint("TOP",SC_Options,"TOP",100,-40);

	local anchor = {}
			anchor.point = "TOPLEFT"
			anchor.relativePoint = "TOPLEFT"
			anchor.xOfs = 7
			anchor.yOfs = -50

	local WhisperMode = {
		SC.L["Invite only"],
		SC.L["Invite, then whisper"],
		SC.L["Whisper only"],
	}

	local spacing = 25;

	SC_Options.dropDown1 = CreateDropDown("DROPDOWN_INVITE_MODE", SC_Options, SC.L["Invite Mode"], WhisperMode, anchor);
		anchor.yOfs = anchor.yOfs - spacing - 7;
		anchor.xOfs = anchor.xOfs + 13;
	SC_Options.checkBox1 = CreateCheckbox("CHECKBOX_SC_MUTE", SC_Options, SC.L["Mute SC"], anchor);
		anchor.yOfs = anchor.yOfs - spacing;
	SC_Options.checkBox2 = CreateCheckbox("CHECKBOX_ADV_SCAN", SC_Options, SC.L["Advanced scan options"], anchor);
		anchor.yOfs = anchor.yOfs - spacing;
	SC_Options.checkBox3 = CreateCheckbox("CHECKBOX_HIDE_SYSTEM", SC_Options, SC.L["Hide system messages"], anchor);
		anchor.yOfs = anchor.yOfs - spacing;
	SC_Options.checkBox7 = CreateCheckbox("CHECKBOX_HIDE_WHISPER", SC_Options, SC.L["Hide outgoing whispers"], anchor);
		anchor.yOfs = anchor.yOfs - spacing;
	SC_Options.checkBox4 = CreateCheckbox("CHECKBOX_HIDE_MINIMAP", SC_Options, SC.L["Hide minimap button"], anchor);
		anchor.yOfs = anchor.yOfs - spacing;
	SC_Options.checkBox5 = CreateCheckbox("CHECKBOX_BACKGROUND_MODE", SC_Options, SC.L["Run SuperScan in the background"], anchor);
		anchor.yOfs = anchor.yOfs - spacing;
	SC_Options.checkBox6 = CreateCheckbox("CHECKBOX_ENABLE_FILTERS", SC_Options, SC.L["Enable filtering"], anchor);

	SC_Options.checkBox3:HookScript("PostClick", function(self) ChatIntercept:StateSystem(self:GetChecked()) end);
	SC_Options.checkBox7:HookScript("PostClick", function(self) ChatIntercept:StateWhisper(self:GetChecked()) end);

		anchor.point = "BOTTOMLEFT"
		anchor.relativePoint = "BOTTOMLEFT"
		anchor.xOfs = 20
		anchor.yOfs = 45

	--onClickTester
	SC_Options.button1 = CreateButton("BUTTON_CUSTOM_WHISPER", SC_Options, 120, 30, SC.L["Customize whisper"], anchor, function(self) ShowWhisperFrame() SC_Options:Hide() SC_Options.showAgain = true end);
		anchor.xOfs = anchor.xOfs + 125;
	SC_Options.button2 = CreateButton("BUTTON_SUPER_SCAN", SC_Options, 120, 30, SC.L["SuperScan"], anchor, OptBtn2_OnClick);
		anchor.xOfs = anchor.xOfs + 125;
	SC_Options.button3 = CreateButton("BUTTON_INVITE", SC_Options, 120, 30, format(SC.L["Invite: %d"],SC:GetNumQueued()), anchor, SC.SendGuildInvite);
		anchor.xOfs = anchor.xOfs + 125;
	SC_Options.button4 = CreateButton("BUTTON_CHOOSE_INVITES", SC_Options, 120, 30, SC.L["Choose invites"], anchor, SC.ShowInviteList);
		anchor.yOfs = 80;
	SC_Options.button5 = CreateButton("BUTTON_EDIT_FILTERS", SC_Options, 120, 30, SC.L["Filters"], anchor, function() SC:ShowFilterHandle() SC_Options:Hide() end);
		anchor.xOfs = anchor.xOfs - 125;
	--SC_Options.button6 = CreateButton("BUTTON_HELP", SC_Options, 120, 30, SC.L["Help"],anchor, function() SC:ShowTroubleShooter() SC_Options:Hide() SC_Options.showAgain = true end);
		--anchor.xOfs = anchor.xOfs - 125;
	SC_Options.button7 = CreateButton("BUTTON_KEYBIND", SC_Options, 120, 30, SC.L["Set Keybind ("..(SC_DATA[SC_DATA_INDEX].keyBind and SC_DATA[SC_DATA_INDEX].keyBind or "NONE")..")"], anchor, KeyHarvestFrame.GetNewKeybindKey);
		anchor.xOfs = anchor.xOfs - 125;
	--SC_Options.button8 = CreateButton("BUTTON_FILTER", SC_Options, 120, 30, SC.L["Filters"], anchor, onClickTester);


	SC_Options.limitLow = CreateFrame("Frame","SC_LowLimit",SC_Options)
	SC_Options.limitLow:SetWidth(40)
	SC_Options.limitLow:SetHeight(40)
	SC_Options.limitLow:SetPoint("CENTER",SC_Options,"CENTER",20,80)
	SC_Options.limitLow.text = SC_Options.limitLow:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SC_Options.limitLow.text:SetPoint("CENTER")
	SC_Options.limitLow.texture = SC_Options.limitLow:CreateTexture()
	SC_Options.limitLow.texture:SetAllPoints()
	SC_Options.limitLow.texture:SetTexture(1,1,0,0.2)
	SC_Options.limitLow.texture:Hide()
	SC_Options.limitTooltip = CreateFrame("Frame","LimitTool",SC_Options.limitLow,"GameTooltipTemplate")

	SC_Options.limitTooltip:SetPoint("TOP",SC_Options.limitLow,"BOTTOM")
	SC_Options.limitTooltip.text = SC_Options.limitTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Options.limitTooltip.text:SetPoint("LEFT",SC_Options.limitTooltip,"LEFT",12,0)
	SC_Options.limitTooltip.text:SetJustifyH("LEFT")
	SC_Options.limitTooltip.text:SetText(SC.L["Highest and lowest level to search for"])
	SC_Options.limitTooltip.text:SetWidth(115)
	SC_Options.limitTooltip:SetWidth(130)
	SC_Options.limitTooltip:SetHeight(SC_Options.limitTooltip.text:GetHeight() + 12)

	SC_Options.limitLow:SetScript("OnEnter",function()
		SC_Options.limitLow.texture:Show()
		SC_Options.limitTooltip:Show()
	end)
	SC_Options.limitLow:SetScript("OnLeave",function()
		SC_Options.limitLow.texture:Hide()
		SC_Options.limitTooltip:Hide()
	end)

	SC_Options.limitHigh = CreateFrame("Frame","SC_HighLimit",SC_Options)
	SC_Options.limitHigh:SetWidth(40)
	SC_Options.limitHigh:SetHeight(40)
	SC_Options.limitHigh:SetPoint("CENTER",SC_Options,"CENTER",60,80)
	SC_Options.limitHigh.text = SC_Options.limitHigh:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SC_Options.limitHigh.text:SetPoint("CENTER")
	SC_Options.limitHigh.texture = SC_Options.limitHigh:CreateTexture()
	SC_Options.limitHigh.texture:SetAllPoints()
	SC_Options.limitHigh.texture:SetTexture(1,1,0,0.2)
	SC_Options.limitHigh.texture:Hide()

	SC_Options.limitHigh:SetScript("OnEnter",function()
		SC_Options.limitHigh.texture:Show()
		SC_Options.limitTooltip:Show()
	end)
	SC_Options.limitHigh:SetScript("OnLeave",function()
		SC_Options.limitHigh.texture:Hide()
		SC_Options.limitTooltip:Hide()
	end)

	SC_Options.limitLow.text:SetText(SC_DATA[SC_DATA_INDEX].settings.lowLimit.."  - ")
	SC_Options.limitLow:SetScript("OnMouseWheel",function(self,delta)
		if delta == 1 and SC_DATA[SC_DATA_INDEX].settings.lowLimit + 1 <= SC_DATA[SC_DATA_INDEX].settings.highLimit then
			SC_DATA[SC_DATA_INDEX].settings.lowLimit = SC_DATA[SC_DATA_INDEX].settings.lowLimit + 1
			SC_Options.limitLow.text:SetText(SC_DATA[SC_DATA_INDEX].settings.lowLimit.." - ")
		elseif delta == -1 and SC_DATA[SC_DATA_INDEX].settings.lowLimit - 1 >= SC_MIN_LEVEL_SUPER_SCAN then
			SC_DATA[SC_DATA_INDEX].settings.lowLimit = SC_DATA[SC_DATA_INDEX].settings.lowLimit - 1
			SC_Options.limitLow.text:SetText(SC_DATA[SC_DATA_INDEX].settings.lowLimit.." - ")
		end
	end)

	SC_Options.limitHigh.text:SetText(SC_DATA[SC_DATA_INDEX].settings.highLimit)
	SC_Options.limitHigh:SetScript("OnMouseWheel",function(self,delta)
		if delta == 1 and SC_DATA[SC_DATA_INDEX].settings.highLimit + 1 <= SC_MAX_LEVEL_SUPER_SCAN then
			SC_DATA[SC_DATA_INDEX].settings.highLimit = SC_DATA[SC_DATA_INDEX].settings.highLimit + 1
			SC_Options.limitHigh.text:SetText(SC_DATA[SC_DATA_INDEX].settings.highLimit)
		elseif delta == -1 and SC_DATA[SC_DATA_INDEX].settings.highLimit > SC_DATA[SC_DATA_INDEX].settings.lowLimit then
			SC_DATA[SC_DATA_INDEX].settings.highLimit = SC_DATA[SC_DATA_INDEX].settings.highLimit - 1
			SC_Options.limitHigh.text:SetText(SC_DATA[SC_DATA_INDEX].settings.highLimit)
		end
	end)

	SC_Options.limitText = SC_Options.limitLow:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Options.limitText:SetPoint("BOTTOM",SC_Options.limitLow,"TOP",16,3)
	SC_Options.limitText:SetText(SC.L["Level limits"])

	SC_Options.raceLimitHigh = CreateFrame("Frame","SC_RaceLimitHigh",SC_Options)
	SC_Options.raceLimitHigh:SetWidth(40)
	SC_Options.raceLimitHigh:SetHeight(40)
	SC_Options.raceLimitHigh:SetPoint("CENTER",SC_Options,"CENTER",150,80)
	SC_Options.raceLimitHigh.text = SC_Options.raceLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SC_Options.raceLimitHigh.text:SetPoint("CENTER")
	SC_Options.raceLimitHigh.texture = SC_Options.raceLimitHigh:CreateTexture()
	SC_Options.raceLimitHigh.texture:SetAllPoints()
	SC_Options.raceLimitHigh.texture:SetTexture(1,1,0,0.2)
	SC_Options.raceLimitHigh.texture:Hide()
	SC_Options.raceTooltip = CreateFrame("Frame","LimitTool",SC_Options.raceLimitHigh,"GameTooltipTemplate")

	SC_Options.raceTooltip:SetPoint("TOP",SC_Options.raceLimitHigh,"BOTTOM")
	SC_Options.raceTooltip.text = SC_Options.raceTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Options.raceTooltip.text:SetPoint("LEFT",SC_Options.raceTooltip,"LEFT",12,0)
	SC_Options.raceTooltip.text:SetJustifyH("LEFT")
	SC_Options.raceTooltip.text:SetText(SC.L["The level you wish to start dividing the search by race"])
	SC_Options.raceTooltip.text:SetWidth(110)
	SC_Options.raceTooltip:SetWidth(125)
	SC_Options.raceTooltip:SetHeight(SC_Options.raceTooltip.text:GetHeight() + 12)

	SC_Options.raceLimitText = SC_Options.raceLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Options.raceLimitText:SetPoint("BOTTOM",SC_Options.raceLimitHigh,"TOP",0,3)
	SC_Options.raceLimitText:SetText(SC.L["Racefilter Start:"])

	SC_Options.raceLimitHigh.text:SetText(SC_DATA[SC_DATA_INDEX].settings.raceStart)
	SC_Options.raceLimitHigh:SetScript("OnMouseWheel",function(self,delta)
		if delta == -1 and SC_DATA[SC_DATA_INDEX].settings.raceStart > 1 then
			SC_DATA[SC_DATA_INDEX].settings.raceStart = SC_DATA[SC_DATA_INDEX].settings.raceStart - 1
			SC_Options.raceLimitHigh.text:SetText(SC_DATA[SC_DATA_INDEX].settings.raceStart)
		elseif delta == 1 and SC_DATA[SC_DATA_INDEX].settings.raceStart < SC_MAX_LEVEL_SUPER_SCAN + 1 then
			SC_DATA[SC_DATA_INDEX].settings.raceStart = SC_DATA[SC_DATA_INDEX].settings.raceStart + 1
			SC_Options.raceLimitHigh.text:SetText(SC_DATA[SC_DATA_INDEX].settings.raceStart)
			if SC_DATA[SC_DATA_INDEX].settings.raceStart > SC_MAX_LEVEL_SUPER_SCAN then
				SC_Options.raceLimitHigh.text:SetText(SC.L["OFF"])
			end
		end
	end)

	SC_Options.raceLimitHigh:SetScript("OnEnter",function()
		SC_Options.raceLimitHigh.texture:Show()
		SC_Options.raceTooltip:Show()
	end)
	SC_Options.raceLimitHigh:SetScript("OnLeave",function()
		SC_Options.raceLimitHigh.texture:Hide()
		SC_Options.raceTooltip:Hide()
	end)

	SC_Options.classLimitHigh = CreateFrame("Frame","SC_ClassLimitHigh",SC_Options)
	SC_Options.classLimitHigh:SetWidth(40)
	SC_Options.classLimitHigh:SetHeight(40)
	SC_Options.classLimitHigh:SetPoint("CENTER",SC_Options,"CENTER",150,10)
	SC_Options.classLimitHigh.text = SC_Options.classLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SC_Options.classLimitHigh.text:SetPoint("CENTER")
	SC_Options.classLimitHigh.texture = SC_Options.classLimitHigh:CreateTexture()
	SC_Options.classLimitHigh.texture:SetAllPoints()
	SC_Options.classLimitHigh.texture:SetTexture(1,1,0,0.2)
	SC_Options.classLimitHigh.texture:Hide()
	SC_Options.classTooltip = CreateFrame("Frame","LimitTool",SC_Options.classLimitHigh,"GameTooltipTemplate")

	SC_Options.classTooltip:SetPoint("TOP",SC_Options.classLimitHigh,"BOTTOM")
	SC_Options.classTooltip.text = SC_Options.classTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Options.classTooltip.text:SetPoint("LEFT",SC_Options.classTooltip,"LEFT",12,0)
	SC_Options.classTooltip.text:SetJustifyH("LEFT")
	SC_Options.classTooltip.text:SetText(SC.L["The level you wish to divide the search by class"])
	SC_Options.classTooltip.text:SetWidth(110)

	SC_Options.classTooltip:SetWidth(125)
	SC_Options.classTooltip:SetHeight(SC_Options.classTooltip.text:GetHeight() + 12)

	SC_Options.classLimitText = SC_Options.classLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Options.classLimitText:SetPoint("BOTTOM",SC_Options.classLimitHigh,"TOP",0,3)
	SC_Options.classLimitText:SetText(SC.L["Classfilter Start:"])

	SC_Options.classLimitHigh.text:SetText(SC_DATA[SC_DATA_INDEX].settings.classStart)
	SC_Options.classLimitHigh:SetScript("OnMouseWheel",function(self,delta)
		if delta == -1 and SC_DATA[SC_DATA_INDEX].settings.classStart > 1 then
			SC_DATA[SC_DATA_INDEX].settings.classStart = SC_DATA[SC_DATA_INDEX].settings.classStart - 1
			SC_Options.classLimitHigh.text:SetText(SC_DATA[SC_DATA_INDEX].settings.classStart)
		elseif delta == 1 and SC_DATA[SC_DATA_INDEX].settings.classStart < SC_MAX_LEVEL_SUPER_SCAN + 1 then
			SC_DATA[SC_DATA_INDEX].settings.classStart = SC_DATA[SC_DATA_INDEX].settings.classStart + 1
			SC_Options.classLimitHigh.text:SetText(SC_DATA[SC_DATA_INDEX].settings.classStart)
			if SC_DATA[SC_DATA_INDEX].settings.classStart > SC_MAX_LEVEL_SUPER_SCAN then
				SC_Options.classLimitHigh.text:SetText(SC.L["OFF"])
			end
		end
	end)

	SC_Options.classLimitHigh:SetScript("OnEnter",function()
		SC_Options.classLimitHigh.texture:Show()
		SC_Options.classTooltip:Show()
	end)
	SC_Options.classLimitHigh:SetScript("OnLeave",function()
		SC_Options.classLimitHigh.texture:Hide()
		SC_Options.classTooltip:Hide()
	end)

	SC_Options.Interval = CreateFrame("Frame","SC_Interval",SC_Options)
	SC_Options.Interval:SetWidth(40)
	SC_Options.Interval:SetHeight(40)
	SC_Options.Interval:SetPoint("CENTER",SC_Options,"CENTER",40,10)
	SC_Options.Interval.text = SC_Options.Interval:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SC_Options.Interval.text:SetPoint("CENTER")
	SC_Options.Interval.texture = SC_Options.Interval:CreateTexture()
	SC_Options.Interval.texture:SetAllPoints()
	SC_Options.Interval.texture:SetTexture(1,1,0,0.2)
	SC_Options.Interval.texture:Hide()
	SC_Options.intervalTooltip = CreateFrame("Frame","LimitTool",SC_Options.Interval,"GameTooltipTemplate")

	SC_Options.intervalTooltip:SetPoint("TOP",SC_Options.Interval,"BOTTOM")
	SC_Options.intervalTooltip.text = SC_Options.intervalTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Options.intervalTooltip.text:SetPoint("LEFT",SC_Options.intervalTooltip,"LEFT",12,0)
	SC_Options.intervalTooltip.text:SetJustifyH("LEFT")
	SC_Options.intervalTooltip.text:SetText(SC.L["Amount of levels to search every 7 seconds (higher numbers increase the risk of capping the search results)"])
	SC_Options.intervalTooltip.text:SetWidth(130)
	SC_Options.intervalTooltip:SetHeight(120)
	SC_Options.intervalTooltip:SetWidth(135)
	SC_Options.intervalTooltip:SetHeight(SC_Options.intervalTooltip.text:GetHeight() + 12)

	SC_Options.intervalText = SC_Options.Interval:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SC_Options.intervalText:SetPoint("BOTTOM",SC_Options.Interval,"TOP",0,3)
	SC_Options.intervalText:SetText(SC.L["Interval:"])

	SC_Options.Interval.text:SetText(SC_DATA[SC_DATA_INDEX].settings.interval)
	SC_Options.Interval:SetScript("OnMouseWheel",function(self,delta)
		if delta == -1 and SC_DATA[SC_DATA_INDEX].settings.interval > 1 then
			SC_DATA[SC_DATA_INDEX].settings.interval = SC_DATA[SC_DATA_INDEX].settings.interval - 1
			SC_Options.Interval.text:SetText(SC_DATA[SC_DATA_INDEX].settings.interval)
		elseif delta == 1 and SC_DATA[SC_DATA_INDEX].settings.interval < 30 then
			SC_DATA[SC_DATA_INDEX].settings.interval = SC_DATA[SC_DATA_INDEX].settings.interval + 1
			SC_Options.Interval.text:SetText(SC_DATA[SC_DATA_INDEX].settings.interval)
		end
	end)

	SC_Options.Interval:SetScript("OnEnter",function()
		SC_Options.Interval.texture:Show()
		SC_Options.intervalTooltip:Show()
	end)
	SC_Options.Interval:SetScript("OnLeave",function()
		SC_Options.Interval.texture:Hide()
		SC_Options.intervalTooltip:Hide()
	end)

	anchor = {
		point = "BOTTOMLEFT",
		relativePoint = "BOTTOMLEFT",
		xOfs = 4,
		yOfs = 4,
	}
	SC_Options.superScanText = SC_Options:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	SC_Options.superScanText:SetPoint("BOTTOMLEFT", SC_Options, "BOTTOMLEFT", 35, 10);
	SC_Options.superScanText:SetText("SuperScan");
	SC_Options.buttonPlayPause = CreateButton("SC_SUPERSCAN_PLAYPAUSE2", SC_Options, 40,30,"",anchor,SSBtn3_OnClick);
	SC_SUPERSCAN_PLAYPAUSE2:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
	SC_SUPERSCAN_PLAYPAUSE2:Hide();
	SC_Options.superScanText:Hide();

	SC_Options.nextUpdate = 0;
	SC_Options:SetScript("OnUpdate", function()
		if (SC_Options.nextUpdate < GetTime()) then

			if SC_DATA[SC_DATA_INDEX].settings.classStart > SC_MAX_LEVEL_SUPER_SCAN then
				SC_Options.classLimitHigh.text:SetText(SC.L["OFF"])
			end

			if SC_DATA[SC_DATA_INDEX].settings.raceStart > SC_MAX_LEVEL_SUPER_SCAN then
				SC_Options.raceLimitHigh.text:SetText(SC.L["OFF"])
			end

			if (SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_BACKGROUND_MODE"]) then
				SC_SUPERSCAN_PLAYPAUSE2:Show();
				SC_Options.superScanText:Show();
				if SuperScanFrame then SuperScanFrame:Hide() end;
			else
				SC_SUPERSCAN_PLAYPAUSE2:Hide();
				SC_Options.superScanText:Hide();
				if (SC:IsScanning()) then
					SC:ShowSuperScanFrame();
				end
			end

			if (SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_ADV_SCAN"]) then
				if (not SC_Options.Interval:IsShown()) then
					SC_Options.Interval:Show();
				end
				if (not SC_Options.classLimitHigh:IsShown()) then
					SC_Options.classLimitHigh:Show();
				end
				if (not SC_Options.raceLimitHigh:IsShown()) then
					SC_Options.raceLimitHigh:Show();
				end
			else
				SC_Options.Interval:Hide();
				SC_Options.classLimitHigh:Hide();
				SC_Options.raceLimitHigh:Hide();
			end

			BUTTON_INVITE.label:SetText(format(SC.L["Invite: %d"],SC:GetNumQueued()));
			BUTTON_KEYBIND.label:SetText(SC.L["Set Keybind ("..(SC_DATA[SC_DATA_INDEX].keyBind and SC_DATA[SC_DATA_INDEX].keyBind or "NONE")..")"]);

			if (SC_DATA[SC_DATA_INDEX].debug) then
				SC_Options.title:SetText("|cffff3300(DEBUG MODE) |rShadow Collective Recruiter "..SC.VERSION_MAJOR..SC.VERSION_MINOR.." Options")
			else
				SC_Options.title:SetText("Shadow Collective Recruiter "..SC.VERSION_MAJOR..SC.VERSION_MINOR.." Options")
			end

			if (not SC_DATA[SC_DATA_INDEX].settings.checkBox["CHECKBOX_HIDE_MINIMAP"]) then
				SC:ShowMinimapButton();
			else
				SC:HideMinimapButton();
			end

			SC_Options.nextUpdate = GetTime() + 1;
		end
	end)

end

function SC:ShowOptions()
	if (not SC_Options) then
		CreateOptions();
	end
	SC_Options:Show();
end

function SC:HideOptions()
	if (SC_Options) then
		SC_Options:Hide();
	end
end


local function CreateMinimapButton()
	local f = CreateFrame("Button","SC_MiniMapButton",Minimap)
	f:SetWidth(32)
	f:SetHeight(32)
	f:SetFrameStrata("MEDIUM")
	f:SetMovable(true)
	SetFramePosition(f)

	f:SetNormalTexture("Interface\\AddOns\\SCGuildRecruiter\\media\\SC_MiniMapButton")
	f:SetPushedTexture("Interface\\AddOns\\SCGuildRecruiter\\media\\SC_MiniMapButtonPushed")
	f:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	local tooltip = CreateFrame("Frame","SC_TooltTipMini",f,"GameTooltipTemplate")
	tooltip:SetPoint("BOTTOMRIGHT",f,"TOPLEFT",0,-3)
	local toolstring = tooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	toolstring:SetPoint("TOPLEFT",tooltip,"TOPLEFT",5,-7)

	local toolstring2 = tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	local toolstring3 = tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	toolstring2:SetPoint("TOPLEFT",tooltip,"TOPLEFT",7,-33);
	toolstring3:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 7, -46);
	toolstring2:SetText(format("ETR: %s",SC:GetSuperScanTimeLeft()));
	toolstring3:SetText(format("%d%% done",floor(SC:GetPercentageDone())));

	local tUpdate = 0;
	local function UpdateTooltip()
		if (tUpdate < GetTime()) then
			toolstring:SetText(SC.LOGO..format("|cff88aaffShadow Collective Recruiter|r\n|cff16ABB5Queue: %d|r",SC:GetNumQueued()))
			toolstring2:SetText(format("ETR: %s",SC:GetSuperScanTimeLeft()));
			toolstring3:SetText(format("%d%% done",floor(SC:GetPercentageDone())));
			--SC:debug(format("ETR: %s",SC:GetSuperScanETR()));
			--SC:debug(format("%d%% done",floor(SC:GetPercentageDone())));
			tUpdate = GetTime() + 0.2;
		end
	end

	toolstring:SetText(SC.LOGO..format("|cff88aaffShadow Collective Recruiter|r\n|cff16ABB5Queue: |r|cffffff00%d|r",SC:GetNumQueued()))
	toolstring:SetJustifyH("LEFT");
	tooltip:SetWidth(max(toolstring:GetWidth(),toolstring2:GetWidth(),toolstring3:GetWidth())+ 20)
	tooltip:SetHeight(toolstring:GetHeight() + toolstring2:GetHeight() + toolstring3:GetHeight() + 15)
	tooltip:Hide()
	f:SetScript("OnEnter",function()
		toolstring:SetText(SC.LOGO..format("|cff88aaffShadow Collective Recruiter|r\n|cff16ABB5Queue: %d|r",SC:GetNumQueued()))
		tooltip:Show()
		tooltip:SetScript("OnUpdate",UpdateTooltip);
	end)
	f:SetScript("OnLeave",function()
		tooltip:Hide()
		tooltip:SetScript("OnUpdate", nil);
	end)


	local function moveButton(self)
		local centerX, centerY = Minimap:GetCenter()
		local x, y = GetCursorPosition()
		x, y = x / self:GetEffectiveScale() - centerX, y / self:GetEffectiveScale() - centerY
		centerX, centerY = math.abs(x), math.abs(y)
		centerX, centerY = (centerX / math.sqrt(centerX^2 + centerY^2)) * 85, (centerY / sqrt(centerX^2 + centerY^2)) * 85
		centerX = x < 0 and -centerX or centerX
		centerY = y < 0 and -centerY or centerY
		self:ClearAllPoints()
		self:SetPoint("CENTER", centerX, centerY)
	end

	f:SetScript("OnMouseDown",function(self,button)
		if button == "RightButton" then
			self:SetScript("OnUpdate",moveButton)
		end
	end)
	f:SetScript("OnMouseUp",function(self,button)
		self:SetScript("OnUpdate",nil)
		SaveFramePosition(self)
	end)
	f:SetScript("OnClick",function(self,button)
		if SC_Options and SC_Options:IsShown() then
			SC:HideOptions()
		else
			SC:ShowOptions()
		end
	end)
end

function SC:ShowMinimapButton()
	if (not SC_MiniMapButton) then
		CreateMinimapButton();
	end
	SC_MiniMapButton:Show();
end

function SC:HideMinimapButton()
	if (SC_MiniMapButton) then
		SC_MiniMapButton:Hide();
	end
end








SC:debug(">> GUI.lua");
