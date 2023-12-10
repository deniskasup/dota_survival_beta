require("ability_sound_pool")
require("ability_suite_pool")
require("ultimate_pool")
require("hero_pool")
require("ability_pool")
require("modifiers/link_modifiers")
require("bot/bot_link_modifiers")
require("xp_table")

if PveGameMode == nil then
	PveGameMode = class({})
end


function Precache( context )
	for k,v in pairs(ability_sound_pool) do
	   PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/" .. v, context )
	end
	PrecacheUnitByNameAsync("npc_dota_hero_undying",function()end,nil)
end

function Activate()
	GameRules:SetSafeToLeave(true)
	GameRules.GameMode = PveGameMode()
	GameRules.GameMode:Init()
end

_G.player_hero_pool = {}
_G.player_ability_pool = {}

function PveGameMode:Init()
	player_data={}
	for i=0,9 do
		player_data[tostring(i)]={}
	end
	for i=0,9 do
		player_ability_pool[i]={}
	end
	--刷英雄池
	for i=0,9 do
		_G.player_hero_pool[i] = draw_hero_pool()
		CustomNetTables:SetTableValue( "hero_table",tostring(i) , _G.player_hero_pool[i] )
	end
	--伤害统计表
	_G.stat_data={}
	_G.stat_data.damage={}
	for i=0,4 do
		_G.stat_data.damage[i]=0
	end
	--英雄技能表
	CustomNetTables:SetTableValue("ability_pool","value",ability_pool)

	--设置pre时间
	GameRules:SetPreGameTime(70)
	--强制开始游戏
	GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_init")
	--网表初始化
	init_net_tables()
	--初始化难度
	CustomNetTables:SetTableValue( "map_info", "difficulty",{value=0} )

	local level_table = {}
	local total_xp = 0
	for i=1,30 do
		total_xp = total_xp+xp_table[i]
		level_table[i] = total_xp
	end
	--pve等级上限50J
	if(GetMapName()=="pve")then
		for i = 31,50 do
			total_xp = total_xp+7500+(i-30)*1000
			level_table[i] = total_xp
		end
	end

	--设置经验表
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(level_table)
	--启动自定义升级经验
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)

	link_modifiers()
	bot_link_modifiers()

	--设置游戏队伍
	if GetMapName()=="pve" or GetMapName()=="apex"then
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,0)
	end

	--设置不掉中立装备
	GameRules:GetGameModeEntity():SetAllowNeutralItemDrops(false)
	--启用日夜循环
	GameRules:SetTimeOfDay(0.25)
	--死亡不给tp
	GameRules:GetGameModeEntity():SetGiveFreeTPOnDeath(false)
	--死了不掉钱
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
	--杀死英雄获得恒定经验，恒定金钱
	GameRules:SetUseCustomHeroXPValues(true)
	if GetMapName()=="pve" then
		GameRules:SetUseBaseGoldBountyOnHeroes(true)
	end
	--设置赏金符文生成率
	GameRules:GetGameModeEntity():SetBountyRuneSpawnInterval(60)
	--取消买活cd
	GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled(true)
	--禁止传送中立装备
	GameRules:GetGameModeEntity():SetNeutralStashEnabled(false)
	--简易商店模式
	GameRules:SetUseUniversalShopMode(true)
	--扫描cd
	GameRules:GetGameModeEntity():SetCustomScanCooldown(20)

	if(GetMapName()=="pvp")then
		--团队死斗模式
		border = 8200
	else
		--禁用复活
		GameRules:SetHeroRespawnEnabled(false)
	end
	--初始化技能池
	init_player_ability_pool()
	--注册事件
	CustomGameEventManager:RegisterListener("ability_selected",ability_selected)
	CustomGameEventManager:RegisterListener("select_hero",select_hero)
	CustomGameEventManager:RegisterListener("remove_selected_ability",remove_selected_ability)
	CustomGameEventManager:RegisterListener("test",test)
	CustomGameEventManager:RegisterListener("test2",test2)
	CustomGameEventManager:RegisterListener("test3",test3)
	CustomGameEventManager:RegisterListener("get_hotkey_ability",get_hotkey_ability)
	CustomGameEventManager:RegisterListener("select_difficulty",select_difficulty)
	CustomGameEventManager:RegisterListener("player_pause_game",player_pause_game)
	CustomGameEventManager:RegisterListener("boss_read",boss_read)
	CustomGameEventManager:RegisterListener("player_say_team",player_say_team)
	CustomGameEventManager:RegisterListener("create_particle",create_particle)
	CustomGameEventManager:RegisterListener("up_particles",up_particles)


	CustomGameEventManager:RegisterListener("redraw",redraw)
	CustomGameEventManager:RegisterListener("get_player_hero_pool",get_player_hero_pool)
	CustomGameEventManager:RegisterListener("add_ability_to_player_table",add_ability_to_player_table)
	CustomGameEventManager:RegisterListener("swap_ability",swap_ability)
	CustomGameEventManager:RegisterListener("ability_book",ability_book)
	--监听事件,当游戏状态改变
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(PveGameMode,"OnGameRulesStateChange"), self)
	ListenToGameEvent("spawn_boss", Dynamic_Wrap(PveGameMode,"spawn_boss"), self)
	ListenToGameEvent("start_apex", Dynamic_Wrap(PveGameMode,"start_apex"), self)
	ListenToGameEvent( "player_chat", Dynamic_Wrap( PveGameMode, "OnPlayerChat" ), self )
	ListenToGameEvent( "tree_cut", Dynamic_Wrap( PveGameMode, "OnTreeCut" ), self )
	--命令过滤器
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(PveGameMode, "OrderFilter"), self)
	--神符过滤器
	GameRules:GetGameModeEntity():SetRuneSpawnFilter(Dynamic_Wrap(PveGameMode, "RuneSpawnFilter"), self)
	--金钱过滤器
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(PveGameMode, "GoldFilter"), self)
end

--砍树
function PveGameMode:OnTreeCut(keys)
	-- for k,v in pairs(keys)do
		-- print(k,v)
	-- end
	-- print(keys.killerID)
	if keys.killerID>=0 then
		local hero,reward,pos
		hero = PlayerResource:GetSelectedHeroEntity(keys.killerID)
		reward = 10
		hero:ModifyGold(reward,true,DOTA_ModifyGold_HeroKill)
		EmitSoundOn( "General.Sell", hero)
		pos = hero:GetOrigin()
		pos.z = 250

		local particle = ParticleManager:CreateParticleForPlayer("particles/generic_gameplay/lasthit_coins.vpcf",PATTACH_HEALTHBAR,hero,hero:GetPlayerOwner())
		ParticleManager:SetParticleControl( particle, 1, pos)
		local particle = ParticleManager:CreateParticleForPlayer("particles/msg_fx/msg_gold.vpcf",PATTACH_OVERHEAD_FOLLOW,hero,hero:GetPlayerOwner())
		ParticleManager:SetParticleControl( particle, 1, Vector( 0,reward, 0 ) )
		ParticleManager:SetParticleControl( particle, 2, Vector( 1,2,0 ) )
		ParticleManager:SetParticleControl( particle, 3, Vector( 255,215,0 ) )
	end

end

--回调测试函数
function test(eventSourceIndex, data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	-- local boss = CreateUnitByName("npc_dota_creature_primal_beast",Vector(1800,0,0), true, nil, nil, DOTA_TEAM_CUSTOM_6)
	-- boss:AddNewModifier(boss,nil,"modifier_"..boss:GetUnitName(),nil)
	-- boss:AddNewModifier(boss,nil,"modifier_boss_difficulty",nil)

	_G.boss_difficulty_table={3,5,2,6}
	_G.boss_difficulty_table[0] = 0
	CustomNetTables:SetTableValue( "vote_table", "value",_G.boss_difficulty_table)
	-- CustomGameEventManager:Send_ServerToAllClients( "pve_end", {round=1} )
	-- PrecacheUnitByNameAsync(hero:GetName(),function()end,nil)


	-- a = hero:FindAllModifiers()
	-- for k,v in pairs(a)do
		-- print(v:GetName())
	-- end

	-- a = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf",0,nil)
	-- print(a)
	-- a = Entities:FindAllInSphere(hero:GetOrigin(),600)
	-- for k,v in pairs(a)do
		-- pcall(function()
			-- print(v:GetClassname())
			-- if v:GetClassname() =="info_particle_system" then
				-- v:Destroy()
			-- end
			-- print(v:GetName())
		-- end)
	-- end


	-- hero:Kill(nil,nil)

	-- boss = CreateUnitByName("npc_dota_creature_primal_beast",Vector(1000,0,0), true, nil, nil, 6)
	-- boss:AddNewModifier(boss,nil,"modifier_"..boss:GetUnitName(),nil)
	-- boss:AddNewModifier(boss,nil,"modifier_boss_difficulty",nil)


	-- local dummy =  CreateUnitByName("npc_dota_hero_abaddon",Vector(3000,0,128), true, nil, nil, 3)
	-- dummy:AddNewModifier(nil,nil,"modifier_apex_vision",nil)
	-- CreateItemOnPositionSync(Vector(1000,0,128),CreateItem("item_trusty_shovel",nil,nil))

	-- GameRules:SendCustomMessage("player_abandon",0,0)
	-- http_abandon_game(0)
	-- CustomGameEventManager:Send_ServerToAllClients( "pve_end", {} )
	-- FireGameEvent("start_apex",nil)

	-- FireGameEvent("spawn_boss",nil)
	-- CustomGameEventManager:Send_ServerToAllClients( "pvp_end", {} )
	-- hero:Kill(nil,nil)
	--刷傀儡
	-- CreateUnitByName("npc_dota_hero_target_dummy",Vector(800,0,128), true, nil, nil, 6)
	-- GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,5)
	-- FireGameEvent("spawn_boss",nil)
    -- FireGameEvent("start_apex",nil)
	-- a={}
	-- a["0"]={}
	-- a["0"]["is_month_card"] = false
	-- a["0"]["month_card"] = 1698050574000
	-- a["0"]["vip_time"] = 1698050574000
	-- CustomNetTables:SetTableValue("http_player_data", "table", a)
	-- hero:AddNewModifier(hero,nil,"modifier_wudi",nil)
	-- FireGameEvent("spawn_boss",nil)
	-- hero:AddNewModifier(hero,nil,"modifier_wudi",nil)

end
--回调测试函数2
function test2(eventSourceIndex, data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	-- FireGameEvent("spawn_boss",nil)
	-- 刷傀儡
	CreateUnitByName("npc_dota_hero_target_dummy",Vector(800,0,128), true, nil, nil, 6)
	-- hero:Kill(nil,nil)

	-- hero:ModifyGold(99999,true,DOTA_ModifyGold_HeroKill)
	-- for i=1,30 do
		-- hero:HeroLevelUp(true)
	-- end
	-- CreateItemOnPositionSync(Vector(0,0,128),CreateItem("item_aghanims_shard",nil,nil))
	-- hero:AddNewModifier(hero,nil,"modifier_wudi",nil)
	-- a = hero:FindModifierByName("modifier_item_yasha")
	-- print(a:GetName())
	-- print(a:GetAbility():GetName())
	-- hero:Kill(nil,nil)
	-- FireGameEvent("spawn_boss",nil)
	-- hero:RemoveModifierByName("modifier_item_yasha")
	-- hero:RemoveModifierByName("modifier_item_kaya")
	-- local boss = CreateUnitByName("npc_dota_creature_temple_guardian",Vector(0,0,128), true, nil, nil, 2)
	-- boss:AddNewModifier(boss,nil,"modifier_"..boss:GetUnitName(),nil)
	-- boss:AddNewModifier(boss,nil,"modifier_boss_difficulty",nil)
	-- boss:AddNewModifier(nil,nil,"modifier_vision",nil)
	-- boss:AddNewModifier(boss,nil,"modifier_boss_difficulty",nil)
end

--回调测试函数3
function test3(eventSourceIndex, data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	b = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf",0,nil)
	print(b)
	for i=10,23520 do
		ParticleManager:ReleaseParticleIndex(i)
		ParticleManager:DestroyParticle(i,true)
		print("后端清理特效")
	end
end













--创建金库
function create_gold_mine()
	-- Vector(500,500,128)
	-- local pos = Vector(2000,-4500,128)

	-- local pos = RandomVector(RandomInt(2000,7000))
	local pos = Vector(-2000,-4500,128)
	local gold_mine = CreateUnitByName("npc_dota_gold_mine",pos, false, nil, nil, DOTA_TEAM_CUSTOM_6)
	gold_mine:AddItemByName("item_greed_book")
	gold_mine:RemoveModifierByName("modifier_invulnerable")
	gold_mine:AddNewModifier(gold_mine,nil,"modifier_gold_mine",nil)
end

hero_particles={}
for i=0,9 do
	hero_particles[i]={}
	hero_particles[i]["particles2"]={}
	hero_particles[i]["particles2"]["1"]={}
	hero_particles[i]["particles2"]["2"]={}
	hero_particles[i]["particles2"]["3"]={}
end
--回调函数,创建特效
function create_particle(eventSourceIndex, data)
	--data.particle_index(字符串)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	--如果特效存在,就先移除特效
	if hero_particles[data.PlayerID]["particles2"][data.particle_index]["id"] then
		ParticleManager:DestroyParticle(hero_particles[data.PlayerID]["particles2"][data.particle_index]["id"],true)
	end

	hero_particles[data.PlayerID]["particles2"][data.particle_index]["name"] = data.particle_name
	hero_particles[data.PlayerID]["particles2"][data.particle_index]["attach"] = tonumber(data.particle_attach)
	hero_particles[data.PlayerID]["particles2"][data.particle_index]["id"] = ParticleManager:CreateParticle(data.particle_name,tonumber(data.particle_attach),hero)
end
--上传特效
function up_particles(eventSourceIndex, data)
	local request = CreateHTTPRequestScriptVM("post",host.."up_particles")

	request:SetHTTPRequestHeaderValue("x-api-key", key);
	request:SetHTTPRequestHeaderValue("user_id", tostring(PlayerResource:GetSteamAccountID(data.PlayerID)));
	DeepPrintTable(hero_particles[data.PlayerID])
	request:SetHTTPRequestRawPostBody("application/json", json.encode(hero_particles[data.PlayerID]));

	request:Send(nil)
end
--加载特效
function load_particle(id)
	--如果是vip2
	if player_data[tostring(id)]["is_vip"] then
	-- if true then
		print("开始加载特效")
		DeepPrintTable(player_data)
		local hero = PlayerResource:GetSelectedHeroEntity(id)
		--加载特效
		for k,v in pairs(player_data[tostring(id)].particles2)do
			--如果特效槽位存在，才创建特效
			if v.name then
				hero_particles[id].particles2[k]["name"] = v.name
				hero_particles[id].particles2[k]["attach"] = v.attach
				hero_particles[id].particles2[k]["id"] = ParticleManager:CreateParticle(v.name,v.attach,hero)
			end
		end
	end
end




--监听聊天
_G.gg_table={}
function PveGameMode:OnPlayerChat(keys)
	print("监听聊天指令")
	if keys.text=="-eject"then
		 PlayerResource:GetSelectedHeroEntity(keys.playerid):FindModifierByName("modifier_life_stealer_infest_effect"):GetCaster():RemoveModifierByName("modifier_life_stealer_infest")
	end
	if keys.text=="-gg"then
		GameRules:SendCustomMessage("gg_tip",0,0)
		_G.gg_table[keys.playerid] = 1
		gg()
	end
	if keys.text=="-apex" and GetMapName()=="pve" and not _G.apex_status then
		-- print(PlayerResource:GetSelectedHeroEntity(keys.playerid):GetUnitName())
		GameRules:SendCustomMessage("apex_tip",0,0)
		_G.apex_table[keys.playerid] = 1
		suggest_apex()
	end
end

--开始apex
_G.apex_table={}
function suggest_apex()
	for i=0,4 do
		if PlayerResource:GetConnectionState(i)==2 and not _G.apex_table[i] then
			return nil
		end
	end
	FireGameEvent("start_apex",nil)
end



--投降
function gg()
	for i=0,4 do
		if PlayerResource:GetConnectionState(i)==2 and not _G.gg_table[i] then
			return nil
		end
	end
	GameRules:GetGameModeEntity():StopThink("think_abandon_player")
	CustomGameEventManager:Send_ServerToAllClients( "pvp_end", {} )
	GameRules:SetGameWinner(2)
end

--初始化技能池
_G.all_ability_pool = {}
function init_player_ability_pool()
	for k,v in pairs(ability_pool)do
		for i,j in pairs(v)do
			table.insert(_G.all_ability_pool,j)
		end
	end
	DeepPrintTable(_G.all_ability_pool)
end

--技能书
function ability_book(eventSourceIndex, data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)

	--亚巴顿被动
	if data.name == "abaddon_frostmourne" then local ability = hero:AddAbility(data.name);hero:RemoveModifierByName("modifier_abaddon_frostmourne")
	--如果是蚂蚁被动
	elseif data.name == "weaver_geminate_attack" then local ability = hero:AddAbility(data.name);hero:RemoveModifierByName("modifier_weaver_geminate_attack")
	--如果是米波被动
	elseif data.name == "meepo_geostrike" then local ability = hero:AddAbility(data.name);hero:RemoveModifierByName("modifier_meepo_ransack")
	--如果是技能组
	elseif ability_suite_pool[data.name] then
		for k,v in pairs(ability_suite_pool[data.name])do
			hero:AddAbility(v)
		end
	--如果是普通技能
	else
		hero:AddAbility(data.name)
	end
	--增加技能到玩家技能池
	table.insert(_G.player_ability_pool[data.PlayerID],data.name)
end



--建议技能
player_say_team_cool_down = {}
function player_say_team(eventSourceIndex, data)
	if player_say_team_cool_down[data.PlayerID] then
		--如果网络错误，或者是会员
		if not _G.is_download_user_data or player_data[tostring(data.PlayerID)]["is_vip"] or player_data[tostring(data.PlayerID)]["is_month_card"] then
			SendToConsole(string.format("say_team %s",data.value))
		--非会员
		else
			if Time()-player_say_team_cool_down[data.PlayerID]>5 then
				SendToConsole(string.format("say_team %s",data.value))
				player_say_team_cool_down[data.PlayerID] = Time()
			else
				CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(data.PlayerID),"say_team_cd", {cd=string.format("%.1f",5-Time()+player_say_team_cool_down[data.PlayerID])} )
			end
		end
	--如果是第一次
	else
		SendToConsole(string.format("say_team %s",data.value))
		player_say_team_cool_down[data.PlayerID] = Time()
	end
end














host = "http://localhost:5000/"
host = "https://dota-survivor.web.app/"
key = GetDedicatedServerKeyV2("1")


down_data_count = 0
--下载特效存档
function download_user_data()
	print("开始下载数据")
	--下载次数加1
	down_data_count = down_data_count+1

	local players={}
	for i=0,9 do
		--AccountID为数值
		if(PlayerResource:GetSteamAccountID(i) ~= 0)then
			players[i]=PlayerResource:GetSteamAccountID(i)
		end
	end
	DeepPrintTable(players)

	local request = CreateHTTPRequestScriptVM("post",host.."down_data")

	request:SetHTTPRequestHeaderValue("x-api-key", key)
	request:SetHTTPRequestRawPostBody("application/json", json.encode(players))
	request:Send(function(res)
		--如果下载成功
		if(res.StatusCode==200)then
			print("下载数据成功")
			_G.is_download_user_data = 1
			player_data = json.decode(res.Body)
			CustomNetTables:SetTableValue("http_player_data", "table", player_data)
			DeepPrintTable(player_data)
			--如果放弃比赛
			for k,v in pairs(player_data)do
				--如果放弃了比赛
				print(k,v)
				if v.abandon then
					print("减少英雄池")
					local player_hero_pool = CustomNetTables:GetTableValue( "hero_table",k)
					local count = 0
					for k,v in pairs(player_hero_pool)do
						if(count<20)then
							player_hero_pool[k] = nil
							count = count +1
						end
					end
					DeepPrintTable(player_hero_pool)
					CustomNetTables:SetTableValue( "hero_table",k, player_hero_pool )
					--清空已选技能池
					_G.player_ability_pool[tonumber(k)] ={}
					CustomNetTables:SetTableValue( "selected_abilitys_table",k, {})
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(k)),"finish_redraw",{})
				end
			end
		--如果下载次数小于5
		elseif(down_data_count<=5)then
			print("下载失败,开始重下数据")
			download_user_data()
		else
		end
	end)
end







--开始apex
function PveGameMode:start_apex()
	_G.apex_status = 1
	--禁止买活
	GameRules:GetGameModeEntity():SetBuybackEnabled(false)
	for i=0,4 do
		--如果玩家存在，且没有断开连接
		if PlayerResource:GetSelectedHeroEntity(i) and PlayerResource:GetConnectionState(i)~=4 then
			local hero = PlayerResource:GetSelectedHeroEntity(i)
			hero:SetRespawnPosition(Vector(RandomInt(-8000,8000),RandomInt(-8000,8000),128))
			hero:RespawnHero(false,false)
			hero:AddNewModifier(hero,nil,"modifier_vision",nil)
			hero:AddNewModifier(hero,nil,"modifier_apex_life",nil):SetStackCount(5)
			--改变阵营
			local gold = PlayerResource:GetGold(i)
			hero:ChangeTeam(i+6)
			GameRules:SetCustomGameTeamMaxPlayers(i+6,1)
			PlayerResource:SetCustomTeamAssignment(i,i+6)
			PlayerResource:SetGold(i,gold,true)
			PlayerResource:SetGold(i,0,false)
		end
	end
end


--boss就绪
_G.boss_read_player = {}
function boss_read(eventSourceIndex, data)
	_G.boss_read_player[data.PlayerID] = 1
	for i=0,4 do
		if PlayerResource:GetConnectionState(i) == 2 and not _G.boss_read_player[i]then
		-- if (PlayerResource:GetConnectionState(i) == 2 or PlayerResource:GetConnectionState(i) == 1) and not _G.boss_read_player[i]then
			return nil
		end
	end
	if not _G.boss_fighting then
		GameRules:GetGameModeEntity():StopThink("think_spawn_boss")
		PveGameMode:spawn_boss()
		_G.boss_read_player = {}
	end
end


_G.boss_difficulty = 0
_G.boss_difficulty_table={}
--投票选择难度
function select_difficulty(eventSourceIndex, data)
	-- if PlayerResource:GetPlayerCount()==1 then
		-- difficulty = data.difficulty*5
	-- else
		-- difficulty = data.difficulty
	-- end

	_G.boss_difficulty_table[data.PlayerID] = data.difficulty
	CustomNetTables:SetTableValue( "vote_table", "value",_G.boss_difficulty_table)

	GameRules:SendCustomMessage("difficulty"..data.difficulty,0,0)
	local vote_difficulty = 0
	local vote_number = 0
	for i=9,0,-1 do
		local number = 0
		for k,v in pairs(_G.boss_difficulty_table)do
			if v==i then
				number = number + 1
			end
		end
		if number> vote_number then
			vote_difficulty = i
			vote_number = number
		end
	end

	_G.boss_difficulty = vote_difficulty
	CustomGameEventManager:Send_ServerToAllClients( "selected_difficulty", {difficulty=vote_difficulty} )
	CustomNetTables:SetTableValue( "map_info", "difficulty",{value=vote_difficulty} )
end
--暂停游戏
player_pause_table = {}
function player_pause_game(eventSourceIndex, data)
	if not player_pause_table[data.PlayerID] then
		PauseGame(true)
		player_pause_table[data.PlayerID] = 1
	end
end


--已选英雄池
selected_hero_pool = {}
--回调函数，选择英雄
function select_hero(eventSourceIndex, data)
	--如果英雄被人选了，就不创建英雄
	if selected_hero_pool[data.select_hero_name]~=nil then
		return nil
	--如果已选英雄，就关闭面板
	elseif PlayerResource:GetSelectedHeroEntity(data.PlayerID):GetUnitName()~="npc_dota_hero_init" then
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(data.PlayerID),"select_hero_finish", {} )
		return nil
	else
		--否则把已选英雄加入已选英雄池，并向客户端发出事件移除已选英雄
		selected_hero_pool[data.select_hero_name] = 1
		CustomGameEventManager:Send_ServerToAllClients( "remove_selected_hero", {name=data.select_hero_name} )
		--向客户端发出事件，完成英雄选择，关闭选择面板
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(data.PlayerID),"select_hero_finish", {} )
	end
	--替换英雄
	PlayerResource:ReplaceHeroWith(data.PlayerID, data.select_hero_name, 625, 0)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	--删tp
	hero:FindItemInInventory("item_tpscroll"):Destroy()
	--删技能
	for i=0,10 do
		if hero:GetAbilityByIndex(i) then
			hero:RemoveAbilityByHandle(hero:GetAbilityByIndex(i))
		end
	end

	--添加技能
	for k,v in pairs(_G.player_ability_pool[data.PlayerID]) do
	   if(ability_suite_pool[v] == nil) then
			hero:AddAbility(v)
		else
			for k,v in pairs(ability_suite_pool[v]) do
				--如果没有才加
				if not hero:HasAbility(v)then
					hero:AddAbility(v)
				end
			end
		end
	end
	--添加刷怪+自动施法
	hero:AddAbility("spawn_creep"):ToggleAutoCast()
	--野怪生存光环
	hero:AddAbility("creep_alive"):SetLevel(1)
	--添加互动技能
	hero:AddAbility("abyssal_underlord_portal_warp"):SetLevel(1)
	hero:AddAbility("ability_pluck_famango"):SetLevel(1)
	--清除buff
	local clear_modifiers = {"modifier_bristleback_quillspray_autocast","modifier_axe_counter_helix","modifier_alpha_wolf_critical_strike","modifier_slardar_bash_active","modifier_abaddon_frostmourne","modifier_monkey_king_quadruple_tap","modifier_necrolyte_heartstopper_aura","modifier_bloodseeker_thirst","modifier_legion_commander_moment_of_courage","modifier_naga_siren_rip_tide_counter","modifier_weaver_geminate_attack","modifier_meepo_ransack","modifier_antimage_mana_break","modifier_enchantress_untouchable","modifier_kunkka_tidebringer","modifier_life_stealer_feast","modifier_sand_king_caustic_finale","modifier_spectre_desolate","modifier_slark_essence_shift","modifier_storm_spirit_overload_passive","modifier_viper_poison_attack","modifier_tidehunter_kraken_shell","modifier_riki_backstab","modifier_chen_divine_favor_aura"}
	for k,v in pairs(clear_modifiers)do
		if(hero:HasModifier(v))then
			hero:FindModifierByName(v):Destroy()
		end
	end
	if GetMapName()=="pvp" then hero:AddNewModifier(hero,nil,"modifier_pvp_protect",nil) end
	--如果是apex状态
	if _G.apex_status then
		hero:AddNewModifier(hero,nil,"modifier_apex_life",nil):SetStackCount(5)
		hero:AddNewModifier(hero,nil,"modifier_apex_vision",nil)
	end
	--预载资源
	-- PrecacheUnitByNameAsync(hero:GetName(),function()end,nil)
	--加载特效
	pcall(function()load_particle(data.PlayerID)end)
	--加载vip模型
	hero:SetContextThink("load_vip2_model",function()load_vip2_model(data.PlayerID)end,1)
end

_G.hero_personas_table= {
	npc_dota_hero_axe = {model="models/items/axe/ti9_jungle_axe/axe_bare.vmdl"},
	npc_dota_hero_antimage = {model="models/heroes/antimage_female/antimage_female.vmdl"},
	npc_dota_hero_dragon_knight = {model="models/heroes/dragon_knight_persona/dk_persona_base.vmdl"},
	npc_dota_hero_drow_ranger = {model="models/items/drow/drow_arcana/drow_arcana.vmdl"},
	npc_dota_hero_faceless_void = {model="models/items/faceless_void/faceless_void_arcana/faceless_void_arcana_base.vmdl"},
	npc_dota_hero_invoker = {model="models/heroes/invoker_kid/invoker_kid.vmdl"},
	-- npc_dota_hero_phantom_assassin = {model="models/heroes/phantom_assassin_persona/phantom_assassin_persona.vmdl"},
	npc_dota_hero_pudge = {model="models/heroes/pudge_cute/pudge_cute.vmdl"},
	npc_dota_hero_queenofpain= {model="models/items/queenofpain/queenofpain_arcana/queenofpain_arcana.vmdl"},
	npc_dota_hero_razor = {model="models/items/razor/razor_arcana/razor_arcana.vmdl"},
	npc_dota_hero_skeleton_king = {model="models/items/wraith_king/arcana/wraith_king_arcana.vmdl"},
	npc_dota_hero_spectre = {model="models/items/spectre/spectre_arcana/spectre_arcana_base.vmdl"},
	npc_dota_hero_windrunner = {model="models/items/windrunner/windrunner_arcana/wr_arcana_base.vmdl"},
}
--加载模型
function load_vip2_model(id)
	--如果是vip2
	if player_data[tostring(id)]["is_vip"] then
		local hero = PlayerResource:GetSelectedHeroEntity(id)
		if	hero:GetModelName() == _G.hero_personas_table[hero:GetName()].model then
			return nil
		else
			print("开始加载vip2模型")
			local wearable = CreateUnitByName(hero:GetName().."_personas",hero:GetOrigin(), true, nil, nil,hero:GetTeamNumber())
			wearable:AddNewModifier(wearable,nil,"modifier_wearable",nil)
			wearable:FollowEntity(hero,true)
			hero:SetModelScale(1.5)
			hero:AddNewModifier(hero,nil,"modifier_vip2_model",nil)
		end
	end
end


--命令过滤器
function PveGameMode:OrderFilter(event)
	if GetMapName()=="pvp" and event.order_type==16 and GetAbilityKeyValuesByName(event.shop_item_name).ItemShopTags=="pve" then
		return false
	end
	if event.order_type == 19 and EntIndexToHScript(event.entindex_ability):GetName()~="item_rapier" and (event.entindex_target==16 or event.entindex_target==15 or EntIndexToHScript(event.entindex_ability):GetItemSlot()==15 or EntIndexToHScript(event.entindex_ability):GetItemSlot()==16) then
		--目标不是圣剑
		if(EntIndexToHScript(event.entindex_ability):GetParent():GetItemInSlot(event.entindex_target) and EntIndexToHScript(event.entindex_ability):GetParent():GetItemInSlot(event.entindex_target):GetName()=="item_rapier")then

		else
			EntIndexToHScript(event.entindex_ability):GetParent():SwapItems(EntIndexToHScript(event.entindex_ability):GetItemSlot(),event.entindex_target)
			return false
		end
    end
	return true
end
--神符过滤器
function PveGameMode:RuneSpawnFilter(event)
	for k,v in pairs(event)do
		print(k,v)
	end
	return false
end
--金钱过滤器
function PveGameMode:GoldFilter(event)
	-- for k,v in pairs(event)do
		-- print(k,v)
	-- end
	-- print(EntIndexToHScript(event.source_entindex_const):GetName())
	if GetMapName()=="pve" and event.reason_const==12 and EntIndexToHScript(event.source_entindex_const):IsControllableByAnyPlayer() then
		return nil
	end
	return true
end


--获取玩家的英雄池
function get_player_hero_pool(eventSourceIndex, data)
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID),"get_player_hero_pool",_G.player_hero_pool[data.PlayerID])
end

--回调函数，添加技能到玩家技能表
function add_ability_to_player_table(eventSourceIndex, data)
	print("添加技能到玩家技能表")
	--是否拥有此技能
	function is_has_ability()
		for k,v in pairs(_G.player_ability_pool[data.PlayerID])do
			if v == data.name then return true end
		end
		return false
	end

	if _G.player_ability_pool[data.PlayerID] == nil then _G.player_ability_pool[data.PlayerID] = {} end
	if #(_G.player_ability_pool[data.PlayerID]) < 10 and not is_has_ability() then
		table.insert(_G.player_ability_pool[data.PlayerID],data.name)
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID),"show_selected_ability",{name=data.name})
	end
	CustomNetTables:SetTableValue( "selected_abilitys_table", tostring(data.PlayerID), _G.player_ability_pool[data.PlayerID] )
end

--回调函数，从玩家技能表删除点击技能
function remove_selected_ability(eventSourceIndex, data)
	for k,v in pairs(_G.player_ability_pool[data.PlayerID])do
		if v == data.name then
			table.remove(_G.player_ability_pool[data.PlayerID],k)
		end
	end
	CustomNetTables:SetTableValue( "selected_abilitys_table", tostring(data.PlayerID), _G.player_ability_pool[data.PlayerID] )
end


function think_remind()
	if(not GameRules:IsGamePaused())then
		if(GameRules:GetDOTATime(false,true)>=-10)then
			return 0
		elseif(GameRules:GetDOTATime(false,true)>=-11)then
			EmitAnnouncerSound("announcer_ann_custom_countdown_01")
		elseif(GameRules:GetDOTATime(false,true)>=-12)then
			EmitAnnouncerSound("announcer_ann_custom_countdown_02")
		elseif(GameRules:GetDOTATime(false,true)>=-13)then
			EmitAnnouncerSound("announcer_ann_custom_countdown_03")
		elseif(GameRules:GetDOTATime(false,true)>=-14)then
			EmitAnnouncerSound("announcer_ann_custom_countdown_04")
		elseif(GameRules:GetDOTATime(false,true)>=-15)then
			EmitAnnouncerSound("announcer_ann_custom_countdown_05")
		elseif(GameRules:GetDOTATime(false,true)>=-16)then
			EmitAnnouncerSound("announcer_ann_custom_countdown_06")
		elseif(GameRules:GetDOTATime(false,true)>=-17)then
			EmitAnnouncerSound("announcer_ann_custom_countdown_07")
		elseif(GameRules:GetDOTATime(false,true)>=-18)then
			EmitAnnouncerSound("announcer_ann_custom_countdown_08")
		elseif(GameRules:GetDOTATime(false,true)>=-19)then
			EmitAnnouncerSound("announcer_ann_custom_countdown_09")
		elseif(GameRules:GetDOTATime(false,true)>=-20)then
			EmitAnnouncerSound("announcer_ann_custom_countdown_10")
		else
		end
	end
	return 1
end


--游戏状态
function PveGameMode:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()
	print(newState)
	--进入loading
	if(newState==2)then
		--测试下载
		-- download_user_data()
		--展示选择难度界面
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(0),"show_select_difficulty",nil)
		--玩家信息表,用于在前端展示头像
		for i=0,9 do
			CustomNetTables:SetTableValue( "player_info",tostring(i) , {steam_id = PlayerResource:GetSteamID(i),account_id=PlayerResource:GetSteamAccountID(i)} )
		end
		load_hero_data()
		--如果非官方服务器
		if not IsDedicatedServer() then
			_G.is_download_user_data = 1
		end
		--下载数据
		download_user_data()
		--是否官方服务器存表
		CustomNetTables:SetTableValue("common_table", "IsDedicatedServer", {value=IsDedicatedServer()})
	end
	--进入游戏
	if(newState==DOTA_GAMERULES_STATE_PRE_GAME)then
		GameRules:SpawnNeutralCreeps()
		GameRules:GetGameModeEntity():SetContextThink("think_remind",think_remind,10)
		GameRules:GetGameModeEntity():SetContextThink("think_timer",think_timer,0)
		if GetMapName()=="pvp" then pvp_init() end
		if GetMapName()=="pve" or GetMapName()=="apex" then pve_init() end
		if (GetMapName()=="pvp" and PlayerResource:GetPlayerCount()==10) or (GetMapName()=="pve" and PlayerResource:GetPlayerCount()==5)then
			--开始秒退检测
			GameRules:GetGameModeEntity():SetContextThink("think_abandon_player",think_abandon_player,0)
		end
		--如果是apex地图
		if GetMapName()=="apex" then
			GameRules:GetGameModeEntity():SetContextThink("think_apex",function()init_apex()end,10)
		end
	end

end

--开始apex
function init_apex()
	_G.apex_status = 1
	--禁止买活
	GameRules:GetGameModeEntity():SetBuybackEnabled(false)
	for i=0,4 do
		--随机位置
		local hero = PlayerResource:GetSelectedHeroEntity(i)
		hero:SetRespawnPosition(Vector(RandomInt(-8000,8000),RandomInt(-8000,8000),128))
		hero:RespawnHero(false,false)
		--改变阵营
		GameRules:SetCustomGameTeamMaxPlayers(i+6,1)
		hero:ChangeTeam(i+6)
		PlayerResource:SetCustomTeamAssignment(i,i+6)
	end
end


--秒退放弃检测
function think_abandon_player()
	print("开始秒退检测")
	--如果时间小于3分钟
	if GameRules:GetDOTATime(false,true)<=180 then
		for i=0,9 do
			if PlayerResource:GetConnectionState(i)==4 then
				GameRules:SendCustomMessage("player_abandon",0,0)
				http_abandon_game(i)
				return nil
			end
		end
	else
		return nil
	end
	return 1
end
--记录放弃游戏人员
function http_abandon_game(i)
	local data ={}
	data.id=PlayerResource:GetSteamAccountID(i)
	DeepPrintTable(data)
	local request = CreateHTTPRequestScriptVM("post",host.."abandon_game")

	request:SetHTTPRequestHeaderValue("x-api-key", key);
	request:SetHTTPRequestRawPostBody("application/json", json.encode(data));
	request:Send(nil)
	print("放弃游戏惩罚")
end


--加载英雄数据
function load_hero_data()
	local hero_data_table={}
	for k,v in pairs(hero_pool)do
		local hero = DOTAGameManager:GetHeroDataByName_Script(v)
		hero_data_table[v]={}
		hero_data_table[v]["HeroType"] = hero.AttributePrimary
		hero_data_table[v]["AttributeBaseStrength"]= tostring(hero.AttributeBaseStrength)
		hero_data_table[v]["AttributeBaseAgility"] = tostring(hero.AttributeBaseAgility)
		hero_data_table[v]["AttributeBaseIntelligence"] = tostring(hero.AttributeBaseIntelligence)
		hero_data_table[v]["AttributeStrengthGain"] = string.format("%.2f", hero.AttributeStrengthGain)
		hero_data_table[v]["AttributeAgilityGain"] = string.format("%.2f", hero.AttributeAgilityGain)
		hero_data_table[v]["AttributeIntelligenceGain"] = string.format("%.2f", hero.AttributeIntelligenceGain)

		--攻击力
		if hero.AttributePrimary == "DOTA_ATTRIBUTE_STRENGTH" then
			hero.average_damage = (hero.AttackDamageMin+hero.AttackDamageMax)/2+hero.AttributeBaseStrength
		elseif hero.AttributePrimary == "DOTA_ATTRIBUTE_AGILITY" then
			hero.average_damage = (hero.AttackDamageMin+hero.AttackDamageMax)/2+hero.AttributeBaseAgility
		elseif hero.AttributePrimary == "DOTA_ATTRIBUTE_INTELLECT" then
			hero.average_damage = (hero.AttackDamageMin+hero.AttackDamageMax)/2+hero.AttributeBaseIntelligence
		else
			hero.average_damage = (hero.AttackDamageMin+hero.AttackDamageMax)/2+(hero.AttributeBaseStrength+hero.AttributeBaseAgility+hero.AttributeBaseIntelligence)*0.7
		end
		hero_data_table[v]["AttackDamage"] = string.format("%.0f", hero.average_damage)
		--护甲
		hero_data_table[v]["ArmorPhysical"] = string.format("%.1f", hero.ArmorPhysical + hero.AttributeBaseAgility/6)
		--移速
		hero_data_table[v]["MovementSpeed"] = tostring(hero.MovementSpeed)
		--攻击间隔
		hero_data_table[v]["AttackRate"] = string.format("%.2f", hero.AttackRate)
		--攻速
		hero_data_table[v]["BaseAttackSpeed"] = tostring(hero.BaseAttackSpeed)
		--攻击距离
		hero_data_table[v]["AttackRange"] = tostring(hero.AttackRange)
		--基础生命
		hero_data_table[v]["StatusHealth"] = tostring(hero.StatusHealth + hero.AttributeBaseStrength*22)
		--基础回复
		hero_data_table[v]["StatusHealthRegen"] = string.format("%.1f",hero.StatusHealthRegen + hero.AttributeBaseStrength*0.1)
		--基础魔法
		hero_data_table[v]["StatusMana"] = tostring(hero.StatusMana + hero.AttributeBaseIntelligence*12)
		--基础回魔
		hero_data_table[v]["StatusManaRegen"] = string.format("%.1f",hero.StatusManaRegen + hero.AttributeBaseIntelligence*0.05)

		CustomNetTables:SetTableValue("hero_data_table",v,hero_data_table[v])
	end
end


--pve初始化
function pve_init()
	--刷铲子
	CreateItemOnPositionSync(Vector(1800,0,128),CreateItem("item_trusty_shovel",nil,nil))
	CreateItemOnPositionSync(Vector(0,-1800,128),CreateItem("item_trusty_shovel",nil,nil))
	--刷npc伐木机
	local npc_shredder = CreateUnitByName("npc_shredder",Vector(-7000,2600,128), true, nil, nil, 2)
	npc_shredder:SetAbsAngles(0,-50,0)
	npc_shredder:AddNewModifier(npc_shredder,nil,"modifier_npc_shredder",nil)
	--刷金库
	create_gold_mine()
	--刷魔方
	local cube = CreateUnitByName("npc_dota_miniboss",Vector(2000,-4500,128), false, nil, nil, DOTA_TEAM_CUSTOM_6)
	cube:AddNewModifier(nil,nil,"modifier_cube",nil)
	cube:AddNewModifier(nil,nil,"modifier_vision",nil)
	--刷小boss
	GameRules:GetGameModeEntity():SetContextThink("think_spawn_mini_boss",think_spawn_mini_boss,0)
	--伤害统计网表
	GameRules:GetGameModeEntity():SetContextThink("think_stat_data_damage",function()
		local play_counter = PlayerResource:GetPlayerCount()
		local damage_table = {}
		for i=0,play_counter-1 do
			damage_table[i]=_G.stat_data.damage[i]
		end
		CustomNetTables:SetTableValue("stat_data","damage",damage_table)
		return 1
	end,0)
end
--刷小boss
function think_spawn_mini_boss()
	--5-10分钟
	if GameRules:GetDOTATime(false,true)>=300 and GameRules:GetDOTATime(false,true)<600 and (_G.boss_difficulty>0 or GetMapName()=="apex") then
		local random_number = RandomFloat(1,100)
		--5%概率`
		if random_number>=1 and random_number<=5 then
			local pos = RandomVector(RandomInt(0,7000))
			local boss = CreateUnitByName("npc_dota_mini_boss",pos, true, nil, nil, DOTA_TEAM_CUSTOM_6)
			boss:AddNewModifier(boss,nil,"modifier_"..boss:GetUnitName(),nil)
		end
	end
	return 1
end
--pvp初始化
function pvp_init()
	_G.particle_wall_1 = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_wall_of_replica_2.vpcf",PATTACH_WORLDORIGIN,nil)
	ParticleManager:SetParticleControl( _G.particle_wall_1, 0, Vector( -8192,8192, 128 ) )
	ParticleManager:SetParticleControl( _G.particle_wall_1, 1, Vector( -2571,2571, 128 ) )
	_G.particle_wall_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_wall_of_replica_2.vpcf",PATTACH_WORLDORIGIN,nil)
	ParticleManager:SetParticleControl( _G.particle_wall_2, 0, Vector( 8192,-8192, 128 ) )
	ParticleManager:SetParticleControl( _G.particle_wall_2, 1, Vector( 2571,-2571, 128 ) )
	--胜利条件
	GameRules:GetGameModeEntity():SetContextThink("think_win",think_win_kill,70)
	--标记经验最高
	GameRules:GetGameModeEntity():SetContextThink("think_mark_highest_xp",think_mark_highest_xp,10)
end

--标记经验最高
function think_mark_highest_xp()
	--3分钟以后
	if GameRules:GetDOTATime(false,true)>180 then
	-- if true then
		--标记经验最高
		local strongest_hero = {0,0}
		for i=0,9 do
			local hero = PlayerResource:GetSelectedHeroEntity(i)
			if hero then
				if hero:GetCurrentXP()>strongest_hero[2] then
					strongest_hero[1]=i
					strongest_hero[2]=hero:GetCurrentXP()
				end
			end
		end
		PlayerResource:GetSelectedHeroEntity(strongest_hero[1]):AddNewModifier(nil,nil,"modifier_bloodseeker_thirst_vision",{duration=5})
	end
	return 5
end

--移除boss
--{"npc_dota_hero_bounty_hunter","npc_dota_hero_ancient_apparition"}
_G.all_boss_table={"npc_dota_creature_primal_beast","npc_dota_hero_bounty_hunter","npc_dota_hero_ancient_apparition","npc_dota_creature_ogre_tank_boss","npc_dota_roshan2","npc_dota_creature_ogre_seal","npc_dota_badguys_cny_beast2","npc_dota_creature_temple_guardian","npc_dota_creature_lycan_boss","npc_dota_creature_invoker_boss","npc_dota_hero_beastmaster","npc_dota_hero_alchemist","npc_dota_hero_abyssal_underlord","npc_dota_hero_brewmaster","npc_dota_hero_axe","npc_dota_hero_batrider","npc_dota_hero_bloodseeker","npc_dota_hero_arc_warden","npc_dota_hero_bane","npc_dota_hero_abaddon","npc_dota_hero_antimage","npc_dota_hero_bristleback","npc_dota_hero_centaur","npc_dota_hero_pangolier","npc_dota_hero_undying"}
_G.boss_table={"npc_dota_creature_ogre_tank_boss","npc_dota_roshan2","npc_dota_creature_ogre_seal","npc_dota_badguys_cny_beast2","npc_dota_creature_temple_guardian","npc_dota_creature_lycan_boss","npc_dota_creature_invoker_boss","npc_dota_creature_primal_beast","npc_dota_hero_beastmaster","npc_dota_hero_abyssal_underlord","npc_dota_hero_brewmaster","npc_dota_hero_axe","npc_dota_hero_batrider","npc_dota_hero_bloodseeker","npc_dota_hero_arc_warden","npc_dota_hero_bane","npc_dota_hero_abaddon","npc_dota_hero_antimage","npc_dota_hero_bristleback","npc_dota_hero_centaur","npc_dota_hero_pangolier","npc_dota_hero_undying"}
function think_timer()
	--3分钟,消除特效墙
	if GameRules:GetDOTATime(false,true)>180 and not destroy_particle_wall and GetMapName()=="pvp"	then
		ParticleManager:DestroyParticle(_G.particle_wall_1,true)
		ParticleManager:DestroyParticle(_G.particle_wall_2,true)
		destroy_particle_wall = 1
	end
	--10分钟，刷第一个boss
	if GameRules:GetDOTATime(false,true)>600 and not start_spawn_boss and GetMapName()=="pve" then
		-- local boss = CreateUnitByName("npc_dota_hero_axe",Vector(0,0,128), true, nil, nil, DOTA_TEAM_CUSTOM_6)
		-- boss:AddNewModifier(boss,nil,"modifier_"..boss:GetName(),nil)
		PveGameMode:spawn_boss()
		start_spawn_boss = 1
	end



	return 1
end

--刷n轮boss
_G.boss_round = 1
_G.alive_boss_table = {}
_G.round_boss_table = {}
function PveGameMode:spawn_boss()
	_G.boss_fighting = 1
	--隐藏boss准备按钮
	CustomGameEventManager:Send_ServerToAllClients( "hide_boss_read", {} )
	--第1轮
	if _G.boss_round == 1 then
		--如果还有boss
		if _G.boss_table[1] then
			local pop = table.remove (_G.boss_table,1)
			local boss = CreateUnitByName(pop,Vector(0,0,128), true, nil, nil, DOTA_TEAM_CUSTOM_6)
			boss:AddNewModifier(boss,nil,"modifier_"..boss:GetUnitName(),nil)
			boss:AddNewModifier(boss,nil,"modifier_vision",nil)
			boss:AddNewModifier(boss,nil,"modifier_boss_difficulty",nil)

			_G.alive_boss_table[boss:GetEntityIndex()] = 1
		else
			--如果没有boss，进第二轮
			_G.boss_round = 2
			--复制全boss表
			for k,v in pairs(_G.all_boss_table)do
				table.insert(_G.round_boss_table,v)
			end
			PveGameMode:spawn_boss()
		end
	else
		--第n轮,如果表里还有boss
		if _G.round_boss_table[1] then
			--第n轮就刷n个boss
			for i=1,_G.boss_round do
				local pop = table.remove (_G.round_boss_table,RandomInt(1,#_G.round_boss_table))
				local boss = CreateUnitByName(pop,Vector(0,0,128), true, nil, nil, DOTA_TEAM_CUSTOM_6)
				boss:AddNewModifier(boss,nil,"modifier_"..boss:GetUnitName(),nil)
				boss:AddNewModifier(boss,nil,"modifier_vision",nil)
				boss:AddNewModifier(boss,nil,"modifier_boss_difficulty",nil)

				_G.alive_boss_table[boss:GetEntityIndex()] = 1
			end
		else
			--否则进下一轮
			_G.boss_round = _G.boss_round+1
			--复制全boss表
			for k,v in pairs(_G.all_boss_table)do
				table.insert(_G.round_boss_table,v)
			end
			PveGameMode:spawn_boss()
		end
	end
end



--刷boss
-- function PveGameMode:spawn_boss()
	-- _G.boss_fighting = 1
	-- CustomGameEventManager:Send_ServerToAllClients( "hide_boss_read", {} )
	-- local pop = table.remove (_G.boss_table,1)
	-- local boss = CreateUnitByName(pop,Vector(0,0,128), true, nil, nil, DOTA_TEAM_CUSTOM_6)
	-- boss:AddNewModifier(boss,nil,"modifier_"..boss:GetUnitName(),nil)
	-- boss:AddNewModifier(boss,nil,"modifier_vision",nil)
	-- boss:AddNewModifier(boss,nil,"modifier_boss_difficulty",nil)
-- end

--初始化网表
function init_net_tables()
	local i
	for i=0,9 do
		CustomNetTables:SetTableValue("selected_abilitys_table",tostring(i),{})
	end
end

--抽30英雄池
function draw_hero_pool()
	local total_pool = {}
	local player_pool = {}
	for i=1,124 do
		table.insert(total_pool,i)
	end
	for i=1,30 do
		j = table.remove(total_pool,RandomInt(1,#total_pool))
		table.insert(player_pool,j-1)
	end

	-- if GameRules:IsCheatMode()then
		-- player_pool={}
		-- for i=1,124 do
			-- table.insert(player_pool,i-1)
		-- end
	-- end
	return player_pool
end

--获取热键技能
function get_hotkey_ability(eventSourceIndex, data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local showed_abilities ={}
	for i=0,34 do
		local ability = hero:GetAbilityByIndex(i)
		if ability and not ability:IsHidden() and not ability:IsAttributeBonus() then
			showed_abilities[i] = ability:GetName()
		end
	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID),"get_hotkey_ability",showed_abilities)
end
--交换技能位置
function swap_ability(eventSourceIndex, data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	hero:SwapAbilities(data.ability1,data.ability2,true,true)

end

--击杀胜利
function think_win_kill()
	local score = PlayerResource:GetPlayerCount()*5
	if PlayerResource:GetTeamKills(DOTA_TEAM_GOODGUYS)>=score then
		CustomGameEventManager:Send_ServerToAllClients( "pvp_end", {} )
		return nil
	elseif PlayerResource:GetTeamKills(DOTA_TEAM_BADGUYS)>=score then
		CustomGameEventManager:Send_ServerToAllClients( "pvp_end", {} )
		return nil
	else
	end
	return 1
end
redraw_counter = {}
--重抽英雄池
function redraw(eventSourceIndex, data)
	--网络错误或者会员
	if not _G.is_download_user_data or player_data[tostring(data.PlayerID)]["is_vip"] or player_data[tostring(data.PlayerID)]["is_month_card"] then
		if not redraw_counter[data.PlayerID] then
			redraw_counter[data.PlayerID]=1
			local redraw_hero_pool = draw_hero_pool()
			--如果放弃了比赛
			pcall(function()
				if(player_data[tostring(data.PlayerID)]["abandon"])then
					local count = 0
					for k,v in pairs(redraw_hero_pool)do
						if(count<20)then
							redraw_hero_pool[k] = nil
							count = count +1
						end
					end
				end
			end)
			--英雄池刷新
			CustomNetTables:SetTableValue( "hero_table",tostring(data.PlayerID) , redraw_hero_pool )
			--前端刷新英雄池
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID),"finish_redraw",{})
			--清空已选技能池
			_G.player_ability_pool[data.PlayerID] ={}
			CustomNetTables:SetTableValue( "selected_abilitys_table", tostring(data.PlayerID), {})
		end
	else
	end
end
