item_ice_lance = class( {} )

function item_ice_lance:GetIntrinsicModifierName()
	return "modifier_item_ice_lance_passive"
end

modifier_item_ice_lance_passive = class({})
LinkLuaModifier("modifier_item_ice_lance_passive", "abilities/item_ice_lance", LUA_MODIFIER_MOTION_NONE)

function modifier_item_ice_lance_passive:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end
--当buff创建
function  modifier_item_ice_lance_passive:OnCreated(keys)
	self.buff1 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_dragon_lance",nil)
	self.buff2 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_skadi",nil)
	self.buff3 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_splash_attack",nil)
end
--当销毁
function  modifier_item_ice_lance_passive:OnDestroy(keys)
	self.buff1:Destroy()
	self.buff2:Destroy()
	self.buff3:Destroy()
end
--隐藏
function  modifier_item_ice_lance_passive:IsHidden()return true end
--攻击力
function  modifier_item_ice_lance_passive:GetModifierPreAttack_BonusDamage()return 50 end
--攻速
function  modifier_item_ice_lance_passive:GetModifierAttackSpeedBonus_Constant()return 70 end
