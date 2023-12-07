modifier_npc_dota_hero_undying = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_hero_undying:DeclareFunctions()
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
function  modifier_npc_dota_hero_undying:OnCreated(keys)
	local boss = self:GetCaster()
	boss:SetModelScale(2)
	
	--升级
	for i=1,30 do
		boss:HeroLevelUp(true)
	end
	
	boss_abilitys = {"undying_decay","undying_flesh_golem","spectre_dispersion","medusa_mana_shield","batrider_sticky_napalm","pugna_life_drain","pudge_flesh_heap","pangolier_shield_crash","lich_frost_shield","lich_frost_armor"}
	boss_items = {"item_heart","item_trident","item_shivas_guard","item_skadi","item_bloodstone","item_blade_mail","item_travel_boots_2","item_ultimate_scepter_2","item_eternal_shroud"}
	for k,v in pairs(boss_abilitys)do
		boss:AddAbility(v):SetLevel(4)
	end
	for k,v in pairs(boss_items)do
		boss:AddItemByName(v)
	end
	boss:AddNewModifier(nil,nil,"modifier_vision",nil)
	boss:SwapItems(6,16)
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
		--腐朽
		local casting_ability = self:GetCaster():FindAbilityByName("undying_decay")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--血肉傀儡
		local casting_ability = self:GetCaster():FindAbilityByName("undying_flesh_golem")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--燃油
		local casting_ability = self:GetCaster():FindAbilityByName("batrider_sticky_napalm")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--抽血
		local casting_ability = self:GetCaster():FindAbilityByName("pugna_life_drain")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--腐肉
		local casting_ability = self:GetCaster():FindAbilityByName("pudge_flesh_heap")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--甲盾冲击
		local casting_ability = self:GetCaster():FindAbilityByName("pangolier_shield_crash")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		
		
		--冰霜护甲
		local casting_ability = self:GetCaster():FindAbilityByName("lich_frost_shield")
		if(casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--冰甲
		local casting_ability = self:GetCaster():FindAbilityByName("lich_frost_armor")
		if(casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--刃甲
		local casting_ability = self:GetCaster():FindItemInInventory("item_blade_mail")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--冰甲
		local casting_ability = self:GetCaster():FindItemInInventory("item_shivas_guard")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--血精石
		local casting_ability = self:GetCaster():FindItemInInventory("item_bloodstone")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<30)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end

		
		
		return 0.1
	end,0)
	
end


--是否可驱散
function  modifier_npc_dota_hero_undying:IsPurgable()return false end
--永久
function  modifier_npc_dota_hero_undying:IsPermanent()return true end


--当死亡
function  modifier_npc_dota_hero_undying:OnDeath(keys)
	if keys.unit==self:GetParent() and _G.boss_round==1 then
		CustomGameEventManager:Send_ServerToAllClients( "pve_end", {round=1} )
		-- GameRules:GetGameModeEntity():SetContextThink("think_apex",function()
			-- FireGameEvent("start_apex",nil)
		-- end,5)
	end
end
