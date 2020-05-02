DC_Roll = DC_Roll or {}


StaticPopupDialogs["BIG_ADD_LOOT"] = {
	text = "Is %s +1?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function(_, player, item)
		DC_Roll:addLoot(player, item)
	end,
	timeout = 0,
	whileDead = true,
	preferredIndex = 3,
}

StaticPopupDialogs["BIG_ACTIVE_SESSION"] = {
	text = "You have an active session",
	button1 = "Continue",
	button2 = "Stop",
	OnAccept = function()
	end,
	OnCancel = function()
		DCSession.active = false
	end,
	timeout = 0,
	whileDead = true,
	preferredIndex = 3,
}