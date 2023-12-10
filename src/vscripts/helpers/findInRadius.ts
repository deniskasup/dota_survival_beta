export const findEnemiesInRadius = (finder: CDOTA_BaseNPC, radius = 1500, targetType: DOTA_UNIT_TARGET_TYPE = DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_CREEP+1) => {
    return FindUnitsInRadius(
        finder!.GetTeamNumber(),
        finder!.GetLocalOrigin(),
        undefined,
        radius,
        DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,
        targetType, // Проверить, объединение ли это с предыдущим
        DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
        FindOrder.FIND_CLOSEST,
        false
    )
}



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
