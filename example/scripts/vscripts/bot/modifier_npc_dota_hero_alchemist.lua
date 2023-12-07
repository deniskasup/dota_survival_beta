modifier_npc_dota_hero_alchemist = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_hero_alchemist:DeclareFunctions()
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
function  modifier_npc_dota_hero_alchemist:OnCreated(keys)
	self:GetParent():SetModelScale(3)
	local boss = self:GetParent()
	--升级
	for i=1,30 do
		boss:HeroLevelUp(true)
	end
	
	boss_abilitys = {"skeleton_king_vampiric_aura","riki_blink_strike","alchemist_acid_spray","alchemist_chemical_rage","vengefulspirit_magic_missile","sven_great_cleave","troll_warlord_fervor","sniper_headshot","viper_poison_attack","dragon_knight_dragon_blood","sniper_take_aim"}
	boss_items = {"item_heart","item_mjollnir","item_trident","item_monkey_king_bar","item_assault","item_black_king_bar","item_nullifier","item_skadi"}
	for k,v in pairs(boss_abilitys)do
		boss:AddAbility(v):SetLevel(4)
	end
	for k,v in pairs(boss_items)do
		boss:AddItemByName(v)
	end
	boss:FindAbilityByName("viper_poison_attack"):ToggleAutoCast()
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
		--blink
		local casting_ability = self:GetCaster():FindAbilityByName("riki_blink_strike")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--酸雾
		local casting_ability = self:GetCaster():FindAbilityByName("alchemist_acid_spray")
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
		--魔法箭
		local casting_ability = self:GetCaster():FindAbilityByName("vengefulspirit_magic_missile")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--瞄准
		local casting_ability = self:GetCaster():FindAbilityByName("sniper_take_aim")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,400,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--雷锤
		local casting_ability = self:GetCaster():FindItemInInventory("item_mjollnir")
		if(casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(self:GetParent())end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		
		--否决
		local casting_ability = self:GetCaster():FindItemInInventory("item_nullifier")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
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
function  modifier_npc_dota_hero_alchemist:IsPurgable()return false end
--永久
function  modifier_npc_dota_hero_alchemist:IsPermanent()return true end
