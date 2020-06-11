DC_Roll = DC_Roll or {}

local f = CreateFrame("Frame")

function f:ADDON_LOADED(addonName)
	if addonName == "DC-Roll" then
        f:UnregisterEvent('ADDON_LOADED')
        
        SLASH_BIG1 = '/big'

		DC_Roll:setup()

		SlashCmdList.BIG = function (msg)
			local msg_split = {}
			for v in string.gmatch(msg, "[^ ]+") do
				table.insert(msg_split, v)
			end
			if msg_split[1] == "startsession" then
				if #msg_split < 2 then
					DEFAULT_CHAT_FRAME:AddMessage("|cFF00A59CBiG:|r ~ Missing session name ~")
					return
				end

				local session = {["name"] = msg_split[2], ["looters"] = {}, ["date"] = date("%d/%m/%Y"), ["reserves"] = {}}

				table.insert(DCSession,session)
				DCSession.active = true
				print("Session "..session["name"].." started")
			elseif msg_split[1] == "endsession" then
				if DCSession.active then
					print("Session "..DCSession[#DCSession]["name"].." ended")
				end
				DCSession.active = false
			elseif msg_split[1] == "add" then
				if not DCSession.active then
					DEFAULT_CHAT_FRAME:AddMessage("|cFF00A59CBiG:|r ~ No active session ~")
					return
				end

				local player = UnitName("target")
				local loot = string.match(msg, "^add +(.+|r)")
				DC_Roll:addLoot(player, loot);
				
			elseif msg_split[1] == "del" then
				if not DCSession.active then
					DEFAULT_CHAT_FRAME:AddMessage("|cFF00A59CBiG:|r ~ No active session ~")
					return
				end

				local player = UnitName("target")
				local loot = string.match(msg, "^del (.+)")
				local index = 0;
				for i = 1, #DCSession[#DCSession]["looters"] do
					if DCSession[#DCSession]["looters"][i]["player"] == player and DCSession[#DCSession]["looters"][i]["loot"] == loot then
						index = i
						break
					end
				end

				if index > 0 then
					print("Deleted "..loot.." from "..player)
					table.remove(DCSession[#DCSession]["looters"],index)
				end
			elseif msg_split[1] == "roll" then
				local loot = string.match(msg, "^roll (.+)")
				local lootName = string.match(loot, "%[(.+)%]")

				DC_Roll.currentlyRolledLoot = loot

				local announceString = "Roll " .. loot
				if DCSession.active then
					local lootPrios = DC_Roll:getPrios(lootName)
					
					if lootPrios then
						if lootPrios["nameCount"] > 1 then
							announceString = strjoin(" ", announceString, lootPrios["namesString"])
						else
							announceString = "GZ " .. DC_Roll.currentlyRolledLoot .. " " .. lootPrios["namesString"] .. " softres"
						end
					end
				end
				SendChatMessage(announceString, "RAID_WARNING")
				print("Roll started for "..loot)
				DC_Roll.trackRolls = true;
				DC_Roll.rolls = {}
			elseif msg_split[1] == "endroll" then
				DC_Roll.trackRolls = false;
				SendChatMessage("Rolls are now closed", "RAID");
				DEFAULT_CHAT_FRAME:AddMessage("|cFF00A59CBiG:|r ~ Roll Results ~")
				
				for p,r in DC_Roll:spairs(DC_Roll.rolls, function(t,a,b) return t[a] > t[b] end) do
					DEFAULT_CHAT_FRAME:AddMessage(p.." : "..r)
				end
			elseif msg_split[1] == "export" then
				local index = #DCSession
				if #msg_split > 1 then
					local nr = tonumber(msg_split[2])
					if nr < #DCSession and nr > 0 then
						index = nr
					elseif nr < 0 and index + nr > 0 then
						index = index + nr
					end
				end
				
				DC_Roll:DumpSession(index)
			elseif msg_split[1] == "import" then
				local ImportFrame = DC_Roll:createImportBox()
				ImportFrame:Show()
			end
		end
	end
end

function f:CHAT_MSG_SYSTEM(text)
    local name, roll, range = string.match(text, "^([^ ]+) rolls (%d+) %((%d+-%d+)%)$")
    if roll ~= nil and DC_Roll.trackRolls and range == "1-100" then
        if DC_Roll.rolls[name] == nil then
            DC_Roll.rolls[name] = roll - (DC_Roll:receivedLoot(name)*100)
        end
    end
end

function f:CHAT_MSG_LOOT(text, ...) 
    if not DCSession.active then
        return
    end
    local player = select(4,...)
	local item = string.match(text, "loot: (.+[^.])") or string.match(text, "item: (.+[^.])")
	local itemName = string.match(item, "%[(.+)%]")
	
    if item == DC_Roll.currentlyRolledLoot and DC_Roll:getPrios(itemName) == nil then
		local dialog = StaticPopup_Show("BIG_ADD_LOOT", item);
		if dialog then
			dialog.data = player
			dialog.data2 = item
		end
	end
end

function f:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
    if DCSession.active and (isInitialLogin or isReloadingUi) then
        StaticPopup_Show("BIG_ACTIVE_SESSION");
    end
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:RegisterEvent("CHAT_MSG_LOOT")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function (self, event, ...)
    return self[event](self,...)
end)
