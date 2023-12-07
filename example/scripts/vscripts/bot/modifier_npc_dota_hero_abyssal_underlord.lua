modifier_npc_dota_hero_abyssal_underlord = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_hero_abyssal_underlord:DeclareFunctions()
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
function  modifier_npc_dota_hero_abyssal_underlord:OnCreated(keys)
	local boss = self:GetCaster()
	self:GetParent():SetModelScale(3)
	
	--升级
	for i=1,30 do
		boss:HeroLevelUp(true)
	end
	
	boss_abilitys = {"abyssal_underlord_firestorm","abyssal_underlord_pit_of_malice","abyssal_underlord_atrophy_aura","sniper_take_aim","jakiro_macropyre","ursa_overpower","techies_land_mines","beastmaster_wild_axes","skywrath_mage_ancient_seal","tiny_grow"}
	boss_items = {"item_heart","item_trident","item_shivas_guard","item_skadi","item_bloodstone","item_revenants_brooch","item_travel_boots_2","item_ultimate_scepter_2","item_greater_crit"}
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
		if(not self:GetParent():IsAlive())then
			return nil
		end
		--火雨
		local casting_ability = self:GetCaster():FindAbilityByName("abyssal_underlord_firestorm")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--深渊
		local casting_ability = self:GetCaster():FindAbilityByName("abyssal_underlord_pit_of_malice")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--双头龙 大招
		local casting_ability = self:GetCaster():FindAbilityByName("jakiro_macropyre")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--拍拍 连击
		local casting_ability = self:GetCaster():FindAbilityByName("ursa_overpower")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--地雷
		local casting_ability = self:GetCaster():FindAbilityByName("techies_land_mines")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,700,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:GetCurrentAbilityCharges()>0)then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--飞斧
		local casting_ability = self:GetCaster():FindAbilityByName("beastmaster_wild_axes")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--沉默
		local casting_ability = self:GetCaster():FindAbilityByName("skywrath_mage_ancient_seal")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--冰甲
		local casting_ability = self:GetCaster():FindItemInInventory("item_shivas_guard")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--亡灵胸针
		local casting_ability = self:GetCaster():FindItemInInventory("item_revenants_brooch")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,600,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if bad_hero[1] and casting_ability:IsCooldownReady() and not self:GetParent():HasModifier("modifier_item_revenants_brooch_counter")then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		elseif not bad_hero[1] and casting_ability:IsCooldownReady() and self:GetParent():HasModifier("modifier_item_revenants_brooch_counter")then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--血精石
		local casting_ability = self:GetCaster():FindItemInInventory("item_bloodstone")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<35)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		
		
		
		return 0.1
	end,0)
	
end


--是否可驱散
function  modifier_npc_dota_hero_abyssal_underlord:IsPurgable()return false end
--永久
function  modifier_npc_dota_hero_abyssal_underlord:IsPermanent()return true end
