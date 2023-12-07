spawn_creep = class( {} )

function spawn_creep:GetIntrinsicModifierName()
	return "modifier_auto_cast"
end

function spawn_creep:OnHeroLevelUp()
	if GetMapName()=="pvp" and self:GetCaster():GetLevel()%4==0 and self:GetCaster():GetLevel()>6 then
		self:GetCaster():SetAbilityPoints(self:GetCaster():GetAbilityPoints()+1)
	end
end

function spawn_creep:Init()
	self:SetContextThink("think_set_level",function() self:SetLevel(1) end,0)
	self:SetContextThink("think_spawn_creep",function()
		spawn_time = 0.4
		if self:GetCaster():IsAlive() and not GameRules:IsGamePaused() and PlayerResource:GetConnectionState(self:GetCaster():GetPlayerID())==2 and GameRules:State_Get()==10 and self:GetAutoCastState() then
			--刷僵尸
			local creep_name = "npc_dota_dark_troll_warlord_skeleton_warrior"
			local creep_counter = 20
			--刷15个小狗头人
			if GetMapName()=="pvp" and GameRules:GetDOTATime(false,true)> 300 then
				creep_name = "npc_dota_neutral_kobold2"
				creep_counter=15
				spawn_time = 0.4
			end
			--刷10个中狗头人
			if GetMapName()=="pvp" and GameRules:GetDOTATime(false,true)> 600 then
				creep_name = "npc_dota_neutral_kobold_tunneler2"
				creep_counter=10
				spawn_time = 0.4
			end
			--刷5个大狗头人
			if GetMapName()=="pvp" and GameRules:GetDOTATime(false,true)> 900 then
				creep_name = "npc_dota_neutral_kobold_taskmaster2"
				creep_counter=5
			end
			
			local neutrals = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,1800,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_CREEP+1,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
			if(#neutrals<creep_counter)then
				local pos = self:GetCaster():GetOrigin()+RandomVector(1)*1000
				if pos.x>8000 then pos.x=8000 end
				if pos.x<-8000 then pos.x=-8000 end
				if pos.y>8000 then pos.y=8000 end
				if pos.y<-8000 then pos.y=-8000 end
				local creep = CreateUnitByName(creep_name,pos, true, nil, nil, DOTA_TEAM_NEUTRALS)
				creep:AddNewModifier(creep,nil,"modifier_creep_upgrade",nil)
				creep:SetForceAttackTarget(self:GetCaster())
			else
				
			end
		end
		--掉下地图，死亡
		if self:GetCaster():GetCenter().z<-1000 then
			-- self:GetCaster():Kill(nil,nil)
			local pos = self:GetCaster():GetOrigin()
			if pos.x>8000 then pos.x=8000 end
			if pos.x<-8000 then pos.x=-8000 end
			if pos.y>8000 then pos.y=8000 end
			if pos.y<-8000 then pos.y=-8000 end
			FindClearSpaceForUnit( self:GetCaster(), pos, true )
		end
		-- print("刷怪时间是"..spawn_time)
		return spawn_time
	end,0)
end

function spawn_creep:OnToggle()
	
end



modifier_auto_cast = class({})
LinkLuaModifier("modifier_auto_cast", "abilities/spawn_creep", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_auto_cast:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_EVENT_ON_RESPAWN,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_GOLD_RATE_BOOST,
		MODIFIER_PROPERTY_EXP_RATE_BOOST,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end
function modifier_auto_cast:CheckState()
	return {
		[MODIFIER_STATE_FORCED_FLYING_VISION] = true
	}
end


--当buff创建
function  modifier_auto_cast:OnCreated(keys)
	--对自身施法
	cast_self = {}
	--对友好单位施法技能池
	cast_friend = {techies_reactive_tazer=1,ogre_magi_smash=1,oracle_rain_of_destiny2=1,shadow_demon_demonic_cleanse=1,keeper_of_the_light_chakra_magic=1,alchemist_berserk_potion2=1,abaddon_aphotic_shield=1,bloodseeker_bloodrage=1,dark_seer_surge=1,legion_commander_press_the_attack=1,lich_frost_armor=1,lich_frost_shield=1,magnataur_empower=1,ogre_magi_bloodlust=1,omniknight_purification=1,omniknight_repel=1,oracle_false_promise=1,treant_living_armor=1,undying_soul_rip=1,venomancer_poison_sting=1,marci_unleash=1,grimstroke_spirit_walk=1,dazzle_shadow_wave=1,tinker_defense_matrix=1,arc_warden_magnetic_field=1,dazzle_shallow_grave=1,huskar_inner_vitality=1,snapfire_firesnap_cookie=1,invoker_alacrity_ad=1,juggernaut_healing_ward=1,omniknight_purification2=1}
	--禁用自动施法
	no_cast = {primal_beast_uproar=1,slark_pounce=1,queenofpain_blink=1,lone_druid_spirit_link=1,centaur_mount=1,furion_teleportation=1,huskar_burning_spear=1,silencer_glaives_of_wisdom=1,drow_ranger_frost_arrows=1,viper_poison_attack=1,clinkz_searing_arrows=1,huskar_life_break=1,earth_spirit_rolling_boulder=1,antimage_blink=1,spawn_creep=1,ancient_apparition_ice_blast=1,ancient_apparition_ice_blast_release=1,terrorblade_sunder=1,weaver_time_lapse=1,juggernaut_swift_slash2=1,viper_nose_dive=1,keeper_of_the_light_recall2=1,winter_wyvern_cold_embrace=1,vengefulspirit_nether_swap=1,tusk_launch_snowball=1,tusk_snowball=1,phoenix_icarus_dive_stop=1,phoenix_icarus_dive=1,morphling_waveform=1,enchantress_bunny_hop2=1,faceless_void_time_walk=1,primal_beast_onslaught=1,centaur_mount2=1,shredder_return_chakram_2=1,shredder_return_chakram=1,abyssal_underlord_dark_portal=1,spirit_breaker_charge_of_darkness=1,rattletrap_hookshot=1,sandking_burrowstrike=1,storm_spirit_ball_lightning=1,mars_arena_of_blood=1,kunkka_return=1,kunkka_x_marks_the_spot=1,wisp_relocate=1,dawnbreaker_solar_guardian=1,brewmaster_drunken_brawler=1,night_stalker_hunter_in_the_night=1,mars_bulwark=1,vengefulspirit_command_aura=1,doom_bringer_infernal_blade=1,tusk_walrus_punch=1,kunkka_tidebringer=1,ancient_apparition_chilling_touch=1,jakiro_liquid_fire=1,obsidian_destroyer_arcane_orb=1,skeleton_king_mortal_strike=1,weaver_geminate_attack=1,rubick_null_field=1,life_stealer_infest=1,life_stealer_consume=1,wisp_tether=1,wisp_tether_break=1,luna_lunar_blessing=1,enchantress_impetus=1,bounty_hunter_jinada=1,phoenix_supernova=1,windrunner_focusfire=1,legion_commander_duel=1,invoker_sun_strike_ad=1,magnataur_skewer=1,dark_willow_terrorize=1,enchantress_enchant=1,juggernaut_omni_slash=1}
	--控制施法
	control_cast = {centaur_work_horse=1,shredder_chakram=1,lone_druid_spirit_bear=1,rattletrap_rocket_flare2=1,phantom_assassin_blur=1,lion_finger_of_death=1,bristleback_bristleback=1,mirana_leap=1,phantom_assassin_phantom_strike=1,chaos_knight_reality_rift=1,windrunner_windrun=1,axe_culling_blade=1,muerta_pierce_the_veil=1,slark_shadow_dance=1,dark_willow_shadow_realm=1,troll_warlord_battle_trance=1,templar_assassin_meld=1,sniper_take_aim=1,centaur_double_edge=1}
	--优先英雄施法
	cast_hero = {bristleback_viscous_nasal_goo=1,phantom_assassin_phantom_strike=1,elder_titan_earth_splitter=1,venomancer_latent_poison=1,hoodwink_hunters_boomerang=1,tiny_toss_tree=1,keeper_of_the_light_radiant_bind=1,bounty_hunter_shuriken_toss=1,bounty_hunter_track=1,axe_culling_blade=1,ancient_apparition_ice_vortex=1,ogre_magi_fireblast=1,antimage_mana_void=1,shredder_chakram_2=1,shredder_chakram=1,abyssal_underlord_pit_of_malice=1,ancient_apparition_cold_feet=1,bane_enfeeble=1,bane_brain_sap=1,bane_fiends_grip=1,batrider_flaming_lasso=1,beastmaster_primal_roar=1,bloodseeker_rupture=1,bounty_hunter_shuriken_toss=1,chen_penitence=1,chen_test_of_faith=1,lina_laguna_blade=1,lion_finger_of_death=1,necrolyte_reapers_scythe=1,razor_static_link=1,shadow_demon_demonic_purge=1,silencer_last_word=1,skywrath_mage_arcane_bolt=1,skywrath_mage_ancient_seal=1,skywrath_mage_mystic_flare=1,sniper_assassinate=1,visage_soul_assumption=1,winter_wyvern_winters_curse=1,witch_doctor_maledict=1,primal_beast_pulverize=1,dark_willow_cursed_crown=1,grimstroke_ink_creature=1,tinker_laser=1,phantom_assassin_stifling_dagger=1,queenofpain_sonic_wave=1,beastmaster_wild_axes=1,ancient_apparition_ice_blast=1,disruptor_kinetic_field=1,disruptor_static_storm=1,faceless_void_chronosphere=1,bane_nightmare=1,drow_ranger_multishot=1,riki_smoke_screen=1,night_stalker_void=1,tidehunter_gush=1,batrider_flamebreak=1,death_prophet_silence=1,obsidian_destroyer_astral_imprisonment=1,bloodseeker_blood_bath=1,jakiro_dual_breath=1,shadow_demon_disruption=1,enchantress_enchant=1,furion_sprout=1,naga_siren_ensnare=1}
	--自动物品
	auto_item = {"item_berserk_potion","item_monkey_king_bar2","item_phase_boots_2","item_phase_boots","item_havoc_hammer","item_shivas_guard","item_eternal_shroud","item_lotus_orb","item_mask_of_madness","item_mjollnir","item_hood_of_defiance","item_pipe","item_thunder_armor"}
	--自动物品（对英雄施法）
	auto_item_hero = {"item_gunblade","item_orchid","item_veil_of_discord","item_bloodthorn","item_drag_net","item_dagon","item_dagon_2","item_dagon_3","item_dagon_4","item_dagon_5","item_nullifier","item_shackles_dagger"}
	--自动物品（对小兵施法）
	auto_item_creep = {"item_shackles_dagger","item_dagon","item_dagon_2","item_dagon_3","item_dagon_4","item_dagon_5"}
	
	

	self:GetCaster():SetContextThink("think_cast",function()
		--寻找目标
		local enemy = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetLocalOrigin(),nil,700,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_CREEP+1,48,FIND_CLOSEST,false)
		local good_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetLocalOrigin(),nil,800,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_HERO,48,FIND_CLOSEST,false)
		local creep = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetLocalOrigin(),nil,700,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_CREEP,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetLocalOrigin(),nil,800,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		
		if(not self:GetCaster():IsChanneling() and self:GetCaster():IsAlive())then
			--自动物品
			for k,v in pairs(auto_item)do
				if(self:GetCaster():HasItemInInventory(v) and self:GetCaster():FindItemInInventory(v):IsCooldownReady())then
					pcall(function()self:GetCaster():SetCursorCastTarget(self:GetCaster())end)
					self:GetCaster():CastAbilityImmediately(self:GetCaster():FindItemInInventory(v),0)
				end
			end
			--对最近英雄使用装备
			for k,v in pairs(auto_item_hero)do
				if(self:GetCaster():HasItemInInventory(v) and self:GetCaster():FindItemInInventory(v):IsCooldownReady()and bad_hero[1])then
					pcall(function()self:GetCaster():SetCursorCastTarget(bad_hero[1])end)
					self:GetCaster():CastAbilityImmediately(self:GetCaster():FindItemInInventory(v),0)
				end
			end
			
			--对最近小兵使用装备
			for k,v in pairs(auto_item_creep)do
				if(self:GetCaster():HasItemInInventory(v) and self:GetCaster():FindItemInInventory(v):IsCooldownReady()and enemy[1])then
					pcall(function()self:GetCaster():SetCursorCastTarget(enemy[1])end)
					self:GetCaster():CastAbilityImmediately(self:GetCaster():FindItemInInventory(v),0)
				end
			end
			
			--点金
			if self:GetCaster():HasItemInInventory("item_hand_of_midas")  then
				local casting_ability = self:GetCaster():FindItemInInventory("item_hand_of_midas")
				if(casting_ability:IsCooldownReady() and creep[1])then
					pcall(function()self:GetCaster():SetCursorCastTarget(creep[1])end)
					self:GetCaster():CastAbilityImmediately(casting_ability,0)
				end
			end
			
			--海盗帽
			if self:GetCaster():HasItemInInventory("item_pirate_hat2")  then
				local casting_ability = self:GetCaster():FindItemInInventory("item_pirate_hat2")
				if(casting_ability:IsCooldownReady() and creep[1])then
					pcall(function()self:GetCaster():SetCursorCastTarget(creep[1])end)
					self:GetCaster():CastAbilityImmediately(casting_ability,0)
				end
			end
		end
		
		local ability_count=self:GetCaster():GetAbilityCount()
		--放技能
		for i=0,ability_count-1 do
			local ability = self:GetCaster():GetAbilityByIndex(i)
			
			--如果技能存在                                技能非隐藏		    非被动						非开关类技能				开启自动					冷却好了							禁用自动施法			非持续施法
			if ability and self:GetCaster():IsAlive() and not ability:IsHidden() and not ability:IsPassive() and not ability:IsToggle() and ability:GetLevel()>0 and ability:IsCooldownReady() and not no_cast[ability:GetName()]and not self:GetCaster():IsChanneling()then
				--如果是控制施法
				if control_cast[ability:GetName()] and (not ability:GetAutoCastState()or self:GetCaster():IsSilenced()) then goto continue end
				--优先英雄
				if cast_hero[ability:GetName()] and bad_hero[1]then
					pcall(function()self:GetCaster():SetCursorCastTarget(bad_hero[RandomInt(1,#bad_hero)])end)
					self:GetCaster():CastAbilityImmediately(ability,0)
				end
				--自身施法
				if cast_self[ability:GetName()] then
					pcall(function()self:GetCaster():SetCursorCastTarget(self:GetCaster())end)
					self:GetCaster():CastAbilityImmediately(ability,0)
				--友好英雄施法
				elseif cast_friend[ability:GetName()] then
					pcall(function()self:GetCaster():SetCursorCastTarget(good_hero[RandomInt(1,#good_hero)])end)
					self:GetCaster():CastAbilityImmediately(ability,0)
				--如果是非目标技能
				elseif bit.band(bit.rshift(ability:GetBehaviorInt(),2),1)==1 then
					self:GetCaster():CastAbilityImmediately(ability,0)
				--敌方单位施法，目标技能
				elseif enemy[1] then
					pcall(function()self:GetCaster():SetCursorCastTarget(enemy[RandomInt(1,#enemy)])end)
					self:GetCaster():CastAbilityImmediately(ability,0)
				else
				end
				::continue::
			end
		end
		return 0.3
	end, 0)
end

--减cd
function  modifier_auto_cast:GetModifierPercentageCooldown(keys)
	if not self:GetParent():HasModifier("modifier_life_stealer_infest")then
		return 70 
	else
		return self:GetParent():FindAbilityByName("life_stealer_infest"):GetSpecialValueFor("cooldown")
	end
end
--不可驱散
function  modifier_auto_cast:IsPurgable()return false end
--魔法损耗降低
function  modifier_auto_cast:GetModifierPercentageManacost(keys)return 100 end
--金币速率
-- function  modifier_auto_cast:GetModifierPercentageGoldRateBoost(keys)return _G.boss_difficulty*10 end
--当死亡
function  modifier_auto_cast:OnDeath(keys)
	if keys.unit:IsRealHero() and keys.unit==self:GetCaster() then
		--pve
		if GetMapName()=="pve" and not keys.unit:HasModifier("modifier_apex_life") then
			-- if keys.attacker:IsControllableByAnyPlayer() then
				-- self:GetCaster():SetRespawnPosition(Vector(0,0,128))
				-- self:GetCaster():SetContextThink("think_respawn",function()self:GetCaster():RespawnHero(false,false)end,1)
				-- return nil
			-- end
			--死亡后起墓碑
			local newItem = CreateItem( "item_tombstone", keys.unit, keys.unit )
			newItem:SetPurchaseTime( 0 )
			newItem:SetPurchaser( keys.unit )
			local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
			tombstone:SetContainedItem( newItem )
			tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
			FindClearSpaceForUnit( tombstone, keys.unit:GetAbsOrigin(), true )
		end
		--pvp
		if GetMapName()=="pvp" then
			--断线
			if PlayerResource:GetConnectionState(keys.unit:GetPlayerID())==4 then
				keys.unit:SetTimeUntilRespawn(10000)
			elseif GameRules:GetDOTATime(false,true)<=180 then
				keys.unit:SetTimeUntilRespawn(1)
			elseif	GameRules:GetDOTATime(false,true)>180 then
				keys.unit:SetTimeUntilRespawn(5)
			else
			end
			--击杀经验
			if keys.attacker:IsRealHero() and keys.attacker:GetCurrentXP()<keys.unit:GetCurrentXP() then
				keys.attacker:AddExperience((keys.unit:GetCurrentXP()-keys.attacker:GetCurrentXP())*0.65,DOTA_ModifyXP_HeroKill,true,true)
			end
		end
	end
end

--当重生
function  modifier_auto_cast:OnRespawn(keys)
	toggle_ability = {"pudge_rot","leshrac_pulse_nova","witch_doctor_voodoo_restoration","winter_wyvern_arctic_burn","bloodseeker_blood_mist2"}
	if keys.unit == self:GetCaster() then
		--如果是pvp地图，3分钟以后
		if GetMapName()=="pvp" and GameRules:GetDOTATime(false,true)>180 then
			pcall(function()
				local respawn_position,bad_hero
				repeat
					respawn_position = Vector(RandomInt(-8000,8000),RandomInt(-8000,8000),128)
					bad_hero = FindUnitsInRadius(keys.unit:GetTeamNumber(),respawn_position,nil,1800,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,48,FIND_CLOSEST,false)
					if(bad_hero[1])then
						local respawn_positions = {bad_hero[1]:GetAbsOrigin()+Vector(0,1900,0),bad_hero[1]:GetAbsOrigin()+Vector(0,-1900,0),bad_hero[1]:GetAbsOrigin()+Vector(1900,0,0),bad_hero[1]:GetAbsOrigin()+Vector(-19000,0,0)}
						for k,v in pairs(respawn_positions)do
							print("重选复活点2")
							if(not FindUnitsInRadius(keys.unit:GetTeamNumber(),v,nil,1800,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,48,FIND_CLOSEST,false)[1] and math.abs(v.x)<8000 and math.abs(v.y)<8000)then
								respawn_position = v
								bad_hero[1] = nil
								break
							end
						end
					end
				until(not bad_hero[1])
				--keys.unit:SetAbsOrigin(respawn_position)
				FindClearSpaceForUnit(keys.unit,respawn_position,true)
			end)
		end
		--自动开启切换技能
		for k,v in pairs(toggle_ability)do
			if keys.unit:HasAbility(v) and keys.unit:FindAbilityByName(v):GetLevel()>0 then
				keys.unit:CastAbilityToggle(keys.unit:FindAbilityByName(v),0)
			end
		end
		keys.unit:RemoveModifierByName("modifier_bristleback_quillspray_autocast")
	end
end
--伤害数据统计
function  modifier_auto_cast:OnTakeDamage(keys)
	if GetMapName()=="pve" and keys.attacker == self:GetParent() and keys.unit~=self:GetParent() and (keys.unit:IsHero() or keys.unit:IsAncient()) then
		local player_id = self:GetParent():GetPlayerID()
		_G.stat_data.damage[player_id] = _G.stat_data.damage[player_id] + keys.damage
	end
end



