local function onClickTester(self)
	if self then
		GR:print("Click on "..self:GetName());
	end
end

function GR_OnLoad(self)
    self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
    self:RegisterEvent("CHAT_MSG_ACHIEVEMENT")
    self:RegisterEvent("CHAT_MSG_PARTY")
    self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	if(GR_GratsMessage1 == nil or "")then
		GR_GratsMessage1 = "Grats!";
		GR_LastMessage = 1;
	end
	if(GR_GratsMessage2 == nil or "")then
		GR_GratsMessage2 = GR_GratsMessage1;
	end
	if(GR_GratsMessage3 == nil or "")then
		GR_GratsMessage3 = GR_GratsMessage1;
	end
	if(GR_GuildJoinMessageToggle == nil)then
		GR_GuildJoinMessageToggle = true;
	end
	if(GR_Guild == nil)then
		GR_Guild = true;
	end
	if(GR_Say == nil)then
		GR_Say = false;
	end
	if(GR_Party == nil)then
		GR_Party = true;
	end
	if(GR_Delay == nil)then
		GR_Delay = 4000;
	end
	if(GR_GroupingTime == nil)then
		GR_GroupingTime = 6000;
	end
	if(GR_GuildDisabledOverride == nil)then
		GR_GuildDisabledOverride = false;
	end
	if(GR_GuildWelcomeMessage1 == nil)then
		GR_GuildWelcomeMessage1 = "Welcome!";
	end
	if(GR_GuildWelcomeMessage2 == nil or "")then
		GR_GuildWelcomeMessage2 = GR_GuildWelcomeMessage1;
	end
	if(GR_GuildWelcomeMessage3 == nil or "")then
		GR_GuildWelcomeMessage3 = GR_GuildWelcomeMessage1;
	end
	if(GR_HideWhisperToggle == nil)then
		GR_HideWhisperToggle = false;
	end
	GR_Print("Guild Recruiter Enabled");
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
--[==[
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
--]==]
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
	GR_PlayerList.progressTexture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark");
	GR_PlayerList.progressTexture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark");
	
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
				GR_PlayerList.items[i].highlight:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
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
	CreateFrame("Frame","GR_Invites", UIParent, "BasicFrameTemplate")
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
	GR_Invites:SetBackdrop(backdrop)

	GR_Invites.text = GR_Invites:CreateFontString(nil,"OVERLAY","GameFontNormalTiny")
	GR_Invites.text:SetPoint("TOP",GR_Invites,"TOP",-7,-7)
	GR_Invites.text:SetText(GR.L["Left Click Name to Whisper, Right Click to Blacklist"])
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
				GR_Invites.items[i].highlight:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
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

	-------------------------
	-- Edit Whisper Window --
	-------------------------

local function CreateWhisperDefineFrame()
	
	---------------------
	-- Window Defaults --
	---------------------
	
	CreateFrame("Frame","GR_Whisper", UIParent, "BasicFrameTemplate");
	GR_Whisper:SetSize(700,340);
	GR_Whisper:SetPoint("CENTER", UIParent, "CENTER");
	GR_Whisper:SetMovable(true)
	GR_Whisper:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	GR_Whisper:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		SaveFramePosition(GR_Whisper)
	end)
	
	------------
	-- Config --
	------------
	
	GR_Whisper.title = GR_Whisper:CreateFontString(nil, "OVERLAY");
	GR_Whisper.title:SetFontObject("GameFontHighlight");
	GR_Whisper.title:SetPoint("CENTER", GR_Whisper.TitleBg, "CENTER", 5,0);
	GR_Whisper.title:SetText("Guild Recruiter Custom Whispers");

	------------------
	-- Editbox Text --
	------------------

	GR_Whisper.info = GR_Whisper:CreateFontString(nil,"OVERLAY","GameFontHighlight")
	GR_Whisper.info:SetPoint("CENTER",GR_Whisper,"CENTER",0,115)
	GR_Whisper.info:SetText("Create up to 3 custom recruitment messages to whisper to people you would like to join your guild. Make it flashy and give as much information as you can, but don't go over the 256 character limit! Good Luck!")
	GR_Whisper.info:SetWidth(650)
	GR_Whisper.info:SetJustifyH("CENTER")
	
	---------------
	-- Editbox 1 --
	---------------
	
	GR_Whisper.edit = CreateFrame("EditBox", "GR_WhisperMessage1", GR_Whisper, "InputBoxTemplate")
	GR_Whisper.edit:SetFrameLevel(300)
	GR_Whisper.edit:SetSize(650,30)
	GR_Whisper.edit:SetMultiLine(false)
    GR_Whisper.edit:ClearAllPoints()
	GR_Whisper.edit:SetPoint("CENTER",GR_Whisper,"CENTER",0,50)
	GR_Whisper.edit:SetCursorPosition(0);
	GR_Whisper.edit:ClearFocus();
    GR_Whisper.edit:SetAutoFocus(false)
	GR_Whisper.edit:SetScript("OnShow", function(self,event,arg1)
		self:SetText(GR_DATA.settings.whispers[1])
		self:SetCursorPosition(0);
		self:ClearFocus();
	end)
	GR_Whisper.edit:SetMaxLetters(256)
	GR_Whisper.edit:SetScript("OnTextChanged", function(self,value)
		GR_DATA.settings.whispers[1] = self:GetText()
	end)
	GR_Whisper.edit:SetText(GR_DATA.settings.whispers[1])
	GR_Whisper.edit:SetScript("OnHide",function()
		GR_Whisper.edit:SetText(GR_DATA.settings.whispers[1])
	end)
	GR_Whisper.editLabel = CreateBasicFontString(GR_Whisper.edit,"GR_Whisper.editLabel","OVERLAY","GameFontNormal","Whisper #1");
	GR_Whisper.editLabel:SetPoint("BOTTOMLEFT", GR_Whisper.edit, "TOPLEFT", 0, 0)
	
	---------------
	-- Editbox 2 --
	---------------	
	
	GR_Whisper.edit = CreateFrame("EditBox", "GR_WhisperMessage2", GR_Whisper, "InputBoxTemplate")
	GR_Whisper.edit:SetFrameLevel(300)
	GR_Whisper.edit:SetSize(650,30)
	GR_Whisper.edit:SetMultiLine(false)
    GR_Whisper.edit:ClearAllPoints()
	GR_Whisper.edit:SetPoint("CENTER",GR_Whisper,"CENTER",0,0)
	GR_Whisper.edit:SetCursorPosition(0);
	GR_Whisper.edit:ClearFocus();
    GR_Whisper.edit:SetAutoFocus(false)
	GR_Whisper.edit:SetScript("OnShow", function(self,event,arg1)
		self:SetText(GR_DATA.settings.whispers[2])
		self:SetCursorPosition(0);
		self:ClearFocus();
	end)
	GR_Whisper.edit:SetMaxLetters(256)
	GR_Whisper.edit:SetScript("OnTextChanged", function(self,value)
		GR_DATA.settings.whispers[2] = self:GetText()
	end)
	GR_Whisper.edit:SetText(GR_DATA.settings.whispers[2])
	GR_Whisper.edit:SetScript("OnHide",function()
		GR_Whisper.edit:SetText(GR_DATA.settings.whispers[2])
	end)
	GR_Whisper.editLabel = CreateBasicFontString(GR_Whisper.edit,"GR_Whisper.editLabel","OVERLAY","GameFontNormal","Whisper #2");
	GR_Whisper.editLabel:SetPoint("BOTTOMLEFT", GR_Whisper.edit, "TOPLEFT", 0, 0)
	
	---------------
	-- Editbox 3 --
	---------------
	
	GR_Whisper.edit = CreateFrame("EditBox", "GR_WhisperMessage3", GR_Whisper, "InputBoxTemplate")
	GR_Whisper.edit:SetFrameLevel(300)
	GR_Whisper.edit:SetSize(650,30)
	GR_Whisper.edit:SetMultiLine(false)
    GR_Whisper.edit:ClearAllPoints()
	GR_Whisper.edit:SetPoint("CENTER",GR_Whisper,"CENTER",0,-50)
	GR_Whisper.edit:SetCursorPosition(0);
	GR_Whisper.edit:ClearFocus();
    GR_Whisper.edit:SetAutoFocus(false)
	GR_Whisper.edit:SetScript("OnShow", function(self,event,arg1)
		self:SetText(GR_DATA.settings.whispers[3])
		self:SetCursorPosition(0);
		self:ClearFocus();
	end)
	GR_Whisper.edit:SetMaxLetters(256)
	GR_Whisper.edit:SetScript("OnTextChanged", function(self,value)
		GR_DATA.settings.whispers[3] = self:GetText()
	end)
	GR_Whisper.edit:SetText(GR_DATA.settings.whispers[3])
	GR_Whisper.edit:SetScript("OnHide",function()
		GR_Whisper.edit:SetText(GR_DATA.settings.whispers[3])
	end)
	GR_Whisper.editLabel = CreateBasicFontString(GR_Whisper.edit,"GR_Whisper.editLabel","OVERLAY","GameFontNormal","Whisper #3");
	GR_Whisper.editLabel:SetPoint("BOTTOMLEFT", GR_Whisper.edit, "TOPLEFT", 0, 0)	
	
	--------------------------------------------------
	-- Anchor Point for the editbox preview buttons --
	--------------------------------------------------
	
	local anchor = {};	
		anchor.point = "TOPRIGHT"
		anchor.relativePoint = "TOPRIGHT"
		anchor.xOfs = -104
		anchor.yOfs = -130

	-----------------------------
	-- editbox preview buttons --
	-----------------------------
	
	GR_Whisper.button1 = CreateButton("BUTTON_PREVIEW_WHISPER", GR_Whisper, 80, 20, "Preview", anchor, function(self) SendChatMessage(GR_DATA.settings.whispers[1],"WHISPER",nil,UnitName("player"))end);
		anchor.yOfs = anchor.yOfs - 50;
	GR_Whisper.button2 = CreateButton("BUTTON_PREVIEW_WHISPER", GR_Whisper, 80, 20, "Preview", anchor, function(self) SendChatMessage(GR_DATA.settings.whispers[2],"WHISPER",nil,UnitName("player"))end);
		anchor.yOfs = anchor.yOfs - 50;
	GR_Whisper.button3 = CreateButton("BUTTON_PREVIEW_WHISPER", GR_Whisper, 80, 20, "Preview", anchor, function(self) SendChatMessage(GR_DATA.settings.whispers[3],"WHISPER",nil,UnitName("player"))end);
		anchor.yOfs = anchor.yOfs - 50;

	-------------------------------------------------------
	-- Anchor Point for the editbox (dummy) save buttons --
	-------------------------------------------------------
	
		anchor.point = "TOPRIGHT"
		anchor.relativePoint = "TOPRIGHT"
		anchor.xOfs = -24
		anchor.yOfs = -130
		
	---------------------------------------------------------------------------------------------------------	
	-- save buttons (these don't actually do anything aside from provide the user with necessary feedback) --
	---------------------------------------------------------------------------------------------------------
	
	GR_Whisper.button4 = CreateButton("BUTTON_SAVE_WHISPER", GR_Whisper, 80, 20, "Save", anchor, function(self) GR_Print("Whisper #1 Saved.")end);
		anchor.yOfs = anchor.yOfs - 50;
	GR_Whisper.button5 = CreateButton("BUTTON_SAVE_WHISPER", GR_Whisper, 80, 20, "Save", anchor, function(self) GR_Print("Whisper #2 Saved.")end);
		anchor.yOfs = anchor.yOfs - 50;
	GR_Whisper.button6 = CreateButton("BUTTON_SAVE_WHISPER", GR_Whisper, 80, 20, "Save", anchor, function(self) GR_Print("Whisper #3 Saved.")end);
		anchor.yOfs = anchor.yOfs - 50;
	
	----------------
	-- Guild Logo --
	----------------
	
	GR_Whisper.guildlogo = CreateFrame("Frame","guildlogo",GR_Whisper)
	GR_Whisper.guildlogo:SetWidth(64)
	GR_Whisper.guildlogo:SetHeight(64)
	GR_Whisper.guildlogo:SetPoint("CENTER",GR_Whisper,"CENTER",-5,-110)
	GR_Whisper.guildlogo.text = GR_Options.guildlogo:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_Whisper.guildlogo.text:SetPoint("CENTER")
	GR_Whisper.guildlogo.texture = GR_Whisper.guildlogo:CreateTexture()
	GR_Whisper.guildlogo.texture:SetAllPoints()
	GR_Whisper.guildlogo.texture:SetTexture("Interface\\AddOns\\SCGuildRecruiter\\media\\grlogo.blp")
	GR_Whisper.guildlogo.texture:Show()

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
	GR_Options.bottom:SetText("|cff88aaffWritten and Maintained by The Shadow Collective|r");
	
	--Menu Text
	GR_Options.top = GR_Options:CreateFontString(nil, "OVERLAY");
	GR_Options.top:SetFontObject("GameFontHighlight");
	GR_Options.top:SetPoint("TOP", GR_Options, "TOP", -5, -30);
	GR_Options.top:SetText("Options Menu");
	
	--Scroll Text
	GR_Options.optionHelpText = GR_Options:CreateFontString(nil, "OVERLAY","GameFontNormalTiny");
	GR_Options.optionHelpText:SetText("|cff00D2FFScroll to change levels|r");
	GR_Options.optionHelpText:SetPoint("TOP",GR_Options,"TOP",-5,-200);

	--Logo
	GR_Options.guildlogo = CreateFrame("Frame","guildlogo",GR_Options)
	GR_Options.guildlogo:SetWidth(64)
	GR_Options.guildlogo:SetHeight(64)
	GR_Options.guildlogo:SetPoint("CENTER",GR_Options,"CENTER",-5,50)
	GR_Options.guildlogo.text = GR_Options.guildlogo:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	GR_Options.guildlogo.text:SetPoint("CENTER")
	GR_Options.guildlogo.texture = GR_Options.guildlogo:CreateTexture()
	GR_Options.guildlogo.texture:SetAllPoints()
	GR_Options.guildlogo.texture:SetTexture("Interface\\AddOns\\SCGuildRecruiter\\media\\grlogo.blp")
	GR_Options.guildlogo.texture:Show()
	

	--Anchor Local Variable
	local anchor = {}
	
	--Checkbox Anchor
		anchor.point = "TOPLEFT"
		anchor.relativePoint = "TOPLEFT"
		anchor.xOfs = 7
		anchor.yOfs = -80

	--Checkboxes
	local spacing = 45;
	
	--------------------------------
	-- Hide Whispers Check Button --
	--------------------------------
	
	GR_Options.hideWhispersCheckButton = CreateFrame("CheckButton","GR_HideWhisperCheckButton",GR_Options,"UICheckButtonTemplate")
	GR_Options.hideWhispersCheckButton:SetFrameLevel(300)
	GR_Options.hideWhispersCheckButton:SetPoint("TOPLEFT",7,-160)
	GR_Options.hideWhispersCheckButton.text:SetText("Hide Outgoing Whispers")
	GR_Options.hideWhispersCheckButton:SetScript("OnShow", function(self,event,arg1) 
		self:SetChecked(GR_HideWhisperToggle);
	end)
	GR_Options.hideWhispersCheckButton:SetScript("OnClick", function(self,event,arg1) 
		GR_ToggleHideWhisper();
	end)
	
	-------------------------
	-- Hide Whisper Toggle --
	-------------------------
	
	function GR_ToggleHideWhisper()

	if(GR_HideWhisperToggle) then 
		GR_HideWhisperToggle = false; 
		GR_Print("Hide Whispers Off");
	else
		GR_HideWhisperToggle = true;    
		GR_Print("Hide Whispers On");
	end;
	GR_Options.hideWhispersCheckButton:SetChecked(GR_HideWhisperToggle);
	end
	
	---------------------------
	-- Hide Whisper Function --
	---------------------------

	local function Filter ( self, Event, Message )
		if (GR_HideWhisperToggle == true) then
			return true;
		end
	end
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_WHISPER_INFORM", Filter );
	
	--Anchor Point for the bottom row of buttons
		anchor.point = "BOTTOMLEFT"
		anchor.relativePoint = "BOTTOMLEFT"
		anchor.xOfs = 154.5
		anchor.yOfs = 25

	--onClickTester
	GR_Options.button1 = CreateButton("BUTTON_CUSTOM_WHISPER", GR_Options, 92, 30, "Edit Whispers", anchor, function(self) ShowWhisperFrame() GR_Options:Hide() GR_Options.showAgain = true end);
		anchor.xOfs = anchor.xOfs + 125;
	--GR_Options.button5 = CreateButton("BUTTON_CUSTOM_WELCOME", GR_Options, 92, 30, "Set Welcome", anchor, function(self) ShowWelcomeFrame() GR_Options:Hide() GR_Options.showAgain = true end);
	--	anchor.xOfs = anchor.xOfs + 100;
	--GR_Options.button4 = CreateButton("BUTTON_FILTER", GR_Options, 92, 30, "Set Filters", anchor, function() GR:ShowFilterHandle() GR_Options:Hide() end);
	--	anchor.xOfs = anchor.xOfs + 100;
	--GR_Options.button2 = CreateButton("BUTTON_SUPER_SCAN", GR_Options, 92, 30, "Scan", anchor, OptBtn2_OnClick);
		--anchor.xOfs = anchor.xOfs + 125;
	GR_Options.button3 = CreateButton("BUTTON_INVITE", GR_Options, 92, 30, format("Whisper: %d",GR:GetNumQueued()), anchor, GR.SendGuildInvite);
		anchor.xOfs = anchor.xOfs + 125;
	--GR_Options.button6 = CreateButton("BUTTON_BLACKLIST", GR_Options, 92, 30, "Black List", anchor, function(self) ShowBlackListFrame() GR_Options:Hide() GR_Options.showAgain = true end);
		--anchor.xOfs = anchor.xOfs + 125;
	
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
	GR_Options.raceLimitHigh:SetPoint("CENTER",GR_Options,"CENTER",180,60)
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
	GR_Options.raceLimitText:SetText("Race Filter Start:")

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
	GR_Options.classLimitHigh:SetPoint("CENTER",GR_Options,"CENTER",180,0)
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
	GR_Options.classLimitText:SetText("Class Filter Start:")

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
	GR_Options.Interval:SetPoint("CENTER",GR_Options,"CENTER",180,-50)
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
		xOfs = 9,
		yOfs = -115,
	}
	GR_Options.superScanText = GR_Options:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	GR_Options.superScanText:SetPoint("TOPLEFT", GR_Options, "TOPLEFT", 40, -125);
	GR_Options.superScanText:SetText("Player Scan");
	GR_Options.buttonPlayPause = CreateButton("GR_SUPERSCAN_PLAYPAUSE2", GR_Options, 38,30,"",anchor,SSBtn3_OnClick);
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
				if SuperScanFrame then SuperScanFrame:Show() end;
			else
				GR_SUPERSCAN_PLAYPAUSE2:Show();
				GR_Options.superScanText:Show();
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
				GR_Options.Interval:Show();
				GR_Options.classLimitHigh:Show();
				GR_Options.raceLimitHigh:Show();
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
--[[
function GR_OnEvent(self,event,arg1,arg2)
	if(event == "GUILD_ROSTER_UPDATE")then GR_CheckOverride(); return end
	
    if(not GR_IsMe(arg2))then
	    if(event == "CHAT_MSG_GUILD_ACHIEVEMENT" and not GR_GuildDisabledOverride)then GR_DoGrats("GUILD");
	    elseif(event == "CHAT_MSG_ACHIEVEMENT")then GR_DoGrats("SAY");
	    elseif(event == "CHAT_MSG_ACHIEVEMENT")then GR_DoGrats("PARTY");
	    elseif(event == "CHAT_MSG_SYSTEM" and not GR_GuildDisabledOverride) then
	    	if(arg1 ~= nil) then
				if(string.find(arg1,"has joined the guild.")) then SendChatMessage(GetRandomArgument("Goat is amazing!","I'm in love with a farm animal!","I love Goat!"), "GUILD");
				end
			end
	    end
	end
end

function GR_IsMe(nameString)
	local name,server = split(nameString,"-")
	local myName, myServer = UnitName("player")
	if(myServer == nil)then
		myServer = GetRealmName();
	end
	if(server == nil and name == myName)then
		return true;
	elseif(server ~= nil and name == myName and server == myServer)then
		return true;
	else
		return false;
	end
end

function GR_CheckOverride()
	local myName = UnitName("player")
	for index=1, GetNumGuildMembers() do 
		
		 local name,_,_,_,_,_,note = GetGuildRosterInfo(index)
		 if GR_IsMe(name) then
			 note = note:lower()
			 if note:match("noag") then
				GR_GuildDisabledOverride = true;
				return true;
			 else
				GR_GuildDisabledOverride = false;
				return false;
			 end
			 break
		 end
	end
	return false;
end
--]]
function GR_Print(msg)
	print("\124cffff6060[GR]\124r",msg);
end

 function GR_GetCmd(msg)
 	if msg then
 		local a=(msg);
 		if a then
 			return msg
 		else	
 			return "";
 		end
 	end
 end

	function CreateBasicFontString(parent, name, layer, template, text)
		local fs = parent:CreateFontString(name,layer,template)
			fs:SetText(text)
		return fs
	end
  
	function CreateBasicSlider(parent, name, title, minVal, maxVal, valStep)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    local editbox = CreateFrame("EditBox", "$parentEditBox", slider, "InputBoxTemplate")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValue(minVal)
    slider:SetValueStep(1)
    slider.text = _G[name.."Text"]
    slider.text:SetText(title)
    slider.textLow = _G[name.."Low"]
    slider.textHigh = _G[name.."High"]
    slider.textLow:SetText(floor(minVal))
    slider.textHigh:SetText(floor(maxVal))
    slider.textLow:SetTextColor(0.4,0.4,0.4)
    slider.textHigh:SetTextColor(0.4,0.4,0.4)
    editbox:SetSize(50,30)
	editbox:SetNumeric(true)
	editbox:SetMultiLine(false)
	editbox:SetMaxLetters(5)
    editbox:ClearAllPoints()
    editbox:SetPoint("TOP", slider, "BOTTOM", 0, -5)
    editbox:SetNumber(slider:GetValue())
	editbox:SetCursorPosition(0);
	editbox:ClearFocus();
    editbox:SetAutoFocus(false)
    slider:SetScript("OnValueChanged", function(self,value)
		self.editbox:SetNumber(floor(value))
		if(not self.editbox:HasFocus())then
			self.editbox:SetCursorPosition(0);
			self.editbox:ClearFocus();
		end
    end)
    editbox:SetScript("OnTextChanged", function(self)
      local value = self:GetText()
      if tonumber(value) then
		if(floor(value) > maxVal)then
			self:SetNumber(maxVal)
		end
        if floor(self:GetParent():GetValue()) ~= floor(value) then
          self:GetParent():SetValue(floor(value))
        end
      end
    end)
    editbox:SetScript("OnEnterPressed", function(self)
      local value = self:GetText()
      if tonumber(value) then
        self:GetParent():SetValue(floor(value))
        self:ClearFocus()
      end
    end)
    slider.editbox = editbox
    return slider
  end

GR:debug(">> GUI.lua");
