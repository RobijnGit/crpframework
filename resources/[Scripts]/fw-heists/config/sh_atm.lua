Config = Config or {}

Config.ATMs = {
    [GetHashKey("prop_atm_02")] = "prop_atm_02",
    [GetHashKey("prop_atm_03")] = "prop_atm_03",
    [GetHashKey("prop_fleeca_atm")] = "prop_fleeca_atm",
}

Config.BrokenATMModels = {
    ["prop_atm_02"] = { "fw_atm_02_des", "fw_atm_02_console" },
    ["prop_atm_03"] = { "fw_atm_03_des", "fw_atm_03_console" },
    ["prop_fleeca_atm"] = { "fw_fleeca_atm_des", "fw_fleeca_atm_console" },
}