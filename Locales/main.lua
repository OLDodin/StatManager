Global("Locales", {})

function getLocale()
	return Locales[common.GetLocalization()] or Locales["eng"]
end

--------------------------------------------------------------------------------
-- Russian
--------------------------------------------------------------------------------

Locales["rus"]={}
Locales["rus"]["doesNotEnd"]="���-�� ����� �� ���, ���������� ��� ���"
Locales["rus"]["inFight"]="� ��� ����� �� ��������"
Locales["rus"]["missingAttackInsignia"]="����������� ��������� ��������"
Locales["rus"]["missingDefenseInsignia"]="����������� �������� ��������"
Locales["rus"]["workDone"]="����� �����������"
Locales["rus"]["limitError"]="�� ���� ���������� ����� �� 100 �������"

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
