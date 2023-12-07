require("mini_boss_ability_pool")
require("mini_boss_model")
modifier_npc_dota_mini_boss = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_mini_boss:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end


--------------------------------------------------------------------------------

--当buff创建
function  modifier_npc_dota_mini_boss:OnCreated(keys)
	self:GetParent():SetModelScale(2)
	local boss = self:GetParent()
	boss:AddNewModifier(nil,nil,"modifier_vision",nil)
	
	self.model = mini_boss_model[RandomInt(1,#mini_boss_model)]
	self.time = math.modf(GameRules:GetDOTATime(false,true)/60)-5
	local ability_pool = {} 
	for k,v in pairs(mini_boss_ability_pool)do
		table.insert(ability_pool,v)
	end

	for i=1,1+self.time do
		pop = table.remove(ability_pool,RandomInt(1,#ability_pool))
		boss:AddAbility(pop):SetLevel(4)
	end
	-- boss:AddAbility("legion_commander_overwhelming_odds"):SetLevel(4)
	-- boss:AddAbility("legion_commander_press_the_attack"):SetLevel(4)
	-- boss:AddAbility("legion_commander_moment_of_courage"):SetLevel(4)
	-- for i=1,5 do
		-- pop = table.remove(draw_ability_pool,RandomInt(1,#draw_ability_pool))
		-- boss:AddAbility(pop):SetLevel(4)
	-- end
	
	
	
	
	
	
	
	
	
	

	
	
	
	--自动攻击
	self:GetParent():SetContextThink("bot_attack",function()
		self.target = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,46000,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,8240,FIND_CLOSEST,false)
		if(self.target[1])then
			self:GetParent():SetForceAttackTarget(self.target[1])
		end
		return 1
	end,0)
	--对友好单位施法技能池
	cast_friend = {techies_reactive_tazer=1,ogre_magi_smash=1,oracle_rain_of_destiny2=1,shadow_demon_demonic_cleanse=1,keeper_of_the_light_chakra_magic=1,alchemist_berserk_potion2=1,abaddon_aphotic_shield=1,bloodseeker_bloodrage=1,dark_seer_surge=1,legion_commander_press_the_attack=1,lich_frost_armor=1,lich_frost_shield=1,magnataur_empower=1,ogre_magi_bloodlust=1,omniknight_purification=1,omniknight_repel=1,oracle_false_promise=1,treant_living_armor=1,undying_soul_rip=1,venomancer_poison_sting=1,marci_unleash=1,grimstroke_spirit_walk=1,dazzle_shadow_wave=1,tinker_defense_matrix=1,arc_warden_magnetic_field=1,dazzle_shallow_grave=1,huskar_inner_vitality=1,snapfire_firesnap_cookie=1,invoker_alacrity_ad=1,juggernaut_healing_ward=1,omniknight_purification2=1}
	--禁用自动施法
	no_cast = {mars_bulwark=1,bristleback_bristleback=1}
	
	--自动施法
	self:GetParent():SetContextThink("bot_auto_cast",function()
	
		if(not self:GetParent():IsAlive())then
			return nil
		end
		
	
		--寻找目标
		local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetLocalOrigin(),nil,600,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		
		
		--放技能
		for i=0,10 do
			local ability = self:GetParent():GetAbilityByIndex(i)
			
			--如果技能存在                                技能非隐藏		    非被动						非开关类技能				开启自动					冷却好了							禁用自动施法			非持续施法
			if ability and self:GetParent():IsAlive() and not ability:IsHidden() and not ability:IsPassive() and not ability:IsToggle() and ability:GetLevel()>0 and ability:IsCooldownReady() and not no_cast[ability:GetName()]and not self:GetParent():IsChanneling()then
				--友好英雄施法
				if cast_friend[ability:GetName()] then
					pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
					self:GetParent():CastAbilityImmediately(ability,0)
				--如果是非目标技能
				elseif bit.band(bit.rshift(ability:GetBehaviorInt(),2),1)==1 and bad_hero[1] then
					self:GetParent():CastAbilityImmediately(ability,0)
				--敌方单位施法，目标技能
				elseif bad_hero[1] then
					pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[RandomInt(1,#bad_hero)])end)
					self:GetParent():CastAbilityImmediately(ability,0)
				else
				end
			end
		end
		return 0.3
	end,0)
	
end

--模型
function  modifier_npc_dota_mini_boss:GetModifierModelChange()return self.model end
--不可驱散
function  modifier_npc_dota_mini_boss:IsPurgable()return false end
--永久
function  modifier_npc_dota_mini_boss:IsPermanent()return true end
--减cd
function  modifier_npc_dota_mini_boss:GetModifierPercentageCooldown(keys)return 70 end
--状态抗性
function  modifier_npc_dota_mini_boss:GetModifierStatusResistance(keys)return 30 end
--魔抗
function  modifier_npc_dota_mini_boss:GetModifierMagicalResistanceBonus(keys)return 30+5*self.time end
--魔法损耗降低
function  modifier_npc_dota_mini_boss:GetModifierPercentageManacost(keys)return 100 end
--额外生命值
function  modifier_npc_dota_mini_boss:GetModifierHealthBonus()return 400*self.time end
--护甲
function  modifier_npc_dota_mini_boss:GetModifierPhysicalArmorBonus(keys)return self.time*2 end
--当死亡
function  modifier_npc_dota_mini_boss:OnDeath(keys)
	if keys.unit==self:GetParent() then
		self:GetParent():SetContextThink("think_death",function()
			self:GetParent():Destroy()
		end,60)
	end
end