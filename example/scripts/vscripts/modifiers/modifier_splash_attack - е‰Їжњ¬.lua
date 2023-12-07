modifier_splash_attack = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_splash_attack:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

--隐藏
function  modifier_splash_attack:IsHidden()return true end
--不可驱散
function  modifier_splash_attack:IsPurgable()return false end
--永久
function  modifier_splash_attack:IsPermanent()return true end

--当攻击到达
function  modifier_splash_attack:OnAttackLanded(keys)
	if keys.attacker==self:GetParent() then
		ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_n_cowlofice.vpcf",PATTACH_ABSORIGIN,keys.target)
		local damage_units = FindUnitsInRadius(self:GetParent():GetTeamNumber(),keys.target:GetOrigin(),nil,350,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC+1,48,FIND_ANY_ORDER,false)
		for k,v in pairs(damage_units)do
			if(v~=keys.target)then
				local damageTable = {victim=v,attacker=self:GetParent(),damage=keys.damage*0.5,damage_type=DAMAGE_TYPE_PHYSICAL}
				ApplyDamage(damageTable)
			end
		end
	end
end
