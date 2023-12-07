modifier_npc_shredder = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_shredder:DeclareFunctions()
	local funcs = 
	{
		
	}
	return funcs
end
function modifier_npc_shredder:CheckState()
	local state =
	{
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		
	}
	return state
end

--不可驱散
function  modifier_npc_shredder:IsPurgable()return false end




