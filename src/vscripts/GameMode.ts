import {reloadable} from "./lib/tstl-utils";
import {heroSelectionTime} from "./constants/gameMode";

import {arrayShuffle} from "./helpers/arrayShuffle";
import {getWaveNumberFromTime} from "./helpers/getWaveNumberFromTime";
import {wavesConfigByWaveNumber} from "./constants/creeps";
import getRandomInRange from "./helpers/getRandomInRange";

LinkLuaModifier("modifier_spell_autocast", "modifiers/global/modifier_spell_autocast", LuaModifierType.LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_base_settings", "modifiers/global/modifier_base_settings", LuaModifierType.LUA_MODIFIER_MOTION_NONE)


declare global {
    interface CDOTAGameRules {
        Addon: GameMode;
    }
}

@reloadable
export class GameMode {
    public static Precache(this: void, context: CScriptPrecacheContext) {
        PrecacheResource("particle", "particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf", context);
        PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_meepo.vsndevts", context);
    }

    public static Activate(this: void) {
        // When the addon activates, create a new instance of this GameMode class.
        GameRules.Addon = new GameMode();
    }

    constructor() {
        this.configure();

        // Register event listeners for dota engine events
        ListenToGameEvent("game_rules_state_change", () => this.OnStateChange(), undefined);
        ListenToGameEvent("npc_spawned", (event) => this.OnNpcSpawned(event), undefined);
        ListenToGameEvent("dota_on_hero_finish_spawn", (event) => this.OnHeroPlayerHeroSpawned(event), undefined)

        // Register event listeners for events from the UI
        // CustomGameEventManager.RegisterListener("ui_panel_closed", (_, data) => {
        //     print(`Player ${data.PlayerID} has closed their UI panel.`);
        //
        //     // Respond by sending back an example event
        //     const player = PlayerResource.GetPlayer(data.PlayerID)!;
        //     CustomGameEventManager.Send_ServerToPlayer(player, "example_event", {
        //         myNumber: 42,
        //         myBoolean: true,
        //         myString: "Hello!",
        //         myArrayOfNumbers: [1.414, 2.718, 3.142]
        //     });
        //
        //     // Also apply the panic modifier to the sending player's hero
        //     const hero = player.GetAssignedHero();
        //     hero.AddNewModifier(hero, undefined, modifier_panic.name, { duration: 5 });
        // });
    }

    private configure(): void {
        GameRules.SetCustomGameTeamMaxPlayers(DOTATeam_t.DOTA_TEAM_GOODGUYS, 3);
        GameRules.SetCustomGameTeamMaxPlayers(DOTATeam_t.DOTA_TEAM_BADGUYS, 0);

        GameRules.SetShowcaseTime(0);
        GameRules.SetStrategyTime(0);
        GameRules.SetHeroSelectionTime(heroSelectionTime);
    }

    public OnStateChange(): void {
        const state = GameRules.State_Get();

        if (state === DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP) {
            // Automatically skip setup in tools
            if (IsInToolsMode()) {
                Timers.CreateTimer(3, () => {
                    GameRules.FinishCustomGameSetup();
                });
            }
        }

        // Start game once pregame hits
        if (state === DOTA_GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS) {
            Timers.CreateTimer(0.2, () => this.StartGame());
        }
    }

    private StartGame(): void {
        Timers.CreateTimer(5, () => this.SpawnCreeps())
    }

    // Called on script_reload
    public Reload() {
        print("Script reloaded!");

        // Do some stuff here
    }

    private OnNpcSpawned(event: NpcSpawnedEvent) {

    }

    private OnHeroPlayerHeroSpawned(data: GameEventProvidedProperties & DotaOnHeroFinishSpawnEvent) {
        const hero = HeroList.GetAllHeroes().find(hero => hero.GetEntityIndex() === data.heroindex)

        if (hero) {
            hero?.AddNewModifier(hero, undefined, 'modifier_spell_autocast', undefined)
            hero?.AddNewModifier(hero, undefined, 'modifier_base_settings', undefined)
        }
    }

    private SpawnCreeps() {
        const heroes = HeroList.GetAllHeroes()
        const spawnChecker = Entities.FindByName(undefined, 'creeps_count_checker')
        const waveNumber = getWaveNumberFromTime(GameRules.GetDOTATime(false, true))
        print(waveNumber)
        const waveConfig = wavesConfigByWaveNumber[waveNumber]

        //TODO: вынести в хелпер
        const aliveCreepsCount = FindUnitsInRadius(
            DOTATeam_t.DOTA_TEAM_GOODGUYS,
            spawnChecker!.GetAbsOrigin(),
            undefined,
            20000,
            DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_CREEP, // Проверить, объединение ли это с предыдущим
            DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,
            FindOrder.FIND_CLOSEST,
            false
        ).length


        const pointsAvailableForSpawn = heroes.reduce((points, hero, index) => {
            const pointsInHeroVisionPlus = Entities.FindAllByNameWithin('creep_spawn_point', hero.GetAbsOrigin(), hero.GetCurrentVisionRange() + 700)

            const pointsInHeroVision = Entities.FindAllByNameWithin('creep_spawn_point', hero.GetAbsOrigin(), hero.GetCurrentVisionRange())

            return [...points, ...pointsInHeroVisionPlus.filter(point => !pointsInHeroVision.includes(point))]
        }, [] as CBaseEntity[])

        arrayShuffle(pointsAvailableForSpawn).slice(0, PlayerResource.GetPlayerCount() * waveConfig.unitsCountPerPlayer - aliveCreepsCount).forEach(point => {
            const unitName = waveConfig.unitNames[getRandomInRange(0, waveConfig.unitNames.length - 1)]
            const unit = CreateUnitByName(unitName, point.GetAbsOrigin(), true, undefined, undefined, DOTATeam_t.DOTA_TEAM_BADGUYS)

            // радиус агра
            unit.SetAcquisitionRange(10000)
        })

        return 5
    }
}
