local f = CreateFrame("Frame")

local activeSession = false
local trackRolls = false
local rolls = {}

local function setup()
	DCSession = _G["DCSession"] or {}
end

local function receivedLoot(playerName)
	if not activeSession then
		return 0
	end

	local lootReceived = 0;

	for _,t in ipairs(DCSession[#DCSession]["looters"]) do
		if playerName == t["player"] then
			lootReceived = lootReceived + 1
		end
	end

	return lootReceived
end

local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:SetScript("OnEvent", function (self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "DC-Roll" then
		SLASH_BIG1 = '/big'

		setup()

		SlashCmdList.BIG = function (msg)
			local msg_split = {}
			for v in string.gmatch(msg, "[^ ]+") do
				table.insert(msg_split, v)
			end
			if msg_split[1] == "start" then
				if #msg_split < 2 then
					DEFAULT_CHAT_FRAME:AddMessage("|cFF00A59CBiG:|r ~ Missing session name ~")
					return
				end

				local session = {["name"] = msg_split[2], ["looters"] = {}}

				table.insert(DCSession,session)
				activeSession = true
			elseif msg_split[1] == "end" then
				activeSession = false
			elseif msg_split[1] == "add" then
				if not activeSession then
					DEFAULT_CHAT_FRAME:AddMessage("|cFF00A59CBiG:|r ~ No active session ~")
					return
				end

				local loot = string.match(msg, "^add (.+)")
				local player = UnitName("target")
				table.insert(DCSession[#DCSession]["looters"], {["player"] = player, ["loot"] = loot})
			elseif msg_split[1] == "del" then
				if not activeSession then
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
					table.remove(DCSession[#DCSession]["looters"],index)
				end
			elseif msg_split[1] == "roll" then
				local loot = string.match(msg, "^roll (.+)")
				SendChatMessage("Roll ".. loot, "RAID_WARNING")
				trackRolls = true;
				rolls = {}
			elseif msg_split[1] == "endroll" then
				trackRolls = false;
				SendChatMessage("Rolls are now closed", "RAID");
				DEFAULT_CHAT_FRAME:AddMessage("|cFF00A59CBiG:|r ~ Roll Results ~")
				
				for p,r in spairs(rolls, function(t,a,b) return t[a] > t[b] end) do
					DEFAULT_CHAT_FRAME:AddMessage(p.." : "..r)
				end
			end
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		local name, roll, range = string.match(arg1, "^([^ ]+) rolls (%d+) %((%d+-%d+)%)$")
		if roll ~= nil and trackRolls and range == "1-100" then
			if rolls[name] == nil then
				rolls[name] = roll - (receivedLoot(name)*100)
			end
		end
	end
end)
