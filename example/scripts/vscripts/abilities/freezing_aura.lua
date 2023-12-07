freezing_aura = class( {} )

--------------------------------------------------------------------------------

function freezing_aura:GetIntrinsicModifierName()
	return "modifier_freezing_aura"
end


function freezing_aura:Init()
	self:SetContextThink("think_set_level",function() self:SetLevel(1) end,0)
end



modifier_freezing_aura = class({})
LinkLuaModifier("modifier_freezing_aura", "abilities/freezing_aura", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_freezing_aura:DeclareFunctions()
	local funcs = 
	{
	}
	return funcs
end
--隐藏
function  modifier_freezing_aura:IsHidden()return true end
--无法驱散
function  modifier_freezing_aura:IsPurgable() return false end
--光环范围
function  modifier_freezing_aura:GetAuraRadius() return 800 end
--是光环
function  modifier_freezing_aura:IsAura() return true end
--光环buff
function  modifier_freezing_aura:GetModifierAura() return "modifier_freezing_aura2" end
--光环对象
function  modifier_freezing_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function  modifier_freezing_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function  modifier_freezing_aura:GetAuraSearchFlags() return 48 end


--光环生效buff
modifier_freezing_aura2 = class({})
LinkLuaModifier("modifier_freezing_aura2", "abilities/freezing_aura", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_freezing_aura2:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
	}
	return funcs
end
--不隐藏
function  modifier_freezing_aura2:IsHidden()return false end
--无法驱散
function  modifier_freezing_aura2:IsPurgable() return false end
--回复增强
function  modifier_freezing_aura2:GetModifierHPRegenAmplify_Percentage(keys)return -80 end
--吸血增强
function  modifier_freezing_aura2:GetModifierLifestealRegenAmplify_Percentage(keys)return -80 end
--法吸增强
function  modifier_freezing_aura2:GetModifierSpellLifestealRegenAmplify_Percentage(keys)return -80 end
--治疗增强
function  modifier_freezing_aura2:GetModifierHealAmplify_PercentageTarget(keys)return -80 end