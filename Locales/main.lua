Global("Locales", {})
Global( "g_offensiveItems", {} )
Global( "g_defensiveItems", {} )
 
function getLocale()
	return Locales[common.GetLocalization()] or Locales["eng"]
end

--LogInfo(userMods.FromWString(common.GetAddonRelatedTextGroup("common"):GetText("locale")))

local func, err = load(userMods.FromWString(common.GetAddonRelatedTextGroup("common"):GetText("locale")))
if func then
	func()
else
	LogInfo("Localization compilation error:", err)
end

func, err = load(userMods.FromWString(common.GetAddonRelatedTextGroup("common"):GetText("insigniaNames")))
if func then
	func()
else
	LogInfo("insigniaNames compilation error:", err)
end
