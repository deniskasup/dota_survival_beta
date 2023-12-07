modifier_npc_dota_creature_primal_beast = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_creature_primal_beast:DeclareFunctions()
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
function  modifier_npc_dota_creature_primal_beast:OnCreated(keys)
	local boss = self:GetParent()
	boss:AddAbility("freezing_aura")
	boss:AddNewModifier(boss,nil,"modifier_vision",nil)
	
	boss_items = {"item_ultimate_scepter"}
	for k,v in pairs(boss_items)do
		boss:AddItemByName(v)
	end
	
	

	if(IsServer())then
		self:GetParent():SetContextThink("bot_attack",function()
			targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,46000,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,8240,FIND_CLOSEST,false)
			local AttackTarget = {1,0}
			for k,v in pairs(targets)do
				if k==1 then
					AttackTarget[2] = targets[k]:GetHealth()
				end
				if targets[k]:GetHealth() < AttackTarget[2] then
					AttackTarget[1]=k
					AttackTarget[2]=targets[k]:GetHealth()
				end
			
			end
			if targets[AttackTarget[1]] then
				self.target = targets[AttackTarget[1]]
				-- self:GetParent():SetForceAttackTarget(self.target)
				-- self:GetParent():MoveToNPC(self.target)
				order_table = {OrderType=1,UnitIndex=self:GetParent():GetEntityIndex(),Position=self.target:GetOrigin()+(self.target:GetOrigin()-self:GetParent():GetOrigin()):Normalized()*300}
				ExecuteOrderFromTable(order_table)
			end
			return 0.5
		end,0)
		
		self:GetParent():SetContextThink("bot_auto_cast",function()
			if(not self:GetParent():IsAlive())then
				return nil
			end
			--踏
			local casting_ability = self:GetParent():FindAbilityByName("primal_beast_trample2")
			if casting_ability:IsCooldownReady() then
				
				self:GetParent():CastAbilityImmediately(casting_ability,0)
			end
			--突
			local casting_ability = self:GetParent():FindAbilityByName("primal_beast_onslaught2")
			if casting_ability:IsCooldownReady() then
				pcall(function()self:GetParent():SetCursorCastTarget(self.target)end)
				self:GetParent():CastAbilityImmediately(casting_ability,0)
			end
			--丢石头
			local casting_ability = self:GetParent():FindAbilityByName("primal_beast_rock_throw2")
			local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,1800,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_FARTHEST,false)
			if casting_ability:IsCooldownReady() and bad_hero[1] then
				self:GetParent():CastAbilityOnPosition(bad_hero[1]:GetCenter(),casting_ability,0)
				return 0.8
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
function  modifier_npc_dota_creature_primal_beast:IsPurgable()return false end
--永久
function  modifier_npc_dota_creature_primal_beast:IsPermanent()return true end
--绝对移速
function  modifier_npc_dota_creature_primal_beast:GetModifierMoveSpeed_Absolute()return 400 end
--护甲
function  modifier_npc_dota_creature_primal_beast:GetModifierPhysicalArmorBonus(keys)return 10 end
--血量
function  modifier_npc_dota_creature_primal_beast:GetModifierExtraHealthBonus()return (self.player_count-1)*10000 end
--魔抗
function  modifier_npc_dota_creature_primal_beast:GetModifierMagicalResistanceBonus()return 50 end