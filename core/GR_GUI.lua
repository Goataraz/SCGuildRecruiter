
local function onClickTester(self)
	if self then
		GR:print("Click on "..self:GetName());
	end
end

local function CreateButton(name, parent, width, height, label, anchor, onClick)
	local f = CreateFrame("Button", name, parent, "UIPanelButtonTemplate");
	f:SetWidth(width);
	f:SetHeight(height);
	f.label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny");
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
	local f = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate");   --ChatConfigCheckButtonTemplate     OptionsBaseCheckButtonTemplate
	f.label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny");
	f.label:SetText(label);
	f.label:SetPoint("LEFT", f, "RIGHT", 5, 1);

	if (type(anchor) == "table") then
		f:SetPoint(anchor.point,parent,anchor.relativePoint,anchor.xOfs,anchor.yOfs);
	end

	f:HookScript("OnClick", function(self)
		GR_DATA.settings.checkBox[name] = self:GetChecked()
	end)
	if GR_DATA.settings.checkBox[name] then
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
		GR_DATA.settings.dropDown[name] = self:GetID();
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
	GR_DATA.settings.dropDown[name] = GR_DATA.settings.dropDown[name] or 1
	UIDropDownMenu_SetSelectedID(f, GR_DATA.settings.dropDown[name] or 1)
	UIDropDownMenu_JustifyText(f, "LEFT")
	return f
end

local function SetFramePosition(frame)
	if (type(GR_DATA.settings.frames[frame:GetName()]) ~= "table") then
		if (frame:GetName() == "GR_MiniMapButton") then
			GR_DATA.settings.frames[frame:GetName()] = {point = "CENTER", relativePoint = "CENTER", xOfs = -31, yOfs = -31};
		else
			frame:SetPoint("CENTER");
			GR_DATA.settings.frames[frame:GetName()] = {point = "CENTER", relativePoint = "CENTER", xOfs = 0, yOfs = 0};
			return;
		end
	end
	if (frame:GetName() == "GR_MiniMapButton") then
		frame:SetPoint(
			GR_DATA.settings.frames[frame:GetName()].point,
			Minimap,
			GR_DATA.settings.frames[frame:GetName()].relativePoint,
			GR_DATA.settings.frames[frame:GetName()].xOfs,
			GR_DATA.settings.frames[frame:GetName()].yOfs
		);
	else
		frame:SetPoint(
			GR_DATA.settings.frames[frame:GetName()].point,
			UIParent,
			GR_DATA.settings.frames[frame:GetName()].relativePoint,
			GR_DATA.settings.frames[frame:GetName()].xOfs,
			GR_DATA.settings.frames[frame:GetName()].yOfs
		);
	end
end

local function SaveFramePosition(frame)
	if (type(GR_DATA.settings.frames[frame:GetName()]) ~= "table") then
		GR_DATA.settings.frames[frame:GetName()] = {};
	end
	local point, parent, relativePoint, xOfs, yOfs = frame:GetPoint();
	GR_DATA.settings.frames[frame:GetName()] = {point = point, relativePoint = relativePoint, xOfs = xOfs, yOfs = yOfs};
end
local function CreatePlayerListFrame()
	CreateFrame("Frame","GR_PlayerList", UIParent, "BasicFrameTemplate")
	
	local GR_QUEUE = GR:GetInviteQueue();
	GR_PlayerList:SetWidth(370)
	GR_PlayerList:SetHeight(20*GR:CountTable(GR_QUEUE) + 40)
	GR_PlayerList:SetMovable(true)
	SetFramePosition(GR_PlayerList)
	--GR_PlayerList:SetPoint("TOP", UIParent, "CENTER")	
		GR_PlayerList:SetScript("OnMouseDown",function(self)
			self:StartMoving()
		end)
		GR_PlayerList:SetScript("OnMouseUp",function(self)
			self:StopMovingOrSizing()
			SaveFramePosition(GR_PlayerList)
		end)
	
	
	
		
	GR_PlayerList.time = GR_PlayerList:CreateFontString(nil,"OVERLAY","GameFontNormalTiny")
	GR_PlayerList.time:SetPoint("TOP","TOP")
	GR_PlayerList.time:SetTextSetText(format("|cff00ff00%d%%|r|cffffff00 %s|r    ",0,GR:GetSuperScanETR()))
	GR_PlayerList.progressTexture = GR_PlayerList:CreateTexture();
	GR_PlayerList.progressTexture:SetPoint("LEFT", 5, 0);
	GR_PlayerList.progressTexture:SetHeight(18);
	GR_PlayerList.progressTexture:SetWidth(140);
	GR_PlayerList.progressTexture:SetTexture(1,0.5,0,0.4);
	GR_PlayerList.progressTexture:SetTexture(0,0.0,0,0.0);
	
	GR_PlayerList.text = GR_PlayerList:CreateFontString(nil,"OVERLAY","GameFontNormalTiny")
	GR_PlayerList.text:SetPoint("CCENTER",GR_PlayerList,"TOP",-15,-15)
	GR_PlayerList.text:SetText(GR.L["Left Click Name to Whisper, Right Click to Blacklist"])
	
	local close = CreateFrame("Button",nil,GR_PlayerList,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",GR_PlayerList,"TOPRIGHT",-4,-4)
	GR_PlayerList.items = {}
	local update = 0
	local toolUpdate = 0
		GR_PlayerList:SetScript("OnUpdate",function()
		if (not GR_PlayerList:IsShown() or GetTime() < update) then return end

		GR_QUEUE = GR:GetInviteQueue();

		for k,_ in pairs(GR_PlayerList.items) do
			GR_PlayerList.items[k]:Hide()
		end

		local i = 0
		local x,y = 10,-30
		for i = 1,30 do
			if not GR_PlayerList.items[i] then
				GR_PlayerList.items[i] = CreateFrame("Button","InviteBar"..i,GR_PlayerList)
				GR_PlayerList.items[i]:SetWidth(350)
				GR_PlayerList.items[i]:SetHeight(20)
				GR_PlayerList.items[i]:EnableMouse(true)
				GR_PlayerList.items[i]:SetPoint("TOP",GR_PlayerList,"TOP",0,y)
				GR_PlayerList.items[i].text = GR_PlayerList.items[i]:CreateFontString(nil,"OVERLAY","GameFontNormal")
				GR_PlayerList.items[i].text:SetPoint("LEFT",GR_PlayerList.items[i],"LEFT",3,0)
				GR_PlayerList.items[i].text:SetJustifyH("LEFT")
				GR_PlayerList.items[i].text:SetWidth(GR_PlayerList.items[i]:GetWidth()-10);
				GR_PlayerList.items[i].player = "unknown"
				GR_PlayerList.items[i]:RegisterForClicks("LeftButtonDown","RightButtonDown")
				GR_PlayerList.items[i]:SetScript("OnClick",GR.SendGuildInvite)

				GR_PlayerList.items[i].highlight = GR_PlayerList.items[i]:CreateTexture()
				GR_PlayerList.items[i].highlight:SetAllPoints()
				GR_PlayerList.items[i].highlight:SetTexture(1,1,0,0.2)
				GR_PlayerList.items[i].highlight:Hide()

				GR_PlayerList.items[i]:SetScript("OnEnter",function()
					GR_PlayerList.items[i].highlight:Show()
					--GR_PlayerList.tooltip:Show()
					GR_PlayerList.items[i]:SetScript("OnUpdate",function()
						if GetTime() > toolUpdate and GR_QUEUE[GR_PlayerList.items[i].player] then
							--GR_PlayerList.tooltip.text:SetText("Found |cff"..GR:GetClassColor(GR_QUEUE[GR_PlayerList.items[i].player].classFile)..GR_PlayerList.items[i].player.."|r "..GR:FormatTime(floor(GetTime()-GR_QUEUE[GR_PlayerList.items[i].player].found)).." ago")
							--local h,w = GR_PlayerList.tooltip.text:GetHeight(),GR_PlayerList.tooltip.text:GetWidth()
							--GR_PlayerList.tooltip:SetWidth(w+20)
							--GR_PlayerList.tooltip:SetHeight(h+20)
							--toolUpdate = GetTime() + 0.1
						end
					end)
				end)
				GR_PlayerList.items[i]:SetScript("OnLeave",function()
					GR_PlayerList.items[i].highlight:Hide()
					--GR_PlayerList.tooltip:Hide()
					GR_PlayerList.items[i]:SetScript("OnUpdate",nil)
				end)
			end
			y = y - 20
		end
		i = 0
		for k,_ in pairs(GR_QUEUE) do
			i = i + 1
			local level,classFile,race,class,found = GR_QUEUE[k].level, GR_QUEUE[k].classFile, GR_QUEUE[k].race, GR_QUEUE[k].class, GR_QUEUE[k].found
			local Text = i..". |cff"..GR:GetClassColor(classFile)..k.."|r Lvl "..level.." "..race.." |cff"..GR:GetClassColor(classFile)..class.."|r"
			GR_PlayerList.items[i].text:SetText(Text)
			GR_PlayerList.items[i].player = k
			GR_PlayerList.items[i]:Show()
			if i >= 30 then break end
		end
		GR_PlayerList:SetHeight(i * 20 + 40)
		update = GetTime() + 0.5
	end)
end

local function CreateInviteListFrame()
	CreateFrame("Frame","GR_Invites")
	local GR_QUEUE = GR:GetInviteQueue();
	GR_Invites:SetWidth(370)
	GR_Invites:SetHeight(20*GR:CountTable(GR_QUEUE) + 40)
	GR_Invites:SetMovable(true)
	SetFramePosition(GR_Invites)
	GR_Invites:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	GR_Invites:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(GR_Invites)
	end)
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 4,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	GR_Invites:SetBackdrop(backdrop)

	GR_Invites.text = GR_Invites:CreateFontString(nil,"OVERLAY","GameFontNormal")
	GR_Invites.text:SetPoint("TOP",GR_Invites,"TOP",-15,-15)
	GR_Invites.text:SetText(GR.L["Left Click Name to Whisper, Right Click to Blacklist"])
	--GR_Invites.tooltip = CreateFrame("Frame","InviteTime",GR_Invites,"GameTooltipTemplate")

		--GR_Invites.tooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
	

	--GR_Invites.tooltip.text = GR_Invites.tooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	--GR_Invites.tooltip:SetPoint("TOP",GR_Invites,"BOTTOM",0,-2)
	--GR_Invites.tooltip.text:SetText("Unknown")
	--GR_Invites.tooltip.text:SetPoint("CENTER")

	local close = CreateFrame("Button",nil,GR_Invites,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",GR_Invites,"TOPRIGHT",-4,-4)
	--local close = CreateFrame("Button",nil,GR_Invites,"UIPanelCloseButton",anchor,SSBtn3_OnClick)
	--close:SetPoint("TOPLEFT",GR_Invites,"TOPLEFT",-4,-4)
	--GR_Invites.play = CreateButton("GR_SUPERSCAN_PLAYPAUSE","",anchor,SSBtn3_OnClick)
	--GR_Invites.play:SetNormalTexture("Interface\\TimeManager\\PauseButton")
	--GR_Invites.play:SetPoint("TOPLEFT",GR_Invites,"TOPLEFT",-4,-4)
	--local play = CreateFrame("Button",nil,GR_Invites,"PauseButton")
	--play:SetPoint("TOPRIGHT",GR_Invites,"TOPRIGHT",-4,-4)
	GR_Invites.items = {}
	local update = 0
	local toolUpdate = 0
	GR_Invites:SetScript("OnUpdate",function()
		if (not GR_Invites:IsShown() or GetTime() < update) then return end

		GR_QUEUE = GR:GetInviteQueue();

		for k,_ in pairs(GR_Invites.items) do
			GR_Invites.items[k]:Hide()
		end

		local i = 0
		local x,y = 10,-30
		for i = 1,30 do
			if not GR_Invites.items[i] then
				GR_Invites.items[i] = CreateFrame("Button","InviteBar"..i,GR_Invites)
				GR_Invites.items[i]:SetWidth(350)
				GR_Invites.items[i]:SetHeight(20)
				GR_Invites.items[i]:EnableMouse(true)
				GR_Invites.items[i]:SetPoint("TOP",GR_Invites,"TOP",0,y)
				GR_Invites.items[i].text = GR_Invites.items[i]:CreateFontString(nil,"OVERLAY","GameFontNormal")
				GR_Invites.items[i].text:SetPoint("LEFT",GR_Invites.items[i],"LEFT",3,0)
				GR_Invites.items[i].text:SetJustifyH("LEFT")
				GR_Invites.items[i].text:SetWidth(GR_Invites.items[i]:GetWidth()-10);
				GR_Invites.items[i].player = "unknown"
				GR_Invites.items[i]:RegisterForClicks("LeftButtonDown","RightButtonDown")
				GR_Invites.items[i]:SetScript("OnClick",GR.SendGuildInvite)

				GR_Invites.items[i].highlight = GR_Invites.items[i]:CreateTexture()
				GR_Invites.items[i].highlight:SetAllPoints()
				GR_Invites.items[i].highlight:SetTexture(1,1,0,0.2)
				GR_Invites.items[i].highlight:Hide()

				GR_Invites.items[i]:SetScript("OnEnter",function()
					GR_Invites.items[i].highlight:Show()
					--GR_Invites.tooltip:Show()
					GR_Invites.items[i]:SetScript("OnUpdate",function()
						if GetTime() > toolUpdate and GR_QUEUE[GR_Invites.items[i].player] then
							--GR_Invites.tooltip.text:SetText("Found |cff"..GR:GetClassColor(GR_QUEUE[GR_Invites.items[i].player].classFile)..GR_Invites.items[i].player.."|r "..GR:FormatTime(floor(GetTime()-GR_QUEUE[GR_Invites.items[i].player].found)).." ago")
							--local h,w = GR_Invites.tooltip.text:GetHeight(),GR_Invites.tooltip.text:GetWidth()
							--GR_Invites.tooltip:SetWidth(w+20)
							--GR_Invites.tooltip:SetHeight(h+20)
							--toolUpdate = GetTime() + 0.1
						end
					end)
				end)
				GR_Invites.items[i]:SetScript("OnLeave",function()
					GR_Invites.items[i].highlight:Hide()
					--GR_Invites.tooltip:Hide()
					GR_Invites.items[i]:SetScript("OnUpdate",nil)
				end)
			end
			y = y - 20
		end
		i = 0
		for k,_ in pairs(GR_QUEUE) do
			i = i + 1
			local level,classFile,race,class,found = GR_QUEUE[k].level, GR_QUEUE[k].classFile, GR_QUEUE[k].race, GR_QUEUE[k].class, GR_QUEUE[k].found
			local Text = i..". |cff"..GR:GetClassColor(classFile)..k.."|r Lvl "..level.." "..race.." |cff"..GR:GetClassColor(classFile)..class.."|r"
			GR_Invites.items[i].text:SetText(Text)
			GR_Invites.items[i].player = k
			GR_Invites.items[i]:Show()
			if i >= 30 then break end
		end
		GR_Invites:SetHeight(i * 20 + 40)
		update = GetTime() + 0.5
	end)
end


function GR:ShowInviteList()
	if (not GR_Invites) then
		CreateInviteListFrame();
	end
	GR_Invites:Show();
end

function GR:HideInviteList()
	if (GR_Invites) then
		GR_Invites:Hide();
	end
end


local function SSBtn3_OnClick(self)
	if (GR:IsScanning()) then
		GR:StopSuperScan();
		self:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
	else
		GR:StartSuperScan();
		self:SetNormalTexture("Interface\\TimeManager\\PauseButton");
		GR:ShowInviteList();
	end
end

--function GR:CreateSmallSuperScanFrame()
--	CreateFrame("Frame", "SuperScanFrame");
--	SuperScanFrame:SetWidth(130);
--	SuperScanFrame:SetHeight(30);
--	local backdrop =
--	{
--		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
--		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
--		tile = true,
--		tileSize = 16,
--		edgeSize = 4,
--		insets = { left = 4, right = 4, top = 4, bottom = 4 }
--	}
--	SetFramePosition(SuperScanFrame)
--	SuperScanFrame:SetMovable(true)
--	SuperScanFrame:SetScript("OnMouseDown",function(self)
--		self:StartMoving()
--	end)
--	SuperScanFrame:SetScript("OnMouseUp",function(self)
--		self:StopMovingOrSizing()
--		SaveFramePosition(self)
--	end)
--	SuperScanFrame:SetBackdrop(backdrop)
--
--	local close = CreateFrame("Button",nil,SuperScanFrame,"UIPanelCloseButton")
--	close:SetPoint("LEFT",SuperScanFrame,"RIGHT",-5,0)
--
--	SuperScanFrame.time = SuperScanFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
--	SuperScanFrame.time:SetPoint("CENTER")
--	--SuperScanFrame.time:SetText(format("|cff00ff00%d%%|r|cffffff00 %s|r    ",0,GR:GetSuperScanETR()))
--
--
--	SuperScanFrame.progressTexture = SuperScanFrame:CreateTexture();
--	SuperScanFrame.progressTexture:SetPoint("LEFT", 5, 0);
--	SuperScanFrame.progressTexture:SetHeight(18);
--	SuperScanFrame.progressTexture:SetWidth(140);
--	SuperScanFrame.progressTexture:SetTexture(1,0.5,0,0.4);
--	SuperScanFrame.progressTexture:SetTexture(0,0.0,0,0.0);
--	local anchor = {
--		point = "TOPLEFT",
--		relativePoint = "BOTTOMLEFT",
--		xOfs = 0,
--		yOfs = 0,
--	}
--
--	SuperScanFrame.button1 = CreateButton("GR_INVITE_BUTTON2", SuperScanFrame, 70, 30, format("",GR:GetNumQueued()), anchor, GR.SendGuildInvite)
--		anchor.xOfs = 85;
--	SuperScanFrame.button2 = CreateButton("GR_PURGE_QUEUE", SuperScanFrame, 55, 30, "Clear", anchor, GR.PurgeQueue);
--		anchor.xOfs = 57;
--	SuperScanFrame.button2 = CreateButton("GR_SUPERSCAN_PLAYPAUSE", SuperScanFrame, 40,30,"",anchor,SSBtn3_OnClick);
--	GR_SUPERSCAN_PLAYPAUSE:SetNormalTexture("Interface\\TimeManager\\PauseButton");
--
--	SuperScanFrame.nextUpdate = 0;
--	SuperScanFrame:SetScript("OnUpdate", function()
--		if (SuperScanFrame.nextUpdate < GetTime()) then
--
--			SuperScanFrame.button1.label:SetText(format("Invite: %d",GR:GetNumQueued()));
--
--			if (GR:IsScanning() and SuperScanFrame.ETR and SuperScanFrame.lastETR) then
--				local remainingTime = SuperScanFrame.ETR - (GetTime() - SuperScanFrame.lastETR);
--				local totalScanTime = GR:GetTotalScanTime();
--				local percentageDone = (totalScanTime - remainingTime) / totalScanTime;
--				SuperScanFrame.time:SetText(format("|cff00ff00%d%%|r|cffffff00 %s|r",100*(percentageDone > 1 and 1 or percentageDone),GR:FormatTime(remainingTime)))
--				SuperScanFrame.progressTexture:SetWidth(120 * (percentageDone > 1 and 1 or percentageDone));
--			end
--
--			SuperScanFrame.nextUpdate = GetTime() + 0.2;
--		end
--	end)


--	SuperScanFrame:Hide();
--	-- Interface\Buttons\UI-SpellbookIcon-NextPage-Up
--	-- Interface\TimeManager\PauseButton
--end
--
--function GR:GetPercentageDone()
--	if (GR:IsScanning() and SuperScanFrame.ETR and SuperScanFrame.lastETR) then
--		local remainingTime = SuperScanFrame.ETR - (GetTime() - SuperScanFrame.lastETR);
--		local totalScanTime = GR:GetTotalScanTime();
--		local percentageDone = (totalScanTime - remainingTime) / totalScanTime;
--		return percentageDone * 100;
--	end
--	return 0;
--end
--
--function GR:GetSuperScanTimeLeft()
--	if (GR:IsScanning() and SuperScanFrame.ETR and SuperScanFrame.lastETR) then
--		return GR:FormatTime(SuperScanFrame.ETR - (GetTime() - SuperScanFrame.lastETR));
--	end
--	return 0;
--end
--
--
--function GR:ShowSuperScanFrame()
--	if (SuperScanFrame and not (GR_DATA.settings.checkBox["CHECKBOX_BACKGROUND_MODE"])) then
--		SuperScanFrame:Show();
--	else
--		if (GR_DATA.settings.checkBox["CHECKBOX_BACKGROUND_MODE"]) then
--			GR:CreateSmallSuperScanFrame();
--			SuperScanFrame:Hide();
--			return;
--		else
--			GR:CreateSmallSuperScanFrame();
--			SuperScanFrame:Show();
--		end
--
--	end
--end
--
--function GR:HideSuperScanFrame()
--	if (SuperScanFrame) then
--		SuperScanFrame:Hide();
--	end
--end
--

--Welcome Frame
local function CreateWelcomeDefineFrame()

end




--local KeyHarvestFrame = CreateFrame("Frame", "GR_KeyHarvestFrame");
--KeyHarvestFrame:SetPoint("CENTER",0,200);
--KeyHarvestFrame:SetWidth(10);
--KeyHarvestFrame:SetHeight(10);
--KeyHarvestFrame.text = KeyHarvestFrame:CreateFontString(nil, "OVERLAY", "MovieSubtitleFont");
--KeyHarvestFrame.text:SetPoint("CENTER");
--KeyHarvestFrame.text:SetText("|cff00ff00Press the KEY you wish to bind now!|r");
--KeyHarvestFrame:Hide();

--function KeyHarvestFrame:GetNewKeybindKey()
--	KeyHarvestFrame:Show();
--	self:SetScript("OnKeyDown", function(self, key)
--		if (SetBindingClick(key, "GR_INVITE_BUTTON2")) then
--			Alerter:SendAlert("|cff00ff00Successfully bound "..key.." to InviteButton!|r",1.5);
--			GR:print("Successfully bound "..key.." to InviteButton!");
--			GR_DATA.keyBind = key;
--			BUTTON_KEYBIND.label:SetText("Set Keybind ("..key..")");
--		else
--			Alerter:SendAlert("|cffff0000Error binding "..key.." to InviteButton!|r",1.5);
--			GR:print("Error binding "..key.." to InviteButton!");
--		end
--		self:EnableKeyboard(false);
--		KeyHarvestFrame:Hide();
--	end)
--	self:EnableKeyboard(true);
--
--end
local function CreateWelcomePreviewFrame()
	--Window Defaults
	CreateFrame("Frame","GR_Whisper", UIParent, "BasicFrameTemplate");
	GR_Whisper:SetSize(500,365);
	GR_Whisper:SetPoint("CENTER", UIParent, "CENTER");
	GR_Whisper:SetMovable(true)
	GR_Whisper:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	GR_Whisper:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(GR_Whisper)
	end)
	
	--Config
	local close = CreateFrame("Button",nil,GR_wPreview,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",GR_wPreview,"TOPRIGHT",-4,-4)

	GR_wPreview.title = GR_wPreview:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_wPreview.title:SetText(GR.L["GuildRecruiter Welcome Preview"])
	GR_wPreview.title:SetPoint("TOP",GR_wPreview,"TOP",0,-20)

	GR_wPreview.info = GR_wPreview:CreateFontString(nil,"OVERLAY","GameFontNormal")
	GR_wPreview.info:SetPoint("TOPLEFT",GR_wPreview,"TOPLEFT",33,-55)
	GR_wPreview.info:SetText("Welcome #"..i..": ",GR_DATA.settings.welcomes[i])
	GR_wPreview.info:SetWidth(450)
	GR_wPreview.info:SetJustifyH("LEFT")
	
end

local function ShowPreviewFrame()
	if GR_wPreview then
		GR_wPreview:Show()
	else
		CreateWelcomePreviewFrame()
		GR_wPreview:Show()
	end
end

local function HidePreviewFrame()
	if GR_wPreview then
		GR_wPreview:Hide()
	end
end
local function CreateWelcomeDefineFrame()
	--Window Defaults
	CreateFrame("Frame","GR_Welcome", UIParent, "BasicFrameTemplate");
	GR_Welcome:SetSize(500,365);
	GR_Welcome:SetPoint("CENTER", UIParent, "CENTER");
	GR_Welcome:SetMovable(true)
	GR_Welcome:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	GR_Welcome:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(GR_Welcome)
	end)
	--Config
	
	GR_Welcome.title = GR_Welcome:CreateFontString(nil, "OVERLAY");
	GR_Welcome.title:SetFontObject("GameFontHighlight");
	GR_Welcome.title:SetPoint("CENTER", GR_Welcome.TitleBg, "CENTER", 5, 0);
	GR_Welcome.title:SetText("Guild Recruiter Custom Welcome");

	GR_Welcome.info = GR_Welcome:CreateFontString(nil,"OVERLAY","GameFontHighlight")
	GR_Welcome.info:SetPoint("CENTER",GR_Welcome,"CENTER",0,115)
	GR_Welcome.info:SetText("Create a custom welcome message to be sent in guild chat to new guild members on joining.")
	GR_Welcome.info:SetWidth(450)
	GR_Welcome.info:SetJustifyH("CENTER")

	GR_Welcome.edit = CreateFrame("EditBox", "GR_Edit", GR_Welcome, "InsetFrameTemplate3")
	GR_Welcome.edit:SetWidth(450)
	GR_Welcome.edit:SetHeight(65)
	GR_Welcome.edit:SetMultiLine(true)
	GR_Welcome.edit:SetPoint("CENTER",GR_Welcome,"CENTER",0,30)
	GR_Welcome.edit:SetFontObject("GameFontNormal")
	GR_Welcome.edit:SetTextInsets(10,10,10,10)
	GR_Welcome.edit:SetMaxLetters(256)
		GR_Welcome.edit:SetText(GR_DATA.settings.welcomes[GR_DATA.settings.dropDown["GR_WELCOME_DROP"] or 1] or "")
	GR_Welcome.edit:SetScript("OnHide",function()
		GR_Welcome.edit:SetText(GR_DATA.settings.welcomes[GR_DATA.settings.dropDown["GR_WELCOME_DROP"] or 1] or "")
	end)
	GR_Welcome.edit.text = GR_Welcome.edit:CreateFontString(nil,"OVERLAY","GameFontNormal")
	GR_Welcome.edit.text:SetPoint("CENTER",GR_Welcome.edit,"TOP",0,15)
	GR_Welcome.edit.text:SetText("Edit your welcome message.")

	local yOfs = -20
	GR_Welcome.status = {}
	for i = 1,3 do
		GR_Welcome.status[i] = {}
		GR_Welcome.status[i].box = CreateFrame("Frame",nil,GR_Welcome)
		GR_Welcome.status[i].box:SetWidth(170)
		GR_Welcome.status[i].box:SetHeight(18)
		GR_Welcome.status[i].box:SetFrameStrata("HIGH")
		GR_Welcome.status[i].box.index = i
		GR_Welcome.status[i].box:SetPoint("LEFT",GR_Welcome,"CENTER",50,yOfs)
		GR_Welcome.status[i].box:SetScript("OnEnter",function(self)
			if GR_DATA.settings.welcomes[self.index] then
				--GameTooltip:SetOwner(self,"ANCHOR_CURSOR")
				--GameTooltip:SetText(GR:FormatWelcome(GR_DATA.settings.welcomes[self.index],UnitName("Player")))
			end
		end)
		GR_Welcome.status[i].box:SetScript("OnLeave",function(self)
			--GameTooltip:Hide()
		end)
		GR_Welcome.status[i].text = GR_Welcome:CreateFontString(nil,nil,"GameFontNormal")
		GR_Welcome.status[i].text:SetText("Welcome #"..i.." status: ")
		GR_Welcome.status[i].text:SetWidth(200)
		GR_Welcome.status[i].text:SetJustifyH("LEFT")
		GR_Welcome.status[i].text:SetPoint("LEFT",GR_Welcome,"CENTER",50,yOfs)
		yOfs = yOfs - 18
	end
	local welcomes = {
		"Welcome #1",
		"Welcome #2",
		"Welcome #3",
	}

	anchor = {}
		anchor.point = "BOTTOMLEFT"
		anchor.relativePoint = "BOTTOMLEFT"
		anchor.xOfs = 50
		anchor.yOfs = 120

	--CreateDropDown(name, parent, label, items, anchor)
	--GR_Welcome.drop = CreateDropDown("GR_WELCOME_DROP",GR_Welcome,GR.L["Select welcome"],whispers,anchor)

		anchor.xOfs = 100
		anchor.yOfs = 20
	--CreateButton(name, parent, width, height, label, anchor, onClick)
	CreateButton("GR_SAVEWELCOME",GR_Welcome,120,30,GR.L["Save"],anchor,function()
		local text = GR_Welcome.edit:GetText()
		local ID = GR_DATA.settings.dropDown["GR_WELCOME_DROP"]
		GR_DATA.settings.welcomes[ID] = text
		GR_Welcome.edit:SetText("")
	end)
	anchor.xOfs = 280
	CreateButton("GR_CANCELWELCOME",GR_Welcome,120,30,GR.L["Cancel"],anchor,function()
		GR_Welcome:Hide()
	end)

	GR_Welcome.update = 0
	GR_Welcome.changed = false
	GR_Welcome:SetScript("OnUpdate",function()
		if GetTime() > GR_Welcome.update then
			for i = 1,3 do
				if type(GR_DATA.settings.welcomes[i]) == "string" then
					GR_Welcome.status[i].text:SetText("Welcome #"..i.." status: |cff00ff00Good|r")
				else
					GR_Welcome.status[i].text:SetText("Welcome #"..i.." status: |cffff0000Undefined|r")
				end
			end
			local ID = GR_DATA.settings.dropDown["GR_WELCOME_DROP"]
			GR_Welcome.status[ID].text:SetText("Welcome #", i, " status: |cffff8800Editing...|r")

			if ID ~= GR_Welcome.changed then
				GR_Welcome.changed = ID
				GR_Welcome.edit:SetText(GR_DATA.settings.welcomes[GR_DATA.settings.dropDown["GR_WELCOME_DROP"] or 1] or "")
			end

			GR_Welcome.update = GetTime() + 0.5
		end
	end)

	GR_Welcome:HookScript("OnHide", function() if (GR_Options.showAgain) then GR:ShowOptions() GR_Options.showAgain = false end end)
end

local function ShowWelcomeFrame()
	if GR_Welcome then
		GR_Welcome:Show()
	else
		CreateWelcomeDefineFrame()
		GR_Welcome:Show()
	end
end

local function HideWelcomeFrame()
	if GR_Welcome then
		GR_Welcome:Hide()
	end
end

--Whisper Frame
local function CreateWhisperDefineFrame()

end

--local KeyHarvestFrame = CreateFrame("Frame", "GR_KeyHarvestFrame");
--KeyHarvestFrame:SetPoint("CENTER",0,200);
--KeyHarvestFrame:SetWidth(10);
--KeyHarvestFrame:SetHeight(10);
--KeyHarvestFrame.text = KeyHarvestFrame:CreateFontString(nil, "OVERLAY", "MovieSubtitleFont");
--KeyHarvestFrame.text:SetPoint("CENTER");
--KeyHarvestFrame.text:SetText("|cff00ff00Press the KEY you wish to bind now!|r");
--KeyHarvestFrame:Hide();

--function KeyHarvestFrame:GetNewKeybindKey()
--	KeyHarvestFrame:Show();
--	self:SetScript("OnKeyDown", function(self, key)
--		if (SetBindingClick(key, "GR_INVITE_BUTTON2")) then
--			Alerter:SendAlert("|cff00ff00Successfully bound "..key.." to InviteButton!|r",1.5);
--			GR:print("Successfully bound "..key.." to InviteButton!");
--			GR_DATA.keyBind = key;
--			BUTTON_KEYBIND.label:SetText("Set Keybind ("..key..")");
--		else
--			Alerter:SendAlert("|cffff0000Error binding "..key.." to InviteButton!|r",1.5);
--			GR:print("Error binding "..key.." to InviteButton!");
--		end
--		self:EnableKeyboard(false);
--		KeyHarvestFrame:Hide();
--	end)
--	self:EnableKeyboard(true);
--
--end


local function CreateWhisperPreviewFrame()
	CreateFrame("Frame","GR_Preview")
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 4,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	GR_Preview:SetWidth(500)
	GR_Preview:SetHeight(175)
	GR_Preview:SetBackdrop(backdrop)
	SetFramePosition(GR_Preview)
	GR_Preview:SetMovable(true)
	GR_Preview:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	GR_Preview:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(GR_Preview)
	end)

	local close = CreateFrame("Button",nil,GR_Preview,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",GR_Preview,"TOPRIGHT",-4,-4)

	GR_Preview.title = GR_Preview:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_Preview.title:SetText(GR.L["GuildRecruiter Whisper Preview"])
	GR_Preview.title:SetPoint("TOP",GR_Preview,"TOP",0,-20)

	GR_Preview.info = GR_Preview:CreateFontString(nil,"OVERLAY","GameFontNormal")
	GR_Preview.info:SetPoint("TOPLEFT",GR_Preview,"TOPLEFT",33,-55)
	GR_Preview.info:SetText("Whisper #"..i..": ",GR_DATA.settings.whispers[i])
	GR_Preview.info:SetWidth(450)
	GR_Preview.info:SetJustifyH("LEFT")
	
end

local function ShowPreviewFrame()
	if GR_Preview then
		GR_Preview:Show()
	else
		CreateWhisperPreviewFrame()
		GR_Preview:Show()
	end
end

local function HidePreviewFrame()
	if GR_Preview then
		GR_Preview:Hide()
	end
end
local function CreateWhisperDefineFrame()
	--Window Defaults
	CreateFrame("Frame","GR_Whisper", UIParent, "BasicFrameTemplate");
	GR_Whisper:SetSize(500,365);
	GR_Whisper:SetPoint("CENTER", UIParent, "CENTER");
	GR_Whisper:SetMovable(true)
	GR_Whisper:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	GR_Whisper:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(GR_Whisper)
	end)
	--Config
	
	GR_Whisper.title = GR_Whisper:CreateFontString(nil, "OVERLAY");
	GR_Whisper.title:SetFontObject("GameFontHighlight");
	GR_Whisper.title:SetPoint("CENTER", GR_Whisper.TitleBg, "CENTER", 5,0);
	GR_Whisper.title:SetText("Guild Recruiter Custom Whispers");

	GR_Whisper.info = GR_Whisper:CreateFontString(nil,"OVERLAY","GameFontHighlight")
	GR_Whisper.info:SetPoint("CENTER",GR_Whisper,"CENTER",0,115)
	GR_Whisper.info:SetText("Create up to 3 custom recruitment messages to whisper to people you would like to join your guild. Make it flashy and give as much information as you can, but don't go over the 256 character limit! Good Luck!")
	GR_Whisper.info:SetWidth(450)
	GR_Whisper.info:SetJustifyH("CENTER")

	GR_Whisper.edit = CreateFrame("EditBox", "GR_Edit", GR_Whisper, "InsetFrameTemplate3")
	GR_Whisper.edit:SetWidth(450)
	GR_Whisper.edit:SetHeight(65)
	GR_Whisper.edit:SetMultiLine(true)
	GR_Whisper.edit:SetPoint("CENTER",GR_Whisper,"CENTER",0,30)
	GR_Whisper.edit:SetFontObject("GameFontNormal")
	GR_Whisper.edit:SetTextInsets(10,10,10,10)
	GR_Whisper.edit:SetMaxLetters(256)
		GR_Whisper.edit:SetText(GR_DATA.settings.whispers[GR_DATA.settings.dropDown["GR_WHISPER_DROP"] or 1] or "")
	GR_Whisper.edit:SetScript("OnHide",function()
		GR_Whisper.edit:SetText(GR_DATA.settings.whispers[GR_DATA.settings.dropDown["GR_WHISPER_DROP"] or 1] or "")
	end)
	GR_Whisper.edit.text = GR_Whisper.edit:CreateFontString(nil,"OVERLAY","GameFontNormal")
	GR_Whisper.edit.text:SetPoint("CENTER",GR_Whisper.edit,"TOP",0,15)
	GR_Whisper.edit.text:SetText("Enter your recruitment message.")

	local yOfs = -20
	GR_Whisper.status = {}
	for i = 1,3 do
		GR_Whisper.status[i] = {}
		GR_Whisper.status[i].box = CreateFrame("Frame",nil,GR_Whisper)
		GR_Whisper.status[i].box:SetWidth(170)
		GR_Whisper.status[i].box:SetHeight(18)
		GR_Whisper.status[i].box:SetFrameStrata("HIGH")
		GR_Whisper.status[i].box.index = i
		GR_Whisper.status[i].box:SetPoint("LEFT",GR_Whisper,"CENTER",50,0)
		GR_Whisper.status[i].box:SetScript("OnEnter",function(self)
			if GR_DATA.settings.whispers[self.index] then
				--GameTooltip:SetOwner(self,"ANCHOR_CURSOR")
				--GameTooltip:SetText(GR:FormatWhisper(GR_DATA.settings.whispers[self.index],UnitName("Player")))
			end
		end)
		GR_Whisper.status[i].box:SetScript("OnLeave",function(self)
			--GameTooltip:Hide()
		end)
		GR_Whisper.status[i].text = GR_Whisper:CreateFontString(nil,nil,"GameFontNormal")
		GR_Whisper.status[i].text:SetText("Whisper #"..i.." status: ")
		GR_Whisper.status[i].text:SetWidth(200)
		GR_Whisper.status[i].text:SetJustifyH("LEFT")
		GR_Whisper.status[i].text:SetPoint("LEFT",GR_Whisper,"CENTER",50,yOfs)
		yOfs = yOfs - 18
	end
	local whispers = {
		"Whisper #1",
		"Whisper #2",
		"Whisper #3",
	}

	anchor = {}
		anchor.point = "BOTTOMLEFT"
		anchor.relativePoint = "BOTTOMLEFT"
		anchor.xOfs = 50
		anchor.yOfs = 120

	--CreateDropDown(name, parent, label, items, anchor)
	GR_Whisper.drop = CreateDropDown("GR_WHISPER_DROP",GR_Whisper,"Select Message",whispers,anchor)

		anchor.xOfs = 100
		anchor.yOfs = 20
	--CreateButton(name, parent, width, height, label, anchor, onClick)
	CreateButton("GR_SAVEWHISPER",GR_Whisper,120,30,GR.L["Save"],anchor,function()
		local text = GR_Whisper.edit:GetText()
		local ID = GR_DATA.settings.dropDown["GR_WHISPER_DROP"]
		GR_DATA.settings.whispers[ID] = text
		GR_Whisper.edit:SetText("")
	end)
	anchor.xOfs = 280
	CreateButton("GR_CANCELWHISPER",GR_Whisper,120,30,GR.L["Cancel"],anchor,function()
		GR_Whisper:Hide()
	end)

	GR_Whisper.update = 0
	GR_Whisper.changed = false
	GR_Whisper:SetScript("OnUpdate",function()
		if GetTime() > GR_Whisper.update then
			for i = 1,3 do
				if type(GR_DATA.settings.whispers[i]) == "string" then
					GR_Whisper.status[i].text:SetText("Whisper status: |cff00ff00Good|r")
				else
					GR_Whisper.status[i].text:SetText("Whisper status: |cffff0000Undefined|r")
				end
			end
			local ID = GR_DATA.settings.dropDown["GR_WHISPER_DROP"]
			GR_Whisper.status[ID].text:SetText("Whisper status: |cffff8800Editing...|r")

			if ID ~= GR_Whisper.changed then
				GR_Whisper.changed = ID
				GR_Whisper.edit:SetText(GR_DATA.settings.whispers[GR_DATA.settings.dropDown["GR_WHISPER_DROP"] or 1] or "")
			end

			GR_Whisper.update = GetTime() + 0.5
		end
	end)

	GR_Whisper:HookScript("OnHide", function() if (GR_Options.showAgain) then GR:ShowOptions() GR_Options.showAgain = false end end)
end

local function ShowWhisperFrame()
	if GR_Whisper then
		GR_Whisper:Show()
	else
		CreateWhisperDefineFrame()
		GR_Whisper:Show()
	end
end

local function HideWhisperFrame()
	if GR_Whisper then
		GR_Whisper:Hide()
	end
end

local function CreateFilterFrame()
	CreateFrame("Frame","GR_Filters")
	GR_Filters:SetWidth(550)
	GR_Filters:SetHeight(400)
	SetFramePosition(GR_Filters)
	GR_Filters:SetMovable(true)
	GR_Filters:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	GR_Filters:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(GR_Filters)
	end)
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 4,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	GR_Filters:SetBackdrop(backdrop)
	local close = CreateFrame("Button",nil,GR_Filters,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",GR_Filters,"TOPRIGHT",-4,-4)

	GR_Filters.title = GR_Filters:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	GR_Filters.title:SetPoint("TOP", GR_Filters, "TOP", 0, -15);
	GR_Filters.title:SetText("Edit filters");
	GR_Filters.underTitle = GR_Filters:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	GR_Filters.underTitle:SetPoint("TOP", GR_Filters, "TOP", 0, -38);
	GR_Filters.underTitle:SetText("|cffff3300Any textbox left empty, except \"Filter name\" will be excluded from the filter|r");
	GR_Filters.underTitle:SetWidth(400);
	GR_Filters.bottomText = GR_Filters:CreateFontString(nil, "OVERLAY", "GameFOntNormal");
	GR_Filters.bottomText:SetPoint("BOTTOM", GR_Filters, "BOTTOM", 0, 60);
	GR_Filters.bottomText:SetText("|cff00ff00In order to be filtered, a player has to match |r|cffFF3300ALL|r |cff00ff00criterias|r");

	--GR_Filters.tooltip = CreateFrame("Frame", "FilterTooltip", GR_Filters.tooltip, "GameTooltipTemplate");




	--GR_Filters.tooltip:SetWidth(150);
	--GR_Filters.tooltip.text = GR_Filters.tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	--GR_Filters.tooltip.text:SetPoint("CENTER", GR_Filters.tooltip, "CENTER", 0, 0);
	--GR_Filters.tooltip.text:SetJustifyH("LEFT");

	GR_Filters.editBoxName = CreateFrame("EditBox", "GR_EditBoxName", GR_Filters);
	GR_Filters.editBoxName:SetWidth(150);
	GR_Filters.editBoxName:SetHeight(30);
	GR_Filters.editBoxName:SetPoint("TOPRIGHT", GR_Filters, "TOPRIGHT", -40, -90);
	GR_Filters.editBoxName:SetFontObject("GameFontNormal");
	GR_Filters.editBoxName:SetMaxLetters(65);
	GR_Filters.editBoxName:SetBackdrop(backdrop);
	GR_Filters.editBoxName:SetText("");
	GR_Filters.editBoxName:SetTextInsets(10,10,10,10);
	GR_Filters.editBoxName:SetScript("OnHide",function(self)
		self:SetText("");
	end)
	GR_Filters.editBoxName.title = GR_Filters.editBoxName:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	GR_Filters.editBoxName.title:SetPoint("BOTTOMLEFT", GR_Filters.editBoxName,"TOPLEFT", 0, 5);
	GR_Filters.editBoxName.title:SetText("Filter name");

	GR_Filters.editBoxNameFilter = CreateFrame("EditBox", "GR_EditBoxNameFilter", GR_Filters);
	GR_Filters.editBoxNameFilter:SetWidth(150);
	GR_Filters.editBoxNameFilter:SetHeight(30);
	GR_Filters.editBoxNameFilter:SetPoint("TOPRIGHT", GR_Filters, "TOPRIGHT", -40, -150);
	GR_Filters.editBoxNameFilter:SetFontObject("GameFontNormal");
	GR_Filters.editBoxNameFilter:SetMaxLetters(65);
	GR_Filters.editBoxNameFilter:SetBackdrop(backdrop);
	GR_Filters.editBoxNameFilter:SetText("");
	GR_Filters.editBoxNameFilter:SetTextInsets(10,10,10,10);
	GR_Filters.editBoxNameFilter:SetScript("OnHide",function(self)
		self:SetText("");
	end)
	GR_Filters.editBoxNameFilter:SetScript("OnEnter", function(self)
		--GR_Filters.tooltip.text:SetText(GR.L["Enter a phrase which you wish to include in the filter. If a player's name contains the phrase, they will not be queued"]);
		--GR_Filters.tooltip.text:SetWidth(135);
		--GR_Filters.tooltip:SetHeight(GR_Filters.tooltip.text:GetHeight() + 12);
		--GR_Filters.tooltip:SetPoint("TOP", self, "BOTTOM", 0, -5);
		--GR_Filters.tooltip:Show();
	end)
	GR_Filters.editBoxNameFilter:SetScript("OnLeave", function()
		--GR_Filters.tooltip:Hide()
	end)

	GR_Filters.editBoxNameFilter.title = GR_Filters.editBoxNameFilter:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	GR_Filters.editBoxNameFilter.title:SetPoint("BOTTOMLEFT", GR_Filters.editBoxNameFilter,"TOPLEFT", 0, 5);
	GR_Filters.editBoxNameFilter.title:SetText("Name exceptions");

	GR_Filters.editBoxLvl = CreateFrame("EditBox", "GR_EditBoxLvl", GR_Filters);
	GR_Filters.editBoxLvl:SetWidth(150);
	GR_Filters.editBoxLvl:SetHeight(30);
	GR_Filters.editBoxLvl:SetPoint("TOPRIGHT", GR_Filters, "TOPRIGHT", -40, -210);
	GR_Filters.editBoxLvl:SetFontObject("GameFontNormal");
	GR_Filters.editBoxLvl:SetMaxLetters(65);
	GR_Filters.editBoxLvl:SetBackdrop(backdrop);
	GR_Filters.editBoxLvl:SetText("");
	GR_Filters.editBoxLvl:SetTextInsets(10,10,10,10);
	GR_Filters.editBoxLvl:SetScript("OnHide",function(self)
		self:SetText("");
	end)
	GR_Filters.editBoxLvl:SetScript("OnEnter", function(self)
		--GR_Filters.tooltip.text:SetText(GR.L["Enter the level range for the filter. \n\nExample: |cff00ff0055|r:|cff00A2FF58|r \n\nThis would result in only matching players that range from level |cff00ff0055|r to |cff00A2FF58|r (inclusive)"]);
		--GR_Filters.tooltip.text:SetWidth(135);
		--GR_Filters.tooltip:SetHeight(GR_Filters.tooltip.text:GetHeight() + 12);
		--GR_Filters.tooltip:SetPoint("TOP", self, "BOTTOM", 0, -5);
		--GR_Filters.tooltip:Show();
	end)
	GR_Filters.editBoxLvl:SetScript("OnLeave", function()
		--GR_Filters.tooltip:Hide()
	end)

	GR_Filters.editBoxLvl.title = GR_Filters.editBoxLvl:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	GR_Filters.editBoxLvl.title:SetPoint("BOTTOMLEFT", GR_Filters.editBoxLvl,"TOPLEFT", 0, 5);
	GR_Filters.editBoxLvl.title:SetText("Level range (Min:Max)");

	GR_Filters.editBoxVC = CreateFrame("EditBox", "GR_EditBoxVC", GR_Filters);
	GR_Filters.editBoxVC:SetWidth(150);
	GR_Filters.editBoxVC:SetHeight(30);
	GR_Filters.editBoxVC:SetPoint("TOPRIGHT", GR_Filters, "TOPRIGHT", -40, -270);
	GR_Filters.editBoxVC:SetFontObject("GameFontNormal");
	GR_Filters.editBoxVC:SetMaxLetters(65);
	GR_Filters.editBoxVC:SetBackdrop(backdrop);
	GR_Filters.editBoxVC:SetText("");
	GR_Filters.editBoxVC:SetTextInsets(10,10,10,10);
	GR_Filters.editBoxVC:SetScript("OnHide",function(self)
		self:SetText("");
	end)

	GR_Filters.editBoxVC:SetScript("OnEnter", function(self)
		--GR_Filters.tooltip.text:SetText(GR.L["Enter the maximum amount of consecutive vowels and consonants a player's name can contain.\n\nExample: |cff00ff003|r:|cff00A2FF5|r\n\nThis would cause players with more than |cff00ff003|r vowels in a row or more than |cff00A2FF5|r consonants in a row not to be queued."]);
		--GR_Filters.tooltip.text:SetWidth(135);
		--GR_Filters.tooltip:SetHeight(GR_Filters.tooltip.text:GetHeight() + 12);
		--GR_Filters.tooltip:SetPoint("TOP", self, "BOTTOM", 0, -5);
		--GR_Filters.tooltip:Show();
	end)
	GR_Filters.editBoxVC:SetScript("OnLeave", function()
		--GR_Filters.tooltip:Hide()
	end)

	GR_Filters.editBoxVC.title = GR_Filters.editBoxVC:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	GR_Filters.editBoxVC.title:SetPoint("BOTTOMLEFT", GR_Filters.editBoxVC,"TOPLEFT", 0, 5);
	GR_Filters.editBoxVC.title:SetText("Max Vowels/Cons (V:C)");

	GR_EditBoxName:SetScript("OnEnterPressed", function()
		GR_EditBoxNameFilter:SetFocus();
	end);
	GR_EditBoxNameFilter:SetScript("OnEnterPressed", function()
		GR_EditBoxLvl:SetFocus();
	end);
	GR_EditBoxLvl:SetScript("OnEnterPressed", function()
		GR_EditBoxVC:SetFocus();
	end);
	GR_EditBoxVC:SetScript("OnEnterPressed", function()
		GR_EditBoxName:SetFocus();
	end);
	GR_EditBoxName:SetScript("OnTabPressed", function()
		GR_EditBoxNameFilter:SetFocus();
	end);
	GR_EditBoxNameFilter:SetScript("OnTabPressed", function()
		GR_EditBoxLvl:SetFocus();
	end);
	GR_EditBoxLvl:SetScript("OnTabPressed", function()
		GR_EditBoxVC:SetFocus();
	end);
	GR_EditBoxVC:SetScript("OnTabPressed", function()
		GR_EditBoxName:SetFocus();
	end);

	local CLASS = {
			[GR.L["Death Knight"]] = "DEATHKNIGHT",
			[GR.L["Demon Hunter"]] = "DEMONHUNTER",
			[GR.L["Druid"]] = "DRUID",
			[GR.L["Hunter"]] = "HUNTER",
			[GR.L["Mage"]] = "MAGE",
			[GR.L["Monk"]] = "MONK",
			[GR.L["Paladin"]] = "PALADIN",
			[GR.L["Priest"]] = "PRIEST",
			[GR.L["Rogue"]] = "ROGUE",
			[GR.L["Shaman"]] = "SHAMAN",
			[GR.L["Warlock"]] = "WARLOCK",
			[GR.L["Warrior"]] = "WARRIOR"
	}
	local Classes = {
			GR.L["Ignore"],
			GR.L["Death Knight"],
			GR.L["Demon Hunter"],
			GR.L["Druid"],
			GR.L["Hunter"],
			GR.L["Mage"],
			GR.L["Monk"],
			GR.L["Paladin"],
			GR.L["Priest"],
			GR.L["Rogue"],
			GR.L["Shaman"],
			GR.L["Warlock"],
			GR.L["Warrior"],
	}
	local Races = {}
	if UnitFactionGroup("player") == "Horde" then
		Races = {
			GR.L["Ignore"],
			GR.L["Orc"],
			GR.L["Blood Elf"],
			GR.L["Undead"],
			GR.L["Troll"],
			GR.L["Goblin"],
			GR.L["Tauren"],
			GR.L["Pandaren"],
			GR.L["Highmountain Tauren"],
			GR.L["Nightborne"],
			GR.L["Mag'har Orc"],
			GR.L["Zandalari Troll"],
		}
	else
		Races = {
			GR.L["Ignore"],
			GR.L["Human"],
			GR.L["Dwarf"],
			GR.L["Worgen"],
			GR.L["Draenei"],
			GR.L["Night Elf"],
			GR.L["Gnome"],
			GR.L["Pandaren"],
			GR.L["Void Elf"],
			GR.L["Lightforged Draenei"],
			GR.L["Dark Iron Dwarf"],
			GR.L["Kul Tiran Human"],
		}
	end

	GR_Filters.classText = GR_Filters:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	GR_Filters.raceText = GR_Filters:CreateFontString(nil, "OVERLAY", "GameFontNormal");

	GR_Filters.classCheckBoxes = {};
	local anchor = {
		point = "TOPLEFT",
		relativePoint = "TOPLEFT",
		xOfs = 40,
		yOfs = -90,
	}
	for k,_ in pairs(Classes) do
		GR_Filters.classCheckBoxes[k] = CreateCheckbox("CHECKBOX_FILTERS_CLASS_"..Classes[k], GR_Filters, Classes[k], anchor)

		anchor.yOfs = anchor.yOfs - 18;
	end
	GR_Filters.classText:SetPoint("BOTTOM", GR_Filters.classCheckBoxes[1], "TOP", -5, 3);
	GR_Filters.classText:SetText(GR.L["Classes:"]);

	if (GR_Filters.classCheckBoxes[1]:GetChecked()) then
		for i = 2,12 do
			GR_Filters.classCheckBoxes[i]:Hide();
		end
	else
		for i = 2,12 do
			GR_Filters.classCheckBoxes[i]:Show();
		end
	end

	GR_Filters.classCheckBoxes[1]:HookScript("PostClick", function()
		if (GR_Filters.classCheckBoxes[1]:GetChecked()) then
			for i = 2,12 do
				GR_Filters.classCheckBoxes[i]:Hide();
			end
		else
			for i = 2,12 do
				GR_Filters.classCheckBoxes[i]:Show();
			end
		end
	end)


	GR_Filters.raceCheckBoxes = {};
	anchor = {
		point = "TOPLEFT",
		relativePoint = "TOPLEFT",
		xOfs = 160,
		yOfs = -90,
	}
	for k,_ in pairs(Races) do
		GR_Filters.raceCheckBoxes[k] = CreateCheckbox("CHECKBOX_FILTERS_RACE_"..Races[k], GR_Filters, Races[k], anchor)
		anchor.yOfs = anchor.yOfs - 18;
	end

	GR_Filters.raceText:SetPoint("BOTTOM", GR_Filters.raceCheckBoxes[1], "TOP", -5, 3);
	GR_Filters.raceText:SetText(GR.L["Races:"]);

	if (GR_Filters.raceCheckBoxes[1]:GetChecked()) then
		for i = 2,8 do
			GR_Filters.raceCheckBoxes[i]:Hide();
		end
	else
		for i = 2,8 do
			GR_Filters.raceCheckBoxes[i]:Show();
		end
	end

	GR_Filters.raceCheckBoxes[1]:HookScript("PostClick", function()
		if (GR_Filters.raceCheckBoxes[1]:GetChecked()) then
			for i = 2,8 do
				GR_Filters.raceCheckBoxes[i]:Hide();
			end
		else
			for i = 2,8 do
				GR_Filters.raceCheckBoxes[i]:Show();
			end
		end
	end)


	local function GetFilterData()
		local FilterName = GR_EditBoxName:GetText();
		GR_EditBoxName:SetText("");
		if (not FilterName or strlen(FilterName) < 1) then
			return;
		end
		GR:debug("Filter name: "..FilterName);
		local V,C = GR_EditBoxVC:GetText();
		if (V and strlen(V) > 1) then
			V,C = strsplit(":", V);
			V = tonumber(V);
			C = tonumber(C);
			if (V == "") then V = nil end
			if (C == "") then C = nil end
			GR:debug("Max Vowels: "..(V or "N/A")..", Max Consonants: "..(C or "N/A"));
		end
		GR_EditBoxVC:SetText("");
		local Min,Max = GR_EditBoxLvl:GetText();
		if (Min and strlen(Min) > 1) then
			Min, Max = strsplit(":",Min);
			Min = tonumber(Min);
			Max = tonumber(Max);
			GR:debug("Level range: "..Min.." - "..Max);
		end
		GR_EditBoxLvl:SetText("");

		local ExceptionName = GR_EditBoxNameFilter:GetText()
		if (ExceptionName == "") then
			ExceptionName = nil;
		end
		GR_EditBoxNameFilter:SetText("");



		local classes = {};
		if (not GR_Filters.classCheckBoxes[1]:GetChecked()) then
			for k,_ in pairs(GR_Filters.classCheckBoxes) do
				if (GR_Filters.classCheckBoxes[k]:GetChecked()) then
					classes[CLASS[GR_Filters.classCheckBoxes[k].label:GetText()]] = true;
					GR:debug(CLASS[GR_Filters.classCheckBoxes[k].label:GetText()]);
					GR_Filters.classCheckBoxes[k]:SetChecked(false);
				end
			end
		end

		local races = {}
		if (not GR_Filters.raceCheckBoxes[1]:GetChecked()) then
			for k,_ in pairs(GR_Filters.raceCheckBoxes) do
				if (GR_Filters.raceCheckBoxes[k]:GetChecked()) then
					races[GR_Filters.raceCheckBoxes[k].label:GetText()] = true;
					GR:debug(GR_Filters.raceCheckBoxes[k].label:GetText());
					GR_Filters.raceCheckBoxes[k]:SetChecked(false);
				end
			end
		end
		GR:CreateFilter(FilterName,classes,ExceptionName,Min,Max,races,V,C);
		GR_FilterHandle.needRedraw = true;
		return true;
	end

	anchor = {
		point = "BOTTOM",
		relativePoint = "BOTTOM",
		xOfs = -60,
		yOfs = 20,
	}


	GR_Filters.button1 = CreateButton("BUTTON_SAVE_FILTER", GR_Filters, 120, 30, GR.L["Save"], anchor, GetFilterData);
		anchor.xOfs = 60;
	GR_Filters.button2 = CreateButton("BUTTON_CANCEL_FILTER", GR_Filters, 120, 30, GR.L["Back"], anchor, function() GR_Filters:Hide() end);

	GR_Filters:HookScript("OnHide", function() GR:ShowFilterHandle() GR_FilterHandle.showOpt = true end);

end

local function ShowFilterFrame()
	if (not GR_Filters) then
		CreateFilterFrame();
	end
	GR_Filters:Show();
end


local function CreateFilterHandleFrame()
	CreateFrame("Frame","GR_FilterHandle")
	GR_FilterHandle:SetWidth(450)
	GR_FilterHandle:SetHeight(350)
	SetFramePosition(GR_FilterHandle)
	GR_FilterHandle:SetMovable(true)
	GR_FilterHandle:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	GR_FilterHandle:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(GR_FilterHandle)
	end)
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 4,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	GR_FilterHandle:SetBackdrop(backdrop)
	local close = CreateFrame("Button",nil,GR_FilterHandle,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",GR_FilterHandle,"TOPRIGHT",-4,-4)

	GR_FilterHandle.title = GR_FilterHandle:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_FilterHandle.title:SetText("Filters")
	GR_FilterHandle.title:SetPoint("TOP",GR_FilterHandle,"TOP",0,-15)
	GR_FilterHandle.underTitle = GR_FilterHandle:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	GR_FilterHandle.underTitle:SetText("Click to toggle");
	GR_FilterHandle.underTitle:SetPoint("TOP", GR_FilterHandle, "TOP", 0, -35);

	local anchor = {}
			anchor.point = "BOTTOM"
			anchor.relativePoint = "BOTTOM"
			anchor.xOfs = -60
			anchor.yOfs = 30

	GR_FilterHandle.button1 = CreateButton("BUTTON_EDIT_FILTERS", GR_FilterHandle, 120, 30, GR.L["Add filters"], anchor, function() ShowFilterFrame() GR_FilterHandle.showOpt = false GR_FilterHandle.showSelf = true GR_FilterHandle:Hide() end);
		anchor.xOfs = 60
	GR_FilterHandle.button2 = CreateButton("BUTTON_EDIT_FILTERS", GR_FilterHandle, 120, 30, GR.L["Back"], anchor, function() close:Click() end);


	--GR_FilterHandle.tooltip = CreateFrame("Frame", "GR_HandleTooltip", GR_FilterHandle, "GameTooltipTemplate");
	--GR_FilterHandle.tooltip:SetWidth(150);
	--GR_FilterHandle.tooltip.text = GR_FilterHandle.tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	--GR_FilterHandle.tooltip.text:SetPoint("CENTER", GR_FilterHandle.tooltip, "CENTER", 0, 0);
	--GR_FilterHandle.tooltip.text:SetJustifyH("LEFT");

	local function FormatTooltipFilterText(filter)
		local text = "Filter name: "..filter.nameOfFilter.."\n";

		if (filter.active) then
			text = text.."|cff00ff00[ACTIVE]|r\n";
		else
			text = text.."|cffff0000[INACTIVE]|r\n";
		end

		if (filter.class) then
			for k,v in pairs(filter.class) do
				text = text.."|cff"..(GR:GetClassColor(k)..k).."|r\n";
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

	GR_FilterHandle.filterFrames = {}
	GR_FilterHandle.update = 0;
	GR_FilterHandle.needRedraw = false;
	GR_FilterHandle:SetScript("OnUpdate", function(self)
		if (GR_FilterHandle.update < GetTime()) then

			local anchor = {}
				anchor.xOfs = -175
				anchor.yOfs = 110

			local F = GR_DATA.settings.filters;

			if (GR_FilterHandle.needRedraw) then
				for k,_ in pairs(GR_FilterHandle.filterFrames) do
					GR_FilterHandle.filterFrames[k]:Hide();
				end
				GR_FilterHandle.filterFrames = {};
				GR_FilterHandle.needRedraw = false;
			end

			for k,_ in pairs(F) do
				if (not GR_FilterHandle.filterFrames[k]) then
					GR_FilterHandle.filterFrames[k] = CreateFrame("Button", "FilterFrame"..k, GR_FilterHandle);
					GR_FilterHandle.filterFrames[k]:SetWidth(80)
					GR_FilterHandle.filterFrames[k]:SetHeight(25);
					GR_FilterHandle.filterFrames[k]:EnableMouse(true);
					GR_FilterHandle.filterFrames[k]:SetPoint("CENTER", GR_FilterHandle, "CENTER", anchor.xOfs, anchor.yOfs);
					if mod(k,5) == 0 then
						anchor.xOfs = -175
						anchor.yOfs = anchor.yOfs - 30
					else
						anchor.xOfs = anchor.xOfs + 85
					end
					GR_FilterHandle.filterFrames[k].text = GR_FilterHandle.filterFrames[k]:CreateFontString(nil, "OVERLAY", "GameFontNormal");
					GR_FilterHandle.filterFrames[k].text:SetPoint("LEFT", GR_FilterHandle.filterFrames[k], "LEFT", 3, 0);
					GR_FilterHandle.filterFrames[k].text:SetJustifyH("LEFT");
					GR_FilterHandle.filterFrames[k].text:SetWidth(75);
					GR_FilterHandle.filterFrames[k]:EnableMouse(true);
					GR_FilterHandle.filterFrames[k]:RegisterForClicks("LeftButtonDown","RightButtonDown");
					GR_FilterHandle.filterFrames[k].highlight = GR_FilterHandle.filterFrames[k]:CreateTexture();
					GR_FilterHandle.filterFrames[k].highlight:SetAllPoints();
					if (GR_DATA.settings.filters[k].active) then
						GR_FilterHandle.filterFrames[k].highlight:SetTexture(0,1,0,0.2);
					else
						GR_FilterHandle.filterFrames[k].highlight:SetTexture(1,0,0,0.2);
					end
					GR_FilterHandle.filterFrames[k]:SetScript("OnEnter", function(self)
						self.highlight:SetTexture(1,1,0,0.2);
						GR:debug("Enter: YELLOW");

						--GR_FilterHandle.tooltip.text:SetText(FormatTooltipFilterText(F[k]));
						--GR_FilterHandle.tooltip:SetPoint("TOP", self, "BOTTOM", 0, -3);
						--GR_FilterHandle.tooltip:SetHeight(GR_FilterHandle.tooltip.text:GetHeight() + 12);
						--GR_FilterHandle.tooltip:SetWidth(GR_FilterHandle.tooltip.text:GetWidth() + 10);
						--GR_FilterHandle.tooltip:Show();
					end)
					GR_FilterHandle.filterFrames[k]:SetScript("OnLeave", function(self)
						if (F[k] and F[k].active) then--GR_FilterHandle.filterFrames[k].state) then
							GR_FilterHandle.filterFrames[k].highlight:SetTexture(0,1,0,0.2);
							GR:debug("Leave: GREEN");

						else
							GR_FilterHandle.filterFrames[k].highlight:SetTexture(1,0,0,0.2);
							GR:debug("Leave: RED");
						end

						--GR_FilterHandle.tooltip:Hide();
					end)
				end

				GR_FilterHandle.filterFrames[k].filter = F[k];
				GR_FilterHandle.filterFrames[k].text:SetText(F[k].nameOfFilter);
				GR_FilterHandle.filterFrames[k]:Show();

				GR_FilterHandle.filterFrames[k]:SetScript("OnClick", function(self, button)
					GR:debug(button);
					if (button == "LeftButton") then
						if (GR_DATA.settings.filters[k].active) then
							GR_DATA.settings.filters[k].active = nil;
							GR_FilterHandle.filterFrames[k].highlight:SetTexture(1,0,0,0.2);
							GR:debug("Click: RED");
						else
							GR_DATA.settings.filters[k].active = true;
							GR_FilterHandle.filterFrames[k].highlight:SetTexture(0,1,0,0.2);
							GR:debug("Click: GREEN");
						end

						--GR_FilterHandle.tooltip.text:SetText(FormatTooltipFilterText(F[k]));
						--GR_FilterHandle.tooltip:SetPoint("TOP", self, "BOTTOM", 0, -3);
						--GR_FilterHandle.tooltip:SetHeight(GR_FilterHandle.tooltip.text:GetHeight() + 12);
						--GR_FilterHandle.tooltip:SetWidth(GR_FilterHandle.tooltip.text:GetWidth() + 10);
						--GR_FilterHandle.tooltip:Show();
					else
						GR_DATA.settings.filters[k] = nil;
						GR_FilterHandle.needRedraw = true;
					end

				end)

			end

			GR_FilterHandle.update = GetTime() + 1;
		end
	end)
	GR_FilterHandle.showOpt = true;
	GR_FilterHandle:HookScript("OnHide", function() if GR_FilterHandle.showOpt then GR:ShowOptions() end end)
end

function GR:ShowFilterHandle()
	if (not GR_FilterHandle) then
		CreateFilterHandleFrame();
	end
	GR_FilterHandle:Show()
end

local function ChangeLog()
	CreateFrame("Frame","GR_ChangeLog")
	GR_ChangeLog:SetWidth(550)
	GR_ChangeLog:SetHeight(350)
	GR_ChangeLog:SetBackdrop(
	{
		bgFile = "Interface/ACHIEVEMENTFRAME/UI-Achievement-Parchment-Horizontal",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = false,
		tileSize = 16,
		edgeSize = 4,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	)
	SetFramePosition(GR_ChangeLog)

	local anchor = {}
			anchor.point = "BOTTOMRIGHT"
			anchor.relativePoint = "BOTTOMRIGHT"
			anchor.xOfs = -210
			anchor.yOfs = 10

	GR_ChangeLog.check1 = CreateCheckbox("GR_CHANGES",GR_ChangeLog,GR.L["Don't show this after new updates"],anchor)
		anchor.xOfs = -300
	GR_ChangeLog.button1 = CreateButton("GR_CLOSE_CHANGES",GR_ChangeLog,120,30,GR.L["Close"],anchor,function() GR_ChangeLog:Hide() GR_DATA.showChanges = GR.VERSION_MAJOR end)

	GR_ChangeLog.title = GR_ChangeLog:CreateFontString()
	GR_ChangeLog.title:SetFont("Fonts\\FRIZQT__.TTF",22,"OUTLINE")
	GR_ChangeLog.title:SetText("|cffffff00<|r|cff16ABB5GuildRecruiter|r|cff00ff00 Recent Changes|r|cffffff00>|r|cffffff00")
	GR_ChangeLog.title:SetPoint("TOP",GR_ChangeLog,"TOP",0,-12)

	GR_ChangeLog.version = GR_ChangeLog:CreateFontString()
	GR_ChangeLog.version:SetFont("Fonts\\FRIZQT__.TTF",16,"OUTLINE")
	GR_ChangeLog.version:SetPoint("TOPLEFT",GR_ChangeLog,"TOPLEFT",15,-40)
	GR_ChangeLog.version:SetText("")

	GR_ChangeLog.items = {}
	local y = -65
	for i = 1,10 do
		GR_ChangeLog.items[i] = GR_ChangeLog:CreateFontString()
		GR_ChangeLog.items[i]:SetFont("Fonts\\FRIZQT__.TTF",14,"OUTLINE")
		GR_ChangeLog.items[i]:SetPoint("TOPLEFT",GR_ChangeLog,"TOPLEFT",30,y)
		GR_ChangeLog.items[i]:SetText("")
		GR_ChangeLog.items[i]:SetJustifyH("LEFT")
		GR_ChangeLog.items[i]:SetSpacing(3)
		y = y - 17
	end
	GR_ChangeLog.SetChange = function(changes)
		local Y = -65
		GR_ChangeLog.version:SetText("|cff16ABB5"..changes.version.."|r")
		for k,_ in pairs(changes.items) do
			GR_ChangeLog.items[k]:SetText("|cffffff00"..changes.items[k].."|r")
			GR_ChangeLog.items[k]:SetWidth(490)
			GR_ChangeLog.items[k]:SetPoint("TOPLEFT",GR_ChangeLog,"TOPLEFT",30,Y)
			Y = Y - GR_ChangeLog.items[k]:GetHeight() - 5
		end
	end
end

function GR:ShowChanges()
	if ( GR_ChangeLog ) then
		GR_ChangeLog:Show()
	else
		ChangeLog()
		GR_ChangeLog:Show()
	end
	GR_ChangeLog.SetChange(GR.versionChanges);
end


local function CreateTroubleShooter()
	CreateFrame("Frame","GR_TroubleShooter")
	GR_TroubleShooter:SetWidth(300)
	GR_TroubleShooter:SetHeight(100)
	SetFramePosition(GR_TroubleShooter)
	GR_TroubleShooter:SetMovable(true)
	GR_TroubleShooter:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	GR_TroubleShooter:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(GR_TroubleShooter)
	end)
	local backdrop =
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 4,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	GR_TroubleShooter:SetBackdrop(backdrop)
	local close = CreateFrame("Button",nil,GR_TroubleShooter,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",GR_TroubleShooter,"TOPRIGHT",-4,-4)

	GR_TroubleShooter.title = GR_TroubleShooter:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_TroubleShooter.title:SetPoint("TOP",GR_TroubleShooter,"TOP",0,-10)
	GR_TroubleShooter.title:SetText("Common issues")


	local update = 0;

	GR_TroubleShooter.items = {};
	GR_TroubleShooter:SetScript("OnUpdate", function()
		if (update < GetTime()) then




			update = GetTime() + 0.5;
		end
	end)


	GR_TroubleShooter:HookScript("OnHide", function() if (GR_Options.showAgain) then GR_Options:Show() GR_Options.showAgain = false end end);
end

function GR:ShowTroubleShooter()
	if (not GR_TroubleShooter) then
		CreateTroubleShooter();
	end
	GR_TroubleShooter:Show();
end


local function OptBtn2_OnClick()
	--GR:ShowSuperScanFrame();
	SSBtn3_OnClick(GR_SUPERSCAN_PLAYPAUSE2);
end


local function CreateOptions()
	CreateFrame("Frame", "GR_Options", UIParent, "BasicFrameTemplate")
	GR_Options:SetWidth(530)
	GR_Options:SetHeight(300)
	SetFramePosition(GR_Options)
	GR_Options:SetMovable(true)
	GR_Options:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	GR_Options:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(GR_Options)
	end)
	
	--Title Text	
	GR_Options.title = GR_Options:CreateFontString(nil, "OVERLAY");
	GR_Options.title:SetFontObject("GameFontHighlight");
	GR_Options.title:SetPoint("CENTER", GR_Options.TitleBg, "CENTER", 5, 0);
	GR_Options.title:SetText("Guild Recruiter "..GR.VERSION_MAJOR..GR.VERSION_MINOR.." ")
	
	--Bottom Text (Guild Ad)
	GR_Options.bottom = GR_Options:CreateFontString(nil,"OVERLAY");
	GR_Options.bottom:SetFontObject("GameFontNormalTiny");
	GR_Options.bottom:SetPoint("BOTTOM", GR_Options, "BOTTOM",0,10);
	GR_Options.bottom:SetText("|cff88aaffUpdated and Maintained by The Shadow Collective https://discord.gg/x4tR4sX|r");
	
	--Menu Text
	GR_Options.top = GR_Options:CreateFontString(nil, "OVERLAY");
	GR_Options.top:SetFontObject("GameFontHighlight");
	GR_Options.top:SetPoint("TOP", GR_Options, "TOP", -5, -30);
	GR_Options.top:SetText("Options Menu");
	
	--Scroll Text
	GR_Options.optionHelpText = GR_Options:CreateFontString(nil, "OVERLAY","GameFontNormalTiny");
	GR_Options.optionHelpText:SetText("|cff00D2FFScroll to change levels|r");
	GR_Options.optionHelpText:SetPoint("TOP",GR_Options,"TOP",-5,-200);
	--Easter Egg-- I love you, Alisha. <3
	local egg = CreateFrame("Button","GR_EasterEgg",GR_Options)
	egg:SetWidth(24)
	egg:SetHeight(24)
	egg:SetPoint("BOTTOMLEFT",GR_Options,"BOTTOMLEFT",70,70)
	egg:SetNormalTexture(nil)
	egg:SetPushedTexture(nil)
	egg:SetHighlightTexture("Interface\\AddOns\\SCGuildRecruiter\\media\\GR_MiniMapButton.tga")
	egg:SetScript("OnClick",function(self,button)
		if GR_EasterEgg then
			SendChatMessage("Goataraz loves Algaroat! <3", "YELL");
		else
			SendChatMessage("Goataraz loves Algaroat! <3", "YELL");
		end
	end)
	
	--Logo
	GR_Options.guildlogo = CreateFrame("Frame","guildlogo",GR_Options)
	GR_Options.guildlogo:SetWidth(64)
	GR_Options.guildlogo:SetHeight(64)
	GR_Options.guildlogo:SetPoint("CENTER",GR_Options,"CENTER",-5,50)
	GR_Options.guildlogo.text = GR_Options.guildlogo:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_Options.guildlogo.text:SetPoint("CENTER")
	GR_Options.guildlogo.texture = GR_Options.guildlogo:CreateTexture()
	GR_Options.guildlogo.texture:SetAllPoints()
	GR_Options.guildlogo.texture:SetTexture("Interface\\AddOns\\goat\\media\\logo64")
	GR_Options.guildlogo.texture:Show()
	
	--Anchor Local Variable
	local anchor = {}
	
	--Checkbox Anchor
		anchor.point = "TOPLEFT"
		anchor.relativePoint = "TOPLEFT"
		anchor.xOfs = 7
		anchor.yOfs = -60

	--Checkboxes
	local spacing = 25;
	GR_Options.checkBox2 = CreateCheckbox("CHECKBOX_ADV_SCAN", GR_Options, "Show Advanced Scan Options", anchor);
		anchor.yOfs = anchor.yOfs - spacing;
	GR_Options.checkBox7 = CreateCheckbox("CHECKBOX_HIDE_WHISPER", GR_Options, "Hide Outgoing Whispers (WIP)", anchor);
		anchor.yOfs = anchor.yOfs - spacing;
	GR_Options.checkBox5 = CreateCheckbox("CHECKBOX_BACKGROUND_MODE", GR_Options, "Run Scan in Background", anchor);
		anchor.yOfs = anchor.yOfs - spacing;
	GR_Options.checkBox6 = CreateCheckbox("CHECKBOX_ENABLE_FILTERS", GR_Options, "Enable Filtering", anchor);
		anchor.yOfs = anchor.yOfs - spacing;
	GR_Options.checkbox1 = CreateCheckbox("CHECKBOX_MEMBER_WELCOME", GR_Options, "Welcome New Members (WIP)", anchor);
		anchor.yOfs = anchor.yOfs - spacing;
		
	--GR_Options.checkBox3:HookScript("PostClick", function(self) ChatIntercept:StateSystem(self:GetChecked()) end);
	--GR_Options.checkBox7:HookScript("PostClick", function(self) ChatIntercept:StateWhisper(self:GetChecked()) end);


	--Anchor Point for the bottom row of buttons
		anchor.point = "BOTTOMLEFT"
		anchor.relativePoint = "BOTTOMLEFT"
		anchor.xOfs = 20
		anchor.yOfs = 25

	--onClickTester
	GR_Options.button1 = CreateButton("BUTTON_CUSTOM_WHISPER", GR_Options, 96, 30, "Edit Whispers", anchor, function(self) ShowWhisperFrame() GR_Options:Hide() GR_Options.showAgain = true end);
		anchor.xOfs = anchor.xOfs + 100;
	GR_Options.button4 = CreateButton("BUTTON_CUSTOM_WELCOME", GR_Options, 96, 30, "Set Welcome", anchor, function(self) ShowWelcomeFrame() GR_Options:Hide() GR_Options.showAgain = true end);
		anchor.xOfs = anchor.xOfs + 100;
	GR_Options.button4 = CreateButton("BUTTON_FILTER", GR_Options, 96, 30, "Set Filters", anchor, function() GR:ShowFilterHandle() GR_Options:Hide() end);
		anchor.xOfs = anchor.xOfs + 100;
	GR_Options.button2 = CreateButton("BUTTON_SUPER_SCAN", GR_Options, 96, 30, "Scan", anchor, OptBtn2_OnClick);
		anchor.xOfs = anchor.xOfs + 100;
	GR_Options.button3 = CreateButton("BUTTON_INVITE", GR_Options, 96, 30, format("Whisper: %d",GR:GetNumQueued()), anchor, GR.SendGuildInvite);
		anchor.xOfs = anchor.xOfs + 100;
	
	--Low Limit Selector
	GR_Options.limitLow = CreateFrame("Frame","GR_LowLimit",GR_Options)
	GR_Options.limitLow:SetWidth(40)
	GR_Options.limitLow:SetHeight(40)
	GR_Options.limitLow:SetPoint("CENTER",GR_Options,"CENTER",-20,-30)
	GR_Options.limitLow.text = GR_Options.limitLow:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_Options.limitLow.text:SetPoint("CENTER")
	GR_Options.limitLow.texture = GR_Options.limitLow:CreateTexture()
	GR_Options.limitLow.texture:SetAllPoints()
	--GR_Options.limitLow.texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
	GR_Options.limitLow.texture:Hide()
	--GR_Options.limitTooltip = CreateFrame("Frame","LimitTool",GR_Options.limitLow,"GameTooltipTemplate")

	--GR_Options.limitTooltip:SetPoint("TOP",GR_Options.limitLow,"BOTTOM")
	--GR_Options.limitTooltip.text = GR_Options.limitTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	--GR_Options.limitTooltip.text:SetPoint("LEFT",GR_Options.limitTooltip,"LEFT",12,0)
	--GR_Options.limitTooltip.text:SetJustifyH("LEFT")
	--GR_Options.limitTooltip.text:SetText(GR.L["Highest and lowest level to search for"])
	--GR_Options.limitTooltip.text:SetWidth(115)
	--GR_Options.limitTooltip:SetWidth(130)
	--GR_Options.limitTooltip:SetHeight(GR_Options.limitTooltip.text:GetHeight() + 12)

	GR_Options.limitLow:SetScript("OnEnter",function()
		GR_Options.limitLow.texture:Show()
		--GR_Options.limitTooltip:Show()
	end)
	GR_Options.limitLow:SetScript("OnLeave",function()
		GR_Options.limitLow.texture:Hide()
		--GR_Options.limitTooltip:Hide()
	end)
	
	--High Limit Selector
	GR_Options.limitHigh = CreateFrame("Frame","GR_HighLimit",GR_Options)
	GR_Options.limitHigh:SetWidth(40)
	GR_Options.limitHigh:SetHeight(40)
	GR_Options.limitHigh:SetPoint("CENTER",GR_Options,"CENTER",20,-30)
	GR_Options.limitHigh.text = GR_Options.limitHigh:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_Options.limitHigh.text:SetPoint("CENTER")
	GR_Options.limitHigh.texture = GR_Options.limitHigh:CreateTexture()
	GR_Options.limitHigh.texture:SetAllPoints()
	--GR_Options.limitHigh.texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
	GR_Options.limitHigh.texture:Hide()

	GR_Options.limitHigh:SetScript("OnEnter",function()
		GR_Options.limitHigh.texture:Show()
		--GR_Options.limitTooltip:Show()
	end)
	GR_Options.limitHigh:SetScript("OnLeave",function()
		GR_Options.limitHigh.texture:Hide()
		--GR_Options.limitTooltip:Hide(nil)
	end)

	GR_Options.limitLow.text:SetText(GR_DATA.settings.lowLimit.." - ")
	GR_Options.limitLow:SetScript("OnMouseWheel",function(self,delta)
		if delta == 1 and GR_DATA.settings.lowLimit + 1 <= GR_DATA.settings.highLimit then
			GR_DATA.settings.lowLimit = GR_DATA.settings.lowLimit + 1
			GR_Options.limitLow.text:SetText(GR_DATA.settings.lowLimit.." - ")
		elseif delta == -1 and GR_DATA.settings.lowLimit - 1 >= GR_MIN_LEVEL_SUPER_SCAN then
			GR_DATA.settings.lowLimit = GR_DATA.settings.lowLimit - 1
			GR_Options.limitLow.text:SetText(GR_DATA.settings.lowLimit.." - ")
		end
	end)

	GR_Options.limitHigh.text:SetText(GR_DATA.settings.highLimit)
	GR_Options.limitHigh:SetScript("OnMouseWheel",function(self,delta)
		if delta == 1 and GR_DATA.settings.highLimit + 1 <= GR_MAX_LEVEL_SUPER_SCAN then
			GR_DATA.settings.highLimit = GR_DATA.settings.highLimit + 1
			GR_Options.limitHigh.text:SetText(GR_DATA.settings.highLimit)
		elseif delta == -1 and GR_DATA.settings.highLimit > GR_DATA.settings.lowLimit then
			GR_DATA.settings.highLimit = GR_DATA.settings.highLimit - 1
			GR_Options.limitHigh.text:SetText(GR_DATA.settings.highLimit)
		end
	end)

	GR_Options.limitText = GR_Options.limitLow:CreateFontString(nil,"OVERLAY","GameFontNormal")
	GR_Options.limitText:SetPoint("BOTTOM",GR_Options.limitLow,"TOP",16,0)
	GR_Options.limitText:SetText(GR.L["Level limits"])
	
	--Advanced Options
	GR_Options.raceLimitHigh = CreateFrame("Frame","GR_RaceLimitHigh",GR_Options)
	GR_Options.raceLimitHigh:SetWidth(40)
	GR_Options.raceLimitHigh:SetHeight(40)
	GR_Options.raceLimitHigh:SetPoint("CENTER",GR_Options,"CENTER",200,80)
	GR_Options.raceLimitHigh.text = GR_Options.raceLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_Options.raceLimitHigh.text:SetPoint("CENTER")
	GR_Options.raceLimitHigh.texture = GR_Options.raceLimitHigh:CreateTexture()
	GR_Options.raceLimitHigh.texture:SetAllPoints()
	--GR_Options.raceLimitHigh.texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
	GR_Options.raceLimitHigh.texture:Hide()
	--GR_Options.raceTooltip = CreateFrame("Frame","LimitTool",GR_Options.raceLimitHigh,"GameTooltipTemplate")

	--GR_Options.raceTooltip:SetPoint("TOP",GR_Options.raceLimitHigh,"BOTTOM")
	--GR_Options.raceTooltip.text = GR_Options.raceTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	--GR_Options.raceTooltip.text:SetPoint("LEFT",GR_Options.raceTooltip,"LEFT",12,0)
	--GR_Options.raceTooltip.text:SetJustifyH("LEFT")
	--GR_Options.raceTooltip.text:SetText(GR.L["The level you wish to start dividing the search by race"])
	--GR_Options.raceTooltip.text:SetWidth(110)
	--GR_Options.raceTooltip:SetWidth(125)
	--GR_Options.raceTooltip:SetHeight(GR_Options.raceTooltip.text:GetHeight() + 12)

	GR_Options.raceLimitText = GR_Options.raceLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormal")
	GR_Options.raceLimitText:SetPoint("BOTTOM",GR_Options.raceLimitHigh,"TOP",0,3)
	GR_Options.raceLimitText:SetText(GR.L["Racefilter Start:"])

	GR_Options.raceLimitHigh.text:SetText(GR_DATA.settings.raceStart)
	GR_Options.raceLimitHigh:SetScript("OnMouseWheel",function(self,delta)
		if delta == -1 and GR_DATA.settings.raceStart > 1 then
			GR_DATA.settings.raceStart = GR_DATA.settings.raceStart - 1
			GR_Options.raceLimitHigh.text:SetText(GR_DATA.settings.raceStart)
		elseif delta == 1 and GR_DATA.settings.raceStart < GR_MAX_LEVEL_SUPER_SCAN + 1 then
			GR_DATA.settings.raceStart = GR_DATA.settings.raceStart + 1
			GR_Options.raceLimitHigh.text:SetText(GR_DATA.settings.raceStart)
			if GR_DATA.settings.raceStart > GR_MAX_LEVEL_SUPER_SCAN then
				GR_Options.raceLimitHigh.text:SetText(GR.L["OFF"])
			end
		end
	end)

	GR_Options.raceLimitHigh:SetScript("OnEnter",function()
		GR_Options.raceLimitHigh.texture:Show()
		--GR_Options.raceTooltip:Show()
	end)
	GR_Options.raceLimitHigh:SetScript("OnLeave",function()
		GR_Options.raceLimitHigh.texture:Hide()
		--GR_Options.raceTooltip:Hide()
	end)

	GR_Options.classLimitHigh = CreateFrame("Frame","GR_ClassLimitHigh",GR_Options)
	GR_Options.classLimitHigh:SetWidth(40)
	GR_Options.classLimitHigh:SetHeight(40)
	GR_Options.classLimitHigh:SetPoint("CENTER",GR_Options,"CENTER",200,20)
	GR_Options.classLimitHigh.text = GR_Options.classLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_Options.classLimitHigh.text:SetPoint("CENTER")
	GR_Options.classLimitHigh.texture = GR_Options.classLimitHigh:CreateTexture()
	GR_Options.classLimitHigh.texture:SetAllPoints()
	--GR_Options.classLimitHigh.texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
	GR_Options.classLimitHigh.texture:Hide()
	--GR_Options.classTooltip = CreateFrame("Frame","LimitTool",GR_Options.classLimitHigh,"GameTooltipTemplate")

	--GR_Options.classTooltip:SetPoint("TOP",GR_Options.classLimitHigh,"BOTTOM")
	--GR_Options.classTooltip.text = GR_Options.classTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	--GR_Options.classTooltip.text:SetPoint("LEFT",GR_Options.classTooltip,"LEFT",12,0)
	--GR_Options.classTooltip.text:SetJustifyH("LEFT")
	--GR_Options.classTooltip.text:SetText(GR.L["The level you wish to divide the search by class"])
	--GR_Options.classTooltip.text:SetWidth(110)

	--GR_Options.classTooltip:SetWidth(125)
	--GR_Options.classTooltip:SetHeight(GR_Options.classTooltip.text:GetHeight() + 12)

	GR_Options.classLimitText = GR_Options.classLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormal")
	GR_Options.classLimitText:SetPoint("BOTTOM",GR_Options.classLimitHigh,"TOP",0,3)
	GR_Options.classLimitText:SetText(GR.L["Classfilter Start:"])

	GR_Options.classLimitHigh.text:SetText(GR_DATA.settings.classStart)
	GR_Options.classLimitHigh:SetScript("OnMouseWheel",function(self,delta)
		if delta == -1 and GR_DATA.settings.classStart > 1 then
			GR_DATA.settings.classStart = GR_DATA.settings.classStart - 1
			GR_Options.classLimitHigh.text:SetText(GR_DATA.settings.classStart)
		elseif delta == 1 and GR_DATA.settings.classStart < GR_MAX_LEVEL_SUPER_SCAN + 1 then
			GR_DATA.settings.classStart = GR_DATA.settings.classStart + 1
			GR_Options.classLimitHigh.text:SetText(GR_DATA.settings.classStart)
			if GR_DATA.settings.classStart > GR_MAX_LEVEL_SUPER_SCAN then
				GR_Options.classLimitHigh.text:SetText(GR.L["OFF"])
			end
		end
	end)

	GR_Options.classLimitHigh:SetScript("OnEnter",function()
		GR_Options.classLimitHigh.texture:Show()
		--GR_Options.classTooltip:Show()
	end)
	GR_Options.classLimitHigh:SetScript("OnLeave",function()
		GR_Options.classLimitHigh.texture:Hide()
		--GR_Options.classTooltip:Hide()
	end)

	GR_Options.Interval = CreateFrame("Frame","GR_Interval",GR_Options)
	GR_Options.Interval:SetWidth(40)
	GR_Options.Interval:SetHeight(40)
	GR_Options.Interval:SetPoint("CENTER",GR_Options,"CENTER",200,-30)
	GR_Options.Interval.text = GR_Options.Interval:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_Options.Interval.text:SetPoint("CENTER")
	GR_Options.Interval.texture = GR_Options.Interval:CreateTexture()
	GR_Options.Interval.texture:SetAllPoints()
	--GR_Options.Interval.texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
	GR_Options.Interval.texture:Hide()
	--GR_Options.intervalTooltip = CreateFrame("Frame","LimitTool",GR_Options.Interval,"GameTooltipTemplate")

	--GR_Options.intervalTooltip:SetPoint("TOP",GR_Options.Interval,"BOTTOM")
	--GR_Options.intervalTooltip.text = GR_Options.intervalTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	--GR_Options.intervalTooltip.text:SetPoint("LEFT",GR_Options.intervalTooltip,"LEFT",12,0)
	--GR_Options.intervalTooltip.text:SetJustifyH("LEFT")
	--GR_Options.intervalTooltip.text:SetText(GR.L["Amount of levels to search every 7 seconds (higher numbers increase the risk of capping the search results)"])
	--GR_Options.intervalTooltip.text:SetWidth(130)
	--GR_Options.intervalTooltip:SetHeight(120)
	--GR_Options.intervalTooltip:SetWidth(135)
	--GR_Options.intervalTooltip:SetHeight(GR_Options.intervalTooltip.text:GetHeight() + 12)

	GR_Options.intervalText = GR_Options.Interval:CreateFontString(nil,"OVERLAY","GameFontNormal")
	GR_Options.intervalText:SetPoint("BOTTOM",GR_Options.Interval,"TOP",0,3)
	GR_Options.intervalText:SetText(GR.L["Interval:"])

	GR_Options.Interval.text:SetText(GR_DATA.settings.interval)
	GR_Options.Interval:SetScript("OnMouseWheel",function(self,delta)
		if delta == -1 and GR_DATA.settings.interval > 1 then
			GR_DATA.settings.interval = GR_DATA.settings.interval - 1
			GR_Options.Interval.text:SetText(GR_DATA.settings.interval)
		elseif delta == 1 and GR_DATA.settings.interval < 30 then
			GR_DATA.settings.interval = GR_DATA.settings.interval + 1
			GR_Options.Interval.text:SetText(GR_DATA.settings.interval)
		end
	end)

	GR_Options.Interval:SetScript("OnEnter",function()
		GR_Options.Interval.texture:Show()
		--GR_Options.intervalTooltip:Show()
	end)
	GR_Options.Interval:SetScript("OnLeave",function()
		GR_Options.Interval.texture:Hide()
		--GR_Options.intervalTooltip:Hide()
	end)

	anchor = {
		point = "TOPLEFT",
		relativePoint = "TOPLEFT",
		xOfs = 7,
		yOfs = -27,
	}
	GR_Options.superScanText = GR_Options:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	GR_Options.superScanText:SetPoint("TOPLEFT", GR_Options, "TOPLEFT", 40, -35);
	GR_Options.superScanText:SetText("Player Scan");
	GR_Options.buttonPlayPause = CreateButton("GR_SUPERSCAN_PLAYPAUSE2", GR_Options, 40,30,"",anchor,SSBtn3_OnClick);
	GR_SUPERSCAN_PLAYPAUSE2:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
	GR_SUPERSCAN_PLAYPAUSE2:Hide();
	GR_Options.superScanText:Hide();

	GR_Options.nextUpdate = GetTime();
	GR_Options:SetScript("OnUpdate", function()

		if (GR_Options.nextUpdate < GetTime()) then



			if GR_DATA.settings.classStart > GR_MAX_LEVEL_SUPER_SCAN then
				GR_Options.classLimitHigh.text:SetText(GR.L["OFF"])
			end

			if GR_DATA.settings.raceStart > GR_MAX_LEVEL_SUPER_SCAN then
				GR_Options.raceLimitHigh.text:SetText(GR.L["OFF"])
			end

			if (GR_DATA.settings.checkBox["CHECKBOX_BACKGROUND_MODE"]) then
				GR_SUPERSCAN_PLAYPAUSE2:Show();
				GR_Options.superScanText:Show();
				if SuperScanFrame then SuperScanFrame:Hide() end;
			else
				GR_SUPERSCAN_PLAYPAUSE2:Hide();
				GR_Options.superScanText:Hide();
				if (GR:IsScanning()) then
					--GR:ShowSuperScanFrame();
				end
			end

			if (GR_DATA.settings.checkBox["CHECKBOX_ADV_SCAN"]) then


			-- print ( GR_Options.nextUpdate) 

				if (not GR_Options.Interval:IsShown()) then
					GR_Options.Interval:Show();
				end
				if (not GR_Options.classLimitHigh:IsShown()) then
					GR_Options.classLimitHigh:Show();
				end
				if (not GR_Options.raceLimitHigh:IsShown()) then
					GR_Options.raceLimitHigh:Show();
				end
			else
				GR_Options.Interval:Hide();
				GR_Options.classLimitHigh:Hide();
				GR_Options.raceLimitHigh:Hide();
			end

		--GR_Options.Interval:Show();
		--GR_Options.classLimitHigh:Show();
		--GR_Options.raceLimitHigh:Show();



			BUTTON_INVITE.label:SetText(format(GR.L["Whisper: %d"],GR:GetNumQueued()));
--			BUTTON_KEYBIND.label:SetText(GR.L["Set Keybind ("..(GR_DATA.keyBind and GR_DATA.keyBind or "NONE")..")"]);

			if (GR_DATA.debug) then
				GR_Options.title:SetText("|cffff3300(DEBUG MODE) |rGuild Recruiter "..GR.VERSION_MAJOR..GR.VERSION_MINOR.." ")
			else
				GR_Options.title:SetText("Guild Recruiter "..GR.VERSION_MAJOR..GR.VERSION_MINOR.." ")
				
			end

			if (not GR_DATA.settings.checkBox["CHECKBOX_HIDE_MINIMAP"]) then
				GR:ShowMinimapButton();
			else
				GR:HideMinimapButton();
			end

			GR_Options.nextUpdate = GetTime() + 1;
		end
	end)

end

function GR:ShowOptions()
	if (not GR_Options) then
		CreateOptions();
	end
	GR_Options:Show();
end

function GR:HideOptions()
	if (GR_Options) then
		GR_Options:Hide();
	end
end


local function CreateMinimapButton()
	local f = CreateFrame("Button","GR_MiniMapButton",Minimap)
	f:SetWidth(24)
	f:SetHeight(24)
	f:SetFrameStrata("MEDIUM")
	f:SetMovable(true)
	SetFramePosition(f)

	f:SetNormalTexture("Interface\\AddOns\\SCGuildRecruiter\\media\\GR_MiniMapButton.tga")
	f:SetPushedTexture("Interface\\AddOns\\SCGuildRecruiter\\media\\GR_MiniMapButtonPushed.tga")
	f:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

--	local tooltip = CreateFrame("Frame","GR_TooltTipMini",f,"GameTooltipTemplate")
--	tooltip:SetPoint("BOTTOMRIGHT",f,"TOPLEFT",0,-3)
--	local toolstring = tooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
--	toolstring:SetPoint("TOPLEFT",tooltip,"TOPLEFT",5,-7)
--	local toolstring2 = tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal");
--	local toolstring3 = tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal");
--	toolstring2:SetPoint("TOPLEFT",tooltip,"TOPLEFT",7,-33);
--	toolstring3:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 7, -46);
--	toolstring2:SetText(format("ETR: %s",GR:GetSuperScanTimeLeft()));
--	toolstring3:SetText(format("%d%% done",floor(GR:GetPercentageDone())));
--
--	local tUpdate = 0;
--	local function UpdateTooltip()
--		if (tUpdate < GetTime()) then
--			toolstring:SetText(GR.LOGO..format("|cff88aaffGuildRecruiter|r\n|cff16ABB5Queue: %d|r",GR:GetNumQueued()))
--			toolstring2:SetText(format("ETR: %s",GR:GetSuperScanTimeLeft()));
--			toolstring3:SetText(format("%d%% done",floor(GR:GetPercentageDone())));
--			GR:debug(format("ETR: %s",GR:GetSuperScanETR()));
--			GR:debug(format("%d%% done",floor(GR:GetPercentageDone())));
--			tUpdate = GetTime() + 0.2;
--		end
--	end
--
--	toolstring:SetText(GR.LOGO..format("|cff88aaffGuildRecruiter|r\n|cff16ABB5Queue: |r|cffffff00%d|r",GR:GetNumQueued()))
--	toolstring:SetJustifyH("LEFT");
--	tooltip:SetWidth(max(toolstring:GetWidth(),toolstring2:GetWidth(),toolstring3:GetWidth())+ 20)
--	tooltip:SetHeight(toolstring:GetHeight() + toolstring2:GetHeight() + toolstring3:GetHeight() + 15)
--	--tooltip:Hide(2)
--	f:SetScript("OnEnter",function()
--		toolstring:SetText(GR.LOGO..format("|cff88aaffGuildRecruiter|r\n|cff16ABB5Queue: %d|r",GR:GetNumQueued()))
--		tooltip:Show()
--		tooltip:SetScript("OnUpdate",UpdateTooltip);
--	end)
--	f:SetScript("OnLeave",function()
--	--tooltip:Hide()
--	--tooltip:Hide()
--	tooltip:SetScript("OnUpdate", nil);
--	end)


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
		if GR_Options and GR_Options:IsShown() then
			GR:HideOptions()
		else
			GR:ShowOptions()
		end
	end)
end

function GR:ShowMinimapButton()
	if (not GR_MiniMapButton) then
		CreateMinimapButton();
	end
	GR_MiniMapButton:Show();
end

function GR:HideMinimapButton()
	if (GR_MiniMapButton) then
		GR_MiniMapButton:Hide();
	end
end








GR:debug(">> GUI.lua");
