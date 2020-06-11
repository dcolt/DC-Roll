DC_Roll = DC_Roll or {}

DC_Roll.trackRolls = false
DC_Roll.rolls = {}
DC_Roll.currentlyRolledLoot = ""

function DC_Roll:setup()
	DCSession = _G["DCSession"] or {}
	DCSession.active = DCSession.active or false
end

function DC_Roll:receivedLoot(playerName)
	if not DCSession.active then
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

function DC_Roll:spairs(t, order)
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

function DC_Roll:getPrios(lootName)
	if DCSession[#DCSession]["reserves"][lootName] == nil then
		return nil
	end

	local namesString = DCSession[#DCSession]["reserves"][lootName][1]

	for i = 2, #DCSession[#DCSession]["reserves"][lootName] do
		namesString = strjoin(" ", namesString, DCSession[#DCSession]["reserves"][lootName][i])
	end

	nameCount = #(DCSession[#DCSession]["reserves"][lootName])
	prioInfo = {}
	prioInfo["namesString"] = namesString
	prioInfo["nameCount"] = nameCount
	
	return prioInfo
end

function DC_Roll:addLoot(player, loot)
	table.insert(DCSession[#DCSession]["looters"], {["player"] = player, ["loot"] = loot})
	print("Added "..loot.." to "..player)
end
