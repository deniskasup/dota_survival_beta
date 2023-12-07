modifier_duel = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_duel:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end


--不可驱散
function  modifier_duel:IsPurgable()return false end
--永久
function  modifier_duel:IsPermanent()return true end




