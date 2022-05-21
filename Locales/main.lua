Global("Locales", {})
Global( "g_offensiveItems", {} )
Global( "g_defensiveItems", {} )
 

local localeGroup = common.GetAddonRelatedTextGroup(common.GetLocalization()) or common.GetAddonRelatedTextGroup("eng")

function PrepareLocale()
	--[[указываем инсигнии в порядке приоритета их использовния (чем раньше тем выше приоритет)]]
	for i = 1, 12 do
		table.insert(g_offensiveItems, common.GetAddonRelatedTextGroup("insigniaNames"):GetText("offensiveItem"..i))
	end
	for i = 1, 12 do
		table.insert(g_defensiveItems, common.GetAddonRelatedTextGroup("insigniaNames"):GetText("defensiveItem"..i))
	end
end

PrepareLocale()

function getLocale()
	return setmetatable(Locales, 
		{__index = function(t,k) 
			if localeGroup:HasText(k) then
				return localeGroup:GetText(k) 
			end
		end
		}
	)
end
