function wtGetDesc(Safe, Name, recursive, flagDel) -- �������� �������� �������, ��� ������������� ���������� ������
	local wtSelectBuffColorSafe = Safe:GetChildChecked( Name, recursive )
	local wtSelectBuffColorDesc = wtSelectBuffColorSafe:GetWidgetDesc()
	if flagDel then
		wtSelectBuffColorSafe:DestroyWidget()
	end	
	return wtSelectBuffColorDesc
end
function wtSetPos(Safe, tabPos) --���������� ������������ �������� 
	--[[
	  - alignX,   alignY:   number (enum) -- ������ �������� (�� ������ ����, �� ������� ����, �� ������)
	  - posX,     posY:     number        -- ������ �� �������� ����
	  - highPosX, highPosY: number        -- ������ �� ������� ����
	  - sizeX,    sizeY:    number        -- ������
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