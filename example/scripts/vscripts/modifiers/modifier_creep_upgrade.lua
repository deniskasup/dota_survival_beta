modifier_creep_upgrade = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_creep_upgrade:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end
function modifier_creep_upgrade:CheckState()
	local state = {
		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
	}
	return state
end

--不可驱散
function  modifier_creep_upgrade:IsPurgable()
	return false
end

--隐藏
function  modifier_creep_upgrade:IsHidden()
	return true
end

--当创建
function  modifier_creep_upgrade:OnCreated(keys)
	self.caster = self:GetCaster()
	self.time = math.modf(GameRules:GetDOTATime(false,true)/60)
	if IsServer() then
		self.bounty = self.caster:GetGoldBounty()
		--单位金钱奖励
		self.caster:SetMinimumGoldBounty(self.bounty+self.time*2)
		self.caster:SetMaximumGoldBounty(self.bounty+self.time*2)
		--单位经验奖励
		self.caster:SetDeathXP(self.caster:GetDeathXP()+self.time*2)
	end
end


--加攻击力
function  modifier_creep_upgrade:GetModifierPreAttack_BonusDamage(keys)
	return self.time*5
end

--加攻速
function  modifier_creep_upgrade:GetModifierAttackSpeedBonus_Constant(keys)
	return self.time*5
end

--加血
function  modifier_creep_upgrade:GetModifierExtraHealthBonus(keys)
	return self.time*250
end

--加护甲
-- function  modifier_creep_upgrade:GetModifierPhysicalArmorBonus(keys)
	-- if _G.boss_difficulty >= 6 then
		-- return self.time*1
	-- end
-- end




