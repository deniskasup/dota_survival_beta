export const getWaveNumberFromTime = (dotaTime: number) => {
    switch (true) {
        case dotaTime > 0 && dotaTime < 200:
            return 1
        case dotaTime > 200 && dotaTime < 400:
            return 2
        case dotaTime > 400:
            return 2
        default:
            return 1
    }
}
