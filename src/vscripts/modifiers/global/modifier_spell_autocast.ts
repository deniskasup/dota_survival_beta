import {BaseModifier, registerModifier} from "../../lib/dota_ts_adapter";
import getRandomInRange from "../../helpers/getRandomInRange";
import {noCastSpells} from "../../constants/autocast";

@registerModifier()
export class modifier_spell_autocast extends BaseModifier {
    IsHidden(): boolean {
        return true
    }

    DeclareFunctions(): modifierfunction[] {
        return [
            modifierfunction.MODIFIER_EVENT_ON_ATTACK,
            modifierfunction.MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
            modifierfunction.MODIFIER_EVENT_ON_DEATH,
            modifierfunction.MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
            modifierfunction.MODIFIER_EVENT_ON_RESPAWN,
            modifierfunction.MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            modifierfunction.MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            modifierfunction.MODIFIER_PROPERTY_STATUS_RESISTANCE,
            modifierfunction.MODIFIER_PROPERTY_GOLD_RATE_BOOST,
            modifierfunction.MODIFIER_PROPERTY_EXP_RATE_BOOST,
            modifierfunction.MODIFIER_EVENT_ON_TAKEDAMAGE,
        ]
    }

    OnCreated(params: object) {
        const caster = this.GetCaster()

        //TODO: проверить флаги
        caster?.SetContextThink('think_cast', () => {

            for(let abilityIndex = 0; abilityIndex < caster.GetAbilityCount(); abilityIndex++) {
                const ability = caster?.GetAbilityByIndex(abilityIndex)

                if(
                    caster.IsAlive()
                    && !caster.IsChanneling()
                    && ability
                    && !ability.IsHidden()
                    && !ability.IsPassive()
                    && ability.GetLevel() > 0
                    && ability.IsCooldownReady()
                ) {
                    castAbility(ability, caster)
                }
            }

            // интервал обновления
            return .3
        }, 0)
    }
}


const castAbility = (ability: CDOTABaseAbility, caster: CDOTA_BaseNPC) => {
    const enemiesList = FindUnitsInRadius(
        caster!.GetTeamNumber(),
        caster!.GetLocalOrigin(),
        undefined,
        1500,
        DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_CREEP+1, // Проверить, объединение ли это с предыдущим
        DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,
        FindOrder.FIND_CLOSEST,
        false
    )

    // const aliesList = FindUnitsInRadius(
    //     caster?.GetTeamNumber(),
    //     caster?.GetLocalOrigin(),
    //     undefined,
    //     1500,
    //     DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_FRIENDLY,
    //     DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO,
    //     DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,
    //     FindOrder.FIND_CLOSEST,
    //     false
    // )
    // const creepsList = FindUnitsInRadius(
    //     caster?.GetTeamNumber(),
    //     caster?.GetLocalOrigin(),
    //     undefined,
    //     1500,
    //     DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,
    //     DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_CREEP,
    //     DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,
    //     FindOrder.FIND_CLOSEST,
    //     false
    // )

    if(enemiesList[0] && !noCastSpells.includes(ability.GetName())) {
        //TODO: не работает выбор ближ врагов (мб сортировка массива не работает)
        const randomIndex = getRandomInRange(0, enemiesList.length) / 7
        const randomEnemyInRadius = enemiesList[randomIndex ? Math.ceil(randomIndex) : randomIndex]

        pcall(() => caster.SetCursorCastTarget(randomEnemyInRadius))

        caster.CastAbilityImmediately(ability,0)
    }
}
