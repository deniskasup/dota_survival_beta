modifier_item_assault2_positive_aura = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_item_assault2_positive_aura:DeclareFunctions()
	local funcs = 
	{
		
	}
	return funcs
end

--隐藏
function  modifier_item_assault2_positive_aura:IsHidden()return true end
--无法驱散
function  modifier_item_assault2_positive_aura:IsPurgable() return false end
--光环范围
function  modifier_item_assault2_positive_aura:GetAuraRadius() return 1200 end
--是光环
function  modifier_item_assault2_positive_aura:IsAura() return true end
--光环buff
function  modifier_item_assault2_positive_aura:GetModifierAura() return "modifier_item_assault2_positive" end
--光环对象
function  modifier_item_assault2_positive_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function  modifier_item_assault2_positive_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC+1 end
function  modifier_item_assault2_positive_aura:GetAuraSearchFlags() return 48 end

--光环生效buff
modifier_item_assault2_positive = class({})
LinkLuaModifier("modifier_item_assault2_positive", "modifiers/modifier_item_assault2_positive_aura", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_item_assault2_positive:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end
--不隐藏
function  modifier_item_assault2_positive:IsHidden()return false end
--无法驱散
function  modifier_item_assault2_positive:IsPurgable() return false end
--增加护甲
function  modifier_item_assault2_positive:GetModifierPhysicalArmorBonus(keys)return self:GetAbility():GetSpecialValueFor("aura_positive_armor") end
--增加攻速
function  modifier_item_assault2_positive:GetModifierAttackSpeedBonus_Constant(keys)return self:GetAbility():GetSpecialValueFor("aura_attack_speed") end

