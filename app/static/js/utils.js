function cleanAreaName(areaName) {
    const DEFAULT_AREA_TYPES = [
        "COM", "DEP", "ZNIEFF1", "ZNIEFF2", "APB", "RNR", "RNN",
        "ZPS", "SIC", "ZICO", "PNR", "RBIOL", "RBIOS", "ZSC",
        "PSIC", "ENS", "PRIF", "INTERCOM"
    ];

    const found = DEFAULT_AREA_TYPES.some(code => areaName.includes(code));

    if (found && areaName.includes("-")) {
        return areaName.split("-", 2)[1].trim(); // Découpe sur le premier tiret
    } else {
        return areaName;
    }
}
