bear_cd = class( {} )

--------------------------------------------------------------------------------

function bear_cd:GetIntrinsicModifierName()
	if not self:GetCaster():IsIllusion() then
		return "modifier_bear_cd"
	end
end

function bear_cd:Init()
	self:SetContextThink("think_set_level",function() self:SetLevel(1) end,0)
end



modifier_bear_cd = class({})
LinkLuaModifier("modifier_bear_cd", "abilities/bear_cd", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------


function modifier_bear_cd:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE
	}
	return funcs
end
--隐藏
function  modifier_bear_cd:IsHidden()return false end
--无法驱散
function  modifier_bear_cd:IsPurgable() return false end
--减cd
function  modifier_bear_cd:GetModifierPercentageCooldown(keys)return 70 end
--魔法损耗降低
function  modifier_bear_cd:GetModifierPercentageManacost(keys)return 100 end
--当buff创建
function  modifier_bear_cd:OnCreated(keys)
	--自动物品
	auto_item = {"item_monkey_king_bar2","item_phase_boots_2","item_phase_boots","item_havoc_hammer","item_shivas_guard","item_eternal_shroud","item_lotus_orb","item_mask_of_madness","item_mjollnir","item_hood_of_defiance","item_pipe","item_thunder_armor"}
	--自动物品（对英雄施法）
	auto_item_hero = {"item_gunblade","item_orchid","item_veil_of_discord","item_bloodthorn","item_drag_net","item_dagon","item_dagon_2","item_dagon_3","item_dagon_4","item_dagon_5","item_nullifier","item_shackles_dagger"}
	--自动物品（对小兵施法）
	auto_item_creep = {"item_shackles_dagger","item_dagon","item_dagon_2","item_dagon_3","item_dagon_4","item_dagon_5"}
	
	
	if not self:GetCaster():IsIllusion() then
	
		self:GetCaster():SetContextThink("think_cast",function()
			--寻找目标
			local enemy = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetLocalOrigin(),nil,700,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_CREEP+1,48,FIND_CLOSEST,false)
			local good_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetLocalOrigin(),nil,800,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_HERO,48,FIND_CLOSEST,false)
			local creep = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetLocalOrigin(),nil,700,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_CREEP,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
			local bad_hero = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetLocalOrigin(),nil,800,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
			
			if(not self:GetCaster():IsChanneling() and self:GetCaster():IsAlive())then
				--自动物品
				for k,v in pairs(auto_item)do
					if(self:GetCaster():HasItemInInventory(v) and self:GetCaster():FindItemInInventory(v):IsCooldownReady())then
						pcall(function()self:GetCaster():SetCursorCastTarget(self:GetCaster())end)
						self:GetCaster():CastAbilityImmediately(self:GetCaster():FindItemInInventory(v),0)
					end
				end
				--对最近英雄使用装备
				for k,v in pairs(auto_item_hero)do
					if(self:GetCaster():HasItemInInventory(v) and self:GetCaster():FindItemInInventory(v):IsCooldownReady()and bad_hero[1])then
						pcall(function()self:GetCaster():SetCursorCastTarget(bad_hero[1])end)
						self:GetCaster():CastAbilityImmediately(self:GetCaster():FindItemInInventory(v),0)
					end
				end
				
				--对最近小兵使用装备
				for k,v in pairs(auto_item_creep)do
					if(self:GetCaster():HasItemInInventory(v) and self:GetCaster():FindItemInInventory(v):IsCooldownReady()and enemy[1])then
						pcall(function()self:GetCaster():SetCursorCastTarget(enemy[1])end)
						self:GetCaster():CastAbilityImmediately(self:GetCaster():FindItemInInventory(v),0)
					end
				end
				
				--点金
				if self:GetCaster():HasItemInInventory("item_hand_of_midas")  then
					local casting_ability = self:GetCaster():FindItemInInventory("item_hand_of_midas")
					if(casting_ability:IsCooldownReady() and creep[1])then
						pcall(function()self:GetCaster():SetCursorCastTarget(creep[1])end)
						self:GetCaster():CastAbilityImmediately(casting_ability,0)
					end
				end
				
				--海盗帽
				if self:GetCaster():HasItemInInventory("item_pirate_hat2")  then
					local casting_ability = self:GetCaster():FindItemInInventory("item_pirate_hat2")
					if(casting_ability:IsCooldownReady() and creep[1])then
						pcall(function()self:GetCaster():SetCursorCastTarget(creep[1])end)
						self:GetCaster():CastAbilityImmediately(casting_ability,0)
					end
				end
			end
			--掉下地图
			if self:GetCaster():GetCenter().z<-1000 then
				-- self:GetCaster():Kill(nil,nil)
				local pos = self:GetCaster():GetOrigin()
				if pos.x>8000 then pos.x=8000 end
				if pos.x<-8000 then pos.x=-8000 end
				if pos.y>8000 then pos.y=8000 end
				if pos.y<-8000 then pos.y=-8000 end
				FindClearSpaceForUnit( self:GetCaster(), pos, true )
			end
			return 0.3
		end, 0)
	
	end
end