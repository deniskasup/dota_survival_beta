modifier_gold_mine = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_gold_mine:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

--不可驱散
function  modifier_gold_mine:IsPurgable()return false end
--减伤
function  modifier_gold_mine:GetModifierIncomingDamage_Percentage()return -100 end

--当被攻击
function  modifier_gold_mine:OnAttackLanded(keys)
	if keys.target==self:GetParent() then
	-- if keys.target==self:GetParent() then
		local hero,reward,pos
		if keys.attacker:IsHero() then
			hero = keys.attacker
		else
			hero = keys.attacker:GetOwner()
		end
		reward = 4
		hero:ModifyGold(reward,true,DOTA_ModifyGold_HeroKill)
		EmitSoundOn( "General.Sell", hero)
		pos = hero:GetOrigin()
		pos.z = 250
		-- local particle = ParticleManager:CreateParticle("particles/generic_gameplay/lasthit_coins.vpcf",PATTACH_HEALTHBAR,hero)
		-- ParticleManager:SetParticleControl( particle, 1, pos)
		-- local particle = ParticleManager:CreateParticle("particles/msg_fx/msg_gold.vpcf",PATTACH_OVERHEAD_FOLLOW,hero)
		-- ParticleManager:SetParticleControl( particle, 1, Vector( 10,2, 0 ) )
		-- ParticleManager:SetParticleControl( particle, 2, Vector( 1,1,1 ) )
		-- ParticleManager:SetParticleControl( particle, 3, Vector( 255,140,0 ) )
		
		local particle = ParticleManager:CreateParticleForPlayer("particles/generic_gameplay/lasthit_coins.vpcf",PATTACH_HEALTHBAR,hero,hero:GetPlayerOwner())
		ParticleManager:SetParticleControl( particle, 1, pos)
		local particle = ParticleManager:CreateParticleForPlayer("particles/msg_fx/msg_gold.vpcf",PATTACH_OVERHEAD_FOLLOW,hero,hero:GetPlayerOwner())
		ParticleManager:SetParticleControl( particle, 1, Vector( 0,reward, 0 ) )
		ParticleManager:SetParticleControl( particle, 2, Vector( 1,2,0 ) )
		ParticleManager:SetParticleControl( particle, 3, Vector( 255,215,0 ) )
		
		keys.target:SetHealth(keys.target:GetHealth()-1)
		if keys.target:GetHealth()==0 then 
			CreateItemOnPositionSync(keys.target:GetOrigin(),CreateItem("item_greed_book",nil,nil))
			keys.target:Destroy()
		end
	end
end



