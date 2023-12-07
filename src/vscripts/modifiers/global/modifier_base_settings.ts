import {BaseModifier, registerModifier} from "../../lib/dota_ts_adapter";

@registerModifier()
export class modifier_base_settings extends BaseModifier {
    CheckState(): Partial<Record<modifierstate, boolean>> {
        return {
            [modifierstate.MODIFIER_STATE_FORCED_FLYING_VISION]: true,
        }
    }
}
