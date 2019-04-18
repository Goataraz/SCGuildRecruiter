function AGW_OnLoad(self)
    self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
    self:RegisterEvent("CHAT_MSG_ACHIEVEMENT")
    self:RegisterEvent("CHAT_MSG_PARTY")
    self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
    --slash commands
	SlashCmdList["AGW"] = AGW_Command;
    SLASH_AGW1 = "/agw";
    SLASH_AGW2 = "/autograts";
    if(AGW_GratsMessage == nil)then
		AGW_GratsMessage="Grats!";
	end
	if(AGW_GuildJoinMessageToggle == nil)then
		AGW_GuildJoinMessageToggle = true;
	end
	if(AGW_Guild == nil)then
		AGW_Guild = false;
	end
	if(AGW_Say == nil)then
		AGW_Say = false;
	end
	if(AGW_Party == nil)then
		AGW_Party = false;
	end
	if(AGW_Delay == nil)then
		AGW_Delay=4000;
	end
	if(AGW_GroupingTime == nil)then
		AGW_GroupingTime=4000;
	end
	if(AGW_GuildDisabledOverride == nil)then
		AGW_GuildDisabledOverride = false;
	end
	if(AGW_GuildWelcomeMessage == nil)then
		AGW_GuildWelcomeMessage = "Welcome to the guild!";		
	end
	AGW_SetupOptionsUI();
	AGW_Print("Please visit http://shadowco.io/ for feedback and support.");
end

function AGW_SetupOptionsUI()
	AutoGratsAndWelcome = {};
	AutoGratsAndWelcome.ui = {};
	AutoGratsAndWelcome.ui.panel = CreateFrame( "Frame", "AutoGratsAndWelcomePanel", InterfaceOptionsFramePanelContainer );
	AutoGratsAndWelcome.ui.panel.name = "Guild Recruiter Auto Grats and Welcome Options";

	--Guild Check Button
	AutoGratsAndWelcome.ui.guildCheckButton = CreateFrame("CheckButton","AGW_GuildCheckButton",AutoGratsAndWelcome.ui.panel,"UICheckButtonTemplate") --frameType, frameName, frameParent, frameTemplate    
	AutoGratsAndWelcome.ui.guildCheckButton:SetPoint("TOPLEFT",20,-20)
	AutoGratsAndWelcome.ui.guildCheckButton.text:SetText("Guild Gratzing")
	AutoGratsAndWelcome.ui.guildCheckButton:SetScript("OnShow", function(self,event,arg1) 
		self:SetChecked(AGW_Guild);
	end)
	AutoGratsAndWelcome.ui.guildCheckButton:SetScript("OnClick", function(self,event,arg1) 
		AGW_ToggleGuild();
	end)

	--Party Check Button
	AutoGratsAndWelcome.ui.partyCheckButton = CreateFrame("CheckButton","AGW_PartyCheckButton",AutoGratsAndWelcome.ui.panel,"UICheckButtonTemplate") --frameType, frameName, frameParent, frameTemplate    
	AutoGratsAndWelcome.ui.partyCheckButton:SetPoint("TOPLEFT",20,-40)
	AutoGratsAndWelcome.ui.partyCheckButton.text:SetText("Party Gratzing")
	AutoGratsAndWelcome.ui.partyCheckButton:SetScript("OnShow", function(self,event,arg1) 
		self:SetChecked(AGW_Party);
	end)
	AutoGratsAndWelcome.ui.partyCheckButton:SetScript("OnClick", function(self,event,arg1) 
		AGW_ToggleParty();
	end)

	--Say Check Button
	AutoGratsAndWelcome.ui.sayCheckButton = CreateFrame("CheckButton","AGW_SayCheckButton",AutoGratsAndWelcome.ui.panel,"UICheckButtonTemplate") --frameType, frameName, frameParent, frameTemplate    
	AutoGratsAndWelcome.ui.sayCheckButton:SetPoint("TOPLEFT",20,-60)
	AutoGratsAndWelcome.ui.sayCheckButton.text:SetText("Say Gratzing")
	AutoGratsAndWelcome.ui.sayCheckButton:SetScript("OnShow", function(self,event,arg1) 
		self:SetChecked(AGW_Say);
	end)
	AutoGratsAndWelcome.ui.sayCheckButton:SetScript("OnClick", function(self,event,arg1) 
		AGW_ToggleSay();
	end)

	--Guild Welcome Check Button
	AutoGratsAndWelcome.ui.guildWelcomeCheckButton = CreateFrame("CheckButton","AGW_GuildWelcomeCheckButton",AutoGratsAndWelcome.ui.panel,"UICheckButtonTemplate") --frameType, frameName, frameParent, frameTemplate    
	AutoGratsAndWelcome.ui.guildWelcomeCheckButton:SetPoint("TOPLEFT",20,-100)
	AutoGratsAndWelcome.ui.guildWelcomeCheckButton.text:SetText("New Guild Member Welcoming")
	AutoGratsAndWelcome.ui.guildWelcomeCheckButton:SetScript("OnShow", function(self,event,arg1) 
		self:SetChecked(AGW_GuildJoinMessageToggle);
	end)
	AutoGratsAndWelcome.ui.guildWelcomeCheckButton:SetScript("OnClick", function(self,event,arg1) 
		AGW_ToggleGuildWelcome();
	end)

	--Delay Slider
	AutoGratsAndWelcome.ui.delaySlider = CreateBasicSlider(AutoGratsAndWelcome.ui.panel, "AGW_DelaySlider", "Delay in milliseconds before sending the message", 0, 60000, 100);
	AutoGratsAndWelcome.ui.delaySlider:HookScript("OnValueChanged", function(self,value)
		AGW_Delay = floor(value)
	end)
	AutoGratsAndWelcome.ui.delaySlider:HookScript("OnShow", function(self,value)
		self:SetValue(AGW_Delay);
		self.editbox:SetNumber(AGW_Delay);
	end)
	AutoGratsAndWelcome.ui.delaySlider.editbox:SetScript("OnShow", function(self,event,arg1)
		self:SetNumber(AGW_Delay);
	end)
	AutoGratsAndWelcome.ui.delaySlider:SetPoint("TOPRIGHT",-120,-20)

	--Grouping Slider
	AutoGratsAndWelcome.ui.groupingSlider = CreateBasicSlider(AutoGratsAndWelcome.ui.panel, "AGW_GroupingSlider", "Delay in milliseconds after a message is sent that it won't send another", 0, 60000, 100);
	AutoGratsAndWelcome.ui.groupingSlider:HookScript("OnValueChanged", function(self,value)
		AGW_GroupingTime = floor(value)
	end)
	AutoGratsAndWelcome.ui.groupingSlider:HookScript("OnShow", function(self,value)
		self:SetValue(AGW_GroupingTime);
		self.editbox:SetNumber(AGW_GroupingTime);
	end)
	AutoGratsAndWelcome.ui.groupingSlider.editbox:SetScript("OnShow", function(self,event,arg1)
		self:SetNumber(AGW_GroupingTime);
	end)
	AutoGratsAndWelcome.ui.groupingSlider:SetPoint("TOPRIGHT",-120,-100)
	--AutoGratsAndWelcome.ui.delayLabel = AutoGratsAndWelcome.ui.panel:CreateFontString(nil,"OVERLAY","GameFontNormal", 200,200)
	--AutoGratsAndWelcome.ui.delayLabel:SetText("delay")
	--AutoGratsAndWelcome.ui.delayEditBox = CreateFrame("EditBox","AGW_DelayEditBox",AutoGratsAndWelcome.ui.panel,"InputBoxTemplate") --frameType, frameName, frameParent, frameTemplate    
	--AutoGratsAndWelcome.ui.delayEditBox:SetSize(50,30)
 --   AutoGratsAndWelcome.ui.delayEditBox:ClearAllPoints()
	--AutoGratsAndWelcome.ui.delayEditBox:SetPoint("TOPLEFT",120,-120)
 --   AutoGratsAndWelcome.ui.delayEditBox:SetText("test");
 --   AutoGratsAndWelcome.ui.delayEditBox:SetAutoFocus(false)
	--AutoGratsAndWelcome.ui.delayEditBox.text:SetText("Delay(ms)")
	--AutoGratsAndWelcome.ui.delayEditBox:SetScript("OnShow", function(self,event,arg1) 
		--self:SetChecked(AGW_Say);
	--end)

	--Grats Message
	AutoGratsAndWelcome.ui.gratsMessageEditBox = CreateFrame("EditBox", "AGW_GratsMessage", AutoGratsAndWelcome.ui.panel, "InputBoxTemplate")
	AutoGratsAndWelcome.ui.gratsMessageEditBox:SetSize(500,30)
	AutoGratsAndWelcome.ui.gratsMessageEditBox:SetMultiLine(false)
    AutoGratsAndWelcome.ui.gratsMessageEditBox:ClearAllPoints()
	AutoGratsAndWelcome.ui.gratsMessageEditBox:SetPoint("TOPLEFT",20,-180)
	AutoGratsAndWelcome.ui.gratsMessageEditBox:SetCursorPosition(0);
	AutoGratsAndWelcome.ui.gratsMessageEditBox:ClearFocus();
    AutoGratsAndWelcome.ui.gratsMessageEditBox:SetAutoFocus(false)
	AutoGratsAndWelcome.ui.gratsMessageEditBox:SetScript("OnShow", function(self,event,arg1)
		self:SetText(AGW_GratsMessage)
		self:SetCursorPosition(0);
		self:ClearFocus();
	end)
	AutoGratsAndWelcome.ui.gratsMessageEditBox:SetScript("OnTextChanged", function(self,value)
		AGW_GratsMessage = self:GetText()
	end)
	AutoGratsAndWelcome.ui.gratsMessageLabel = CreateBasicFontString(AutoGratsAndWelcome.ui.gratsMessageEditBox,"AGW_GratsMessageLabel","OVERLAY","GameFontNormal","Grats Message");
	AutoGratsAndWelcome.ui.gratsMessageLabel:SetPoint("BOTTOMLEFT", AutoGratsAndWelcome.ui.gratsMessageEditBox, "TOPLEFT", 0, 0)

	--Welcome to Guild Message
	AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox = CreateFrame("EditBox", "AGW_GuildWelcomeMessage", AutoGratsAndWelcome.ui.panel, "InputBoxTemplate")
	AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox:SetSize(500,30)
	AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox:SetMultiLine(false)
    AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox:ClearAllPoints()
	AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox:SetPoint("TOPLEFT",20,-240)
	AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox:SetCursorPosition(0);
	AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox:ClearFocus();
    AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox:SetAutoFocus(false)
	AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox:SetScript("OnShow", function(self,event,arg1)
		self:SetText(AGW_GuildWelcomeMessage)
		self:SetCursorPosition(0);
		self:ClearFocus();
	end)
	AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox:SetScript("OnTextChanged", function(self,value)
		AGW_GuildWelcomeMessage = self:GetText()
	end)
	AutoGratsAndWelcome.ui.guildWelcomeMessageLabel = CreateBasicFontString(AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox,"AGW_GuildWelcomeMessageLabel","OVERLAY","GameFontNormal","Guild Welcome Message");
	AutoGratsAndWelcome.ui.guildWelcomeMessageLabel:SetPoint("BOTTOMLEFT", AutoGratsAndWelcome.ui.guildWelcomeMessageEditBox, "TOPLEFT", 0, 0)


	InterfaceOptions_AddCategory(AutoGratsAndWelcome.ui.panel);
	
end

 function AGW_GetCmd(msg)
 	if msg then
 		local a=(msg); --contiguous string of non-space characters
 		if a then
 			return msg
 		else	
 			return "";
 		end
 	end
 end

function AGW_ShowHelp()
	print("AutoGratsAndWelcome usage:");
	print("'/ag' or '/ag options' to show options ui");
	print("'/ag {msg}' or '/AutoGratsAndWelcome {msg}'");
	print("'/ag delay {delay}' or '/AutoGratsAndWelcome {delay}', with delay in milliseconds to set delay");
	print("'/ag guild' or '/AutoGratsAndWelcome guild' to enable/disable guild gratzing");
	print("'/ag say' or '/AutoGratsAndWelcome say' to enable/disable say gratzing");
	print("'/ag party' or '/AutoGratsAndWelcome party' to enable/disable say gratzing");
end

function AGW_ToggleGuild()
	if(AGW_Guild) then 
		AGW_Guild = false; 
		AGW_Print("Guild gratzing now off");
	else
		AGW_Guild = true;    
		AGW_Print("Guild gratzing now on");
	end;
	AutoGratsAndWelcome.ui.guildCheckButton:SetChecked(AGW_Guild);
end

function AGW_ToggleSay()
	if(AGW_Say) then 
		AGW_Say = false; 
		AGW_Print("Say gratzing now off");
	else
		AGW_Say = true;
		AGW_Print("Say gratzing now on");
	end;
	AutoGratsAndWelcome.ui.sayCheckButton:SetChecked(AGW_Say);
end

function AGW_ToggleParty()
	if(AGW_Party) then 
		AGW_Party = false; 
		AGW_Print("Party gratzing now off");
	else
		AGW_Party = true; 
		AGW_Print("Party gratzing now on");
	end;
	AutoGratsAndWelcome.ui.partyCheckButton:SetChecked(AGW_Party);
end

function AGW_ToggleGuildWelcome()
	if(AGW_GuildJoinMessageToggle) then 
		AGW_GuildJoinMessageToggle = false; 
		AGW_Print("New guild member welcoming now off");
	else
		AGW_GuildJoinMessageToggle = true;    
		AGW_Print("New guild member welcoming now on");
	end;
	AutoGratsAndWelcome.ui.guildWelcomeCheckButton:SetChecked(AGW_GuildJoinMessageToggle);
end

function AGW_SetDelay(delay)
	if(delay ~= nill)then
		AGW_Delay = tonumber(delay); 
		AGW_Print("Grats message delay set to: " ..delay.."ms");	
	else
		AGW_Print("Provide a number in milliseconds, eg '/ag delay 5000' for 5 seconds");
	end
end

function AGW_Command(msg)
    local Cmd, SubCmd = AGW_GetCmd(msg);
    if (Cmd == "")then
        --If the interface options aren't already loaded this doesn't work fully(just opens to non addons tab)
		--but apparently if you call it twice it works fine!
		InterfaceOptionsFrame_OpenToCategory(AutoGratsAndWelcome.ui.panel);
		InterfaceOptionsFrame_OpenToCategory(AutoGratsAndWelcome.ui.panel);
    elseif (Cmd == "help")then
        AGW_ShowHelp();
    elseif (Cmd == "options")then
        InterfaceOptionsFrame_OpenToCategory(AutoGratsAndWelcome.ui.panel);
		InterfaceOptionsFrame_OpenToCategory(AutoGratsAndWelcome.ui.panel);
    elseif (Cmd == "guild")then
        AGW_ToggleGuild();
    elseif (Cmd == "say")then
        AGW_ToggleSay();
    elseif (Cmd == "party")then
        AGW_ToggleParty();
	elseif (Cmd == "guildwelcome")then
        AGW_ToggleGuildWelcome();
	elseif (string.find(Cmd,"delay") == 1)then
        AGW_SetDelay(string.match(Cmd,"%d+"));
    else
        AGW_GratsMessage = Cmd;
		AGW_Print("Grats message set to: " .. Cmd);
    end
end


function AGW_OnEvent(self,event,arg1,arg2)
	if(event == "GUILD_ROSTER_UPDATE")then AGW_CheckOverride(); return end
	if(AGW_GratsMessage == nil)then
		AGW_GratsMessage="Gratzzz";
    end
    if(not AGW_IsMe(arg2))then
	    if(event == "CHAT_MSG_GUILD_ACHIEVEMENT" and not AGW_GuildDisabledOverride)then AGW_DoGrats("GUILD");
	    elseif(event == "CHAT_MSG_ACHIEVEMENT")then AGW_DoGrats("SAY");
	    elseif(event == "CHAT_MSG_ACHIEVEMENT")then AGW_DoGrats("PARTY");
	    elseif(event == "CHAT_MSG_SYSTEM" and not AGW_GuildDisabledOverride) then
	    	if(arg1 ~= nil) then
				if(string.find(arg1,"has joined the guild.")) then AGW_GuildWelcome();
				end
			end
	    end
	end
end

function AGW_DoGrats(source)
	if((source == "SAY" and AGW_Say == true) or (source == "GUILD" and AGW_Guild == true) or (source == "PARTY" and AGW_Party == true)) then
		CurTime=GetTime();
		if (AGW_LastMessage == nil) then
			AGW_LastMessage = 1;
		end
		if((CurTime - AGW_LastMessage) > (AGW_GroupingTime/1000))then
			AGW_LastMessage = GetTime();
			if(AGW_Delay > 0)then
				C_Timer.After((AGW_Delay/1000), function() SendChatMessage(AGW_GratsMessage, source); end)
			else
				SendChatMessage(AGW_GratsMessage, source);
			end
		end
	end
end

function AGW_GuildWelcome()
	--Testing, enable if you know what your doing...
	if(AGW_GuildJoinMessageToggle and (GetTime() - AGW_LastMessage > (AGW_GroupingTime/1000)))then
		AGW_LastMessage = GetTime();
		if(AGW_Delay > 0)then
			C_Timer.After((AGW_Delay/1000), function() SendChatMessage("Welcome :)", "GUILD"); end)
		else
			SendChatMessage(AGW_GuildWelcomeMessage, "GUILD");
		end
    end
end

function AGW_IsMe(nameString)
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

function AGW_CheckOverride()
	local myName = UnitName("player")
	for index=1, GetNumGuildMembers() do 
		
		 local name,_,_,_,_,_,note = GetGuildRosterInfo(index)
		 if AGW_IsMe(name) then
			 note = note:lower()
			 if note:match("noag") then
				AGW_GuildDisabledOverride = true;
				return true;
			 else
				AGW_GuildDisabledOverride = false;
				return false;
			 end
			 break
		 end
	end
	return false;
end

function AGW_Print(msg)
	print("\124cffffFF00[GOAT]\124r",msg);
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return unpack(t)
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
