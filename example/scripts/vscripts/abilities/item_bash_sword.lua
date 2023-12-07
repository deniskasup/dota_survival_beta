item_bash_sword = class( {} )

function item_bash_sword:GetIntrinsicModifierName()
	return "modifier_item_bash_sword_passive"
end

modifier_item_bash_sword_passive = class({})
LinkLuaModifier("modifier_item_bash_sword_passive", "abilities/item_bash_sword", LUA_MODIFIER_MOTION_NONE)

function modifier_item_bash_sword_passive:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end
--隐藏
function  modifier_item_bash_sword_passive:IsHidden()return true end
--当buff创建
function  modifier_item_bash_sword_passive:OnCreated(keys)
	self.buff1 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_penta_edged_sword",nil)
	self.buff2 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_cranium_basher",nil)
	self.buff3 = self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_skadi",nil)
end
--当销毁
function  modifier_item_bash_sword_passive:OnDestroy(keys)
	self.buff1:Destroy()
	self.buff2:Destroy()
	self.buff3:Destroy()
end
--当攻击到达
function  modifier_item_bash_sword_passive:OnAttackLanded(keys)
	if keys.attacker==self:GetParent() then
		DoCleaveAttack(keys.attacker,keys.target,self:GetAbility(),keys.original_damage*0.5,150,360,700,"particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf")
	end
end
