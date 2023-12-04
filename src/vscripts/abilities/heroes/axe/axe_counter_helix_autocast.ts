import { BaseAbility, registerAbility } from "../../../lib/dota_ts_adapter";

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
            UnitTargetTeam.ENEMY,
            UnitTargetType.BASIC,
            UnitTargetFlags.NONE,
            FindOrder.ANY,
            false
        )

        targets.forEach(target => {
            const damageTable = {
                victim: target,
                attacker: caster,
                damage,
                damage_type: DamageTypes.PURE,
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
