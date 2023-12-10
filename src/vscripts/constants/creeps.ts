interface WaveConfig {
    unitNames: string[],
    unitsCountPerPlayer: number
}

export const wavesConfigByWaveNumber: Record<number, WaveConfig>  = {
    1: {
        unitNames: ['npc_dota_neutral_kobold'],
        unitsCountPerPlayer: 10,
    },

    2: {
        unitNames: ['npc_dota_neutral_kobold', 'npc_dota_neutral_kobold_1'],
        unitsCountPerPlayer: 15
    },
}
