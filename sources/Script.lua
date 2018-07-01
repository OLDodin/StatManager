local ListMode = false
local ListButton = mainForm:GetChildChecked( "ListButton", true )
local ButtonText = mainForm:GetChildChecked( "ButtonText", true )
ButtonText:SetVal("name", userMods.ToWString( ListMode and "Sc" or "S" )) 
ButtonText:SetClassVal("class", "tip_white" )
ListButton:AddChild(ButtonText)
ButtonText:Show(true)

----------------------------------------------------------------------------------------------------
-- AddonManager support

function onMemUsageRequest( params )
	userMods.SendEvent( "U_EVENT_ADDON_MEM_USAGE_RESPONSE",
		{ sender = common.GetAddonName(), memUsage = gcinfo() } )
end

function onToggleDND( params )
	if params.target == common.GetAddonName() then
		DnD:Enable( ListButton, params.state )
	end
end

function onToggleVisibility( params )
	if params.target == common.GetAddonName() then
		mainForm:Show( params.state == true )
	end
end

function onInfoRequest( params )
	if params.target == common.GetAddonName() then
		userMods.SendEvent( "SCRIPT_ADDON_INFO_RESPONSE", {
			sender = params.target,
			desc = "",
			showDNDButton = true,
			showHideButton = true,
			showSettingsButton = false,
		} )
	end
end

----------------------------------------------------------------------------------------------------
-- AOPanel support

local IsAOPanelEnabled = GetConfig( "EnableAOPanel" ) or GetConfig( "EnableAOPanel" ) == nil

function onAOPanelStart( params )
	if IsAOPanelEnabled then
		local SetVal = { val = userMods.ToWString( "S" ) }
		local params = { header = SetVal, ptype = "button", size = 32 }
		userMods.SendEvent( "AOPANEL_SEND_ADDON",
			{ name = common.GetAddonName(), sysName = common.GetAddonName(), param = params } )

		ListButton:Show( false )
	end
end

function onAOPanelLeftClick( params )
	if params.sender == common.GetAddonName() then
		onShowList()
	end
end

function onAOPanelRightClick( params )
	if params.sender == common.GetAddonName() then
		local SetVal = { val = userMods.ToWString( ListMode and "S" or "Sc" )}
		userMods.SendEvent( "AOPANEL_UPDATE_ADDON", { sysName = common.GetAddonName(), header = SetVal } )
		ListMode = not ListMode
	end
end

function RightClick(param)
	ButtonText:SetVal("name", userMods.ToWString( ListMode and "S" or "Sc" )) 
	ListMode = not ListMode
end

function onAOPanelChange( params )
	if params.unloading and params.name == "UserAddon/AOPanelMod" then
		ListButton:Show( true )
	end
end

function enableAOPanelIntegration( enable )
	IsAOPanelEnabled = enable
	SetConfig( "EnableAOPanel", enable )

	if enable then
		onAOPanelStart()
	else
		ListButton:Show( true )
	end
end

----------------------------------------------------------------------------------------------------

function GetLocalizedText()
	local localizationStr = common.GetLocalization()
	if localizationStr == "eng_eu" then
		localizationStr = "eng"
	end
	return common.GetAddonRelatedTextGroup( localizationStr )
end

local BuildsMenu = nil
local ClassMenu = nil
local Localization = GetLocalizedText()

function onSaveBuild( params )
	local wtEdit = params.widget:GetParent():GetChildChecked( "BuildNameEdit", true )
	local text = userMods.FromWString( wtEdit:GetText() )

	if text ~= "" then
		SaveCurrentBuild( text )
		onShowList()
		onShowList()
	end
end


function getBuildIndex( build )
	for i = 1, table.getn( BuildsTable ) do
		if BuildsTable[i] == build then
			return i
		end
	end
end

function CreateSubMenu(ClassName)
	local SubMenu = {}
	for i, v in ipairs( BuildsTable ) do
		if type(v) == "table" then
			local build = BuildsTable[i]
			if ClassName == nil or v.class== clTable[ClassName] then
				local MenuName = v.name 
				--if v.class then MenuName = MenuName..'('..v.class..')'	end			
				table.insert( SubMenu, {
					name = userMods.ToWString( MenuName ),
					onActivate = function() LoadBuild( build ) end,
					submenu = {
						{ name = Localization:GetText( "rename" ),
							onActivate = function() onRenameBuild( build ) end },
						{ name = Localization:GetText( "delete" ),
							onActivate = function() DeleteBuild( getBuildIndex( build ) ); onShowList(); onShowList() end },
						{ name = Localization:GetText( "update" ),
							onActivate = function() UpdateBuild( getBuildIndex( build ) ) end },
					}
				})
			end
		end
	end
	return SubMenu
end

function onShowList( params )
	if DnD:IsDragging() then
		return
	end

	if not ClassMenu or not ClassMenu:IsValid() then
		local menu = {}
		
		if ListMode then
			for i, v in pairs( clTable ) do
				local SubMenus = CreateSubMenu(i)
			 	if table.getn(SubMenus) > 0 then table.insert( menu, { name = userMods.ToWString(v),submenu = SubMenus} ) end
			end		
		else
			menu = CreateSubMenu(nil)
		end

		local desc = mainForm:GetChildChecked( "SaveBuildTemplate", false ):GetWidgetDesc()
		table.insert( menu, { createWidget = function() return mainForm:CreateWidgetByDesc( desc ) end } )

		if ListButton:IsVisible() then
			local pos = ListButton:GetPlacementPlain()
			ClassMenu = ShowMenu( { x = pos.posX, y = pos.posY + pos.sizeY }, menu )
		else
			ClassMenu = ShowMenu( { x = 0, y = 32 }, menu )
		end
		RegisterDnd()
		ClassMenu:GetChildChecked( "BuildNameEdit", true ):SetFocus( true )
	else
		DestroyMenu( ClassMenu )
		ClassMenu = nil
	end
end

----------------------------------------------------------------------------------------------------
-- Renaming

local RenameBuildIndex = nil

function GetMenuItems()
	local children = ClassMenu:GetNamedChildren()
	table.sort( children,
		function( a, b )
			if a:GetName() == "ItemEditTemplate" then return false end
			if b:GetName() == "ItemEditTemplate" then return true end
			return a:GetPlacementPlain().posY < b:GetPlacementPlain().posY
		end )
	return children
end

function onRenameBuild( build )
	if RenameBuildIndex then
		onRenameCancel()
	end

	RenameBuildIndex = getBuildIndex( build )

	local item = GetMenuItems()[ RenameBuildIndex ]
	item:Show( false )

	local edit = ClassMenu:GetChildChecked( "ItemEditTemplate", false )
	edit:SetText( userMods.ToWString( build.name ) )
	edit:SetPlacementPlain( item:GetPlacementPlain() )
	edit:Show( true )
	edit:Enable( true )
	edit:SetFocus( true )
	ClassMenu:GetChildChecked( "BuildNameEdit", true ):SetFocus( false )
end

function onRenameCancel( params )
	local item = GetMenuItems()[ RenameBuildIndex ]
	item:Show( true )

	local edit = ClassMenu:GetChildChecked( "ItemEditTemplate", false )
	edit:Show( false )
	edit:Enable( false )

	ClassMenu:GetChildChecked( "BuildNameEdit", true ):SetFocus( true )
	RenameBuildIndex = nil
end

function onRenameAccept( params )
	local edit = ClassMenu:GetChildChecked( "ItemEditTemplate", false )
	BuildsTable[ RenameBuildIndex ].name = userMods.FromWString( edit:GetText() )
	SaveBuildsTable()
	RenameBuildIndex = nil

	onShowList()
	onShowList()
end

function onRenameFocus( params )
	if not params.active then
		onRenameAccept( params )
	end
end

----------------------------------------------------------------------------------------------------
-- DnD support

local BaseDndId = 148754678
local DraggedItem = nil
local DragFrom = nil
local DragTo = nil

function IsDragging()
	return DraggedItem ~= nil
end

function RegisterDnd()
	local children = GetMenuItems()
	for i, child in ipairs(children) do
		local nameWidget = child:GetChildUnchecked( "CombinedItem", false )
		if nameWidget then
			mission.DNDRegister( nameWidget, BaseDndId + i, true )
		end
	end
end

function OnDndPick( params )
	if BaseDndId <= params.srcId and params.srcId <= BaseDndId + table.getn(BuildsTable) then
		DraggedItem = params.srcWidget:GetParent()

		local children = GetMenuItems()
		DragFrom = 1
		while children[DragFrom]:GetInstanceId() ~= DraggedItem:GetInstanceId() do
			DragFrom = DragFrom + 1
			if DragFrom > table.getn(BuildsTable) then
				return
			end
		end

		if RenameBuildIndex then
			onRenameCancel()
		end

		common.RegisterEventHandler( OnDndDragTo, "EVENT_DND_DRAG_TO" )
		common.RegisterEventHandler( OnDndEnd, "EVENT_DND_DROP_ATTEMPT" )
		common.RegisterEventHandler( OnDndEnd, "EVENT_DND_DRAG_CANCELLED" )
		mission.DNDConfirmPickAttempt()
	end
end

function OnDndDragTo( params )
	local posConverter = widgetsSystem:GetPosConverterParams()
	local cursorY = params.posY * posConverter.fullVirtualSizeY / posConverter.realSizeY
	local cursorY = cursorY - DraggedItem:GetParent():GetPlacementPlain().posY

	local children = GetMenuItems()
	local childrenPos = {}
	local dragIndex = nil

	local height = 16
	for i, w in ipairs( children ) do
		if w:GetInstanceId() == DraggedItem:GetInstanceId() then
			dragIndex = i
		end
		childrenPos[ i ] = w:GetPlacementPlain()
		childrenPos[ i ].posY = height
		height = height + childrenPos[ i ].sizeY
	end

	DragTo = dragIndex
	if cursorY < childrenPos[dragIndex].posY then
		while DragTo > 1 and cursorY < childrenPos[DragTo].posY do
			DragTo = DragTo - 1
		end
	else
		while DragTo < table.getn(BuildsTable) and cursorY > childrenPos[DragTo].posY + childrenPos[DragTo].sizeY do
			DragTo = DragTo + 1
		end
	end
	table.insert( children, DragTo, table.remove( children, dragIndex ) )

	for i, w in ipairs( children ) do
		w:PlayMoveEffect( w:GetPlacementPlain(), childrenPos[i], 100, EA_MONOTONOUS_INCREASE )
	end
end

function OnDndEnd( params )
	if DragFrom ~= DragTo then
		table.insert( BuildsTable, DragTo, table.remove( BuildsTable, DragFrom ) )
		SaveBuildsTable()
	end

	DraggedItem = nil
	DragFrom = nil
	DragTo = nil

	common.UnRegisterEventHandler( OnDndDragTo, "EVENT_DND_DRAG_TO" )
	common.UnRegisterEventHandler( OnDndEnd, "EVENT_DND_DROP_ATTEMPT" )
	common.UnRegisterEventHandler( OnDndEnd, "EVENT_DND_DRAG_CANCELLED" )
	mission.DNDConfirmDropAttempt()
end

----------------------------------------------------------------------------------------------------

function Init()
	LoadBuildsTable()

	DnD:Init( 527, ListButton, ListButton, true )
	DnD:Init( 528, ButtonText, ListButton, true )

	common.RegisterEventHandler( onInfoRequest, "SCRIPT_ADDON_INFO_REQUEST" )
	common.RegisterEventHandler( onMemUsageRequest, "U_EVENT_ADDON_MEM_USAGE_REQUEST" )
	common.RegisterEventHandler( onToggleDND, "SCRIPT_TOGGLE_DND" )
	common.RegisterEventHandler( onToggleVisibility, "SCRIPT_TOGGLE_VISIBILITY" )

	common.RegisterEventHandler( onAOPanelStart, "AOPANEL_START" )
	common.RegisterEventHandler( onAOPanelLeftClick, "AOPANEL_BUTTON_LEFT_CLICK" )
	common.RegisterEventHandler( onAOPanelRightClick, "AOPANEL_BUTTON_RIGHT_CLICK" )
	common.RegisterEventHandler( onAOPanelChange, "EVENT_ADDON_LOAD_STATE_CHANGED" )

	common.RegisterReactionHandler( onSaveBuild, "SaveBuildReaction" )
	common.RegisterReactionHandler( onShowList, "ShowBuildsReaction" )
	common.RegisterReactionHandler( RightClick, "RIGHT_CLICK" )
	common.RegisterReactionHandler( onRenameCancel, "RenameCancelReaction" )
	common.RegisterReactionHandler( onRenameAccept, "RenameBuildReaction" )
	common.RegisterReactionHandler( onRenameFocus, "RenameFocusChanged" )
	common.RegisterReactionHandler( onShowList, "WikiEscReaction" )

	common.RegisterEventHandler( OnDndPick, "EVENT_DND_PICK_ATTEMPT" )
	
	common.RegisterEventHandler( OnStatChanged, "EVENT_AVATAR_STATS_CHANGED")

	InitMenu()
end

Init()

