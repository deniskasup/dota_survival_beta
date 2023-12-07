item_ice_heart = class( {} )

function item_ice_heart:GetIntrinsicModifierName()
	return "modifier_item_ice_heart_passive"
end

modifier_item_ice_heart_passive = class({})
LinkLuaModifier("modifier_item_ice_heart_passive", "abilities/item_ice_heart", LUA_MODIFIER_MOTION_NONE)

--当buff创建
function  modifier_item_ice_heart_passive:OnCreated(keys)
	self.buff1 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_heart",nil)
	self.buff2 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_skadi",nil)
end
--当销毁
function  modifier_item_ice_heart_passive:OnDestroy(keys)
	self.buff1:Destroy()
	self.buff2:Destroy()
end
--隐藏
function  modifier_item_ice_heart_passive:IsHidden()return true end
