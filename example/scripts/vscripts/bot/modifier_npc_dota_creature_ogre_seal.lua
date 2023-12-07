modifier_npc_dota_creature_ogre_seal = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_npc_dota_creature_ogre_seal:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end


--------------------------------------------------------------------------------

--当buff创建
function  modifier_npc_dota_creature_ogre_seal:OnCreated(keys)
	self:GetParent():SetModelScale(1.5)
	local boss = self:GetParent()
	boss:AddNewModifier(boss,nil,"modifier_vision",nil)
	boss:AddAbility("puck_illusory_orb2"):SetLevel(4)
	boss:AddAbility("freezing_aura")
	local ability = boss:AddAbility("tusk_walrus_punch")
	ability:SetLevel(3)
	ability:ToggleAutoCast()
	boss:AddItemByName("item_desolator_2")

	
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
		--波
		local casting_ability = self:GetCaster():FindAbilityByName("puck_illusory_orb2")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,casting_ability:GetCastRange(nil,nil),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			pcall(function()self:GetParent():SetCursorCastTarget(bad_hero[1])end)
			self:GetParent():CastAbilityImmediately(casting_ability,0)
		end
		--海豹冲刺
		local casting_ability = self:GetCaster():FindAbilityByName("ogreseal_flop")
		local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,1000,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
		if(bad_hero[1] and casting_ability:IsCooldownReady())then
			self:GetParent():AddNewModifier(nil,nil,"modifier_black_king_bar_immune",{duration=0.5})
			self:GetParent():CastAbilityOnPosition(bad_hero[1]:GetCenter(),casting_ability,0)
			return 0.5
		end

		return 0.1
	end,0)
	self.player_count = get_online_players()
end
--获取在线玩家个数
function  get_online_players()
	local count = 0
	for i=0,9 do
		if PlayerResource:GetConnectionState(i) == 2 then
			count = count+1
		end
	end
	return count
end

--不可驱散
function  modifier_npc_dota_creature_ogre_seal:IsPurgable()return false end
--永久
function  modifier_npc_dota_creature_ogre_seal:IsPermanent()return true end

--额外生命值
function  modifier_npc_dota_creature_ogre_seal:GetModifierExtraHealthBonus()return (self.player_count-1)*10000 end
--护甲
function  modifier_npc_dota_creature_ogre_seal:GetModifierPhysicalArmorBonus(keys)return 15 end
--绝对移速
function  modifier_npc_dota_creature_ogre_seal:GetModifierMoveSpeed_Absolute()return 400 end
--魔抗
function  modifier_npc_dota_creature_ogre_seal:GetModifierMagicalResistanceBonus()return 50 end