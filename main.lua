local f = CreateFrame("Frame")

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:SetScript("OnEvent", function (self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "DC-Roll" then
		SLASH_BIG1 = '/big'
		SlashCmdList.BIG = function (msg)
			local msg_split = {}
			for v in string.gmatch(msg, "[^ ]+") do
				table.insert(msg_split, v)
			end
			
			if (#msg_split < 2) then
				return;
			end
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		local name, roll, range = string.match(arg1, "^([^ ]+) rolls (%d+) %((%d+-%d+)%)$")
		print(arg1)
		print(name)
		print(roll)
		print(range)
	end
end)
