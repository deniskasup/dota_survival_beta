modifier_npc_dota_creature_temple_guardian = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_creature_temple_guardian:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end


--------------------------------------------------------------------------------

--当buff创建
function  modifier_npc_dota_creature_temple_guardian:OnCreated(keys)
	self:GetParent():SetModelScale(3)
	local boss = self:GetParent()

	
	
	
	boss:AddAbility("freezing_aura")
	boss:AddNewModifier(boss,nil,"modifier_vision",nil)
	
	--自动攻击
	self:GetParent():SetContextThink("bot_attack",function()
		self.target = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,46000,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,8240,FIND_CLOSEST,false)
		if(self.target[1])then
			self:GetParent():SetForceAttackTarget(self.target[1])
		end
		return 1
	end,0)
	
	--自动施法
	self:GetParent():SetContextThink("bot_auto_cast",function()
	
		if(not self:GetParent():IsAlive())then
			return nil
		end
		
		--砸
		local casting_ability = self:GetParent():FindAbilityByName("temple_guardian_hammer_smash")
		local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,350,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady() and not self:GetParent():IsChanneling() and self:GetParent():GetHealthPercent()>=50)then
			self:GetParent():CastAbilityOnPosition(bad_hero[1]:GetCenter(),casting_ability,0)
			return 1
		end
		--狂暴砸
		local casting_ability = self:GetParent():FindAbilityByName("temple_guardian_rage_hammer_smash")
		local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,350,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady() and not self:GetParent():IsChanneling() and self:GetParent():GetHealthPercent()<50)then
			self:GetParent():CastAbilityOnPosition(bad_hero[1]:GetCenter(),casting_ability,0)
			return 1
		end
		--丢锤子
		local casting_ability = self:GetParent():FindAbilityByName("temple_guardian_hammer_throw")
		local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,1300,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady() and not self:GetParent():IsChanneling())then
			self:GetParent():CastAbilityOnPosition(bad_hero[1]:GetCenter(),casting_ability,0)
			return 2
		end
		--大
		local casting_ability = self:GetParent():FindAbilityByName("temple_guardian_wrath")
		local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,600,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady() and not self:GetParent():IsChanneling())then
			self:GetParent():CastAbilityNoTarget(casting_ability,0)
			return 5
		end
		
		

		return 0.1
	end,0)
	self.player_count = get_online_players()
end
--获取在线玩家个数
function  get_online_players()
	local count = 0
	for i=0,9 do
		if PlayerResource:GetConnectionState(i) == 2 then
			count = count+1
		end
	end
	return count
end

--不可驱散
function  modifier_npc_dota_creature_temple_guardian:IsPurgable()return false end
--永久
function  modifier_npc_dota_creature_temple_guardian:IsPermanent()return true end
--减cd
function  modifier_npc_dota_creature_temple_guardian:GetModifierPercentageCooldown(keys)return -230 end
--额外生命值
function  modifier_npc_dota_creature_temple_guardian:GetModifierExtraHealthBonus()return (self.player_count-1)*10000 end
--护甲
function  modifier_npc_dota_creature_temple_guardian:GetModifierPhysicalArmorBonus(keys)return 35 end
--加攻击力
-- function  modifier_npc_dota_creature_temple_guardian:GetModifierPreAttack_BonusDamage(keys)return GameRules:GetDOTATime(false,true)*0.08 end
--绝对移速
function  modifier_npc_dota_creature_temple_guardian:GetModifierMoveSpeed_Absolute()return 400 end
--魔抗
function  modifier_npc_dota_creature_temple_guardian:GetModifierMagicalResistanceBonus()return 50 end
