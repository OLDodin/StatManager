Global("Locales", {})
Global("LocalesInited", false)
Global( "g_offensiveItems", {} )
Global( "g_defensiveItems", {} )
 
local localeGroup = common.GetAddonRelatedTextGroup(common.GetLocalization(), true) or common.GetAddonRelatedTextGroup("eng")

function PrepareLocale()
	--[[указываем инсигнии в порядке приоритета их использовния (чем раньше тем выше приоритет)]]
	for i = 1, 16 do
		table.insert(g_offensiveItems, common.GetAddonRelatedTextGroup("insigniaNames"):GetText("offensiveItem"..i))
	end
	for i = 1, 16 do
		table.insert(g_defensiveItems, common.GetAddonRelatedTextGroup("insigniaNames"):GetText("defensiveItem"..i))
	end
end

PrepareLocale()

function getLocale()
	if LocalesInited then
		return Locales
	else
		LocalesInited = true
		return setmetatable(Locales, 
			{__index = function(t,k) 
				if localeGroup:HasText(k) then
					return localeGroup:GetText(k) 
				end
			end
			}
		)
	end
end
