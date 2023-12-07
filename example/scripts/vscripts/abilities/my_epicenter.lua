my_epicenter = class({})

--------------------------------------------------------------------------------

function my_epicenter:OnAbilityPhaseStart()
	if IsServer() then
		EmitSoundOn( "CNY_Beast.Ability.Cast", self:GetCaster() )
		ParticleManager:CreateParticle( "particles/econ/items/earthshaker/deep_magma/deep_magma_cyan/deep_magma_cyan_echoslam_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	end
	return true
end

function my_epicenter:GetChannelAnimation()
	return ACT_DOTA_VICTORY
end


--------------------------------------------------------------------------------

function my_epicenter:OnSpellStart()
	if IsServer() then
		EmitSoundOn( "CNY_Beast.GlobalAbility.Cast", self:GetCaster() )
		self:GetCaster():SetContextThink("think_epicenter",function()

			EmitSoundOn( "Hero_EarthSpirit.Magnetize.StoneBolt", self:GetCaster() )
			for i=1,15 do
				local info = 
				{
					Ability = self,
					vSpawnOrigin = self:GetCaster():GetOrigin(), 
					fStartRadius = 110,
					fEndRadius = 110,
					fDistance = 5000,
					
					vVelocity = RandomVector(1) * 1000,
					
					Source = self:GetCaster(),
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave_2.vpcf"
				}
				ProjectileManager:CreateLinearProjectile( info )
			end
				
			if self:IsChanneling() then
				return 1
			end
		end,0)
	end
end

function my_epicenter:OnProjectileHit(target,pos)
	EmitSoundOn( "Hero_Mars.Attack", target )
	local kv =
	{
		center_x = target:GetOrigin().x,
		center_y = target:GetOrigin().y,
		center_z = target:GetOrigin().z,
		should_stun = true, 
		duration = 0.25,
		knockback_duration = 0.25,
		knockback_distance = 250,
		knockback_height = 125,
	}
	target:AddNewModifier( self:GetCaster(), self, "modifier_knockback", kv )
	local damageInfo =
	{
		victim = target,
		attacker = self:GetCaster(),
		damage = 500,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self,
	}
	ApplyDamage( damageInfo )
end
