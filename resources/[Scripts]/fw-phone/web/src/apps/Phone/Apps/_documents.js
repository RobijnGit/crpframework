import { get } from "svelte/store";
import { CurrentDocument, InputModal, LoaderModal } from "../phone.stores"
import { SendEvent, ShowSuccessModal } from "../../../utils/Utils";

export const EditMode = (Bool) => {
    CurrentDocument.set({...get(CurrentDocument), editing: Bool})
}

export const DropQRCode = () => {
    SendEvent("Documents/DropQRCode", {Id: get(CurrentDocument).id});
};

export const SessionShareDocument = () => {
    SendEvent("Documents/ShareLocal", {Id: get(CurrentDocument).id});
};

export const PermanentShareDocument = () => {
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
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Documents/AddSharee", {...Result, Id: get(CurrentDocument).id}, (Success, Data) => {
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

export const FinalizeDocument = () => {
    LoaderModal.set(true);
    SendEvent("Documents/Finalize", {Id: get(CurrentDocument).id}, (Success, Data) => {
        LoaderModal.set(false);
        if (!Success) return;

        if (Data.Success) {
            ShowSuccessModal();
            const NewDocument = get(CurrentDocument);
            NewDocument.finalized = true;
            CurrentDocument.set(NewDocument);
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
};

export const DeleteDocument = () => {
    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Type: "Text",
                Text: "Weet je het zeker? Dit kan niet teruggedraaid worden.",
                Data: {
                    style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                },
            },
        ],
        OnSubmit: () => {
            LoaderModal.set(true);
            SendEvent("Documents/DeleteDocument", {Id: get(CurrentDocument).id}, (Success, Data) => {
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
        }
    });
};

export const SignDocument = () => {
    SendEvent("Documents/SignDocument", {Id: get(CurrentDocument).id}, (Success, Data) => {
        if (!Success || !Data.Success) return;

        const NewDocument = get(CurrentDocument);
        NewDocument.signatures = Data.Signatures;
        CurrentDocument.set(NewDocument);
    });
};

export const RequestSignature = () => {
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
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            SendEvent("Documents/RequestSignature", {...Result, Id: get(CurrentDocument).id}, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;

                if (Data.Success) {
                    ShowSuccessModal();
                    const NewDocument = get(CurrentDocument);
                    NewDocument.signatures = Data.Signatures;
                    CurrentDocument.set(NewDocument);

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