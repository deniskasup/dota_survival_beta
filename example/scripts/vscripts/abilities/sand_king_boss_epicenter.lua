sand_king_boss_epicenter = class({})
LinkLuaModifier( "modifier_sand_king_boss_epicenter", "modifiers/modifier_sand_king_boss_epicenter", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function sand_king_boss_epicenter:OnAbilityPhaseStart()
	if IsServer() then
		self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_sandking/sandking_epicenter_tell.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_tail", self:GetCaster():GetOrigin(), true )
		EmitSoundOn( "CNY_Beast.Ability.Cast", self:GetCaster() )
		self.nChannelFX = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/deep_magma/deep_magma_cyan/deep_magma_cyan_echoslam_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	end
	return true
end

--------------------------------------------------------------------------------

function sand_king_boss_epicenter:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
	end
end

--------------------------------------------------------------------------------

function sand_king_boss_epicenter:GetChannelAnimation()
	return ACT_DOTA_VICTORY
end

--------------------------------------------------------------------------------

function sand_king_boss_epicenter:GetPlaybackRateOverride()
	return 1
end

--------------------------------------------------------------------------------

function sand_king_boss_epicenter:OnSpellStart()
	if IsServer() then
		EmitSoundOn( "CNY_Beast.GlobalAbility.Cast", self:GetCaster() )
		self.Projectiles = {}
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_sand_king_boss_epicenter", {} )
	end
end

--------------------------------------------------------------------------------

function sand_king_boss_epicenter:OnChannelFinish( bInterrupted )
	if IsServer() then
		self:GetCaster():RemoveModifierByName( "modifier_sand_king_boss_epicenter" )
		ParticleManager:DestroyParticle( self.nChannelFX, false )
	end
end

--------------------------------------------------------------------------------

function sand_king_boss_epicenter:OnProjectileThinkHandle( nProjectileHandle )
	if IsServer() then
		local projectile = nil
		for _,proj in pairs( self.Projectiles ) do
			if proj ~= nil and proj.handle == nProjectileHandle then
				projectile = proj
			end
		end
		if projectile ~= nil then
			local flRadius = ProjectileManager:GetLinearProjectileRadius( nProjectileHandle )
			ParticleManager:SetParticleControl( projectile.nFXIndex, 2, Vector( flRadius, flRadius, 0 ) )
		end	
	end
end

--------------------------------------------------------------------------------

function sand_king_boss_epicenter:OnProjectileHitHandle( hTarget, vLocation, nProjectileHandle )
	if IsServer() then
		if hTarget ~= nil then
			local blocker_radius = self:GetSpecialValueFor( "blocker_radius" )


			local vFromCaster = vLocation - self:GetCaster():GetOrigin()
			vFromCaster = vFromCaster:Normalized()
			local vToCasterPerp  = Vector( -vFromCaster.y, vFromCaster.x, 0 )

			local vLoc1 = vLocation + vFromCaster * 200
			local vLoc2 = vLocation + vFromCaster * 200 + vToCasterPerp * 65
			local vLoc3 = vLocation + vFromCaster * 200 + vToCasterPerp * -65

			EmitSoundOn( "Hero_Mars.Attack", hTarget )
			

			local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self:GetCaster(), blocker_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
			for _,enemy in pairs( enemies ) do
				if enemy ~= nil and enemy:IsInvulnerable() == false and enemy:IsMagicImmune() == false then
					local kv =
					{
						center_x = hTarget:GetOrigin().x,
						center_y = hTarget:GetOrigin().y,
						center_z = hTarget:GetOrigin().z,
						should_stun = true, 
						duration = 0.25,
						knockback_duration = 0.25,
						knockback_distance = 250,
						knockback_height = 125,
					}
					enemy:AddNewModifier( self:GetCaster(), self, "modifier_knockback", kv )
					local damageInfo =
					{
						victim = enemy,
						attacker = self:GetCaster(),
						damage = self:GetSpecialValueFor( "damage" ),
						damage_type = DAMAGE_TYPE_PURE,
						ability = self,
					}
					ApplyDamage( damageInfo )
				end
			end
		end

		local projectile = nil
		for _,proj in pairs( self.Projectiles ) do
			if proj ~= nil and proj.handle == nProjectileHandle then
				projectile = proj
			end
		end
		if projectile ~= nil then
			ParticleManager:DestroyParticle( projectile.nFXIndex, false )
		end	
	end

	return true
end

--------------------------------------------------------------------------------