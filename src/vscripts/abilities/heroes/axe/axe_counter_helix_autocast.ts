import {BaseAbility, registerAbility} from "../../../lib/dota_ts_adapter";

@registerAbility()
export class axe_counter_helix_autocast extends BaseAbility {
    particle?: ParticleID;

    CastAbility() {
        return false
    }

    OnAbilityPhaseStart() {
        if (IsServer()) {
            this.GetCaster().EmitSound("Hero_Axe.CounterHelix");
        }

        return true;
    }

    OnAbilityPhaseInterrupted() {
        this.GetCaster().StopSound("Hero_Axe.CounterHelix");
    }

    OnSpellStart() {
        const caster = this.GetCaster();
        const radius = this.GetSpecialValueFor("radius");
        const damage = this.GetSpecialValueFor('damage');

        const targets = FindUnitsInRadius(
            caster.GetTeamNumber(),
            caster.GetAbsOrigin(),
            undefined,
            radius,
            DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,
            FindOrder.FIND_ANY_ORDER,
            false
        )

        targets.forEach(target => {
            const damageTable = {
                victim: target,
                attacker: caster,
                damage,
                damage_type: DAMAGE_TYPES.DAMAGE_TYPE_PURE,
                ability: this,
            }

            ApplyDamage(damageTable)
        })

    }

    OnAbilityUpgrade() {
        const cooldown = this.GetSpecialValueFor("AbilityCooldown")
        Timers.CreateTimer(cooldown, () => {
            this.GetCaster().CastAbilityNoTarget(this, this.GetCaster().GetEntityIndex())
            return cooldown
        });
    }
}
