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
        citizenid: "State ID",
        firstname: "Firstname",
        lastname: "Lastname",
        birthdate: "Date of Birth",
        nationality: "Nationality",
        gender: "Sex",
    },
    "driver_license": {
        citizenid: "State ID",
        birthdate: "Date of Birth",
        lastname: "Lastname",
        firstname: "Firstname",
        type: "Licenses",
    },
    "identification-badge": {
        Rang: "Rang",
        Callsign: "Callsign",
        Name: "Name"
    },
    "burnerphone": {
        PhoneNumber: "Phone Number"
    },
    "filled_evidence_bag": {
        label: "Type",
        street: "Street Name",
        bloodtype: "Blood Type",
        fingerid: "Fingerprint",
        slimeid: "DNA-code",
        hairid: "DNA-code",
        ammo: "Ammo",
        ammotype: "Ammo Type",
        serie: "Serialnumber"
    },
    "evidence": {
        Serial: "Serialnumber",
        Fingerprint: "Fingerprint",
        BloodType: "Blood Type",
        BloodId: "DNA-code",
    },
    "polaroid-photo": {
        Description: "Description",
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