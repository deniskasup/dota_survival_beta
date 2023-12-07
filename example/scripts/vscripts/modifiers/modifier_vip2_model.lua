modifier_vip2_model = class({})

--隐藏
function modifier_vip2_model:IsHidden()return true end
--无法驱散
function modifier_vip2_model:IsPurgable()return false end
--永久
function modifier_vip2_model:IsPermanent()return true end

-----------------------------------------------------------------------

function modifier_vip2_model:OnCreated( params )
	
end

-----------------------------------------------------------------------

function modifier_vip2_model:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
	return funcs
end


function modifier_vip2_model:GetModifierModelChange()
	return _G.hero_personas_table[self:GetParent():GetName()].model
end