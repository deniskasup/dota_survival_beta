modifier_npc_dota_hero_abaddon = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_hero_abaddon:DeclareFunctions()
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
function  modifier_npc_dota_hero_abaddon:OnCreated(keys)
	local boss = self:GetCaster()
	boss:SetModelScale(3)
	--升级
	for i=1,30 do
		boss:HeroLevelUp(true)
	end
	
	boss_abilitys = {"abaddon_death_coil","abaddon_aphotic_shield","abaddon_frostmourne","abaddon_borrowed_time","slark_essence_shift","sandking_burrowstrike","troll_warlord_fervor","alchemist_chemical_rage","broodmother_insatiable_hunger","life_stealer_feast"}
	boss_items = {"item_heart","item_trident","item_skadi","item_shivas_guard","item_assault","item_monkey_king_bar","item_travel_boots_2","item_ultimate_scepter_2","item_sphere"}
	for k,v in pairs(boss_abilitys)do
		boss:AddAbility(v):SetLevel(4)
	end
	for k,v in pairs(boss_items)do
		boss:AddItemByName(v)
	end
	boss:AddNewModifier(nil,nil,"modifier_vision",nil)
	boss:FindModifierByName("modifier_abaddon_frostmourne"):Destroy()
	boss:FindAbilityByName("abaddon_frostmourne"):SetLevel(4)
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
	self:GetParent():SetContextThink("bot_auto_cast",function()
		if(not self:GetParent():IsAlive())then
			return nil
		end
		--加血
		local casting_ability = self:GetCaster():FindAbilityByName("abaddon_death_coil")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--无光之盾
		local casting_ability = self:GetCaster():FindAbilityByName("abaddon_aphotic_shield")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--穿刺
		local casting_ability = self:GetCaster():FindAbilityByName("sandking_burrowstrike")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end

		
		--极度饥渴
		local casting_ability = self:GetCaster():FindAbilityByName("broodmother_insatiable_hunger")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--化学狂暴
		local casting_ability = self:GetCaster():FindAbilityByName("alchemist_chemical_rage")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--回光反照
		local casting_ability = self:GetCaster():FindAbilityByName("abaddon_borrowed_time")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<15)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--冰甲
		local casting_ability = self:GetCaster():FindItemInInventory("item_shivas_guard")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		
		return 0.1
	end,0)
	
end


--是否可驱散
function  modifier_npc_dota_hero_abaddon:IsPurgable()return false end
--永久
function  modifier_npc_dota_hero_abaddon:IsPermanent()return true end
