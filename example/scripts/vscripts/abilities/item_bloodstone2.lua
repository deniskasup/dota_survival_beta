item_bloodstone2 = class( {} )

--------------------------------------------------------------------------------

function item_bloodstone2:GetIntrinsicModifierName()
	return "modifier_item_bloodstone2"
end

function item_bloodstone2:OnSpellStart()
	self:GetCaster():EmitSound("DOTA_Item.Bloodstone.Cast")
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_special_bonus_spell_lifesteal",{duration=6})
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_special_bonus_spell_lifesteal",{duration=6})
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_item_bloodstone_active",{duration=6})
end

-- modifier_item_bloodstone_active



modifier_item_bloodstone2 = class({})
LinkLuaModifier("modifier_item_bloodstone2", "abilities/item_bloodstone2", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_item_bloodstone2:DeclareFunctions()
	local funcs = 
	{
	}
	return funcs
end
--隐藏
function  modifier_item_bloodstone2:IsHidden()return true end
--无法驱散
function  modifier_item_bloodstone2:IsPurgable() return false end
--当buff创建
function  modifier_item_bloodstone2:OnCreated(keys)
	self.buff1 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_bloodstone",nil)
	self.buff2 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_special_bonus_spell_lifesteal",nil)
	self.buff3 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_trident",nil)
end
--当销毁
function  modifier_item_bloodstone2:OnDestroy(keys)
	self.buff1:Destroy()
	self.buff2:Destroy()
	self.buff3:Destroy()
end
