axe_culling_blade = class( {} )

--------------------------------------------------------------------------------

function axe_culling_blade:OnSpellStart(keys)
	self.victim = self:GetCursorTarget()
	ParticleManager:CreateParticle( "particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_culling_blade_cast.vpcf", PATTACH_ABSORIGIN,self:GetCaster())
	--如果高于斩杀线，直接击杀
	-- if self:GetSpecialValueFor("damage")*(1+self:GetCaster():GetSpellAmplification(false)) >= self.victim:GetHealth() then
		-- self.victim:Kill(self,self:GetCaster())
	--否则造成伤害
	local damageTable = {victim=self.victim,attacker=self:GetCaster(),damage=self:GetSpecialValueFor("damage"),damage_type=DAMAGE_TYPE_PURE,ability=self}
	ApplyDamage(damageTable)
	if self.victim:IsAlive() then
		self.victim:EmitSound("Hero_Axe.Culling_Blade_Fail")
	else
		-- ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_culling_blade_boost.vpcf", PATTACH_ABSORIGIN,self:GetCaster())
		self.victim:EmitSound("Hero_Axe.Culling_Blade_Success")
		if self.victim:IsRealHero() then
			self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_axe_culling_blade_armor",nil):IncrementStackCount()
			keys.ability:EndCooldown()
		end
	end
end




modifier_axe_culling_blade_armor = class({})
LinkLuaModifier("modifier_axe_culling_blade_armor", "abilities/axe_culling_blade", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_axe_culling_blade_armor:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end
--隐藏
function  modifier_axe_culling_blade_armor:IsHidden()return false end
--无法驱散
function  modifier_axe_culling_blade_armor:IsPurgable() return false end
--永久
function  modifier_axe_culling_blade_armor:IsPermanent() return true end
--护甲
function  modifier_axe_culling_blade_armor:GetModifierPhysicalArmorBonus() 
	return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("armor_per_stack")
end