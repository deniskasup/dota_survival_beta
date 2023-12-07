modifier_npc_dota_hero_bane = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_hero_bane:DeclareFunctions()
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
function  modifier_npc_dota_hero_bane:OnCreated(keys)
	self:GetParent():SetModelScale(3)
	local boss = self:GetParent()
	--升级
	for i=1,30 do
		boss:HeroLevelUp(true)
	end
	
	boss_abilitys = {"necrolyte_sadist","ignore_blade_mail","bane_enfeeble","bane_brain_sap","bane_fiends_grip","bloodseeker_blood_bath","chen_test_of_faith","omniknight_hammer_of_purity","rubick_arcane_supremacy","tinker_laser","lina_flame_cloak","tiny_grow"}
	boss_items = {"item_heart","item_shivas_guard","item_trident","item_sphere","item_lotus_orb","item_heavens_halberd","item_bloodstone","item_assault","item_ultimate_scepter_2"}
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
		--莲花
		local casting_ability = self:GetCaster():FindItemInInventory("item_lotus_orb")
		if(casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--冰甲
		local casting_ability = self:GetCaster():FindItemInInventory("item_shivas_guard")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--血精
		local casting_ability = self:GetCaster():FindItemInInventory("item_bloodstone")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<50)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--天堂
		local casting_ability = self:GetCaster():FindItemInInventory("item_heavens_halberd")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		
		
		
		for k,v in pairs(boss_abilitys) do
			local casting_ability = self:GetParent():FindAbilityByName(v)
			local bad_hero = FindUnitsInRadius(self:GetParent():GetTeamNumber(),self:GetParent():GetCenter(),nil,600,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
			if(bad_hero[1] and casting_ability:IsCooldownReady())then
				pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
				self:GetParent():CastAbilityImmediately(casting_ability,0)
			end
		end
		
		return 0.1
	end,0)
	
end


--不可驱散
function  modifier_npc_dota_hero_bane:IsPurgable()return false end
--永久
function  modifier_npc_dota_hero_bane:IsPermanent()return true end
