modifier_item_assault2_negative_armor_aura = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_item_assault2_negative_armor_aura:DeclareFunctions()
	local funcs = 
	{
		
	}
	return funcs
end

--隐藏
function  modifier_item_assault2_negative_armor_aura:IsHidden()return true end
--无法驱散
function  modifier_item_assault2_negative_armor_aura:IsPurgable() return false end
--光环范围
function  modifier_item_assault2_negative_armor_aura:GetAuraRadius() return 1200 end
--是光环
function  modifier_item_assault2_negative_armor_aura:IsAura() return true end
--光环buff
function  modifier_item_assault2_negative_armor_aura:GetModifierAura() return "modifier_item_assault2_negative" end
--光环对象
function  modifier_item_assault2_negative_armor_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function  modifier_item_assault2_negative_armor_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC+1 end
function  modifier_item_assault2_negative_armor_aura:GetAuraSearchFlags() return 48 end

--光环生效buff
modifier_item_assault2_negative = class({})
LinkLuaModifier("modifier_item_assault2_negative", "modifiers/modifier_item_assault2_negative_armor_aura", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_item_assault2_negative:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end
--不隐藏
function  modifier_item_assault2_negative:IsHidden()return false end
--无法驱散
function  modifier_item_assault2_negative:IsPurgable() return false end
--增加护甲
function  modifier_item_assault2_negative:GetModifierPhysicalArmorBonus(keys)return self:GetAbility():GetSpecialValueFor("aura_negative_armor") end

