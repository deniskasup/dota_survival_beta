modifier_npc_dota_hero_arc_warden = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_hero_arc_warden:DeclareFunctions()
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
--电狗

--------------------------------------------------------------------------------

--当buff创建
function  modifier_npc_dota_hero_arc_warden:OnCreated(keys)
	self:GetParent():SetModelScale(3)
	local boss = self:GetParent()
	--升级
	for i=1,30 do
		boss:HeroLevelUp(true)
	end
	
	boss_abilitys = {"ignore_blade_mail","enchantress_impetus","arc_warden_magnetic_field","snapfire_lil_shredder","sniper_take_aim","sniper_headshot","spirit_breaker_greater_bash","clinkz_strafe","jakiro_ice_path","faceless_void_backtrack","slark_dark_pact","centaur_hoof_stomp","omniknight_guardian_angel"}
	boss_items = {"item_black_king_bar","item_trident","item_monkey_king_bar","item_bloodstone","item_refresher","item_hurricane_pike","item_shivas_guard","item_heart"}
	for k,v in pairs(boss_abilitys)do
		boss:AddAbility(v):SetLevel(4)
	end
	for k,v in pairs(boss_items)do
		boss:AddItemByName(v)
	end
	boss:FindAbilityByName("enchantress_impetus"):ToggleAutoCast()
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
		--磁场
		local casting_ability = self:GetCaster():FindAbilityByName("arc_warden_magnetic_field")
		if(casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--铁手
		local casting_ability = self:GetCaster():FindAbilityByName("snapfire_lil_shredder")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--扫射
		local casting_ability = self:GetCaster():FindAbilityByName("clinkz_strafe")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--黑暗契约
		local casting_ability = self:GetCaster():FindAbilityByName("slark_dark_pact")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--踩
		local casting_ability = self:GetCaster():FindAbilityByName("centaur_hoof_stomp")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--冰
		local casting_ability = self:GetCaster():FindAbilityByName("jakiro_ice_path")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--全能大
		local casting_ability = self:GetCaster():FindAbilityByName("omniknight_guardian_angel")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<30)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		
		--西瓦
		local casting_ability = self:GetParent():FindItemInInventory("item_shivas_guard")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--BKB
		local casting_ability = self:GetCaster():FindItemInInventory("item_black_king_bar")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<50)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--血精
		local casting_ability = self:GetCaster():FindItemInInventory("item_bloodstone")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<70)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--大推推
		local casting_ability = self:GetCaster():FindItemInInventory("item_hurricane_pike")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--刷新
		local casting_ability = self:GetCaster():FindItemInInventory("item_refresher")
		if(casting_ability:IsCooldownReady() and self:GetParent():GetHealthPercent()<30)then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		

		return 0.1
	end,0)
	
end


--不可驱散
function  modifier_npc_dota_hero_arc_warden:IsPurgable()return false end
--永久
function  modifier_npc_dota_hero_arc_warden:IsPermanent()return true end
