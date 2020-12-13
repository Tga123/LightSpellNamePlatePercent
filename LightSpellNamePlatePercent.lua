LightSpellNamePlatePercent = LibStub("AceAddon-3.0"):NewAddon("LightSpellNamePlatePercent", "AceEvent-3.0", "AceTimer-3.0")

function LightSpellNamePlatePercent:OnEnable()
	LightSpellNamePlatePercent.LSNPP_Timers = {};
	LightSpellNamePlatePercent:RegisterEvent("NAME_PLATE_UNIT_ADDED",LSNPP_MainAdd)
	LightSpellNamePlatePercent:RegisterEvent("NAME_PLATE_UNIT_REMOVED",LSNPP_MainRemove)
	LightSpellNamePlatePercent:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED",LSNPP_MainAdd)
	LightSpellNamePlatePercent:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_REMOVED",LSNPP_MainRemove)
end

function LSNPP_FormatNumber (LSNPP_Number)
	if (LSNPP_Number > 999999999) then
		return format ("%.2fB", LSNPP_Number/1000000000)
	elseif (LSNPP_Number > 999999) then
		return format ("%.2fM", LSNPP_Number/1000000)
	elseif (LSNPP_Number > 99999) then
		return floor (LSNPP_Number/1000) .. "K"
	elseif (LSNPP_Number > 999) then
		return format ("%.1fK", (LSNPP_Number/1000))
	end
	return format ("%.0f", LSNPP_Number)
end

function LightSpellNamePlatePercent:LSNPP_UpdateFontStringsHP(LSNPP_UpdateHealthBar, LSNPP_unitID_UpdateHP)
	local LSNPP_currentHealth, LSNPP_maxHealth = UnitHealth(LSNPP_unitID_UpdateHP), UnitHealthMax(LSNPP_unitID_UpdateHP)
	LSNPP_UpdateHealthBar.LSNPP_Str_Health:SetText (LSNPP_FormatNumber(LSNPP_currentHealth) .. " (" .. ceil (LSNPP_currentHealth / LSNPP_maxHealth * 100) .. "%)")
end

function LightSpellNamePlatePercent:LSNPP_UpdateFontStringsMP(LSNPP_UpdateManaFrame, LSNPP_unitID_UpdateMP)
	local LSNPP_currentPower, LSNPP_maxPower = UnitPower(LSNPP_unitID_UpdateMP), UnitPowerMax(LSNPP_unitID_UpdateMP)
	LSNPP_UpdateManaFrame.LSNPP_Str_Power:SetText (LSNPP_FormatNumber(LSNPP_currentPower) .. " (" .. ceil (LSNPP_currentPower / LSNPP_maxPower * 100) .. "%)")
end

function LSNPP_MainAddHP(LSNPP_unitID)
	local LSNPP_PlateFrame = C_NamePlate.GetNamePlateForUnit(LSNPP_unitID)
	if not LSNPP_PlateFrame.UnitFrame or not LSNPP_PlateFrame.UnitFrame.healthBar then return end
	local LSNPP_HealthBar = LSNPP_PlateFrame.UnitFrame.healthBar
	if (not LSNPP_HealthBar.LSNPP_Str_Health) then	
		LSNPP_HealthBar.LSNPP_Str_Health = LSNPP_HealthBar:CreateFontString (nil, "Overlay", "GameFontNormal")
		LSNPP_HealthBar.LSNPP_Str_Health:SetPoint ("CENTER", LSNPP_HealthBar)
		LSNPP_HealthBar.LSNPP_Str_Health:SetSize (LSNPP_HealthBar:GetSize())
		LSNPP_HealthBar.LSNPP_Str_Health:SetTextColor(1, 1, 1, 1)
		LSNPP_HealthBar.LSNPP_Str_Health:SetShadowColor(0, 0, 0, 1)
		LSNPP_HealthBar.LSNPP_Str_Health:Hide()
		--print("|r|cFF0099FFLightSpellNamePlatePercent:|r DRAWING " .. LSNPP_unitID)
	end
	LSNPP_HealthBar.LSNPP_Str_Health:SetText("")
	LightSpellNamePlatePercent.LSNPP_Timers[LSNPP_unitID .. "__HP"] = LightSpellNamePlatePercent:ScheduleRepeatingTimer("LSNPP_UpdateFontStringsHP", 0.15, LSNPP_HealthBar, LSNPP_unitID)
	LSNPP_HealthBar.LSNPP_Str_Health:Show()
end

function LSNPP_MainAddMP(LSNPP_unitID)
	local LSNPP_PlateFrame = C_NamePlate.GetNamePlateForUnit(LSNPP_unitID)
	local LSNPP_PlateSubFrame = { LSNPP_PlateFrame:GetChildren() }
	local LSNPP_ManaFrame
	for _, LSNPP_Child in ipairs(LSNPP_PlateSubFrame) do
		if (LSNPP_Child:GetName() == "ClassNameplateManaBarFrame") then
			LSNPP_ManaFrame = LSNPP_Child
		end
	end
	if not LSNPP_ManaFrame then return end
	if (not LSNPP_ManaFrame.LSNPP_Str_Power) then
		LSNPP_ManaFrame.LSNPP_Str_Power = LSNPP_ManaFrame:CreateFontString (nil, "Overlay", "GameFontNormal")
		LSNPP_ManaFrame.LSNPP_Str_Power:SetPoint ("CENTER", LSNPP_ManaFrame)
		LSNPP_ManaFrame.LSNPP_Str_Power:SetSize (LSNPP_ManaFrame:GetSize())
		LSNPP_ManaFrame.LSNPP_Str_Power:SetTextColor(1, 1, 1, 1)
		LSNPP_ManaFrame.LSNPP_Str_Power:SetShadowColor(0, 0, 0, 1)
		LSNPP_ManaFrame.LSNPP_Str_Power:Hide()
	end
	LSNPP_ManaFrame.LSNPP_Str_Power:SetText("")
	LightSpellNamePlatePercent.LSNPP_Timers[LSNPP_unitID .. "__MP"] = LightSpellNamePlatePercent:ScheduleRepeatingTimer("LSNPP_UpdateFontStringsMP", 0.15, LSNPP_ManaFrame, LSNPP_unitID)
	LSNPP_ManaFrame.LSNPP_Str_Power:Show()
end

function LSNPP_MainAdd(_, LSNPP_unitID)
	LSNPP_MainAddHP(LSNPP_unitID);
	if (UnitIsUnit("player", LSNPP_unitID)) then 
		LSNPP_MainAddMP(LSNPP_unitID);
	end;
end

function LSNPP_MainRemove(_, LSNPP_unitID)
	LightSpellNamePlatePercent:CancelTimer(LightSpellNamePlatePercent.LSNPP_Timers[LSNPP_unitID .. "__HP"])
	if (UnitIsUnit("player", LSNPP_unitID)) then 
		LightSpellNamePlatePercent:CancelTimer(LightSpellNamePlatePercent.LSNPP_Timers[LSNPP_unitID .. "__MP"])
	end;
	--print("|r|cFF0099FFLightSpellNamePlatePercent:|r called MainRemove " .. LSNPP_unitID)
end