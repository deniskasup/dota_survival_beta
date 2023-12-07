doom_bringer_doom2 = class({})

function doom_bringer_doom2:OnSpellStart()
	-- EmitSoundOn( "Hero_DoomBringer.Doom.Self", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_doom_bringer_doom2",{duration=16})
end

modifier_doom_bringer_doom2 = class({})
LinkLuaModifier("modifier_doom_bringer_doom2", "abilities/doom_bringer_doom2", LUA_MODIFIER_MOTION_NONE)
--当创建
function  modifier_doom_bringer_doom2:OnCreated()
	self:StartIntervalThink(1)
	self:GetCaster():EmitSound("Hero_DoomBringer.Doom.Self")
end
--当销毁
function  modifier_doom_bringer_doom2:OnDestroy()
	self:GetCaster():StopSound("Hero_DoomBringer.Doom.Self")
end
--间隔
function  modifier_doom_bringer_doom2:OnIntervalThink()
	local caster = self:GetParent()
	local units = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetOrigin(),nil,300,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC+1,48,FIND_ANY_ORDER,false)
	for k,v in pairs(units)do
		local damage = self:GetAbility():GetSpecialValueFor("damage")
		local damageTable = {victim=v,attacker=caster,damage=damage,damage_type=DAMAGE_TYPE_PURE,ability=self:GetAbility()}
		ApplyDamage(damageTable)
	end
end
--特效
function  modifier_doom_bringer_doom2:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom_aura.vpcf"
end
--无法驱散
function  modifier_doom_bringer_doom2:IsPurgable() return false end
--无法驱散
function  modifier_doom_bringer_doom2:IsPermanent() return false end
--光环范围
function  modifier_doom_bringer_doom2:GetAuraRadius() return 300 end
--是光环
function  modifier_doom_bringer_doom2:IsAura() return true end
--光环buff
function  modifier_doom_bringer_doom2:GetModifierAura() return "modifier_doom_bringer_doom2_debuff" end
--光环对象
function  modifier_doom_bringer_doom2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function  modifier_doom_bringer_doom2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function  modifier_doom_bringer_doom2:GetAuraSearchFlags() return 48 end

modifier_doom_bringer_doom2_debuff = class({})
LinkLuaModifier("modifier_doom_bringer_doom2_debuff", "abilities/doom_bringer_doom2", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_doom_bringer_doom2_debuff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
	}
	return funcs
end
function modifier_doom_bringer_doom2_debuff:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end
--无法驱散
function  modifier_doom_bringer_doom2_debuff:IsPurgable() return false end
--回复增强
function  modifier_doom_bringer_doom2_debuff:GetModifierHPRegenAmplify_Percentage(keys)return -90 end
--吸血增强
function  modifier_doom_bringer_doom2_debuff:GetModifierLifestealRegenAmplify_Percentage(keys)return -90 end
--法吸增强
function  modifier_doom_bringer_doom2_debuff:GetModifierSpellLifestealRegenAmplify_Percentage(keys)return -90 end
--治疗增强
function  modifier_doom_bringer_doom2_debuff:GetModifierHealAmplify_PercentageTarget(keys)return -90 end

