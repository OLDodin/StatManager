function wtGetDesc(Safe, Name, recursive, flagDel) -- ѕолучить описание виджета, при необходимость уничтожает виджет
	local wtSelectBuffColorSafe = Safe:GetChildChecked( Name, recursive )
	local wtSelectBuffColorDesc = wtSelectBuffColorSafe:GetWidgetDesc()
	if flagDel then
		wtSelectBuffColorSafe:DestroyWidget()
	end	
	return wtSelectBuffColorDesc
end
function wtSetPos(Safe, tabPos) --”становить расположение контрола 
	--[[
	  - alignX,   alignY:   number (enum) -- формат выравни€ (по левому краю, по правому краю, по ширине)
	  - posX,     posY:     number        -- отступ от верхнего кра€
	  - highPosX, highPosY: number        -- отступ от нижнего кра€
	  - sizeX,    sizeY:    number        -- размер
	]]
	
	local placement = Safe:GetPlacementPlain()
	
	--alignX
	if tabPos.alignX then
		placement.alignX = tabPos.alignX
	end
	
	--alignY
	if tabPos.alignY then
		placement.alignY = tabPos.alignY
	end	
	
	--posX
	if tabPos.posX then
		placement.posX = tabPos.posX
	end
	
	--posY
	if tabPos.posY then
		placement.posY = tabPos.posY
	end

	--highPosX
	if tabPos.highPosX then
		placement.highPosX = tabPos.highPosX
	end
	
	--highPosY
	if tabPos.highPosY then
		placement.highPosY = tabPos.highPosY
	end	
	
	--sizeX
	if tabPos.sizeX then
		placement.sizeX = tabPos.sizeX
	end
	
	--sizeY
	if tabPos.sizeY then
		placement.sizeY = tabPos.sizeY
	end
	
	Safe:SetPlacementPlain( placement )
end