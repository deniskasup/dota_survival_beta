item_trident = class( {} )

function item_trident:GetIntrinsicModifierName()
	return "modifier_item_trident_passive"
end

modifier_item_trident_passive = class({})
LinkLuaModifier("modifier_item_trident_passive", "abilities/item_trident", LUA_MODIFIER_MOTION_NONE)

--当buff创建
function  modifier_item_trident_passive:OnCreated(keys)
	self.buff1 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_sange",nil)
	self.buff2 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_yasha",nil)
	self.buff3 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_kaya",nil)
end
--当销毁
function  modifier_item_trident_passive:OnDestroy(keys)
	self.buff1:Destroy()
	self.buff2:Destroy()
	self.buff3:Destroy()
end
--隐藏
function  modifier_item_trident_passive:IsHidden()return true end
