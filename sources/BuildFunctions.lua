
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

Global( "TryFindCnt", 0 )
Global( "LoadingBuild", {} )
Global( "IsLoadingNow", false )
Global( "LastActivityTime", 0 )

local m_lastOffenceInsigniaID = nil
local m_lastDefenceInsigniaID = nil
local m_lastOffenceInsigniaIndex = nil
local m_lastDefenceInsigniaIndex = nil
local m_changedItemOnTick = {}

local m_locale = getLocale()
----------------------------------------------------------------------------------------------------
-- Save/Load

function IsSaveGlobal()
	local saveGlobal = userMods.GetGlobalConfigSection("StatManger_free_use_global")
	
	return saveGlobal and saveGlobal.value
end

function SetSaveGlobal(aValue)
	if aValue then
		Chat(m_locale["saveGlobal"])
	else
		Chat(m_locale["saveLocal"])
	end
	userMods.SetGlobalConfigSection( "StatManger_free_use_global", { value = aValue } )
end

function IsFirstStart()
	if not userMods.GetAvatarConfigSection( "StatBuilds" ) and not userMods.GetGlobalConfigSection( "StatBuilds" ) then
		return true
	end
end

function SaveBuildsTable()
	if (IsSaveGlobal()) then
		userMods.SetGlobalConfigSection( "StatBuilds", BuildsTable )
	else
		userMods.SetAvatarConfigSection( "StatBuilds", BuildsTable )
	end
end

function LoadBuildsTable()
	if (IsSaveGlobal()) then
		BuildsTable = userMods.GetGlobalConfigSection( "StatBuilds" )
	else
		BuildsTable = userMods.GetAvatarConfigSection( "StatBuilds" )
	end

	if not BuildsTable then
	--[[ --при нескольких аккаунтах/аватарх мы не сможем однозначно сказать, чистая это
	--при "чистой" установке включаем режим глобального хранения
		if IsFirstStart() then
			SetSaveGlobal(true)
		end]]
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
end

function UpdateBuild( index )
	BuildsTable[ index ].class = clTable[avatar.GetClass()]
	SaveStatBuild( BuildsTable[ index ] )

	SaveBuildsTable()
end

function LoadBuild( aBuild )
	Chat(m_locale["workStart"])
	IsLoadingNow = true
	ResetTryCnt()
	LoadingBuild = aBuild
	LoadBuildInternal(aBuild, true)
end

function StopLoadBuild()
	IsLoadingNow = false
	ResetTryCnt()
	m_changedItemOnTick = {}
	LoadingBuild = {}
	Chat(m_locale["doesNotEnd"], "warning")
end

function GetTimestamp()
	return common.GetMsFromDateTime( common.GetLocalDateTime() )
end


local function IsAllChangedItemVerified()
	for _, verified in pairs(m_changedItemOnTick) do
		if not verified then
			return false
		end
	end
	return true
end

function OnItemChanged(aParam)
	if IsLoadingNow then
		if m_changedItemOnTick[aParam.itemId] ~= nil then
			m_changedItemOnTick[aParam.itemId] = true
			if IsAllChangedItemVerified() then
				LoadBuildInternal( LoadingBuild )
			end
		end
	end
end

local function GetItemTier(anItemId)
	local category = itemLib.GetCategory(anItemId)
	local categoryInfo = category and itemLib.GetCategoryInfo(category)
	local tier = categoryInfo and categoryInfo.sysName and string.match(categoryInfo.sysName, 'Tier(%d+)') -- sysName = 'Tier03'
	return tier and tonumber(tier) or -1
end

local function CheckTier(anItemId)
	return true
	--return GetItemTier(anItemId) < 3
end

function LoadBuildInternal( aBuild )
	LastActivityTime = GetTimestamp()
	if IsPlayerInCombat() then
		Chat(m_locale["inFight"], "warning")
		IsLoadingNow = false
		return false
	end
	local myDressedSlots = unit.GetEquipmentItemIds(avatar.GetId(), ITEM_CONT_EQUIPMENT)
	m_changedItemOnTick = {}
	for i = 0, DRESS_SLOT_UNDRESSABLE-1 do
		local dressedItemID = myDressedSlots[i]
		if aBuild.stats[i] and dressedItemID and CheckTier(dressedItemID) then
			local neededOffenceStatId = aBuild.stats[i][ENUM_SpecialStatType_Offence]
			local neededDefenceStatId = aBuild.stats[i][ENUM_SpecialStatType_Defence]
			local bonus = itemLib.GetBonus(dressedItemID)

			if bonus and bonus.specStats then
				local offenceStat = GetStatByType(bonus.specStats, ENUM_SpecialStatType_Offence)
				local defenceStat = GetStatByType(bonus.specStats, ENUM_SpecialStatType_Defence)
				
				if offenceStat and defenceStat then
					local offenceInsignia = nil;
					local defenceInsignia = nil;

					offenceInsignia, defenceInsignia = GetInsignia()
					if offenceInsignia then 
						if ChangeStat(i, offenceInsignia, dressedItemID, neededOffenceStatId, ENUM_SpecialStatType_Offence) then
							m_changedItemOnTick[dressedItemID] = false
						end
					else 
						Chat(m_locale["missingAttackInsignia"], "warning")
					end
					--иногда при смене одновременно атакующей и защитной стат они меняются сервером в разное время, поэтому крутим по одной
					if m_changedItemOnTick[dressedItemID] == nil then
						if defenceInsignia then 
							if ChangeStat(i, defenceInsignia, dressedItemID, neededDefenceStatId, ENUM_SpecialStatType_Defence) then
								m_changedItemOnTick[dressedItemID] = false
							end
						else 
							Chat(m_locale["missingDefenseInsignia"], "warning")
						end
					end
				end
			end
		end
	end
	
	-- защита от дурака, если что то изменится в api для избежания ухода в бесконечный цикл
	if TryFindCnt > 10 then 
		IsLoadingNow = false
		Chat(m_locale["limitError"], "error")
		return
	end
	
	TryFindCnt = TryFindCnt + 1
	
	if GetTableSize(m_changedItemOnTick) == 0 then
		IsLoadingNow = false
		Chat(m_locale["workDone"])
	end
end

function DeleteBuild( anIndex )
	table.remove( BuildsTable, anIndex )
	SaveBuildsTable()
end

function ChangeStat(anInd, anInsignia, aDressedItemID, aNeededOffenceStatId, aType)
	if IsPlayerInCombat() then
		Chat(m_locale["inFight"], "warning")
		IsLoadingNow = false
		return false
	end
	
	local mayBeUsed = itemLib.CanUseOnItem(anInsignia, aDressedItemID)
	if mayBeUsed then
		if itemLib.IsUseOnItemAndTakeActions(anInsignia) then 
			local bonus = itemLib.GetBonus(aDressedItemID)
			local someStat = GetStatByType(bonus.specStats, aType)
			
			if not aNeededOffenceStatId:IsEqual(someStat.id) then
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
	TryFindCnt = 0
end

function GetStatByType(aSpecStat, aType)
	if GetTableSize(aSpecStat) > 3 then
		--не тир3 а что-то новое, выведем предупреждение, возможно потребуется др механизм
		Chat(m_locale["unsuportedEquip"], "error")
	end
	local statsByTypeArr = {}
	for i, specStat in pairs(aSpecStat) do
		if specStat and specStat.type == aType then
			table.insert(statsByTypeArr, specStat)
		end
	end
	--в тир3 шмоте ищем макс стат этого типа и сохраняем его
	local maxSpexStat = nil
	for i, specStat in pairs(statsByTypeArr) do
		if maxSpexStat == nil then
			maxSpexStat = specStat
		end
		if specStat.value > maxSpexStat.value then
			maxSpexStat = specStat
		end
	end
	
	return maxSpexStat
end

function CheckItemName(aMyItems, anRightNameArr, aLastInsigniaIndex, aLastInsigniaID)
	if aLastInsigniaIndex~=nil then
		local itemID = avatar.GetInventoryItemId(aLastInsigniaIndex)
		if aLastInsigniaID and itemID and aLastInsigniaID == itemID then
			return aLastInsigniaID, aLastInsigniaIndex
		end
	end
		
	for _, searchInsigniaName in ipairs(anRightNameArr) do
		for i, itemID in pairs(aMyItems) do
			local itemName = ItemInfoGetName(itemID)
			
			if itemName == searchInsigniaName then
				return itemID, i
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
	m_lastOffenceInsigniaID, m_lastOffenceInsigniaIndex = CheckItemName(myItems, g_offensiveItems, m_lastOffenceInsigniaIndex, m_lastOffenceInsigniaID)
	m_lastDefenceInsigniaID, m_lastDefenceInsigniaIndex = CheckItemName(myItems, g_defensiveItems, m_lastDefenceInsigniaIndex, m_lastDefenceInsigniaID)
	
	return m_lastOffenceInsigniaID, m_lastDefenceInsigniaID
end


function ItemInfoGetName(anID)
	if anID then
		local itemInfo = itemLib.GetItemInfo(anID)
		if itemInfo then
			if itemInfo.name then
				return itemInfo.name
			else
				return common.GetEmptyWString()
			end
		else
			return common.GetEmptyWString()
		end
	end
end
----------------------------------------------------------------------------------------------------

function SaveStatBuild(aBuilds)
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




