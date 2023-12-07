modifier_npc_dota_hero_axe = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_hero_axe:DeclareFunctions()
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
function  modifier_npc_dota_hero_axe:OnCreated(keys)
	self:GetParent():SetModelScale(3)
	local boss = self:GetParent()
	--升级
	for i=1,30 do
		boss:HeroLevelUp(true)
	end
	
	boss_abilitys = {"axe_berserkers_call","axe_battle_hunger","axe_counter_helix","axe_culling_blade","necrolyte_heartstopper_aura","bloodseeker_thirst","huskar_berserkers_blood","alchemist_chemical_rage","pugna_life_drain"}
	boss_items = {"item_overwhelming_blink","item_heart","item_mjollnir","item_trident","item_blade_mail","item_lotus_orb","item_force_boots","item_ultimate_scepter_2","item_shivas_guard"}
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
		--吸血
		local casting_ability = self:GetCaster():FindAbilityByName("pugna_life_drain")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--斧王 战斗饥渴
		local casting_ability = self:GetCaster():FindAbilityByName("axe_battle_hunger")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--化学狂暴
		local casting_ability = self:GetCaster():FindAbilityByName("alchemist_chemical_rage")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--刃甲
		local casting_ability = self:GetCaster():FindItemInInventory("item_blade_mail")
		if(casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--莲花
		local casting_ability = self:GetCaster():FindItemInInventory("item_lotus_orb")
		if(casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--雷锤
		local casting_ability = self:GetCaster():FindItemInInventory("item_mjollnir")
		if(casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--跳刀
		local casting_ability = self:GetCaster():FindItemInInventory("item_overwhelming_blink")
		if(casting_ability:IsCooldownReady())then
			if(self.target[1])then
				pcall(function()self:GetParent():SetCursorCastTarget(self.target[1])end)
				self:GetParent():CastAbilityImmediately(casting_ability,0)
			end
		end
		
		--推推
		local casting_ability = self:GetCaster():FindItemInInventory("item_force_boots")
		if(casting_ability:IsCooldownReady())then
			if(self.target[1])then
				local distance = (self:GetCaster():GetCenter()-self.target[1]:GetCenter()):Length()
				if(distance>400)then
					pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
					self:GetParent():CastAbilityImmediately(casting_ability,0)
				end
			end
		end
		
		
		--斧王 斩
		local casting_ability = self:GetCaster():FindAbilityByName("axe_culling_blade")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,150,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			self:GetCaster():CastAbilityOnTarget(bad_hero[1],casting_ability,0)
			return 0.5
		end
		
		--斧王 吼
		local casting_ability = self:GetCaster():FindAbilityByName("axe_berserkers_call")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,400,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			self:GetCaster():CastAbilityNoTarget(casting_ability,0)
			return 0.5
		end

		return 0.1
	end,0)
	
end


--不可驱散
function  modifier_npc_dota_hero_axe:IsPurgable()return false end
--永久
function  modifier_npc_dota_hero_axe:IsPermanent()return true end
