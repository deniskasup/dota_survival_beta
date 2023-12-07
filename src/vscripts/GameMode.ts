import { reloadable } from "./lib/tstl-utils";

LinkLuaModifier("modifier_spell_autocast", "modifiers/global/modifier_spell_autocast", LuaModifierType.LUA_MODIFIER_MOTION_NONE)

const heroSelectionTime = 60;

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
        ListenToGameEvent("npc_spawned", event => this.OnNpcSpawned(event), undefined);
        ListenToGameEvent("dota_on_hero_finish_spawn", (data) => {
            const hero = HeroList.GetAllHeroes().find(hero => hero.GetEntityIndex() === data.heroindex)
            hero?.AddNewModifier(hero,  undefined, 'modifier_spell_autocast', undefined)
        }, undefined)

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
        if (state === DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME) {
            Timers.CreateTimer(0.2, () => this.StartGame());
        }
    }

    private StartGame(): void {
        print("Game starting!");

        // Do some stuff here
    }

    // Called on script_reload
    public Reload() {
        print("Script reloaded!");

        // Do some stuff here
    }

    private OnNpcSpawned(event: NpcSpawnedEvent) {

    }
}
