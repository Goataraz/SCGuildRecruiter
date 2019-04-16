SC_Locale = {}

local function defaultFunc(L,key)
	return key
end

local English = setmetatable({}, {__index=defaultFunc})
	English["English Locale loaded"] = "English Locale loaded"
	English["Enable whispers"] = "Enable whispers"
	English["Level limits"] = nil
	English["Invite Mode"] = nil
	English["Whisper only"] = nil
	English["Invite and whisper"] = nil
	English["Invite only"] = nil
	English["Mute SC"] = nil
	English["Filter 55-58 Death Knights"] = nil
	English["Do a more thorough search"] = nil
	English["Customize whisper"] = nil
	English["SuperScan"] = nil
	English["Invite: %d"] = nil
	English["Choose Invites"] = nil
	English["Exceptions"] = nil
	English["Help"] = nil
	English["The level you wish to start dividing the search by race"] = nil
	English["Racefilter Start:"] = nil
	English["The level you wish to divide the search by class"] = nil
	English["Classfilter Start:"] = nil
	English["Amount of levels to search every ~7 seconds (higher numbers increase the risk of capping the search results)"] = nil
	English["Interval:"] = nil
	English["Shadow Collective Recruiter Custom Whisper"] = nil
	English["WhisperInstructions"] = "Create a customized whisper to send to people! If you set multiple messages, each message will be selected randomly and sent to the player. There is a 256 character limit per message."
	English["Enter your whisper"] = nil
	English["Save"] = nil
	English["Cancel"] = nil
	English["less than 1 second"] = nil
	English[" hours "] = nil
	English[" minutes "] = nil
	English[" seconds"] = nil
	English[" remaining"] = nil
	English["Purge Queue"] = nil
	English["Click to toggle SuperScan"] = nil
	English["Click on the players you wish to invite"] = nil
	English["Scan Completed"] = nil
	English["Who sent: "] = nil
	English["SuperScan was started"] = nil
	English["SuperScan was stopped"] = nil
	English["PlayersScanned"] = "Players Scanned: |cff44FF44%d|r |cffffff00(Total: |r|cff44FF44%d|r)"
	English["PlayersGuildLess"] = "Guildless Players: |cff44FF44%d|r (|cff44FF44%d%%|r)"
	English["InvitesQueued"] = "Invites Queued: |cff44FF44%d|r"
	English["ExceptionsInstructions"] = "You can add exception phrases that when found in a name will cause the player to be ignore by Shadow Collective Recruiter. You can add several exceptions at once, seperated by a comma (,)."
	English["SC Exceptions"] = nil
	English["Enter exceptions"] = nil
	English["Go to Options and select your Invite Mode"] = nil
	English["You need to specify the mode in which you wish to invite"] = nil
	English["Unable to invite %s. They are already in a guild."] = nil
	English["Unable to invite %s. They will not be blacklisted."] = nil
	
	--Trouble shooter--
	English["not sending"] = "|cffff8800Why am I not sending any whispers?|r |cff00A2FFPossibly because you have not checked the checkbox.|r|cff00ff00 Click on this message to fix.|r"
	English["to specify"] = "|cffff8800I am getting a message telling me to specify my invite mode when I try to invite!|r|cff00A2FF This happens when you have not used the dropdown menu in the options to pick how to invite people.|r|cff00ff00 Click to fix.|r"
	English["I checked the box"] = "|cffff8800I am not sending any whispers when I invite and I checked the box!|r|cff00A2FF This is because you have selected only to invite with the dropdown menu in the options.|r|cff00ff00 Click to fix|r"
	English["whisper to everyone"] = "|cffff8800I keep sending a whisper to everyone I invite, OR I just want to send whispers and not invite, but your AddOn does both!|r|cff00A2FF This is because you specified to both invite and whisper on the dropdown menu in options.|r|cff00ff00 Click to fix|r"
	English["can't get SC to invite"] = "|cffff8800I can't get SC to invite people, all it does is sending whispers.|r|cff00A2FF This is because you picked that option in the dropdown menu.|r|cff00ff00 Click to fix|r"
	English["can't see any messages"] = "|cffff8800I can't see any messages from SC at all!|r|cff00A2FF This is because you have muted SC in the options.|r|cff00ff00 Click to fix|r"
	English["None of the above"] = "|cffff8800None of the above solved my problem!|r|cff00A2FF There might be an issue with the localization (language) you are using. You can try to load your locale manually: /SC locale:deDE loads German (frFR for french). Please contact me at:|r|cff00ff00 SuperGuildInvite@gmail.com|r"
	English["Enabled whispers"] = nil
	English['Changed invite mode to "Invite and Whisper"'] = nil
	English["Mute has been turned off"] = nil
	English['Changed invite mode to "Only Invite". If you wanted "Only Whisper" go to Options and change.'] = nil
	
	
	
	English["Shaman"] = nil
	English["Death Knight"] = nil
	English["Mage"] = nil
	English["Priest"] = nil
	English["Rogue"] = nil
	English["Paladin"] = nil
	English["Warlock"] = nil
	English["Druid"] = nil
	English["Warrior"] = nil
	English["Hunter"] = nil
	English["Monk"] = nil
	
	English["Human"] = nil
	English["Gnome"] = nil
	English["Dwarf"] = nil
	English["NightElf"] = nil
	English["Draenei"] = nil
	English["Worgen"] = nil
	English["Pandaren"] = nil
	English["Undead"] = nil
	English["Orc"] = nil
	English["Troll"] = nil
	English["Tauren"] = nil
	English["BloodElf"] = nil
	English["Goblin"] = nil
	
	English["Author"] = "|cff00A2FF Written by Nimueah - Eldre'Thalas - US.|r"
	

	

SC_Locale["enGB"] = English
SC_Locale["enUS"] = English
