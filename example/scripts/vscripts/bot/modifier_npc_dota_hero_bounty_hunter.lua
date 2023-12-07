modifier_npc_dota_hero_bounty_hunter = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_hero_bounty_hunter:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end


--------------------------------------------------------------------------------

--当buff创建
function  modifier_npc_dota_hero_bounty_hunter:OnCreated(keys)
	self:GetParent():SetModelScale(3)
	local boss = self:GetParent()
	--升级
	for i=1,30 do
		boss:HeroLevelUp(true)
	end
	
	boss_abilitys = {"bounty_hunter_shuriken_toss","bounty_hunter_wind_walk","bounty_hunter_jinada","bounty_hunter_track","skeleton_king_mortal_strike","tusk_walrus_punch","weaver_geminate_attack","phantom_assassin_stifling_dagger","tiny_toss_tree","hoodwink_acorn_shot","chaos_knight_chaos_strike"}
	boss_items = {"item_heart","item_nullifier","item_black_king_bar","item_satanic","item_skadi","item_monkey_king_bar","item_ex_machina","item_assault"}
	for k,v in pairs(boss_abilitys)do
		boss:AddAbility(v):SetLevel(4)
	end
	for k,v in pairs(boss_items)do
		boss:AddItemByName(v)
	end
	boss:FindAbilityByName("tusk_walrus_punch"):ToggleAutoCast()
	
	boss:AddNewModifier(nil,nil,"modifier_vision",nil)
	boss:SwapItems(6,16)
	boss:SwapItems(7,15)
	
	
	
	
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
	no_cast = {mars_bulwark=1,bristleback_bristleback=1,troll_warlord_berserkers_rage=1,bounty_hunter_jinada=1,tusk_walrus_punch=1,weaver_geminate_attack=1}
	
	--自动施法
	self:GetParent():SetContextThink("bot_auto_cast",function()
		if(not self:GetParent():IsAlive())then
			return nil
		end
		
		
		
		
		
		
		
		--寻找目标
		local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetLocalOrigin(),nil,600,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		--BKB
		local casting_ability = self:GetCaster():FindItemInInventory("item_black_king_bar")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<70)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--机械之心
		local casting_ability = self:GetCaster():FindItemInInventory("item_ex_machina")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<30)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--撒旦
		local casting_ability = self:GetCaster():FindItemInInventory("item_satanic")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<50)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--否决
		local casting_ability = self:GetCaster():FindItemInInventory("item_nullifier")
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--放技能
		for i=0,20 do
			local ability = self:GetParent():GetAbilityByIndex(i)
			
			--如果技能存在                                技能非隐藏		    非被动						非开关类技能						冷却好了							                禁用自动施法			  非持续施法
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
		
		return 0.1
	end,0)
	
end


--不可驱散
function  modifier_npc_dota_hero_bounty_hunter:IsPurgable()return false end
--永久
function  modifier_npc_dota_hero_bounty_hunter:IsPermanent()return true end
