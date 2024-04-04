function Chat(aMessage, aType)
	if not aType then
		aType = "notice"
	end
	userMods.SendSelfChatMessage(ToWString(aMessage), aType)
end

function ToWString(aStr)
	if not common.IsWString(aStr) then 
		if type(aStr) == "number" then
			aStr = tostring(aStr)
		end
		return userMods.ToWString(aStr) 
	end
	return aStr
end