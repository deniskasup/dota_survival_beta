modifier_cube = class({})

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_cube:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end
--不可驱散
function  modifier_cube:IsPurgable()return false end
--永久
function  modifier_cube:IsPermanent()return true end
--当死亡
function  modifier_cube:OnDeath(keys)
	if keys.unit == self:GetParent() then
		CreateItemOnPositionSync(self:GetParent():GetOrigin(),CreateItem("item_aghanims_shard",nil,nil))
	end
end



