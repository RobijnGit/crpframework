import { AsyncSendEvent, Delay, FormatCurrency, SendEvent, ShowSuccessModal } from "../../../utils/Utils";
import { InputModal, LoaderModal } from "../phone.stores";
import { HouseClasses, HouseTiersLabels } from "../../../config";

export const IsNearHouse = async HouseId => {
    const [Success, Result] = await AsyncSendEvent("Housing/IsNearHouse", {Id: HouseId})

    if (!Result) {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: "Je moet in de buurt zijn van het eigendom om dit te kunnen doen!",
                    Data: {
                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                    },
                },
            ],
            Buttons: [
                {
                    Color: "success",
                    Text: "Okay",
                    Cb: () => {},
                },
            ],
        });
    }

    return Result;
}

export const IsNearAnyHouse = async () => {
    const [Success, Result] = await AsyncSendEvent("Housing/IsNearAnyHouse")

    if (!Result) {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: "Je moet in de buurt zijn van het eigendom om dit te kunnen doen!",
                    Data: {
                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                    },
                },
            ],
            Buttons: [
                {
                    Color: "success",
                    Text: "Okay",
                    Cb: () => {},
                },
            ],
        });
    }

    return Result;
}

export const PurchaseHouse = async HouseId => {
    await Delay(0.01);
    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Type: "Text",
                Text: "Weet je het zeker?",
                Data: {
                    style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                },
            },
        ],
        OnSubmit: () => {
            LoaderModal.set(true);
            SendEvent("Housing/PurchaseHouse", { HouseId }, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;

                if (Data.Success) {
                    ShowSuccessModal();
                    return;
                }

                InputModal.set({
                    Visible: true,
                    Inputs: [
                        {
                            Type: "Text",
                            Text: Data.Msg,
                            Data: {
                                style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;",
                            },
                        },
                    ],
                    Buttons: [
                        {
                            Color: "success",
                            Text: "Okay",
                            Cb: () => {},
                        },
                    ],
                });
            });
        }
    });
};

export const CheckCurrentLocation = async () => {
    const [ Success, Result ] = await AsyncSendEvent("Housing/GetCurrentHouse")
    if (!Success) return;

    if (!Result) {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: "Geen eigendom gevonden op huidige locatie.",
                    Data: {
                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;",
                    },
                },
            ],
            Buttons: [
                {
                    Color: "success",
                    Text: "Okay",
                    Cb: () => {},
                },
            ],
        });
        return;
    }

    let Buttons = [
        {
            Color: "warning",
            Text: "Annuleren",
            Cb: () => {},
        },
    ]

    if (Result.Selling) {
        Buttons.push({
            Color: "success",
            Text: "Kopen",
            Cb: () => {
                PurchaseHouse(Result.Id)
            },
        })
    }

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Type: "Text",
                Text: "Adres:",
                Data: { style: "font-size: 1.3vh;" }
            },
            {
                Type: "Text",
                Text: Result.Adress,
                Data: { style: "margin-bottom: 1.5vh; font-size: 1.3vh;" }
            },
            {
                Type: "Text",
                Text: "Categorie:",
                Data: { style: "font-size: 1.3vh;" }
            },
            {
                Type: "Text",
                Text: Result.Category,
                Data: { style: "margin-bottom: 1.5vh; font-size: 1.3vh;" }
            },
            {
                Type: "Text",
                Text: "Prijs:",
                Data: { style: "font-size: 1.3vh;" }
            },
            {
                Type: "Text",
                Text: FormatCurrency.format(Result.Price),
                Data: { style: "margin-bottom: 1.5vh; font-size: 1.3vh;" }
            },
        ],
        Buttons: Buttons,
    });
};

export const Locate = (Data) => {
    SendEvent("Housing/SetGPS", {HouseId: Data.Id})
};

export const PlaceGarage = (HouseId) => {
    SendEvent("Housing/SetInteractLocation", {HouseId, Interaction: "Garage"})
};

export const PlaceStash = (HouseId) => {
    SendEvent("Housing/SetInteractLocation", {HouseId, Interaction: "Stash"})
};

export const PlaceBackdoor = (HouseId) => {
    SendEvent("Housing/SetInteractLocation", {HouseId, Interaction: "Backdoor"})
};

export const PlaceWardrobe = (HouseId) => {
    SendEvent("Housing/SetInteractLocation", {HouseId, Interaction: "Wardrobe"})
};

export const OpenDecoration = (HouseId) => {
    // SendEvent("Housing/SetInteractLocation", {HouseId, Interaction: "Furniture"})
};

export const AddKeyholder = (HouseId, Cid, AmountOfKeyholders) => {
    if (AmountOfKeyholders + 1 > 8) {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: "Maximum aantal sleutels bereikt.",
                    Data: {
                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;",
                    },
                },
            ],
            Buttons: [
                {
                    Color: "success",
                    Text: "Okay",
                    Cb: () => {},
                },
            ],
        });
        return;
    };

    SendEvent("Housing/AddKeys", {HouseId, Target: Cid})
    ShowSuccessModal();
}

export const RemoveKeyholder = (HouseId, Cid) => {
    SendEvent("Housing/RemoveKeys", {HouseId, Target: Cid})
    ShowSuccessModal();
}

export const SellHousing = async () => {
    if (!await IsNearAnyHouse()) return;

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Cid",
                Type: "TextField",
                Data: {
                    Title: "BSN",
                    Icon: "id-card",
                    Value: "",
                },
            },
            {
                Id: "Commission",
                Type: "TextField",
                Data: {
                    Title: "Commissie (Bijvoorbeeld: 20, geen 0.3 etc)",
                    Icon: "highlighter",
                    Type: "number"
                },
            },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            if (Number(Result.Commission) < 0.0 || Number(Result.Commission) > 15.0) {
                return InputModal.set({
                    Visible: true,
                    Inputs: [
                        {
                            Type: "Text",
                            Text: "Commissie kan niet hoger dan 15% zijn.",
                            Data: {
                                style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;",
                            },
                        },
                    ],
                    Buttons: [
                        {
                            Color: "success",
                            Text: "Okay",
                            Cb: () => {},
                        },
                    ],
                });
            }

            SendEvent("Housing/SellLocation", {...Result }, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;
                ShowSuccessModal();
            });
        },
    });
};

export const CreateHousing = () => {
    let Tiers = [];
    for (let i = 0; i < HouseClasses.length; i++) {
        const TierLabel = HouseClasses[i];
        Tiers.push({Text: `${TierLabel}`, Value: i})
    }

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Class",
                Type: "TextField",
                Data: {
                    Title: "Tier",
                    Select: Tiers,
                    ReadOnly: true,
                },
            },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Housing/CreateHouse", {...Result }, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;
                ShowSuccessModal();
            });
        },
    });
};

export const EditHousing = async () => {
    const [ Success, Result ] = await AsyncSendEvent("Housing/GetCurrentHouse")
    if (!Success || !Result) return;

    let Tiers = [];
    for (let i = 1; i < HouseTiersLabels[Result.Class].length; i++) {
        const [TierKey, TierLabel] = HouseTiersLabels[Result.Class][i];
        Tiers.push({Text: `(${TierKey}) ${TierLabel}`, Value: TierKey})
    };

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Tier",
                Type: "TextField",
                Data: {
                    Title: "Tier",
                    Select: Tiers,
                    ReadOnly: true,
                },
            },
            {
                Id: "Price",
                Type: "TextField",
                IsCurrency: true,
                Data: {
                    Title: "Prijs",
                    Icon: "sign",
                    Sub: "€ 0,00",
                    Type: "number"
                },
            },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Housing/EditHouse", {...Result }, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success || !Data) return;
                ShowSuccessModal();
            });
        },
    });
};

export const DeleteHousing = async () => {
    if (!await IsNearAnyHouse()) return;

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Type: "Text",
                Text: "Weet je het zeker?",
                Data: {
                    style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                },
            },
        ],
        OnSubmit: () => {
            LoaderModal.set(true);
            SendEvent("Housing/DeleteHouse", {}, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;

                ShowSuccessModal();
                return;
            });
        }
    });
};