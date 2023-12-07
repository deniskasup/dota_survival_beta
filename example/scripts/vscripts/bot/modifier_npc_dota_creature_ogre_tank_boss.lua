modifier_npc_dota_creature_ogre_tank_boss = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_creature_ogre_tank_boss:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end


--------------------------------------------------------------------------------

--当buff创建
function  modifier_npc_dota_creature_ogre_tank_boss:OnCreated(keys)
	local boss = self:GetParent()
	boss:AddAbility("freezing_aura")
	boss:AddNewModifier(boss,nil,"modifier_vision",nil)

	if(IsServer())then
		self:GetParent():SetContextThink("bot_attack",function()
			self.target = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,46000,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,8240,FIND_CLOSEST,false)
			if(self.target[1])then
				self:GetParent():SetForceAttackTarget(self.target[1])
			end
			return 1
		end,0)
		
		self:GetParent():SetContextThink("bot_auto_cast",function()
			if(not self:GetParent():IsAlive())then
				return nil
			end
			--坐
			local casting_ability = self:GetParent():FindAbilityByName("ogre_tank_boss_jump_smash")
			local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,300,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
			if(casting_ability:IsCooldownReady() and bad_hero[1])then
				self:GetParent():CastAbilityNoTarget(casting_ability,0)
				return 1.5
			end
			--砸
			local casting_ability = self:GetParent():FindAbilityByName("ogre_tank_boss_melee_smash")
			local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,500,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
			if(casting_ability:IsCooldownReady() and bad_hero[1])then
				self:GetParent():CastAbilityOnPosition(bad_hero[1]:GetCenter(),casting_ability,0)
				return 1
			end
			
			
			return 0.1
		end,0)
	end
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
function  modifier_npc_dota_creature_ogre_tank_boss:IsPurgable()return false end
--永久
function  modifier_npc_dota_creature_ogre_tank_boss:IsPermanent()return true end
--绝对移速
function  modifier_npc_dota_creature_ogre_tank_boss:GetModifierMoveSpeed_Absolute()return 400 end
--护甲
function  modifier_npc_dota_creature_ogre_tank_boss:GetModifierPhysicalArmorBonus(keys)return 10 end
--血量
function  modifier_npc_dota_creature_ogre_tank_boss:GetModifierExtraHealthBonus()return (self.player_count-1)*10000 end
--魔抗
function  modifier_npc_dota_creature_ogre_tank_boss:GetModifierMagicalResistanceBonus()return 50 end