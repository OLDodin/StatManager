Global("Locales", {})

function getLocale()
	return Locales[common.GetLocalization()] or Locales["eng"]
end

--------------------------------------------------------------------------------
-- Russian
--------------------------------------------------------------------------------

Locales["rus"]={}
Locales["rus"]["doesNotEnd"]="Что-то пошло не так, попробуйте еще раз"
Locales["rus"]["inFight"]="В бою статы не изменить"
Locales["rus"]["missingAttackInsignia"]="Отсутствует атакующая инсигния"
Locales["rus"]["missingDefenseInsignia"]="Отсутствует защитная инсигния"
Locales["rus"]["workDone"]="Статы установлены"
Locales["rus"]["limitError"]="Не смог установить статы за 100 попыток"

--------------------------------------------------------------------------------
-- English
--------------------------------------------------------------------------------

		
Locales["eng"]={}
Locales["eng"]["doesNotEnd"]="Something went wrong, try again"
Locales["eng"]["inFight"]="Stats cannot be changed in fight"
Locales["eng"]["missingAttackInsignia"]="Missing Insignia of Attack"
Locales["eng"]["missingDefenseInsignia"]="Missing Insignia of Defense"
Locales["eng"]["workDone"]="Work done"
Locales["eng"]["limitError"]="Could not set stats in 100 attempts"
