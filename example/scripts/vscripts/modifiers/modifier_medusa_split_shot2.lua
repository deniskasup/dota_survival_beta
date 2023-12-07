modifier_medusa_split_shot2 = class( {} )

--------------------------------------------------------------------------------

function modifier_medusa_split_shot2:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

--不可驱散
function  modifier_medusa_split_shot2:IsPurgable()return false end
--隐藏
function  modifier_medusa_split_shot2:IsHidden()return true end
--永久
function  modifier_medusa_split_shot2:IsPermanent()return true end
--当buff创建
function  modifier_medusa_split_shot2:OnCreated(keys)
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
end


function modifier_medusa_split_shot2:OnAttackLanded(keys)
	if keys.attacker == self.caster and keys.target:IsAlive() then
		local damage_units = FindUnitsInRadius(keys.attacker:GetTeamNumber(),keys.attacker:GetCenter(),nil,keys.attacker:Script_GetAttackRange()+500,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC+1,48,FIND_CLOSEST,false)
		local damage_counter = 0
		for k,v in pairs(damage_units)do
			if(v~=keys.target)then
				local damageTable = {victim=v,attacker=keys.attacker,damage=keys.attacker:GetAverageTrueAttackDamage(nil)*0.8,damage_type=DAMAGE_TYPE_PHYSICAL}
				ApplyDamage(damageTable)
				damage_counter = damage_counter + 1
				if(damage_counter==self.ability:GetSpecialValueFor("arrow_count"))then
					return nil
				end
			end
		end
	end
end

