crystal_maiden_brilliance_power = class( {} )

--------------------------------------------------------------------------------

function crystal_maiden_brilliance_power:GetIntrinsicModifierName()
	return "modifier_crystal_maiden_brilliance_power"
end




modifier_crystal_maiden_brilliance_power = class({})
LinkLuaModifier("modifier_crystal_maiden_brilliance_power", "abilities/crystal_maiden_brilliance_power", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_crystal_maiden_brilliance_power:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
	return funcs
end
--隐藏
function  modifier_crystal_maiden_brilliance_power:IsHidden()return true end
--无法驱散
function  modifier_crystal_maiden_brilliance_power:IsPurgable() return false end
--智力
function  modifier_crystal_maiden_brilliance_power:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("intellect")end
--技能增强
function  modifier_crystal_maiden_brilliance_power:GetModifierSpellAmplify_Percentage()
	return self:GetParent():GetIntellect()*0.1
end