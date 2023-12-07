modifier_famango = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_famango:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
	return funcs
end

--图标
function  modifier_famango:GetTexture()return "item_famango" end
--不可驱散
function  modifier_famango:IsPurgable()return false end
--永久
function  modifier_famango:IsPermanent()return true end
--力量
function  modifier_famango:GetModifierBonusStats_Strength()return self:GetStackCount() end
--敏捷
function  modifier_famango:GetModifierBonusStats_Agility()return self:GetStackCount() end
--智力
function  modifier_famango:GetModifierBonusStats_Intellect()return self:GetStackCount() end



