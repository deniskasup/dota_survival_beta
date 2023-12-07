ignore_blade_mail = class( {} )

--------------------------------------------------------------------------------

function ignore_blade_mail:GetIntrinsicModifierName()
	return "modifier_ignore_blade_mail"
end

function ignore_blade_mail:OnCreated()
	--self:SetContextThink("think_set_level",function() self:SetLevel(1) end,0)
end




modifier_ignore_blade_mail = class({})
LinkLuaModifier("modifier_ignore_blade_mail", "abilities/ignore_blade_mail", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_ignore_blade_mail:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end
--隐藏
function  modifier_ignore_blade_mail:IsHidden()return true end
--无法驱散
function  modifier_ignore_blade_mail:IsPurgable() return false end
--当受到伤害
function  modifier_ignore_blade_mail:OnTakeDamage(keys)
	if keys.unit == self:GetParent() and keys.inflictor:GetName()=="item_blade_mail" then
		keys.unit:Heal(keys.damage,nil)
	end
end