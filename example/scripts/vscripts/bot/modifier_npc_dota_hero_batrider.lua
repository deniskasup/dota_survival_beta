modifier_npc_dota_hero_batrider = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_hero_batrider:DeclareFunctions()
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
function  modifier_npc_dota_hero_batrider:OnCreated(keys)
	self:GetParent():SetModelScale(2)
	local boss = self:GetParent()
	--升级
	for i=1,30 do
		boss:HeroLevelUp(true)
	end
	
	boss_abilitys = {"batrider_sticky_napalm","batrider_flamebreak","batrider_firefly","batrider_flaming_lasso","shredder_flamethrower","skywrath_mage_mystic_flare","grimstroke_ink_creature","gyrocopter_rocket_barrage","rattletrap_battery_assault","enchantress_natures_attendants","legion_commander_press_the_attack","huskar_burning_spear","phantom_assassin_stifling_dagger"}
	boss_items = {"item_heart","item_black_king_bar","item_ex_machina","item_shivas_guard","item_bloodstone","item_refresher","item_trident","item_skadi"}
	for k,v in pairs(boss_abilitys)do
		boss:AddAbility(v):SetLevel(4)
	end
	for k,v in pairs(boss_items)do
		boss:AddItemByName(v)
	end
	boss:FindAbilityByName("huskar_burning_spear"):ToggleAutoCast()
	boss:AddNewModifier(nil,nil,"modifier_vision",nil)
	boss:SwapItems(6,16)
	boss:SwapItems(7,15)
	
	
	
	
	--自动移动
	self:GetParent():SetContextThink("bot_attack",function()
		self.target = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,46000,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,8240,FIND_CLOSEST,false)
		if(self.target[1])then
			self:GetParent():MoveToNPC(self.target[1])
		end
		return 1
	end,0)
	
	--自动施法
	self:GetParent():SetContextThink("bot_auto_cast",function()
	
		if(not self:GetParent():IsAlive())then
			return nil
		end
		
		--西瓦
		local casting_ability = self:GetCaster():FindItemInInventory("item_shivas_guard")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--BKB
		local casting_ability = self:GetCaster():FindItemInInventory("item_black_king_bar")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<50)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--机械之心
		local casting_ability = self:GetCaster():FindItemInInventory("item_ex_machina")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<50)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--血精
		local casting_ability = self:GetCaster():FindItemInInventory("item_bloodstone")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<70)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--刷新
		local casting_ability = self:GetCaster():FindItemInInventory("item_bloodstone")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<30)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		
		for k,v in pairs(boss_abilitys)do
			local casting_ability = self:GetCaster():FindAbilityByName(v)
			local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,700,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
			if(bad_hero[1] and casting_ability:IsCooldownReady())then
				--如果是强攻
				if casting_ability:GetName() == "legion_commander_press_the_attack"then
					pcall(function()self:GetParent():SetCursorCastTarget(self:GetCaster())end)
					self:GetParent():CastAbilityImmediately(casting_ability,0)
				end
				pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
				self:GetParent():CastAbilityImmediately(casting_ability,0)
			end
		end
		return 0.3
	end,0)
	
end


--不可驱散
function  modifier_npc_dota_hero_batrider:IsPurgable()return false end
--永久
function  modifier_npc_dota_hero_batrider:IsPermanent()return true end