item_multicast_staff = class( {} )

--------------------------------------------------------------------------------

function item_multicast_staff:GetIntrinsicModifierName()
	return "modifier_item_multicast_staff"
end



modifier_item_multicast_staff = class({})
LinkLuaModifier("modifier_item_multicast_staff", "abilities/item_multicast_staff", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_item_multicast_staff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
	return funcs
end
--隐藏
function  modifier_item_multicast_staff:IsHidden()return false end
--无法驱散
function  modifier_item_multicast_staff:IsPurgable() return false end
--永久
function  modifier_item_multicast_staff:IsPermanent() return true end
--智力
function  modifier_item_multicast_staff:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("intellect") end
--护甲
function  modifier_item_multicast_staff:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor") end
--技能增强
function  modifier_item_multicast_staff:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("SpellAmp") end


--当施法时,不适用多重
no_support_abilitys = {primal_beast_trample=1,primal_beast_uproar=1,death_prophet_carrion_swarm=1,obsidian_destroyer_arcane_orb=1,tusk_snowball=1}
function modifier_item_multicast_staff:OnAbilityExecuted( keys )
	--如果是小技能，非装备
	if keys.unit == self:GetParent() and keys.ability:GetAbilityType()==0 and not keys.ability:IsItem()then
		--不支持技能池
		--小松鼠大，大锤 丢锤子，冰魂大,伐木机飞盘,大牛 魂，雪球,真眼，假眼
		if no_support_abilitys[keys.ability:GetName()] then
			return nil
		end
		local random_int = RandomInt(1,100)
		
		if random_int<=self:GetAbility():GetSpecialValueFor("chance") and not keys.ability.multicast then
			keys.ability.multicast = true
			
			EmitSoundOn("Hero_OgreMagi.Fireblast.x1",keys.unit)
			local particle = ParticleManager:CreateParticle("particles/econ/items/ogre_magi/ogre_magi_jackpot/ogre_magi_jackpot_multicast.vpcf",PATTACH_OVERHEAD_FOLLOW,keys.unit)
			ParticleManager:SetParticleControl( particle, 1, Vector( 2,1, 1 ) )
			
			keys.unit:CastAbilityImmediately(keys.ability,0)
			
			keys.ability:SetContextThink("think_multicast",function()
				-- print("多重施法中")
				keys.ability.multicast = false
			end,0.1)
		end
	end
end