modifier_npc_dota_hero_bloodseeker = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_hero_bloodseeker:DeclareFunctions()
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
function  modifier_npc_dota_hero_bloodseeker:OnCreated(keys)
	self:GetParent():SetModelScale(3)
	local boss = self:GetParent()
	--升级
	for i=1,30 do
		boss:HeroLevelUp(true)
	end
	
	local boss_abilitys = {"bloodseeker_bloodrage","bloodseeker_blood_bath","bloodseeker_thirst","bloodseeker_rupture","huskar_berserkers_blood","huskar_life_break","lina_laguna_blade","ursa_fury_swipes","life_stealer_rage","bloodseeker_blood_mist"}
	local boss_items = {"item_heart","item_mjollnir","item_trident","item_butterfly","item_mirror_shield","item_skadi","item_satanic","item_aghanims_shard","item_ultimate_scepter_2","item_assault"}
	for k,v in pairs(boss_abilitys)do
		boss:AddAbility(v):SetLevel(4)
	end
	for k,v in pairs(boss_items)do
		boss:AddItemByName(v)
	end
	boss:AddNewModifier(nil,nil,"modifier_vision",nil)
	
	
	boss:SwapItems(7,15)
	
	
	
	--自动攻击
	self:GetParent():SetContextThink("bot_attack",function()
		self.target = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,46000,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,8240,FIND_CLOSEST,false)
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
		--割裂
		local casting_ability = self:GetCaster():FindAbilityByName("bloodseeker_rupture")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:GetLevel()>0 and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--血祭
		local casting_ability = self:GetCaster():FindAbilityByName("bloodseeker_blood_bath")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--哈斯卡 跳
		local casting_ability = self:GetCaster():FindAbilityByName("huskar_life_break")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--琳娜 大
		local casting_ability = self:GetCaster():FindAbilityByName("lina_laguna_blade")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--血雾 
		local casting_ability = self:GetCaster():FindAbilityByName("bloodseeker_blood_mist")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,450,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if bad_hero[1] and casting_ability:IsCooldownReady() and not casting_ability:GetToggleState() then
			casting_ability:ToggleAbility()
		elseif not bad_hero[1] and casting_ability:IsCooldownReady() and casting_ability:GetToggleState() then
			casting_ability:ToggleAbility()
		end

		
		--血怒
		local casting_ability = self:GetCaster():FindAbilityByName("bloodseeker_bloodrage")
		if(casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--魔免
		local casting_ability = self:GetCaster():FindAbilityByName("life_stealer_rage")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<50)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--撒旦
		local casting_ability = self:GetCaster():FindItemInInventory("item_satanic")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<50)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--雷锤
		local casting_ability = self:GetCaster():FindItemInInventory("item_mjollnir")
		if(casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		return 0.1
	end,0)
	
end


--不可驱散
function  modifier_npc_dota_hero_bloodseeker:IsPurgable()return false end
--永久
function  modifier_npc_dota_hero_bloodseeker:IsPermanent()return true end
