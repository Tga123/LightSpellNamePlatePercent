--------------------INITIALIZE-------------------------------
local LSNPP = LibStub("AceAddon-3.0"):NewAddon("LightSpellNamePlatePercent", "AceEvent-3.0")

function LSNPP:OnEnable()
	LSNPP:RegisterEvent("NAME_PLATE_UNIT_ADDED", "MainAdd")
	LSNPP:RegisterEvent("NAME_PLATE_UNIT_REMOVED", "MainRemove")
	LSNPP:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED", "MainAdd")
	LSNPP:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_REMOVED", "MainRemove")
	LSNPP:RegisterEvent("UNIT_MAXHEALTH")
	LSNPP:RegisterEvent("UNIT_HEALTH")

	LSNPP.HpMaxList = {}
	LSNPP.MaxPower = 1
	LSNPP.PowerType = 0
	LSNPP.PowerToken = "MANA"
end
-----------------------------------------------------------
-------------------------UTILITY---------------------------
local function LSNPP_FormatNumber(Number)
	if Number > 999999999 then
		return format("%.2fB", Number / 1000000000)
	elseif Number > 999999 then
		return format("%.2fM", Number / 1000000)
	elseif Number > 99999 then
		return floor(Number / 1000) .. "K"
	elseif Number > 999 then
		return format("%.1fK", (Number / 1000))
	end
	return format("%.0f", Number)
end

function LSNPP:MainAdd(_, UnitID)
	LSNPP:AddHpString(nil, UnitID)
	if UnitIsPlayer(UnitID) then
		local Success = pcall(function() LSNPP:AddMpString() end)
		if not Success then return end
		LSNPP:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
		LSNPP:UnregisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED")
		LSNPP:RegisterEvent("NAME_PLATE_UNIT_ADDED", "AddHpString")
		LSNPP:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED", "AddHpString")
	end
end

function LSNPP:MainRemove(_, UnitID)
	LSNPP.HpMaxList[UnitID] = nil
end
-----------------------------------------------------------
-------------------------HEALTH---------------------------

function LSNPP:UNIT_MAXHEALTH(_, UnitID)
	if LSNPP.HpMaxList[UnitID] then
		LSNPP.HpMaxList[UnitID] = UnitHealthMax(UnitID)
		LSNPP:UNIT_HEALTH(nil, UnitID)
	end
end

function LSNPP:UNIT_HEALTH(_, UnitID)
	if LSNPP.HpMaxList[UnitID] then
		local HpStr = C_NamePlate.GetNamePlateForUnit(UnitID).UnitFrame.healthBar.LSNPP_Str_Health
		local CurrentHealth = UnitHealth(UnitID)
		HpStr:SetText(
			LSNPP_FormatNumber(CurrentHealth) .. " (" .. ceil(CurrentHealth / LSNPP.HpMaxList[UnitID] * 100) .. "%)"
		)
	end
end

function LSNPP:AddHpString(_, UnitID)
	local PlateFrame = C_NamePlate.GetNamePlateForUnit(UnitID)
	if not PlateFrame or not PlateFrame.UnitFrame or not PlateFrame.UnitFrame.healthBar then
		return
	end
	--print("|r|cFF0099FFLSNPP:|r DRAWING " .. UnitID)
	local HealthBar = PlateFrame.UnitFrame.healthBar
	if not HealthBar.LSNPP_Str_Health then
		HealthBar.LSNPP_Str_Health = HealthBar:CreateFontString(nil, "Overlay", "GameFontNormal")
		HealthBar.LSNPP_Str_Health:SetPoint("TOPLEFT", HealthBar)
		HealthBar.LSNPP_Str_Health:SetPoint("BOTTOMRIGHT", HealthBar)
		HealthBar.LSNPP_Str_Health:SetTextColor(1, 1, 1, 1)
		HealthBar.LSNPP_Str_Health:SetShadowColor(0, 0, 0, 1)
		HealthBar.LSNPP_Str_Health:Show()
	end
	HealthBar.LSNPP_Str_Health:SetText("")
	LSNPP.HpMaxList[UnitID] = 1
	LSNPP:UNIT_MAXHEALTH(nil, UnitID)
	LSNPP:UNIT_HEALTH(nil, UnitID)
end
---------------------------------------------------------
-------------------------POWER---------------------------
function LSNPP:PLAYER_TALENT_UPDATE()
	LSNPP.PowerType, LSNPP.PowerToken = UnitPowerType("player")
	LSNPP:UNIT_MAXPOWER(nil, "player", LSNPP.PowerToken)
end

function LSNPP:UNIT_MAXPOWER(_, UnitID, PowerID)
	if UnitID == "player" and PowerID == LSNPP.PowerToken then
		LSNPP.MaxPower = UnitPowerMax("player", LSNPP.PowerType)
	end
end

function LSNPP:UNIT_POWER_FREQUENT(_, UnitID, PowerID)
	if UnitID == "player" and PowerID == LSNPP.PowerToken then
		local CurrentPower = UnitPower("player", LSNPP.PowerType)
		LSNPP_Str_Power:SetText(
			LSNPP_FormatNumber(CurrentPower) .. " (" .. ceil(CurrentPower / LSNPP.MaxPower * 100) .. "%)"
		)
	end
end

function LSNPP:AddMpString()
	local PlateSubFrames = {C_NamePlate.GetNamePlateForUnit("player"):GetChildren()}
	local PowerFrame
	for _, Child in ipairs(PlateSubFrames) do
		if Child:GetName() == "ClassNameplateManaBarFrame" then
			PowerFrame = Child
		end
	end
	assert(PowerFrame)
	local PowerString = PowerFrame:CreateFontString("LSNPP_Str_Power", "Overlay", "GameFontNormal")
	PowerString:SetPoint("TOPLEFT", PowerFrame)
	PowerString:SetPoint("BOTTOMRIGHT", PowerFrame)
	PowerString:SetTextColor(1, 1, 1, 1)
	PowerString:SetShadowColor(0, 0, 0, 1)
	LSNPP:PLAYER_TALENT_UPDATE()
	PowerString:SetText("")
	PowerString:Show()
	LSNPP:UNIT_POWER_FREQUENT(nil, "player", LSNPP.PowerToken)
	LSNPP:RegisterEvent("PLAYER_TALENT_UPDATE")
	LSNPP:RegisterEvent("UNIT_MAXPOWER")
	LSNPP:RegisterEvent("UNIT_POWER_FREQUENT")
end
-----------------------------------------------------------
