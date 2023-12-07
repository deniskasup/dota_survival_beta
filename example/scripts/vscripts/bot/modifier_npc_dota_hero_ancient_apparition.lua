modifier_npc_dota_hero_ancient_apparition = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_hero_ancient_apparition:DeclareFunctions()
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
function  modifier_npc_dota_hero_ancient_apparition:OnCreated(keys)
	self:GetParent():SetModelScale(3)
	local boss = self:GetParent()
	--升级
	for i=1,30 do
		boss:HeroLevelUp(true)
	end
	
	boss_abilitys = {"ancient_apparition_cold_feet","ancient_apparition_ice_vortex","ancient_apparition_chilling_touch","templar_assassin_refraction","wisp_overcharge","bloodseeker_bloodrage","juggernaut_blade_fury","oracle_false_promise","sniper_take_aim","abaddon_frostmourne"}
	boss_items = {"item_skadi","item_black_king_bar","item_mjollnir","item_trident","item_assault","item_hurricane_pike","item_ultimate_scepter_2","item_bloodstone","item_monkey_king_bar"}
	for k,v in pairs(boss_abilitys)do
		boss:AddAbility(v):SetLevel(4)
	end
	for k,v in pairs(boss_items)do
		boss:AddItemByName(v)
	end
	boss:FindAbilityByName("ancient_apparition_chilling_touch"):ToggleAutoCast()
	boss:FindModifierByName("modifier_abaddon_frostmourne"):Destroy()
	boss:FindAbilityByName("abaddon_frostmourne"):SetLevel(4)
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
	
	--自动施法
	self:GetParent():SetContextThink("bot_auto_cast",function()
	
		if(not self:GetParent():IsAlive())then
			return nil
		end

		--寒冰之足
		local casting_ability = self:GetParent():FindAbilityByName("ancient_apparition_cold_feet")
		local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--血怒
		local casting_ability = self:GetParent():FindAbilityByName("bloodseeker_bloodrage")
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--漩涡
		local casting_ability = self:GetParent():FindAbilityByName("ancient_apparition_ice_vortex")
		local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--神谕大
		local casting_ability = self:GetParent():FindAbilityByName("oracle_false_promise")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<30)then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--折光
		local casting_ability = self:GetParent():FindAbilityByName("templar_assassin_refraction")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--过载
		local casting_ability = self:GetParent():FindAbilityByName("wisp_overcharge")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--风暴
		local casting_ability = self:GetParent():FindAbilityByName("juggernaut_blade_fury")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--雷锤
		local casting_ability = self:GetParent():FindItemInInventory("item_mjollnir")
		if(casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--大推推
		local casting_ability = self:GetCaster():FindItemInInventory("item_hurricane_pike")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--血精
		local casting_ability = self:GetCaster():FindItemInInventory("item_bloodstone")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<70)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--BKB
		local casting_ability = self:GetCaster():FindItemInInventory("item_black_king_bar")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<50)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		

		return 0.1
	end,0)
	
end


--不可驱散
function  modifier_npc_dota_hero_ancient_apparition:IsPurgable()return false end
--永久
function  modifier_npc_dota_hero_ancient_apparition:IsPermanent()return true end
