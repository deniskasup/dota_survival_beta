lone_druid_true_form = class( {} )

--------------------------------------------------------------------------------

function lone_druid_true_form:OnSpellStart(keys)
	self:GetCaster():EmitSound("Hero_LoneDruid.TrueForm.Cast")
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_lone_druid_true_form2",{duration=40})
	self:GetCaster():SetHealth(self:GetCaster():GetHealth()+self:GetSpecialValueFor("bonus_hp"))
end




modifier_lone_druid_true_form2 = class({})
LinkLuaModifier("modifier_lone_druid_true_form2", "abilities/lone_druid_true_form", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_lone_druid_true_form2:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end
--隐藏
function  modifier_lone_druid_true_form2:IsHidden()return false end
--无法驱散
function  modifier_lone_druid_true_form2:IsPurgable() return false end
--永久
function  modifier_lone_druid_true_form2:IsPermanent() return true end
--模型
function  modifier_lone_druid_true_form2:GetModifierModelChange() return "models/heroes/lone_druid/true_form.vmdl" end
--基础攻击距离
function  modifier_lone_druid_true_form2:GetModifierAttackRangeOverride()
	return 150
end
--额外血量
function  modifier_lone_druid_true_form2:GetModifierExtraHealthBonus(keys)
	return self:GetAbility():GetSpecialValueFor("bonus_hp")
end
--护甲
function  modifier_lone_druid_true_form2:GetModifierPhysicalArmorBonus(keys)
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end
--当创建
function  modifier_lone_druid_true_form2:OnCreated(keys)
	--获取原本的攻击模式
	self.attack_cap = self:GetCaster():GetAttackCapability()
	self:GetCaster():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end
--当摧毁
function  modifier_lone_druid_true_form2:OnDestroy(keys)
	self:GetCaster():SetAttackCapability(self.attack_cap)
end