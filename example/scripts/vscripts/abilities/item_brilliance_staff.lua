item_brilliance_staff = class( {} )

--------------------------------------------------------------------------------

function item_brilliance_staff:GetIntrinsicModifierName()
	return "item_brilliance_staff_passive"
end



item_brilliance_staff_passive = class({})
LinkLuaModifier("item_brilliance_staff_passive", "abilities/item_brilliance_staff", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function item_brilliance_staff_passive:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
	return funcs
end
--隐藏
function  item_brilliance_staff_passive:IsHidden()return false end
--无法驱散
function  item_brilliance_staff_passive:IsPurgable() return false end

--智力
function  item_brilliance_staff_passive:GetModifierBonusStats_Intellect() return 40 end

--增强无效技能
useless_ability={necrolyte_heartstopper_aura2=1,bloodseeker_blood_mist2=1,tinker_laser=1,item_revenants_brooch=1,razor_eye_of_the_storm=1,bloodseeker_rupture=1,nyx_assassin_spiked_carapace=1,obsidian_destroyer_sanity_eclipse=1,centaur_double_edge=1,centaur_return=1,chaos_knight_chaos_strike=1,muerta_pierce_the_veil=1,witch_doctor_maledict=1,ursa_fury_swipes=1,spirit_breaker_greater_bash=1,spectre_dispersion=1,silencer_last_word=1,sandking_caustic_finale=1,omniknight_hammer_of_purity=1,nyx_assassin_jolt=1,necrolyte_reapers_scythe=1,elder_titan_earth_splitter=1,skywrath_mage_arcane_bolt=1,abyssal_underlord_firestorm=1,doom_bringer_infernal_blade=1,enigma_midnight_pulse=1,huskar_life_break=1,phantom_assassin_fan_of_knives=1,shadow_demon_soul_catcher=1,silencer_glaives_of_wisdom=1,winter_wyvern_arctic_burn=1,life_stealer_feast=1,zuus_arc_lightning=1,obsidian_destroyer_arcane_orb=1}
--技能增强
function  item_brilliance_staff_passive:GetModifierSpellAmplify_Percentage(keys)
	if keys.inflictor and not useless_ability[keys.inflictor:GetName()] then
		-- print("有效")
		return self:GetParent():GetIntellect()*self:GetAbility():GetSpecialValueFor("amp_ratio")
	end
	-- print("无效")
end