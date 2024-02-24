let ItemsList = [], CustomTypes = [];
let HasWeaponsLicense = false;
let OtherInvData = {}, MyInventory = {};
let InventoryOpen = false;
let MaxPlayerWeight = 250.0;
let MaxPlayerSlots = 40;
let PlayerCash = 0;
let IgnoredIntoInvDrag = ['Store', 'Crafting'];

let HiddenMetadata = [
    // metadata that starts with '_' is ignored.
    // '_decryptFailed',
    // '_Description',
    // '_EvidenceData',
    // '_IsDehashed',
    // '_LastCook',
    // '_Purities',
    // '_Purity',
    'InkedBagExpiration',
    'BagId',
    'Image',
    'CookTime',
    'Buff',
    'BuffPercentage',
    'Date',
    'Photos',
];

let ItemI18n = {
    "id_card": {
        citizenid: "BSN",
        firstname: "Voornaam",
        lastname: "Achternaam",
        birthdate: "Geboortedag",
        nationality: "Nationaliteit",
        gender: "Geslacht",
    },
    "driver_license": {
        citizenid: "BSN",
        birthdate: "Geboortedag",
        lastname: "Achternaam",
        firstname: "Voornaam",
        type: "Rijbewijzen",
    },
    "identification-badge": {
        Rang: "Functie",
        Callsign: "Roepnummer",
        Name: "Naam"
    },
    "burnerphone": {
        PhoneNumber: "Telefoonnummer"
    },
    "filled_evidence_bag": {
        label: "Type",
        street: "Straatnaam",
        bloodtype: "Bloed Type",
        fingerid: "Vingerafdruk",
        slimeid: "DNA-code",
        hairid: "DNA-code",
        ammo: "Ammo",
        ammotype: "Ammo Type",
        serie: "Serienummer"
    },
    "evidence": {
        Serial: "Serienummer",
        Fingerprint: "Vingerafdruk",
        BloodType: "Bloed Type",
        BloodId: "DNA-code",
    },
    "polaroid-photo": {
        Description: "Beschrijving",
    }
}

let SpecificItemsInv = [
    {
        Inv: "cassettebox-",
        Items: [
            "musictape"
        ],
    },
    {
        Inv: "seed-bag-",
        Items: [
            "farming-seed"
        ],
    },
    {
        Inv: "produce-basket-",
        Items: [
            "farming-seed",
            "ingredient",
            "foodchain-food-item",
            "foodchain-side-item",
            "foodchain-dessert-item",
            "foodchain-drink-item",
            "foodchain-alcohol-item",
        ],
    },
    {
        Inv: "traphouse-",
        Items: [
            "markedbills",
            "money-roll",
        ],
    },
    {
        Inv: "arcade-tokens-",
        Items: [
            "arcadetoken"
        ]
    }
];