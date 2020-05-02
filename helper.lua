DC_Roll = DC_Roll or {}

function DC_Roll:parseTSV(tsvData)
	for row in string.gmatch(tsvData, "[^\n]+") do
		local columnNr = 0

		local loot = ""
		local prios = {}

		-- WoW translates a tab to 4 spaces, replace that with | for easy split
		local fixedRow = string.gsub(row, "    ", "|");

		for column in string.gmatch(fixedRow, "[^|]+") do
			columnNr = columnNr + 1
			if columnNr == 1 then
				loot = column
			elseif columnNr > 3 and prios[#prios] ~= column then
				table.insert(prios, column)
			end
		end

		if loot ~= "Loot Name" and #prios > 0 then
			DCSession[#DCSession]["reserves"][loot] = prios
		end
	end
	print("Reserved import done!")
end

function DC_Roll:DumpSession(index)
	local dumpString = "Name;"..DCSession[index]["name"]..";"..(DCSession[index]["date"] or "").."\n"
	dumpString = dumpString.."Looter;Loot\n"

	for i = 1, #DCSession[index]["looters"] do
		dumpString = dumpString..DCSession[index]["looters"][i]["player"]..";"..DCSession[index]["looters"][i]["loot"].."\n"
	end
	
	local CopyFrame = DC_Roll:createDumpBox()
	CopyFrame.ScrollText:SetText(dumpString)
	CopyFrame.ScrollText:HighlightText()
	CopyFrame:Show()
end