
-- StatBuilds - table: index (int) -> build
-- 	build - table of:
-- 		name - build name, string
-- 		stats - table: TalentKey( row, line ) -> stattype
--								(dressSlot, 0-atak 1-defence)	

Global( "BuildsTable", {} )

Global( "clTable", {
	DRUID = "DRUID",
	MAGE = "MAGE",
	NECROMANCER = "NECROMANCER",
	PALADIN = "PALADIN",
	PRIEST = "PRIEST",
	PSIONIC = "PSIONIC", 
	STALKER = "STALKER",
	WARRIOR = "WARRIOR",
	BARD = "BARD", 
	ENGINEER = "ENGINEER",
	WARLOCK = "WARLOCK"
})

Global( "TryFindCnt", {} )
Global( "LoadingBuild", {} )
Global( "IsLoadingNow", false )

----------------------------------------------------------------------------------------------------
-- Save/Load

function SaveBuildsTable()
	userMods.SetAvatarConfigSection( "StatBuilds", BuildsTable )
end

function LoadBuildsTable()
	BuildsTable = userMods.GetAvatarConfigSection( "StatBuilds" )
	if not BuildsTable then
		BuildsTable = {}
	end
end

----------------------------------------------------------------------------------------------------


function SaveCurrentBuild( name )
	local build = {}
	build.name = name
	build.class =  clTable[avatar.GetClass()]
	SaveStatBuild( build )

	table.insert( BuildsTable, build )
	SaveBuildsTable()
--	userMods.SendEvent( "BUILD_MANAGER_REQUEST_BILD", { index = table.getn(BuildsTable) } )
end

function UpdateBuild( index )
	BuildsTable[ index ].class = clTable[avatar.GetClass()]
	SaveStatBuild( BuildsTable[ index ] )

	SaveBuildsTable()
--	userMods.SendEvent( "BUILD_MANAGER_REQUEST_BILD", { index = index } )
end

function LoadBuild( aBuild )
	--[[if IsLoadingNow then 
		Chat("Подождите, загружается др. билд")
		return
	end ]]--
	IsLoadingNow = true
	ResetTryCnt()
	LoadingBuild = aBuild
	LoadBuildInternal(aBuild, true)
end

function OnStatChanged()
	--common.LogInfo( common.GetAddonName(), 'change stat ')
	
	--common.UnRegisterEventHandler( OnStatChanged, "EVENT_AVATAR_STATS_CHANGED" )
	if IsLoadingNow then
		LoadBuildInternal( LoadingBuild )	
	end
end

function LoadBuildInternal( aBuild )
	if IsPlayerInCombat() then
		Chat("В бою статы не изменить")
		IsLoadingNow = false
		return false
	end
	local myDressedSlots = unit.GetEquipmentItemIds(avatar.GetId(), ITEM_CONT_EQUIPMENT)
	--common.LogInfo( common.GetAddonName(), 'LoadBuild1')
	for i = 0, DRESS_SLOT_UNDRESSABLE-1 do
		if aBuild.stats[i] then
			local neededOffenceStatId = aBuild.stats[i][ENUM_SpecialStatType_Offence]
			local neededDefenceStatId = aBuild.stats[i][ENUM_SpecialStatType_Defence]
			--common.LogInfo( common.GetAddonName(), 'LoadBuild2  '..i)
			local dressedItemID = myDressedSlots[i]
			local bonus = nil
			if dressedItemID then 
				bonus = itemLib.GetBonus(dressedItemID)
			end
			if bonus and bonus.specStats then
				local offenceStat = GetStatByType(bonus.specStats, ENUM_SpecialStatType_Offence)
				local defenceStat = GetStatByType(bonus.specStats, ENUM_SpecialStatType_Defence)
				--common.LogInfo( common.GetAddonName(), 'LoadBuild3')
				if offenceStat and defenceStat then
					local offenceInsignia = nil;
					local defenceInsignia = nil;
					--common.LogInfo( common.GetAddonName(), 'LoadBuild4')
					offenceInsignia, defenceInsignia = GetInsignia()
					if offenceInsignia then 
					--common.LogInfo( common.GetAddonName(), 'ChangeStat offence')
						if ChangeStat(i, offenceInsignia, dressedItemID, neededOffenceStatId, ENUM_SpecialStatType_Offence) then
							return
						end
					else 
						Chat("Отсутствует атакующая инсигния")
					end
									
					if defenceInsignia then 
					--common.LogInfo( common.GetAddonName(), 'ChangeStat def')
						if ChangeStat(i, defenceInsignia, dressedItemID, neededDefenceStatId, ENUM_SpecialStatType_Defence) then
							return
						end
					else 
						Chat("Отсутствует защитная инсигния")
					end
				end
			end
		end
	end
	IsLoadingNow = false
	Chat("Статы установлены")
end

function DeleteBuild( anIndex )
	table.remove( BuildsTable, anIndex )
	SaveBuildsTable()
end

function ChangeStat(anInd, anInsignia, aDressedItemID, aNeededOffenceStatId, aType)
	if IsPlayerInCombat() then
		Chat("В бою статы не изменить")
		IsLoadingNow = false
		return false
	end
	
	local mayBeUsed = itemLib.CanUseOnItem(anInsignia, aDressedItemID)
	--common.LogInfo( common.GetAddonName(), 'LoadBuild5')
	if mayBeUsed then
		if itemLib.IsUseOnItemAndTakeActions(anInsignia) then 
			local bonus = itemLib.GetBonus(aDressedItemID)
			local offenceStat = GetStatByType(bonus.specStats, aType)

			if not aNeededOffenceStatId:IsEqual(offenceStat.id) then
				--common.LogInfo( common.GetAddonName(), '--LoadBuild8-- ')
				-- защита от дурака, если что то изменится в api для избежание ухода в бесконечный цикл
				if TryFindCnt[anInd] > 100 then 
					--common.LogInfo( common.GetAddonName(), 'terminate change by TryFindCnt[i] ')
					IsLoadingNow = false
					Chat("Не смог установить статы за 100 попыток")
					return true
				end

				--common.RegisterEventHandler( OnStatChanged, "EVENT_AVATAR_STATS_CHANGED")

				TryFindCnt[anInd] = TryFindCnt[anInd] + 1
				
				avatar.UseItemOnItemAndTakeActions(anInsignia, aDressedItemID)
				
				return true
			end
		end
	end
	
	return false
end

function IsPlayerInCombat()
  local playerId = avatar.GetId()
  return object.IsInCombat(playerId)
end

function ResetTryCnt()
	for i = 0, DRESS_SLOT_UNDRESSABLE-1 do
		TryFindCnt[i] = 0
	end
end

function GetStatByType(aSpecStat, aType)
	if aSpecStat[1] and aSpecStat[1].type == aType then
		return aSpecStat[1]
	end
	if aSpecStat[2] and aSpecStat[2].type == aType then
		return aSpecStat[2]
	end
	
	return nil
end

function CheckItemName(aMyItems, anRightNameArr)
	for _, searchInsigniaName in ipairs(anRightNameArr) do
		for i, itemId in pairs(aMyItems) do
			local itemName = ItemInfoGetName(itemId)
			
			if itemName == searchInsigniaName then
				return itemId
			end
		end
	end
	return nil
end

function GetInsignia()
	local myItems = avatar.GetInventoryItemIds()
	if not myItems then 
		myItems = {}
	end
	local resultOffenceInsignia = CheckItemName(myItems, g_offensiveItems)
	local resultDefenceInsignia = CheckItemName(myItems, g_defensiveItems)
	
	return resultOffenceInsignia, resultDefenceInsignia
end


function ItemInfoGetName(anId)
	if anId then
		local itemInfo = itemLib.GetItemInfo(anId)
		if itemInfo then
			if itemInfo.name then
				return userMods.FromWString(itemInfo.name)
			else
				return "";
			end
		else
			return "";
		end
	end
end
----------------------------------------------------------------------------------------------------

function SaveStatBuild( aBuilds )
	aBuilds.stats = {}

	local myDressedSlots = unit.GetEquipmentItemIds(avatar.GetId(), ITEM_CONT_EQUIPMENT)
	
	for i = 0, DRESS_SLOT_UNDRESSABLE-1 do
		local dressedItemID = myDressedSlots[i]
		aBuilds.stats[i] = nil;
		
		if dressedItemID then
			local bonus = itemLib.GetBonus(dressedItemID)
			if bonus and bonus.specStats then
				local offenceStat = GetStatByType(bonus.specStats, ENUM_SpecialStatType_Offence)
				local defenceStat = GetStatByType(bonus.specStats, ENUM_SpecialStatType_Defence)

				
				if offenceStat and defenceStat then					
					local cell = {}
					cell[ENUM_SpecialStatType_Offence] = offenceStat.id
					cell[ENUM_SpecialStatType_Defence] = defenceStat.id

					aBuilds.stats[i] = cell;
				end 
			end
		end
		
	end
end




