--杀死野怪
function kill_creep(keys)
	if(keys.target:IsAlive())then
		keys.target:Kill(nil,nil)
	end
end

--加技能点
function add_ability_point(keys)
	keys.caster:EmitSound("Item.TomeOfKnowledge")
	keys.caster:SetAbilityPoints(keys.caster:GetAbilityPoints()+1)
end

--军团指挥官
function legion_commander_overwhelming_odds(keys)
	ParticleManager:CreateParticle("particles/econ/items/mirana/mirana_persona/mirana_starstorm_moonray.vpcf",0,keys.caster)
	local units = FindUnitsInRadius(keys.caster:GetTeamNumber(),keys.caster:GetOrigin(),nil,600,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC,48,FIND_ANY_ORDER,false)
	local hero = FindUnitsInRadius(keys.caster:GetTeamNumber(),keys.caster:GetOrigin(),nil,600,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,48,FIND_ANY_ORDER,false)
	local damage = keys.ability:GetSpecialValueFor("damage")+#units*keys.ability:GetSpecialValueFor("damage_per_unit")+#hero*keys.ability:GetSpecialValueFor("damage_per_hero")
	for k,v in pairs(units)do
		local damageTable = {victim=v,attacker=keys.caster,damage=damage,damage_type=DAMAGE_TYPE_MAGICAL,ability=keys.ability}
		ApplyDamage(damageTable)
	end
	for k,v in pairs(hero)do
		local damageTable = {victim=v,attacker=keys.caster,damage=damage,damage_type=DAMAGE_TYPE_MAGICAL,ability=keys.ability}
		ApplyDamage(damageTable)
	end
end

--nec 胜利光环
function necrolyte_heartstopper_aura2(keys)
	local units = FindUnitsInRadius(keys.caster:GetTeamNumber(),keys.caster:GetAbsOrigin(),nil,800,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC+1,48,FIND_ANY_ORDER,false)
	for k,v in pairs(units)do
		local damage = v:GetMaxHealth()*keys.ability:GetSpecialValueFor("aura_damage")*0.01 + keys.caster:GetHealthRegen()*keys.ability:GetSpecialValueFor("regen_damage")*0.01
		local damageTable = {victim=v,attacker=keys.caster,damage=damage,damage_type=DAMAGE_TYPE_MAGICAL,ability=keys.ability,damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL}
		ApplyDamage(damageTable)
	end
end

--疗伤莲花
function item_famango(keys)
	keys.caster:AddNewModifier(keys.caster,keys.ability,"modifier_famango",nil):IncrementStackCount()
	keys.caster:AddNewModifier(keys.caster,keys.ability,"modifier_famango",nil):IncrementStackCount()
	keys.caster:AddNewModifier(keys.caster,keys.ability,"modifier_famango",nil):IncrementStackCount()
end
--贪婪
function item_greed_book(keys)
	if not keys.caster:HasAbility("alchemist_goblins_greed")then
		keys.caster:AddAbility("alchemist_goblins_greed")
		keys.ability:Destroy()
	end
end

--雷甲
function item_thunder_armor(keys)
	if(not keys.caster:HasModifier("modifier_item_thunder_armor2"))then
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.caster,"modifier_item_thunder_armor2",{duration=1})
		keys.caster:EmitSound("Hero_Zuus.ArcLightning.Cast")
		local damage_units = FindUnitsInRadius(keys.caster:GetTeamNumber(),keys.caster:GetCenter(),nil,700,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC+1,DOTA_UNIT_TARGET_FLAG_NONE ,FIND_CLOSEST,false)
		local counter = 0
		for k,v in pairs(damage_units)do
			local damageTable = {victim=v,attacker=keys.caster,damage=225,damage_type=DAMAGE_TYPE_MAGICAL,ability=keys.ability}
			ApplyDamage(damageTable)
			counter = counter +1
			if(counter>=12)then
				break
			end
		end
	end
end
--束缚之刃
function item_shackles_dagger(keys)
	keys.caster:PerformAttack(keys.target,true,true,true,true,false,false,true)
end
--血雾
function bloodseeker_blood_mist2(keys)
	local units = FindUnitsInRadius(keys.caster:GetTeamNumber(),keys.caster:GetAbsOrigin(),nil,450,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC+1,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
	local damage = keys.caster:GetMaxHealth()*0.01*keys.ability:GetSpecialValueFor("damage")
	for k,v in pairs(units)do
		local damageTable = {victim=v,attacker=keys.caster,damage=damage,damage_type=DAMAGE_TYPE_MAGICAL,ability=keys.ability}
		ApplyDamage(damageTable)
	end
end

--自动学习
function auto_learn(keys)
	keys.ability:SetLevel(1)
end
--bkb
function bkb(keys)
	keys.caster:Purge(false,true,false,false,false)
	--如果是近战
	if(keys.caster:GetAttackCapability()==DOTA_UNIT_CAP_MELEE_ATTACK)then
		keys.caster:AddNewModifier(keys.caster,keys.ability,"modifier_black_king_bar_immune",{duration=5})
	elseif(keys.caster:GetAttackCapability()==DOTA_UNIT_CAP_RANGED_ATTACK)then
		keys.caster:AddNewModifier(keys.caster,keys.ability,"modifier_black_king_bar_immune",{duration=3})
	else
	end
end

--侧翼机炮2
function side_gunner2(keys)
	keys.caster:SetContextThink("side_gunner2",function()
		local units = FindUnitsInRadius(keys.caster:GetTeamNumber(),keys.caster:GetAbsOrigin(),nil,700,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC+1,48,FIND_CLOSEST,false)
		if(units[1] and keys.caster:IsAlive() and not GameRules:IsGamePaused() and not keys.caster:IsStunned() and not keys.caster:IsDisarmed())then
			keys.caster:PerformAttack(units[1],true,true,true,true,true,false,true)
		end
		return keys.ability:GetSpecialValueFor("cool_down")
	end,0)
end

--lina被动
function lina_fiery_soul2(keys)
	local counter = keys.caster:GetModifierStackCount("modifier_lina_fiery_soul2_counter",keys.caster)
	--如果层数小于7,不是装备,不是法球
	if counter<7 and not keys.event_ability:IsItem() and not keys.event_ability:IsToggle() and not string.find(keys.event_ability:GetAbilityKeyValues().AbilityBehavior,"DOTA_ABILITY_BEHAVIOR_ATTACK") then
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.caster,"modifier_lina_fiery_soul2_counter",{}):IncrementStackCount()
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.caster,"modifier_lina_fiery_soul2_buff",{})
	end
end

--lina被动
function lina_fiery_soul2_reduce(keys)
	keys.caster:FindModifierByName("modifier_lina_fiery_soul2_counter"):DecrementStackCount()
end
--移除装备buff
function destroy_item_buff(keys)
	local buff = keys.caster:FindAllModifiers()
	for k,v in pairs(buff)do
		if v:GetAbility()==keys.ability then
			v:Destroy()
		end
	end
end
--移除三叉戟buff
function destroy_item_trident(keys)
	keys.caster:RemoveModifierByName("modifier_item_sange")
	keys.caster:RemoveModifierByName("modifier_item_yasha")
	keys.caster:RemoveModifierByName("modifier_item_kaya")
end
--移除冰之枪buff
function destroy_item_dragon_lance2(keys)
	keys.caster:RemoveModifierByName("modifier_item_dragon_lance")
	keys.caster:RemoveModifierByName("modifier_item_skadi")
	keys.caster:RemoveModifierByName("modifier_splash_attack")
end
--移除冰之心buff
function destroy_item_ice_heart(keys)
	keys.caster:RemoveModifierByName("modifier_item_heart")
	keys.caster:RemoveModifierByName("modifier_item_skadi")
end


--点金手
function item_hand_of_midas(keys)
	if keys.target:IsCreep() and not keys.target:IsAncient() then
		keys.target:EmitSound("DOTA_Item.Hand_Of_Midas")
		local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)	
		ParticleManager:SetParticleControlEnt(midas_particle, 1, keys.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.caster:GetAbsOrigin(), false)

		--Remove default gold/XP on the creep before killing it so the caster does not receive anything more.
		keys.target:SetDeathXP(keys.target:GetDeathXP()*2.5)
		keys.target:SetMinimumGoldBounty(200)
		keys.target:SetMaximumGoldBounty(200)
		
		local damageTable = {victim=keys.target,attacker=keys.caster,damage=keys.target:GetHealth(),damage_type=DAMAGE_TYPE_PURE,ability=keys.ability}
		ApplyDamage(damageTable)
	end
end