local wtChat = nil
local chatRows = 0
local GlobalFontSize = 14
local ChatPrefix = common.GetAddonName()

local function TimeToStr(dt)
	--return dt.h..':'..dt.min..':'..dt.s;
	return string.format( "%02d", dt.h )..":"..string.format( "%02d", dt.min )..":"..string.format( "%02d", dt.s )
end
local function LocateChat()
	
	if not wtChat then
		local w = stateMainForm:GetChildUnchecked("ChatLog", false)
		if not w then
			--- главня форма не найдена - найден по ребенку
			w = stateMainForm:GetChildUnchecked("Chat", true)
		else
			w = w:GetChildUnchecked("Container", true) -- w = w:GetChildUnchecked("Chat", true);
		end
		wtChat = w
	end
	return wtChat;
end
function Chat(message, color, fontSize)

	wtChat = LocateChat();
	if (not wtChat) then
		LogInfo("No chat");
		return;
	end;

	local valuedText = common.CreateValuedText()
	--- fontname= 'AllodsWest' 'AllodsSystem'
	local format = "<body alignx='left' fontname='AllodsWest' fontsize='"..(fontSize or GlobalFontSize)
	format = format.."' shadow='1' ><rs class='color'><r name='text'/></rs></body>"
	valuedText:SetFormat(userMods.ToWString(format))
	if color then
		valuedText:SetClassVal( "color", color )
	else
		valuedText:SetClassVal( "color", "LogColorYellow" )
	end

	local local_time
	if common.GetLocalDateTime then
		local_time = common.GetLocalDateTime()
	elseif common.GetLocalTimeHMS then
		local_time = common.GetLocalTimeHMS()
		local_time.min = local_time.m
	end

	message = TimeToStr(local_time) ..' ' .. ChatPrefix .. ' - '.. message;
	if not common.IsWString( message ) then 
		message = userMods.ToWString(message) 
	end

	valuedText:SetVal( "text", message )
	chatRows =  chatRows + 1
	wtChat:PushFrontValuedText( valuedText )
end
	
--- call by "EVENT_SECOND_TIMER" - for clear messages from chat
function ClearChat( size )
	for i=1, size or math.ceil( chatRows / 30 ) + 1 do
	if chatRows < 1 then break end
		chatRows = chatRows - 1
		wtChat:PopBack()
	end
end
------------------------------------------------------------------------------------