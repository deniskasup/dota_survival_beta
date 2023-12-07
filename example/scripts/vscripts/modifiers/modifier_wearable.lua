modifier_wearable = class({})

--隐藏
function modifier_wearable:IsHidden()return true end
--无法驱散
function modifier_wearable:IsPurgable()return false end
--永久
function modifier_wearable:IsPermanent()return true end

-----------------------------------------------------------------------

function modifier_wearable:OnCreated( params )
	
end

-----------------------------------------------------------------------

function modifier_wearable:DeclareFunctions()
	local funcs = 
	{
		
	}
	return funcs
end


function modifier_wearable:CheckState()
	local state =
	{
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end