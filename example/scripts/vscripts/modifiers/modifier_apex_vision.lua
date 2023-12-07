modifier_apex_vision = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_apex_vision:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
	return funcs
end

-- function modifier_apex_vision:CheckState()
	-- local state = {
	-- [MODIFIER_STATE_PROVIDES_VISION] = true,
	-- }

	-- return state
-- end

--视野
function  modifier_apex_vision:GetModifierProvidesFOWVision()
	return 1
end

--不可驱散
function  modifier_apex_vision:IsPurgable()return false end

--永久
function  modifier_apex_vision:IsPermanent()return true end



