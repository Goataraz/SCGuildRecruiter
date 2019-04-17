-- SCGInv adds an "Invite To Guild" button to popup menus (like as when you right-click a person's name in chat) to make it easier to add someone as a friend.




local SCGInv = CreateFrame("Frame","SCGInvFrame")
SCGInv:SetScript("OnEvent", function() hooksecurefunc("UnitPopup_OnClick", SCGuildInvite) end)
SCGInv:RegisterEvent("PLAYER_LOGIN")


local PopupUnits = {}


UnitPopupButtons["GUILDINVITE"] = { text = "Invite to Guild", }

table.insert( UnitPopupMenus["SELF"] ,1 , "GUILDINVITE" )


for i,UPMenus in pairs(UnitPopupMenus) do
  for j=1, #UPMenus do
    if UPMenus[j] == "WHISPER" then
--      print ("-- i,j: "..i.." "..j)
      PopupUnits[#PopupUnits + 1] = i
      pos = j + 1
      table.insert( UnitPopupMenus[i] ,pos , "GUILDINVITE" )
      break
    end
  end
end

function SCGuildInvite (self)
 local button = self.value;
 if ( button == "GUILDINVITE" ) then
  local dropdownFrame = UIDROPDOWNMENU_INIT_MENU;
  local unit = dropdownFrame.unit;
  local name = dropdownFrame.name;
  local server = dropdownFrame.server;
  local fullname = name;

  if ( server and ((not unit and GetNormalizedRealmName() ~= server) or (unit and UnitRealmRelationship(unit) ~= LE_REALM_RELATION_SAME)) ) then
   fullname = name.."-"..server;
  end

  print("SC /ginvite",fullname);
  GuildInvite(fullname);
 end
end







