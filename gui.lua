DC_Roll = DC_Roll or {}

function DC_Roll:createDumpBox()
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

function DC_Roll:createImportBox()
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
		DC_Roll:parseTSV(ImportFrameScrollText:GetText())
		ImportFrame:Hide()
	end)

	ImportFrame:Hide()

	return ImportFrame
end