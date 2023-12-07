modifier_vision = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_vision:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
	return funcs
end

function modifier_vision:CheckState()
	local state = {
	[MODIFIER_STATE_PROVIDES_VISION] = true,
	}

	return state
end

--视野
function  modifier_vision:GetModifierProvidesFOWVision()
	return 1
end

--不可驱散
function  modifier_vision:IsPurgable()
	return false
end

--永久
function  modifier_vision:IsPermanent()
	return true
end



