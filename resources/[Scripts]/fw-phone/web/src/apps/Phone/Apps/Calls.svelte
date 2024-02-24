<script>
    import "../components/Misc.css";

    import { onMount } from "svelte";
    import { ExtractImageUrls, FormatPhone, GetContactsSelect, GetTimeLabel, SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    import { InputModal, LoaderModal } from "../phone.stores";

    import Button from "../../../components/Button/Button.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";

    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";
    import Paper from "../components/Paper.svelte";

    let Calls = [];
    let FilteredCalls = [];
    let ShowingLimit = 100;

    const FilterCalls = (Query) => {
        Query = Query.toLowerCase();
        FilteredCalls = Calls.filter(
            (Val) =>
                Val.Contact.toLowerCase().includes(Query) ||
                Val.Phone.toLowerCase().includes(Query)
        );
    };

    const LoadMore = () => {
        ShowingLimit = ShowingLimit + 100;
    };

    const CallSomeone = async (Data) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Phone",
                    Type: "TextField",
                    IsPhone: true,
                    ContactPicker: true,
                    Data: {
                        Title: "Telefoonnummer",
                        Icon: "phone",
                        Value: Data.Phone,
                        Select: await GetContactsSelect(),
                        SearchSelect: true,
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Phone.length <= 0) return;
                SendEvent("Contacts/Call", { Phone: Result.Phone })
            },
        });
    };

    const CallContact = (Data) => {
        SendEvent("Contacts/Call", { Phone: Data.Phone })
    };

    const MessageContact = async (Data) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Phone",
                    Type: "TextField",
                    IsPhone: true,
                    ContactPicker: true,
                    Data: {
                        Title: "Telefoonnummer",
                        Icon: "phone",
                        Value: Data.Phone,
                        Select: await GetContactsSelect(),
                        SearchSelect: true,
                    },
                },
                {
                    Id: "Message",
                    Type: "TextArea",
                    Data: {
                        Title: "Bericht",
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

    const AddContact = (Data) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Name",
                    Type: "TextField",
                    Data: {
                        Title: "Naam",
                        Icon: "user",
                        Value: "",
                    },
                },
                {
                    Id: "Phone",
                    Type: "TextField",
                    IsPhone: true,
                    Data: {
                        Title: "Telefoonnummer",
                        Icon: "phone",
                        Type: "number",
                        Value: Data.Phone,
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Name.length <= 0) return;
                if (Result.Phone.length <= 0) return;

                LoaderModal.set(true);
                SendEvent("Contacts/CreateContact", { ...Result }, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
                    ShowSuccessModal();
                });
            },
        });
    };

    onMount(() => {
        SendEvent("Calls/GetCalls", {}, (Success, Data) => {
            if (!Success) return;

            Calls = Data.reverse();
            FilteredCalls = Calls;
        });
    });
</script>

<AppWrapper>
    <div class="phone-misc-icons">
        <i
            data-tooltip="Bel Iemand"
            data-position="left"
            class="fas fa-phone-alt"
            on:keyup
            on:click={CallSomeone}
        />
    </div>

    <TextField
        Title="Zoeken"
        Icon="search"
        SubSet={FilterCalls}
        class="phone-misc-input"
    />

    <PaperList>
        {#each FilteredCalls.slice(0, ShowingLimit) as Data, Id}
            <Paper
                Icon={Data.Incoming ? "phone-alt" : "phone"}
                Title={Data.Contact}
                Description={GetTimeLabel(Data.Timestamp)}
                HasActions={true}
            >
                <i on:keyup on:click={() => { CallContact(Data); }} data-tooltip="Bellen" class="fas fa-phone-alt" />
                <i on:keyup on:click={() => { MessageContact(Data); }} data-tooltip="Berichten" class="fas fa-comment" />
                {#if Data.Contact == FormatPhone(Data.Phone)}
                    <i on:keyup on:click={() => { AddContact(Data); }} data-tooltip="Contact Toevoegen" class="fas fa-user-plus" />
                {/if}
            </Paper>
        {/each}

        {#if FilteredCalls.length > ShowingLimit}
            <div style="display: flex; justify-content: center; width: 100%;">
                <Button Color="success" on:click={LoadMore}>Laad Meer</Button>
            </div>
        {/if}
    </PaperList>
</AppWrapper>
