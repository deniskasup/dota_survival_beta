item_satanic2 = class( {} )

function item_satanic2:GetIntrinsicModifierName()
	return "modifier_item_satanic2_passive"
end

function item_satanic2:OnSpellStart()
	self:GetCaster():EmitSound("DOTA_Item.Satanic.Activate")
	self:GetCaster():Purge(false,true,false,false,false)
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_item_satanic_unholy",{duration=6})
end

modifier_item_satanic2_passive = class({})
LinkLuaModifier("modifier_item_satanic2_passive", "abilities/item_satanic2", LUA_MODIFIER_MOTION_NONE)


--隐藏
function  modifier_item_satanic2_passive:IsHidden()return true end
--当buff创建
function  modifier_item_satanic2_passive:OnCreated(keys)
	self.buff1 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_paladin_sword",nil)
	self.buff2 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_satanic",nil)
	self.buff3 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_special_bonus_spell_lifesteal",nil)
end
--当销毁
function  modifier_item_satanic2_passive:OnDestroy(keys)
	self.buff1:Destroy()
	self.buff2:Destroy()
	self.buff3:Destroy()
end

-- function modifier_item_satanic2_passive:DeclareFunctions()
	-- local funcs = 
	-- {
		-- MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	-- }
	-- return funcs
-- end

-- function  modifier_item_satanic2_passive:GetModifierBonusStats_Strength()
	-- return 35
-- end

