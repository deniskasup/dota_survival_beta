item_ability_book = class( {} )


--------------------------------------------------------------------------------

function item_ability_book:OnSpellStart()
	if #player_ability_pool[self:GetCaster():GetPlayerID()] >= 11 then return nil end
	local ability_pool = {}
	--拷贝表
	for k,v in pairs(_G.all_ability_pool)do
		table.insert(ability_pool,v)
	end

	local select_ability = {}
	repeat
		local pop = table.remove(ability_pool,RandomInt(1,#ability_pool))
		if not self:GetCaster():HasAbility(pop) then
			table.insert(select_ability,pop)
		end
	until( #select_ability==5 )
	-- for i=1,5 do
		-- local pop = table.remove(ability_pool,RandomInt(1,#ability_pool))
		-- table.insert(select_ability,pop)
	-- end
	-- DeepPrintTable(select_ability)
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(self:GetCaster():GetPlayerID()),"ability_book",select_ability)
	self:SpendCharge()
end


function item_ability_book:Init()
	
end




