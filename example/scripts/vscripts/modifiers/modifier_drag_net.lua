modifier_drag_net = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_drag_net:DeclareFunctions()
	local funcs = 
	{
		
	}
	return funcs
end

--当创建
function  modifier_drag_net:OnCreated(keys)
	self.caster = self:GetCaster()
	self.unit = self:GetParent()
	self.position = self.caster:GetAbsOrigin()
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/siren_net.vpcf",PATTACH_ABSORIGIN_FOLLOW,self.unit)
	
	self:StartIntervalThink(0.1)
end

--不可驱散
function  modifier_drag_net:IsPurgable()
	return false
end

function modifier_drag_net:OnIntervalThink()
	self:UpdateHorizontalMotion(self.unit, 0.1)
end


function  modifier_drag_net:OnDestroy()
	ParticleManager:DestroyParticle(self.particle,true)
end

--运动器
function  modifier_drag_net:UpdateHorizontalMotion(me, dt)
	if IsServer() then
		if((self.caster:GetAbsOrigin()-self.position):Length()>600)then
			print("距离大于1000")
			self:Destroy()
		elseif((self.unit:GetAbsOrigin()-self.caster:GetAbsOrigin()):Length()>350)then
			self.unit:SetAbsOrigin(self.caster:GetAbsOrigin() +(self.unit:GetAbsOrigin()-self.caster:GetAbsOrigin()):Normalized()*400)
		else
		end
		self.position = self.caster:GetAbsOrigin()
	end
end









