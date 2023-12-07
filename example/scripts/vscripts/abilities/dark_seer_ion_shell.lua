dark_seer_ion_shell = class( {} )

function dark_seer_ion_shell:GetIntrinsicModifierName()
	return "modifier_dark_seer_ion_shell2"
end

function dark_seer_ion_shell:OnSpellStart()
	local good_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetOrigin(),nil,900,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_BASIC+1,48,FIND_CLOSEST,false)
	for	k,v in pairs(good_hero)do
		if v ~= self:GetCaster() and not v:HasModifier("modifier_dark_seer_ion_shell2") then
			v:AddNewModifier(self:GetCaster(),self,"modifier_dark_seer_ion_shell2",{duration=20})
			return nil
		end
	end
	
	local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetOrigin(),nil,900,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC+1,48,FIND_CLOSEST,false)
	for	k,v in pairs(bad_hero)do
		if not v:HasModifier("modifier_dark_seer_ion_shell2") then
			v:AddNewModifier(self:GetCaster(),self,"modifier_dark_seer_ion_shell2",{duration=20})
			return nil
		end
	end
	
end

--buff
modifier_dark_seer_ion_shell2 = class({})
LinkLuaModifier("modifier_dark_seer_ion_shell2", "abilities/dark_seer_ion_shell", LUA_MODIFIER_MOTION_NONE)

--隐藏
function  modifier_dark_seer_ion_shell2:IsHidden()return false end

function modifier_dark_seer_ion_shell2:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

--当创建
function  modifier_dark_seer_ion_shell2:OnCreated()
	self:StartIntervalThink(1)
	self.particle = ParticleManager:CreateParticle("particles/econ/items/dark_seer/dark_seer_ti8_immortal_arms/dark_seer_ti8_immortal_ion_shell.vpcf",9,self:GetParent())
	EmitSoundOn( "Hero_Dark_Seer.Ion_Shield_Start.TI8", self:GetParent())
end

function  modifier_dark_seer_ion_shell2:OnIntervalThink()
	if IsServer() then
		local caster = self:GetAbility():GetCaster()
		local damage_units = FindUnitsInRadius(caster:GetTeamNumber(),self:GetParent():GetOrigin(),nil,350,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC+1,48,FIND_ANY_ORDER,false)
		for k,v in pairs(damage_units)do
			local damageTable = {victim=v,attacker=caster,ability=self:GetAbility(),damage=self:GetAbility():GetSpecialValueFor("damage_per_second"),damage_type=DAMAGE_TYPE_MAGICAL}
			ApplyDamage(damageTable)
		end
		
	end
end

function  modifier_dark_seer_ion_shell2:OnDestroy()
	ParticleManager:DestroyParticle(self.particle,true)
end

--血量
function  modifier_dark_seer_ion_shell2:GetModifierHealthBonus()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return self:GetAbility():GetSpecialValueFor("bonus_health")
	end
end