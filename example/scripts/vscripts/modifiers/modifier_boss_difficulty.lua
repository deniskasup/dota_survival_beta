modifier_boss_difficulty = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_boss_difficulty:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}
	return funcs
end
function modifier_boss_difficulty:CheckState()
	if not self:GetParent():IsRealHero() then
		return {
			[MODIFIER_STATE_SILENCED] = false,
			[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
			[MODIFIER_STATE_DEBUFF_IMMUNE] = true,
		}
	else
		return {
			[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
		}
	end
end


--当创建
function  modifier_boss_difficulty:OnCreated()
	self.boss_amplify = get_online_players()*_G.boss_difficulty
	--地图外检测
	self:GetParent():SetContextThink("think_out_map",function()
		if self:GetParent():GetCenter().z<-1000 then
			local pos = self:GetParent():GetOrigin()
			if pos.x>8000 then pos.x=8000 end
			if pos.x<-8000 then pos.x=-8000 end
			if pos.y>8000 then pos.y=8000 end
			if pos.y<-8000 then pos.y=-8000 end
			FindClearSpaceForUnit( self:GetParent(), pos, true )
		end
		return 0.5
	end,0)
end
--获取在线玩家个数
function  get_online_players()
	local count = 0
	for i=0,9 do
		if PlayerResource:GetConnectionState(i) == 2 then
			count = count+1
		end
	end
	count = math.max(1,count)
	return count
end



--不可驱散
function  modifier_boss_difficulty:IsPurgable()return false end
--永久
function  modifier_boss_difficulty:IsPermanent()return true end
--不隐藏
function  modifier_boss_difficulty:IsHidden()return false end

--血量
function  modifier_boss_difficulty:GetModifierHealthBonus()
	return (get_online_players()-1)*10000+GameRules:GetDOTATime(false,true)/60*250*get_online_players()
end
--魔抗
function  modifier_boss_difficulty:GetModifierMagicalResistanceBonus()return 60 end
--护甲
function  modifier_boss_difficulty:GetModifierPhysicalArmorBonus(keys)return GameRules:GetDOTATime(false,true)*0.017 end
--减cd
function  modifier_boss_difficulty:GetModifierPercentageCooldown(keys)return 70 end
--基础状态抗性
function  modifier_boss_difficulty:GetModifierStatusResistance(keys)return 50 end
--魔法损耗降低
function  modifier_boss_difficulty:GetModifierPercentageManacost(keys)return 100 end

--攻击力
function  modifier_boss_difficulty:GetModifierPreAttack_BonusDamage()return self.boss_amplify*40 end
--技能增强
function  modifier_boss_difficulty:GetModifierSpellAmplify_Percentage()return self.boss_amplify*10 end
--状态抗性
function  modifier_boss_difficulty:GetModifierStatusResistanceStacking()return self.boss_amplify*3 end
--减伤
function  modifier_boss_difficulty:GetModifierIncomingDamage_Percentage()return self.boss_amplify*-2 end
--绝对移速
function  modifier_boss_difficulty:GetModifierMoveSpeed_Absolute()return 400 end



--当死亡
function  modifier_boss_difficulty:OnDeath(keys)
	if keys.unit==self:GetParent() then

		self:GetParent():SetContextThink("think_death",function()
			self:GetParent():Destroy()
		end,60)
		
		--从存活boss表，清除自身
		_G.alive_boss_table[self:GetParent():GetEntityIndex()] = nil
		--如果存活boss表没有值,就60s后刷下一波boss
		if get_table_length(_G.alive_boss_table)==0 then
			GameRules:GetGameModeEntity():SetContextThink("think_spawn_boss",function()
				FireGameEvent("spawn_boss",nil)
			end,60)
			--boss状态，准备重置
			_G.boss_fighting = nil
			_G.boss_read_player = {}
			--显示boss准备按钮
			CustomGameEventManager:Send_ServerToAllClients( "show_boss_read", {} )
		end
		
		
		
		reward = 2000
		for i=0,4 do
			if PlayerResource:GetSelectedHeroEntity(i) then
				local hero = PlayerResource:GetSelectedHeroEntity(i)
				hero:AddExperience(reward,DOTA_ModifyXP_HeroKill,false,true)
				hero:ModifyGold(reward,true,DOTA_ModifyGold_HeroKill)
				EmitSoundOn( "General.Sell", hero)
				ParticleManager:CreateParticle("particles/econ/courier/courier_flopjaw_gold/flopjaw_death_gold.vpcf",PATTACH_OVERHEAD_FOLLOW,hero)
				local particle = ParticleManager:CreateParticle("particles/msg_fx/msg_gold.vpcf",PATTACH_OVERHEAD_FOLLOW,hero)
				ParticleManager:SetParticleControl( particle, 1, Vector( 0,reward, 0 ) )
				ParticleManager:SetParticleControl( particle, 2, Vector( 1,5,0 ) )
				ParticleManager:SetParticleControl( particle, 3, Vector( 255,215,0 ) )
			end
		end
	end
end

--当受到伤害
function  modifier_boss_difficulty:OnTakeDamage(keys)
	if keys.unit == self:GetParent() and keys.inflictor and keys.inflictor:GetName()=="phantom_assassin_fan_of_knives" then
		if keys.unit:GetHealth() > 0 then
			keys.unit:Heal(keys.damage*0.7,nil)
		end
	end
end
--获取表长
function get_table_length(table1)
	local n = 0
	for k,v in pairs(table1)do
		n=n+1
	end
	return n
end