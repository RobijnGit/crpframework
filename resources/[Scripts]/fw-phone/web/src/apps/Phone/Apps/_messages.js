import { get } from "svelte/store";
import { ExtractImageUrls, FormatPhone, GetContactsSelect, SendEvent, ShowSuccessModal } from "../../../utils/Utils";
import { CurrentChat, InputModal, LoaderModal, PlayerData } from "../phone.stores";

export const IsMessageSender = Msg => {
    return Msg.Sender == get(PlayerData).PhoneNumber;
};

export const GetContactInformation = Chat => {
    const FormattedPhone = FormatPhone(Chat.to_phone);
    if (Chat.name == FormattedPhone) return FormattedPhone;
    return `${Chat.name} <br/> ${FormattedPhone}`;
};

export const GetLastMessage = Data => {
    let Text = Data.messages[0].Message
    if (Text == '' && Data.messages[0].Attachments[0]) {
        Text = Data.messages[0].Attachments[0];
    };

    if (IsMessageSender(Data.messages[0])) {
        return '<i class="fas fa-share"></i> ' + Text
    };

    return Text;
};

export const SendMessageModal = async () => {
    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Phone",
                Type: "TextField",
                IsPhone: true,
                ContactPicker: true,
                Data: {
                    Title: "Phone Number",
                    Icon: "phone",
                    Select: await GetContactsSelect(),
                    SearchSelect: true,
                },
            },
            {
                Id: "Message",
                Type: "TextArea",
                Data: {
                    Title: "Message",
                },
            },
        ],
        OnSubmit: (Result) => {
            if (Result.Phone.length <= 0) return;
            if (Result.Message.length <= 0) return;

            let [Attachments, Message] = ExtractImageUrls(Result.Message)

            LoaderModal.set(true);
            SendEvent("Messages/SendMessage", { Phone: Result.Phone, Attachments, Message }, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;
                ShowSuccessModal();
            });
        },
    });
};

export const SendMessage = (Text) => {
    if (Text.length <= 0) return;
    const Phone = get(CurrentChat).to_phone
    if (!Phone) return;

    let [Attachments, Message] = ExtractImageUrls(Text)

    SendEvent("Messages/SendMessage", { Phone, Attachments, Message });
};

export const CallContact = (Phone) => {
    SendEvent("Contacts/Call", {Phone})
};