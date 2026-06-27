import { get } from "svelte/store";
import { InputModal, LoaderModal, CurrentBusiness } from "./../phone.stores";
import { AsyncSendEvent, SendEvent, ShowSuccessModal } from "../../../utils/Utils";

// Global
const FormatBusinessRoles = (Biz) => {
    if (!Biz) return;

    return Biz.business_ranks.map((Rank) => ({
        Text: Rank.Name,
        Value: Rank.Name,
    }));
}

export const HireEmployee = () => {
    const Biz = get(CurrentBusiness);
    if (!Biz || !Biz.id) return;

    const Roles = FormatBusinessRoles(Biz);

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Employee",
                Type: "TextField",
                Data: {
                    Title: "BSN",
                    Icon: "id-card",
                    Value: "",
                },
            },
            {
                Id: "Role",
                Type: "TextField",
                Data: {
                    Title: "Rol",
                    Select: Roles,
                },
            },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Employment/HireEmployee", {...Result, Business: Biz.business_name}, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;

                if (Data.Success) {
                    let Business = {...get(CurrentBusiness)};
                    Business.business_employees = Data.Employees;
                    CurrentBusiness.set(Business);
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
        },
    });
};

export const PayExternal = () => {
    const Biz = get(CurrentBusiness);
    if (!Biz || !Biz.id) return;

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
                Id: "Amount",
                Type: "TextField",
                IsCurrency: true,
                Data: {
                    Title: "Aantal",
                    Icon: "dollar-sign",
                    Sub: "$ 0,00"
                },
            },
            {
                Id: "Comment",
                Type: "TextArea",
                Data: {
                    Title: "Commentaar",
                },
            },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Employment/PayExternal", {...Result, Business: Biz.business_name}, (Success, Data) => {
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
        },
    });
};

export const ChargeExternal = () => {
    const Biz = get(CurrentBusiness);
    if (!Biz || !Biz.id) return;

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
                Id: "Amount",
                Type: "TextField",
                IsCurrency: true,
                Data: {
                    Title: "Aantal",
                    Icon: "dollar-sign",
                    Sub: "€ 0,00"
                },
            },
            {
                Id: "Comment",
                Type: "TextArea",
                Data: {
                    Title: "Commentaar",
                },
            },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Employment/ChargeCustomer", {...Result, Business: Biz.business_name}, (Success, Data) => {
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
        },
    });
};

export const CreateRole = () => {
    const Biz = get(CurrentBusiness);
    if (!Biz || !Biz.id) return;

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Name",
                Type: "TextField",
                Data: {
                    Title: "Name",
                    Icon: "user",
                    Value: "",
                },
            },
            { Id: "Hire", Type: "Checkbox", Data: { Title: "Hire", } },
            { Id: "Fire", Type: "Checkbox", Data: { Title: "Fire", } },
            { Id: "ChangeRole", Type: "Checkbox", Data: { Title: "Change Role", } },
            { Id: "PayEmployee", Type: "Checkbox", Data: { Title: "Pay Employee", } },
            { Id: "PayExternal", Type: "Checkbox", Data: { Title: "Pay External", } },
            { Id: "ChargeExternal", Type: "Checkbox", Data: { Title: "Charge External", } },
            { Id: "PropertyKeys", Type: "Checkbox", Data: { Title: "Property Keys", } },
            { Id: "StashAccess", Type: "Checkbox", Data: { Title: "Stash Access", } },
            { Id: "CraftAccess", Type: "Checkbox", Data: { Title: "Craft Access", } },
            { Id: "VehicleSales", Type: "Checkbox", Data: { Title: "Vehicle Sales", } },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Employment/CreateRole", {Name: Result.Name, Permissions: {...Result}, Business: Biz.business_name}, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;

                if (Data.Success) {
                    let Business = {...get(CurrentBusiness)};
                    Business.business_ranks = Data.Ranks;
                    CurrentBusiness.set(Business);
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
        },
    });
};

export const EditRole = () => {
    const Biz = get(CurrentBusiness);
    if (!Biz || !Biz.id) return;

    const Roles = FormatBusinessRoles(Biz);
    let CurrentRole = {
        Name: "",
        Perms: {},
    }

    const CheckRoleChange = (Id, Value, Input) => {
        if (Id != "Name") return Input.Checked;
        return CurrentRole.Perms[Input.Id]
    }

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Name",
                Type: "TextField",
                Data: {
                    Title: "Role",
                    Select: Roles,
                    SubSet: (Value) => {
                        CurrentRole = Biz.business_ranks.find((Val) => Val.Name == Value);
                    }
                },
            },
            { OnChange: CheckRoleChange, Id: "Hire", Type: "Checkbox", Data: { Title: "Hire", Checked: CurrentRole.Perms["Hire"] } },
            { OnChange: CheckRoleChange, Id: "Fire", Type: "Checkbox", Data: { Title: "Fire", Checked: CurrentRole.Perms["Fire"] } },
            { OnChange: CheckRoleChange, Id: "ChangeRole", Type: "Checkbox", Data: { Title: "Change Role", Checked: CurrentRole.Perms["ChangeRole"] } },
            { OnChange: CheckRoleChange, Id: "PayEmployee", Type: "Checkbox", Data: { Title: "Pay Employee", Checked: CurrentRole.Perms["PayEmployee"] } },
            { OnChange: CheckRoleChange, Id: "PayExternal", Type: "Checkbox", Data: { Title: "Pay Person", Checked: CurrentRole.Perms["PayExternal"] } },
            { OnChange: CheckRoleChange, Id: "ChargeExternal", Type: "Checkbox", Data: { Title: "Charge Customer", Checked: CurrentRole.Perms["ChargeExternal"] } },
            { OnChange: CheckRoleChange, Id: "PropertyKeys", Type: "Checkbox", Data: { Title: "Property Keys", Checked: CurrentRole.Perms["PropertyKeys"] } },
            { OnChange: CheckRoleChange, Id: "StashAccess", Type: "Checkbox", Data: { Title: "Stash Access", Checked: CurrentRole.Perms["StashAccess"] } },
            { OnChange: CheckRoleChange, Id: "CraftAccess", Type: "Checkbox", Data: { Title: "Craft Access", Checked: CurrentRole.Perms["CraftAccess"] } },
            { OnChange: CheckRoleChange, Id: "VehicleSales", Type: "Checkbox", Data: { Title: "Vehicle Sales", Checked: CurrentRole.Perms["VehicleSales"] } },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Employment/EditRole", {Name: Result.Name, Permissions: {...Result}, Business: Biz.business_name}, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;

                if (Data.Success) {
                    let Business = {...get(CurrentBusiness)};
                    Business.business_ranks = Data.Ranks;
                    CurrentBusiness.set(Business);
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
        },
    });
};

export const DeleteRole = () => {
    const Biz = get(CurrentBusiness);
    if (!Biz || !Biz.id) return;

    const Roles = FormatBusinessRoles(Biz);

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Name",
                Type: "TextField",
                Data: {
                    Title: "Rol",
                    Select: Roles,
                },
            },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Employment/DeleteRole", {...Result, Business: Biz.business_name}, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;

                if (Data.Success) {
                    let Business = {...get(CurrentBusiness)};
                    Business.business_ranks = Data.Ranks;
                    CurrentBusiness.set(Business);
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
        },
    });
};

export const PayEmployee = (Cid) => {
    const Biz = get(CurrentBusiness);
    if (!Biz || !Biz.id) return;

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Amount",
                Type: "TextField",
                IsCurrency: true,
                Data: {
                    Title: "Aantal",
                    Icon: "dollar-sign",
                    Sub: "$ 0,00"
                },
            },
            {
                Id: "Comment",
                Type: "TextArea",
                Data: {
                    Title: "Comment",
                },
            },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Employment/PayExternal", {Cid, ...Result, Business: Biz.business_name}, (Success, Data) => {
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
        },
    });
};

export const ChangeRole = (Employee) => {
    const Biz = get(CurrentBusiness);
    if (!Biz || !Biz.id) return;

    const Roles = FormatBusinessRoles(Biz);

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Role",
                Type: "TextField",
                Data: {
                    Title: "Rol",
                    Select: Roles,
                },
            },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Employment/ChangeRole", {Employee, ...Result, Business: Biz.business_name}, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;

                if (Data.Success) {
                    let Business = {...get(CurrentBusiness)};
                    Business.business_employees = Data.Employees;
                    CurrentBusiness.set(Business);
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
        },
    });
};

export const FireEmployee = (Employee) => {
    const Biz = get(CurrentBusiness);
    if (!Biz || !Biz.id) return;

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Type: "Text",
                Text: "Werkenemer Ontslaan?",
                Data: {
                    style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                },
            },
        ],
        OnSubmit: () => {
            LoaderModal.set(true);

            SendEvent("Employment/RemoveEmployee", {Employee, Business: Biz.business_name}, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;

                if (Data.Success) {
                    let Business = {...get(CurrentBusiness)};
                    Business.business_employees = Data.Employees;
                    CurrentBusiness.set(Business);
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

export const BankAccess = async (Employee) => {
    const Biz = get(CurrentBusiness);
    if (!Biz || !Biz.id) return;

    const [ _Success, FinancialAccess ] = await AsyncSendEvent("Employment/GetFinancialAccess", {Employee, AccountId: Biz.business_account})
    if (!_Success) return;


    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Balance",
                Type: "Checkbox",
                Data: {
                    Title: "Balans",
                    Checked: FinancialAccess['Balance']
                }
            },
            {
                Id: "Deposit",
                Type: "Checkbox",
                Data: {
                    Title: "Storten",
                    Checked: FinancialAccess['Deposit']
                }
            },
            {
                Id: "Withdraw",
                Type: "Checkbox",
                Data: {
                    Title: "Opnemen",
                    Checked: FinancialAccess['Withdraw']
                }
            },
            {
                Id: "Transfer",
                Type: "Checkbox",
                Data: {
                    Title: "Overmaken",
                    Checked: FinancialAccess['Transfer']
                }
            },
            {
                Id: "Transactions",
                Type: "Checkbox",
                Data: {
                    Title: "Transacties",
                    Checked: FinancialAccess['Transactions']
                }
            },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Employment/SetFinancialAccess", {Employee, Permissions: {...Result}, AccountId: Biz.business_account}, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;

                if (Data.Success) {
                    ShowSuccessModal();
                    return;
                };

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
        },
    });
};

// Business Based Functions
export const Flightschool = {
    TogglePilotsLicense: () => {
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
                    Id: "Give",
                    Type: "Checkbox",
                    Data: {
                        Title: "Geef brevet",
                        Checked: true
                    }
                },
            ],
            OnSubmit: (Result) => {
                LoaderModal.set(true);

                SendEvent("Employment/GivePilotLicense", Result, (Success, Data) => {
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
            },
        });
    },
}