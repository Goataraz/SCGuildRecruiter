function GR_OnLoad(self)
    self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
    self:RegisterEvent("CHAT_MSG_ACHIEVEMENT")
    self:RegisterEvent("CHAT_MSG_PARTY")
    self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
    --slash commands
	SlashCmdList["GR"] = GR_Command;
    SLASH_GR1 = "/gg";
    SLASH_GR2 = "/grats";
    if(GR_GratsMessage == nil)then
		GR_GratsMessage="Grats!";
		GR_LastMessage = 1;
	end
	if(GR_GuildJoinMessageToggle == nil)then
		GR_GuildJoinMessageToggle = true;
	end
	if(GR_Guild == nil)then
		GR_Guild = false;
	end
--	if(GR_Say == nil)then
--		GR_Say = true;
--	end
--	if(GR_Party == nil)then
--		GR_Party = false;
--	end
	if(GR_Delay == nil)then
		GR_Delay=4000;
	end
	if(GR_GroupingTime == nil)then
		GR_GroupingTime=4000;
	end
	if(GR_GuildDisabledOverride == nil)then
		GR_GuildDisabledOverride = false;
	end
	if(GR_GuildWelcomeMessage == nil)then
		GR_GuildWelcomeMessage = "Welcome to the Guild!";
	end
	GR_SetupOptionsUI();
	GR_Print("GuildRecruiter Loaded. Visit http://shadowco.io for support.");
end

function GR_SetupOptionsUI()
	GuildGrats = {};
	GuildGrats.ui = {};
	GuildGrats.ui.panel = CreateFrame( "Frame", "GuildGratsPanel", InterfaceOptionsFramePanelContainer );
	GuildGrats.ui.panel.name = "GuildGrats";

	--Guild Check Button
	GuildGrats.ui.guildCheckButton = CreateFrame("CheckButton","GR_GuildCheckButton",GuildGrats.ui.panel,"UICheckButtonTemplate") --frameType, frameName, frameParent, frameTemplate    
	GuildGrats.ui.guildCheckButton:SetPoint("TOPLEFT",20,-20)
	GuildGrats.ui.guildCheckButton.text:SetText("Guild Gratzing")
	GuildGrats.ui.guildCheckButton:SetScript("OnShow", function(self,event,arg1) 
		self:SetChecked(GR_Guild);
	end)
	GuildGrats.ui.guildCheckButton:SetScript("OnClick", function(self,event,arg1) 
		GR_ToggleGuild();
	end)

	--Party Check Button
	--GuildGrats.ui.partyCheckButton = CreateFrame("CheckButton","GR_PartyCheckButton",GuildGrats.ui.panel,"UICheckButtonTemplate") --frameType, frameName, frameParent, frameTemplate    
	--GuildGrats.ui.partyCheckButton:SetPoint("TOPLEFT",20,-40)
	--GuildGrats.ui.partyCheckButton.text:SetText("Party Gratzing")
	--GuildGrats.ui.partyCheckButton:SetScript("OnShow", function(self,event,arg1) 
	--	self:SetChecked(GR_Party);
	--end)
	--GuildGrats.ui.partyCheckButton:SetScript("OnClick", function(self,event,arg1) 
	--	GR_ToggleParty();
	--end)

	--Say Check Button
	--GuildGrats.ui.sayCheckButton = CreateFrame("CheckButton","GR_SayCheckButton",GuildGrats.ui.panel,"UICheckButtonTemplate") --frameType, frameName, frameParent, frameTemplate    
	--GuildGrats.ui.sayCheckButton:SetPoint("TOPLEFT",20,-60)
	--GuildGrats.ui.sayCheckButton.text:SetText("Say Gratzing")
	--GuildGrats.ui.sayCheckButton:SetScript("OnShow", function(self,event,arg1) 
	--	self:SetChecked(GR_Say);
	--end)
	--GuildGrats.ui.sayCheckButton:SetScript("OnClick", function(self,event,arg1) 
	--	GR_ToggleSay();
	--end)

	--Guild Welcome Check Button
	GuildGrats.ui.guildWelcomeCheckButton = CreateFrame("CheckButton","GR_GuildWelcomeCheckButton",GuildGrats.ui.panel,"UICheckButtonTemplate") --frameType, frameName, frameParent, frameTemplate    
	GuildGrats.ui.guildWelcomeCheckButton:SetPoint("TOPLEFT",20,-100)
	GuildGrats.ui.guildWelcomeCheckButton.text:SetText("New Guild Member Welcoming")
	GuildGrats.ui.guildWelcomeCheckButton:SetScript("OnShow", function(self,event,arg1) 
		self:SetChecked(GR_GuildJoinMessageToggle);
	end)
	GuildGrats.ui.guildWelcomeCheckButton:SetScript("OnClick", function(self,event,arg1) 
		GR_ToggleGuildWelcome();
	end)

	--Delay Slider
	GuildGrats.ui.delaySlider = CreateBasicSlider(GuildGrats.ui.panel, "GR_DelaySlider", "Delay in ms before sending the message", 0, 60000, 100);
	GuildGrats.ui.delaySlider:HookScript("OnValueChanged", function(self,value)
		GR_Delay = floor(value)
	end)
	GuildGrats.ui.delaySlider:HookScript("OnShow", function(self,value)
		self:SetValue(GR_Delay);
		self.editbox:SetNumber(GR_Delay);
	end)
	GuildGrats.ui.delaySlider.editbox:SetScript("OnShow", function(self,event,arg1)
		self:SetNumber(GR_Delay);
	end)
	GuildGrats.ui.delaySlider:SetPoint("TOPRIGHT",-120,-20)

	--Grouping Slider
	GuildGrats.ui.groupingSlider = CreateBasicSlider(GuildGrats.ui.panel, "GR_GroupingSlider", "Delay in ms after a message is sent that it won't send another", 0, 60000, 100);
	GuildGrats.ui.groupingSlider:HookScript("OnValueChanged", function(self,value)
		GR_GroupingTime = floor(value)
	end)
	GuildGrats.ui.groupingSlider:HookScript("OnShow", function(self,value)
		self:SetValue(GR_GroupingTime);
		self.editbox:SetNumber(GR_GroupingTime);
	end)
	GuildGrats.ui.groupingSlider.editbox:SetScript("OnShow", function(self,event,arg1)
		self:SetNumber(GR_GroupingTime);
	end)
	GuildGrats.ui.groupingSlider:SetPoint("TOPRIGHT",-120,-100)
	--GuildGrats.ui.delayLabel = GuildGrats.ui.panel:CreateFontString(nil,"OVERLAY","GameFontNormal", 200,200)
	--GuildGrats.ui.delayLabel:SetText("delay")
	--GuildGrats.ui.delayEditBox = CreateFrame("EditBox","GR_DelayEditBox",GuildGrats.ui.panel,"InputBoxTemplate") --frameType, frameName, frameParent, frameTemplate    
	--GuildGrats.ui.delayEditBox:SetSize(50,30)
 --   GuildGrats.ui.delayEditBox:ClearAllPoints()
	--GuildGrats.ui.delayEditBox:SetPoint("TOPLEFT",120,-120)
 --   GuildGrats.ui.delayEditBox:SetText("test");
 --   GuildGrats.ui.delayEditBox:SetAutoFocus(false)
	--GuildGrats.ui.delayEditBox.text:SetText("Delay(ms)")
	--GuildGrats.ui.delayEditBox:SetScript("OnShow", function(self,event,arg1) 
		--self:SetChecked(GR_Say);
	--end)

	--Grats Message
	GuildGrats.ui.gratsMessageEditBox = CreateFrame("EditBox", "GR_GratsMessage", GuildGrats.ui.panel, "InputBoxTemplate")
	GuildGrats.ui.gratsMessageEditBox:SetSize(500,30)
	GuildGrats.ui.gratsMessageEditBox:SetMultiLine(false)
    GuildGrats.ui.gratsMessageEditBox:ClearAllPoints()
	GuildGrats.ui.gratsMessageEditBox:SetPoint("TOPLEFT",20,-180)
	GuildGrats.ui.gratsMessageEditBox:SetCursorPosition(0);
	GuildGrats.ui.gratsMessageEditBox:ClearFocus();
    GuildGrats.ui.gratsMessageEditBox:SetAutoFocus(false)
	GuildGrats.ui.gratsMessageEditBox:SetScript("OnShow", function(self,event,arg1)
		self:SetText(GR_GratsMessage)
		self:SetCursorPosition(0);
		self:ClearFocus();
	end)
	GuildGrats.ui.gratsMessageEditBox:SetScript("OnTextChanged", function(self,value)
		GR_GratsMessage = self:GetText()
	end)
	GuildGrats.ui.gratsMessageLabel = CreateBasicFontString(GuildGrats.ui.gratsMessageEditBox,"GR_GratsMessageLabel","OVERLAY","GameFontNormal","Grats Message");
	GuildGrats.ui.gratsMessageLabel:SetPoint("BOTTOMLEFT", GuildGrats.ui.gratsMessageEditBox, "TOPLEFT", 0, 0)

	--Welcome to Guild Message
	GuildGrats.ui.guildWelcomeMessageEditBox = CreateFrame("EditBox", "GR_GuildWelcomeMessage", GuildGrats.ui.panel, "InputBoxTemplate")
	GuildGrats.ui.guildWelcomeMessageEditBox:SetSize(500,30)
	GuildGrats.ui.guildWelcomeMessageEditBox:SetMultiLine(false)
    GuildGrats.ui.guildWelcomeMessageEditBox:ClearAllPoints()
	GuildGrats.ui.guildWelcomeMessageEditBox:SetPoint("TOPLEFT",20,-240)
	GuildGrats.ui.guildWelcomeMessageEditBox:SetCursorPosition(0);
	GuildGrats.ui.guildWelcomeMessageEditBox:ClearFocus();
    GuildGrats.ui.guildWelcomeMessageEditBox:SetAutoFocus(false)
	GuildGrats.ui.guildWelcomeMessageEditBox:SetScript("OnShow", function(self,event,arg1)
		self:SetText(GR_GuildWelcomeMessage)
		self:SetCursorPosition(0);
		self:ClearFocus();
	end)
	GuildGrats.ui.guildWelcomeMessageEditBox:SetScript("OnTextChanged", function(self,value)
		GR_GuildWelcomeMessage = self:GetText()
	end)
	GuildGrats.ui.guildWelcomeMessageLabel = CreateBasicFontString(GuildGrats.ui.guildWelcomeMessageEditBox,"GR_GuildWelcomeMessageLabel","OVERLAY","GameFontNormal","Guild Welcome Message");
	GuildGrats.ui.guildWelcomeMessageLabel:SetPoint("BOTTOMLEFT", GuildGrats.ui.guildWelcomeMessageEditBox, "TOPLEFT", 0, 0)


	InterfaceOptions_AddCategory(GuildGrats.ui.panel);
	
end

 function GR_GetCmd(msg)
 	if msg then
 		local a=(msg); --contiguous string of non-space characters
 		if a then
 			return msg
 		else	
 			return "";
 		end
 	end
 end

function GR_ShowHelp()
	print("GuildGrats usage:");
	print("'/gg' or '/grats options' to show options ui");
	print("'/gg {msg}' or '/grats {msg}'");
	print("'/gg delay {delay}' or '/grats {delay}', with delay in milliseconds to set delay");
	print("'/gg guild' or '/grats guild' to enable/disable guild gratzing");

end

function GR_ToggleGuild()
	if(GR_Guild) then 
		GR_Guild = false; 
		GR_Print("Guild gratzing now off");
	else
		GR_Guild = true;    
		GR_Print("Guild gratzing now on");
	end;
	GuildGrats.ui.guildCheckButton:SetChecked(GR_Guild);
end

--function GR_ToggleSay()
--	if(GR_Say) then 
--		GR_Say = false; 
--		GR_Print("Say gratzing now off");
--	else
--		GR_Say = true;
--		GR_Print("Say gratzing now on");
--	end;
--	GuildGrats.ui.sayCheckButton:SetChecked(GR_Say);
--end

--function GR_ToggleParty()
--	if(GR_Party) then 
--		GR_Party = false; 
--		GR_Print("Party gratzing now off");
--	else
--		GR_Party = true; 
--		GR_Print("Party gratzing now on");
--	end;
--	GuildGrats.ui.partyCheckButton:SetChecked(GR_Party);
--end

function GR_ToggleGuildWelcome()
	if(GR_GuildJoinMessageToggle) then 
		GR_GuildJoinMessageToggle = false; 
		GR_Print("New guild member welcoming now off");
	else
		GR_GuildJoinMessageToggle = true;    
		GR_Print("New guild member welcoming now on");
	end;
	GuildGrats.ui.guildWelcomeCheckButton:SetChecked(GR_GuildJoinMessageToggle);
end

function GR_SetDelay(delay)
	if(delay ~= nill)then
		GR_Delay = tonumber(delay); 
		GR_Print("Grats message delay set to: " ..delay.."ms");	
	else
		GR_Print("Provide a number in milliseconds, eg '/gg delay 5000' for 5 seconds");
	end
end

function GR_Command(msg)
    local Cmd, SubCmd = GR_GetCmd(msg);
    if (Cmd == "")then
        --If the interface options aren't already loaded this doesn't work fully(just opens to non addons tab)
		--but apparently if you call it twice it works fine!
		InterfaceOptionsFrame_OpenToCategory(GuildGrats.ui.panel);
		InterfaceOptionsFrame_OpenToCategory(GuildGrats.ui.panel);
    elseif (Cmd == "help")then
        GR_ShowHelp();
    elseif (Cmd == "options")then
        InterfaceOptionsFrame_OpenToCategory(GuildGrats.ui.panel);
		InterfaceOptionsFrame_OpenToCategory(GuildGrats.ui.panel);
    elseif (Cmd == "guild")then
        GR_ToggleGuild();
    --elseif (Cmd == "say")then
    --    GR_ToggleSay();
    --elseif (Cmd == "party")then
     --   GR_ToggleParty();
	elseif (Cmd == "guildwelcome")then
        GR_ToggleGuildWelcome();
	elseif (string.find(Cmd,"delay") == 1)then
        GR_SetDelay(string.match(Cmd,"%d+"));
    else
        GR_GratsMessage = Cmd;
		GR_Print("Grats message set to: " .. Cmd);
    end
end


function GR_OnEvent(self,event,arg1,arg2)
	if(event == "GUILD_ROSTER_UPDATE")then GR_CheckOverride(); return end
	if(GR_GratsMessage == nil)then
		GR_GratsMessage="Grats!";
    end
    if(not GR_IsMe(arg2))then
	    if(event == "CHAT_MSG_GUILD_ACHIEVEMENT" and not GR_GuildDisabledOverride)then GR_DoGrats("GUILD");
	    --elseif(event == "CHAT_MSG_ACHIEVEMENT")then GR_DoGrats("SAY");
	    --elseif(event == "CHAT_MSG_ACHIEVEMENT")then GR_DoGrats("PARTY");
	    elseif(event == "CHAT_MSG_SYSTEM" and not GR_GuildDisabledOverride) then
	    	if(arg1 ~= nil) then
				if(string.find(arg1,"has joined the guild.")) then GR_GuildWelcome();
				end
			end
	    end
	end
end

function GR_DoGrats(source)
	if(source == "GUILD" and GR_Guild == true) then
		CurTime=GetTime();
		if (GR_LastMessage == nil) then
			GR_LastMessage = 1;
		end
		if((CurTime - GR_LastMessage) > (GR_GroupingTime/1000))then
			GR_LastMessage = GetTime();
			if(GR_Delay > 0)then
				C_Timer.After((GR_Delay/1000), function() SendChatMessage(GR_GratsMessage, source); end)
			else
				SendChatMessage(GR_GratsMessage, source);
			end
		end
	end
end

function GR_GuildWelcome()
	--Testing, enable if you know what your doing...
	if(GR_GuildJoinMessageToggle and (GetTime() - GR_LastMessage > (GR_GroupingTime/1000)))then
		GR_LastMessage = GetTime();
		if(GR_Delay > 0)then
			C_Timer.After((GR_Delay/1000), function() SendChatMessage(GR_GuildWelcomeMessage, "GUILD"); end)
		else
			SendChatMessage(GR_GuildWelcomeMessage, "GUILD");
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

function GR_Print(msg)
	print("\124cffffFF00[GR]\124r",msg);
end

function split(str, pat)
   local t = {n = 0}  -- NOTE: use {n = 0} in Lua-5.0
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
