modifier_apex_life = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_apex_life:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

--不可驱散
function  modifier_apex_life:IsPurgable()return false end
--永久
function  modifier_apex_life:IsPermanent()return true end
--不隐藏
function  modifier_apex_life:IsHidden()return false end
--图标
function  modifier_apex_life:GetTexture()return "item_aegis" end
--当死亡
function  modifier_apex_life:OnDeath(event)
	if event.unit == self:GetParent() then
		if self:GetStackCount()>0 then
			self:DecrementStackCount()
			local particle = ParticleManager:CreateParticle("particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe_start.vpcf",1,self:GetParent())
			ParticleManager:SetParticleControl( particle, 1, Vector( self:GetParent():GetOrigin().x,self:GetParent():GetOrigin().y, 128 ) )
			EmitSoundOn( "Hero_Necrolyte.ReapersScythe.Target", self:GetParent() )
			self:GetParent():SetRespawnPosition(Vector(RandomInt(-8000,8000),RandomInt(-8000,8000),128))
			self:GetParent():SetContextThink("think_respawn",function()self:GetParent():RespawnHero(false,false)end,5)
		end
	end

end

--当创建
function  modifier_apex_life:OnCreated()
	-- self:StartIntervalThink(1)
end
--think
function  modifier_apex_life:OnIntervalThink()
	self:GetParent():RemoveModifierByName("modifier_book_of_strength")
	self:GetParent():RemoveModifierByName("modifier_book_of_intelligence")
	self:GetParent():RemoveModifierByName("modifier_book_of_agility")
end

