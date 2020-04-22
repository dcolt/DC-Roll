local f = CreateFrame("Frame")

local function createDumpBox()
	local CopyFrame = CreateFrame("Frame", "CopyFrame", UIParent)
	CopyFrame:SetMovable(true)

	CopyFrame:SetSize(700, 450)
	CopyFrame:SetPoint("CENTER")
	CopyFrame:SetBackdrop({bgFile = "Interface/DialogFrame/UI-DialogBox-Background", 
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
		backdropColor = { r=0, g=0, b=0, a=1 }})

	local CopyFrameButton = CreateFrame("Button", "CopyFrameButton", CopyFrame, "GameMenuButtonTemplate")
	CopyFrameButton:SetText("Okay")
	CopyFrameButton:SetPoint("BOTTOM", CopyFrame, "BOTTOM", 0, 10)

	local CopyFrameScroll = CreateFrame("ScrollFrame", "CopyFrameScroll", CopyFrame, "UIPanelScrollFrameTemplate")
	CopyFrameScroll:SetPoint("TOP", CopyFrame, "TOP", 5, -30)
	CopyFrameScroll:SetPoint("BOTTOM", CopyFrameButton, "BOTTOM", 10, 30)
	CopyFrameScroll:SetPoint("RIGHT", CopyFrame, "RIGHT", -40, 0)

	local CopyFrameScrollText = CreateFrame("EditBox", "CopyFrameScrollText", CopyFrameScroll)
	CopyFrameScrollText:SetMaxLetters(99999)
	CopyFrameScrollText:SetMultiLine(true)
	CopyFrameScrollText:SetAutoFocus(true)
	CopyFrameScrollText:SetSize(630, 380)
	CopyFrameScrollText:SetFontObject(ChatFontNormal)

	CopyFrameScroll:SetScrollChild(CopyFrameScrollText)

	
	CopyFrame.Button = CopyFrameButton
	CopyFrame.Scroll = CopyFrameScroll
	CopyFrame.ScrollText = CopyFrameScrollText

	CopyFrameScrollText:SetScript("OnEscapePressed", function(self)
		CopyFrame:Hide()
	end)
	CopyFrameButton:SetScript("OnClick", function(self)
		CopyFrame:Hide()
	end)

	CopyFrame:Hide()

	return CopyFrame
end

local function parseCSV(csvData)
	for row in string.gmatch(csvData, "[^\n]+") do
		local columnNr = 0

		local loot = ""
		local prios = {}
		local isGroup = false
		local group = ""

		for column in string.gmatch(row, "[^,]+") do
			if column:sub(1,1) == "\"" then
				isGroup = true
			end

			if isGroup then
				group = group .. "," .. column
				
				if column:sub(#column, #column) == "\"" then
					isGroup = false
					column = group
				end
			end

			if not isGroup then
				columnNr = columnNr + 1
				if columnNr == 1 then
					loot = column
				elseif columnNr > 3 and prios[#prios] ~= column then
					table.insert(prios, column)
				end
			end
		end

		if loot ~= "Loot Name" and #prios > 0 then
			DCSession[#DCSession]["reserves"][loot] = prios
		end
	end
	print("Reserverd import done!")
end

local function createImportBox()
	local ImportFrame = CreateFrame("Frame", "ImportFrame", UIParent)
	ImportFrame:SetMovable(true)

	ImportFrame:SetSize(700, 450)
	ImportFrame:SetPoint("CENTER")
	ImportFrame:SetBackdrop({bgFile = "Interface/DialogFrame/UI-DialogBox-Background", 
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
		backdropColor = { r=0, g=0, b=0, a=1 }})

	local ImportFrameButton = CreateFrame("Button", "ImportFrameButton", ImportFrame, "GameMenuButtonTemplate")
	ImportFrameButton:SetText("Okay")
	ImportFrameButton:SetPoint("BOTTOM", ImportFrame, "BOTTOM", 0, 10)

	local ImportFrameScroll = CreateFrame("ScrollFrame", "ImportFrameScroll", ImportFrame, "UIPanelScrollFrameTemplate")
	ImportFrameScroll:SetPoint("TOP", ImportFrame, "TOP", 5, -30)
	ImportFrameScroll:SetPoint("BOTTOM", ImportFrameButton, "BOTTOM", 10, 30)
	ImportFrameScroll:SetPoint("RIGHT", ImportFrame, "RIGHT", -40, 0)

	local ImportFrameScrollText = CreateFrame("EditBox", "ImportFrameScrollText", ImportFrameScroll)
	ImportFrameScrollText:SetMaxLetters(99999)
	ImportFrameScrollText:SetMultiLine(true)
	ImportFrameScrollText:SetAutoFocus(true)
	ImportFrameScrollText:SetSize(630, 380)
	ImportFrameScrollText:SetFontObject(ChatFontNormal)

	ImportFrameScroll:SetScrollChild(ImportFrameScrollText)

	
	ImportFrame.Button = ImportFrameButton
	ImportFrame.Scroll = ImportFrameScroll
	ImportFrame.ScrollText = ImportFrameScrollText

	ImportFrameScrollText:SetScript("OnEscapePressed", function(self)
		ImportFrame:Hide()
	end)
	ImportFrameButton:SetScript("OnClick", function(self)
		parseCSV(ImportFrameScrollText:GetText())
		ImportFrame:Hide()
	end)

	ImportFrame:Hide()

	return ImportFrame
end

local CopyFrame = createDumpBox()
local ImportFrame = createImportBox()

local activeSession = false
local trackRolls = false
local rolls = {}
local currentlyRolledLoot = ""

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

local function getPrios(lootName)
	if DCSession[#DCSession]["reserves"][lootName] == nil then
		return ""
	end

	local names = DCSession[#DCSession]["reserves"][lootName][1]

	for i = 2, #DCSession[#DCSession]["reserves"][lootName] do
		names = strjoin(" ", names, DCSession[#DCSession]["reserves"][lootName][i])
	end

	return names
end

local function DumpSession(index)
	local dumpString = "Name;"..DCSession[index]["name"]..";"..(DCSession[index]["date"] or "").."\n"
	dumpString = dumpString.."Looter;Loot\n"

	for i = 1, #DCSession[index]["looters"] do
		dumpString = dumpString..DCSession[index]["looters"][i]["player"]..";"..DCSession[index]["looters"][i]["loot"].."\n"
	end
	
	CopyFrame.ScrollText:SetText(dumpString)
	CopyFrame.ScrollText:HighlightText()
	CopyFrame:Show()
end


local function addLoot(player, loot)

	table.insert(DCSession[#DCSession]["looters"], {["player"] = player, ["loot"] = loot})
	print("Added "..loot.." to "..player)
end

StaticPopupDialogs["BIG_ADD_LOOT"] = {
	text = "Is %s +1?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function(_, player, item)
		addLoot(player, item)
	end,
	timeout = 0,
	whileDead = true,
	preferredIndex = 3,
}

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:RegisterEvent("CHAT_MSG_LOOT")
f:SetScript("OnEvent", function (self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "DC-Roll" then
		SLASH_BIG1 = '/big'

		setup()

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
				activeSession = true
				print("Session "..session["name"].." started")
			elseif msg_split[1] == "endsession" then
				if (activeSession) then
					print("Session "..DCSession[#DCSession]["name"].." ended")
				end
				activeSession = false
			elseif msg_split[1] == "add" then
				if not activeSession then
					DEFAULT_CHAT_FRAME:AddMessage("|cFF00A59CBiG:|r ~ No active session ~")
					return
				end

				local player = UnitName("target")
				local loot = string.match(msg, "^add +(.+|r)")
				addLoot(player, loot);
				
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
					print("Deleted "..loot.." from "..player)
					table.remove(DCSession[#DCSession]["looters"],index)
				end
			elseif msg_split[1] == "roll" then
				local loot = string.match(msg, "^roll (.+)")
				local lootName = string.match(loot, "%[(.+)%]")

				currentlyRolledLoot = loot

				if activeSession then
					local namesString = getPrios(lootName)

					if strlen(namesString) > 0 then
						loot = strjoin(" ", loot, namesString)
					end
				end
				SendChatMessage("Roll ".. loot, "RAID_WARNING")
				print("Roll started for "..loot)
				trackRolls = true;
				rolls = {}
			elseif msg_split[1] == "endroll" then
				trackRolls = false;
				SendChatMessage("Rolls are now closed", "RAID");
				DEFAULT_CHAT_FRAME:AddMessage("|cFF00A59CBiG:|r ~ Roll Results ~")
				
				for p,r in spairs(rolls, function(t,a,b) return t[a] > t[b] end) do
					DEFAULT_CHAT_FRAME:AddMessage(p.." : "..r)
				end
			elseif msg_split[1] == "export" then
				local index = #DCSession
				if (#msg_split > 1) then
					local nr = tonumber(msg_split[2])
					if (nr < #DCSession and nr > 0) then
						index = nr
					elseif (nr < 0 and index + nr > 0) then
						index = index + nr
					end
				end
				
				DumpSession(index)
			elseif msg_split[1] == "import" then
				ImportFrame.ScrollText:SetText("")
				ImportFrame:Show()
			end
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		local name, roll, range = string.match(arg1, "^([^ ]+) rolls (%d+) %((%d+-%d+)%)$")
		if roll ~= nil and trackRolls and range == "1-100" then
			if rolls[name] == nil then
				rolls[name] = roll - (receivedLoot(name)*100)
			end
		end
	elseif event == "CHAT_MSG_LOOT" and activeSession then
		local player = select(4,...)
		local item = string.match(arg1, "loot: (.+[^.])")
		if item == currentlyRolledLoot then
			local dialog = StaticPopup_Show("BIG_ADD_LOOT", item);
			if dialog then
				dialog.data = player
				dialog.data2 = item
			end
		end
		
	end
end)
