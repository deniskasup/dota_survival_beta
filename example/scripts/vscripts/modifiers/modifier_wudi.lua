modifier_wudi = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_wudi:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
	return funcs
end

function modifier_wudi:CheckState()
	local state = {
	-- [MODIFIER_STATE_ATTACK_IMMUNE] = true,
	-- [MODIFIER_STATE_MAGIC_IMMUNE] = true,
	-- [MODIFIER_STATE_UNSELECTABLE] = true,
	}

	return state
end

--不可驱散
function  modifier_wudi:IsPurgable()return false end
--不可驱散
function  modifier_wudi:IsPermanent()return true end
--不隐藏
function  modifier_wudi:IsHidden()return false end
--攻击力
function  modifier_wudi:GetModifierPreAttack_BonusDamage()
	return 10000
end
--不死
function  modifier_wudi:GetModifierHealthBonus()return 900000 end
--回血
function  modifier_wudi:GetModifierConstantHealthRegen()return 900000 end



