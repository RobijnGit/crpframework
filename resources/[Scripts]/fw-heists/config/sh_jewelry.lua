Config = Config or {}

function GetJewelryPrefix()
    return "jewelry-"
end

Config.Jewelry = {
    DoorIds = {
        "JEWELRY_DOOR_LEFT",
        "JEWELRY_DOOR_RIGHT",
    },
    Weapons = {
        [GetHashKey("weapon_rpk")] = true,
        [GetHashKey("weapon_ak47")] = true,
        [GetHashKey("weapon_groza")] = true,
        [GetHashKey("weapon_mp5")] = true,
        [GetHashKey("weapon_draco")] = true,
        [GetHashKey("weapon_m70")] = true,
        [GetHashKey("weapon_m4")] = true,
        [GetHashKey("weapon_ak74")] = true,
        [GetHashKey("weapon_uzi")] = true,
        [GetHashKey("weapon_remington")] = true,
        [GetHashKey("weapon_expedite")] = true,
    },
}