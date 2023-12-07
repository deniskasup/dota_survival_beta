creep_alive = class( {} )

--------------------------------------------------------------------------------

function creep_alive:GetIntrinsicModifierName()
	
end


function creep_alive:Init()
	local creep_alive_table = {npc_dota_dark_troll_warlord_skeleton_warrior=1,npc_dota_neutral_kobold2=1,npc_dota_neutral_kobold_tunneler2=1,npc_dota_neutral_kobold_taskmaster2=1}
	
	self:SetContextThink("think_set_level",function() self:SetLevel(1) end,0)
	
	
	self:SetContextThink("think_creep_alive",function()
		if self:GetCaster():IsAlive() then
			local creep = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetCenter(),nil,1800,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_CREEP,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
			for k,v in pairs(creep)do
				if creep_alive_table[v:GetUnitName()] then
					v:AddNewModifier(self:GetCaster(),nil,"modifier_creep_alive2",{duration=1.5})
				end
			end
		end
		return 1
	end,0)
	
	
end



modifier_creep_alive2 = class({})
LinkLuaModifier("modifier_creep_alive2", "abilities/creep_alive", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function modifier_creep_alive2:DeclareFunctions()
	local funcs = 
	{
	}
	return funcs
end
--隐藏
function  modifier_creep_alive2:IsHidden()return true end
--无法驱散
function  modifier_creep_alive2:IsPurgable() return false end
--当销毁
function  modifier_creep_alive2:OnDestroy()
	if IsServer() and self:GetParent():IsAlive() then
		self:GetParent():Kill(nil,nil)
	end
end
--当创建
function  modifier_creep_alive2:OnCreated()
	
end