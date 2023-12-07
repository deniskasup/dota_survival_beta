modifier_pvp_protect = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_pvp_protect:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

--隐藏
function  modifier_pvp_protect:IsHidden()return false end
--不可驱散
function  modifier_pvp_protect:IsPurgable()return false end
--永久
function  modifier_pvp_protect:IsPermanent()return true end
--当创建
function  modifier_pvp_protect:OnCreated()
	self:StartIntervalThink(1)
end

--永久
function  modifier_pvp_protect:OnIntervalThink()
	if IsServer() then
		--3分钟后消失
		if GameRules:GetDOTATime(false,true)>180 then self:Destroy()end
		--如果越界,且不在中心竞技场
		if is_cross_border(self:GetParent()) and self:GetParent():GetOrigin():Length2D()>3600 and self:GetParent():IsAlive() then
			local damageTable = {victim=self:GetParent(),attacker=self:GetParent(),damage=100,damage_type=DAMAGE_TYPE_MAGICAL,ability=nil}
			ApplyDamage(damageTable)
			EmitSoundOn( "DOTA_Item.BladeMail.Damage", self:GetParent() )
		end
	end
end
--是否越界
function  is_cross_border(hero)
	--如果是天辉
	if hero:GetTeamNumber()==2 then
		local pos = hero:GetOrigin()
		if pos.x+pos.y>0 then return true else return false end
	end
	--如果是夜宴
	if hero:GetTeamNumber()==3 then
		local pos = hero:GetOrigin()
		if pos.x+pos.y<0 then return true else return false end
	end
end

