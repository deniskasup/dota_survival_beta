lycan_boss_claw_lunge = class({})
LinkLuaModifier( "modifier_lycan_boss_claw_lunge", "abilities/lycan_boss_claw_lunge", LUA_MODIFIER_MOTION_HORIZONTAL )

--------------------------------------------------------------------------------

function lycan_boss_claw_lunge:OnAbilityPhaseStart()
	if IsServer() then
		self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_2 )
		EmitSoundOn( "Hero_Lycan.Howl", self:GetCaster() )

		self.nPreviewFX = ParticleManager:CreateParticle( "particles/darkmoon_creep_warning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
		ParticleManager:SetParticleControl( self.nPreviewFX, 1, Vector( 150, 150, 150 ) )
		ParticleManager:SetParticleControl( self.nPreviewFX, 15, Vector( 188, 26, 26 ) )
	end

	return true
end

--------------------------------------------------------------------------------

function lycan_boss_claw_lunge:OnAbilityPhaseInterrupted()
	if IsServer() then
		self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_2 )
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
	end 
end

--------------------------------------------------------------------------------

function lycan_boss_claw_lunge:OnSpellStart()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, true )
		self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_2 )

		self.lunge_speed = self:GetSpecialValueFor( "lunge_speed" )
		self.lunge_width = self:GetSpecialValueFor( "lunge_width" )
		self.lunge_distance = self:GetSpecialValueFor( "lunge_distance" )
		self.lunge_damage = self:GetSpecialValueFor( "lunge_damage" ) 
		
		--EmitSoundOn( "Hero_Venomancer.PreAttack", self:GetCaster() )

		local vPos = nil
		if self:GetCursorTarget() then
			vPos = self:GetCursorTarget():GetOrigin()
		else
			vPos = self:GetCursorPosition()
		end

		local vDirection = vPos - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		self.vProjectileLocation = self:GetCaster():GetOrigin() -- + ( vDirection * 100 )

		local info = {
			EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
			Ability = self,
			vSpawnOrigin = self.vProjectileLocation, 
			fStartRadius = self.lunge_width,
			fEndRadius = self.lunge_width,
			vVelocity = vDirection * self.lunge_speed,
			fDistance = self.lunge_distance,
			Source = self:GetCaster(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
		}

		ProjectileManager:CreateLinearProjectile( info )

		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_lycan_boss_claw_lunge", {} )
		--EmitSoundOn( "Hero_Bristleback.QuillSpray.Cast", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function lycan_boss_claw_lunge:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
		if hTarget ~= nil then
			if hTarget:IsInvulnerable() == false then
				local damageInfo =
				{
					victim = hTarget,
					attacker = self:GetCaster(),
					damage = self.lunge_damage,
					damage_type = DAMAGE_TYPE_PHYSICAL,
					ability = self,
				}
				ApplyDamage( damageInfo )
			end
		else
			local hBuff = self:GetCaster():FindModifierByName( "modifier_lycan_boss_claw_lunge" )
			if hBuff ~= nil then
				hBuff:Destroy()
			end
		end
	end

	return false
end

--------------------------------------------------------------------------------

function lycan_boss_claw_lunge:OnProjectileThink( vLocation )
	if IsServer() then
		self.vProjectileLocation = vLocation
	end
end

--------------------------------------------------------------------------------
--buff

modifier_lycan_boss_claw_lunge = class({})

--------------------------------------------------------------------------------

function modifier_lycan_boss_claw_lunge:OnCreated( kv )
	if IsServer() then
		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
			return
		end

		self.lunge_width = self:GetAbility():GetSpecialValueFor( "lunge_width" )
	end
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_claw_lunge:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_thirst_owner.vpcf"
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_claw_lunge:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_claw_lunge:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_claw_lunge:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
	end
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_claw_lunge:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end


--------------------------------------------------------------------------------

function modifier_lycan_boss_claw_lunge:CheckState()
	local state =
	{
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_claw_lunge:GetOverrideAnimation( params )
	return ACT_DOTA_RUN_STATUE
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_claw_lunge:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		me:SetOrigin( self:GetAbility().vProjectileLocation )
	end
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_claw_lunge:OnHorizontalMotionInterrupted()
	if IsServer() then
		self.bHorizontalMotionInterrupted = true
	end
end