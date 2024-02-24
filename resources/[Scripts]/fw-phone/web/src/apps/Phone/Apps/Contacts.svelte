<script>
    import "../components/Misc.css";
    import { onMount } from "svelte";
    import { CopyToClipboard, ExtractImageUrls, FormatPhone, GetContactsSelect, OnEvent, SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    import { InputModal, LoaderModal } from "../phone.stores";

    import Button from "../../../components/Button/Button.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";

    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";
    import Paper from "../components/Paper.svelte";
    import Empty from "../components/Empty.svelte";

    let Contacts = [];
    let FilteredContacts = [];
    let Suggestions = [];

    let ShowingLimit = 100;

    const FilterContacts = (Query) => {
        Query = Query.toLowerCase();
        FilteredContacts = Contacts.filter(
            (Val) =>
                Val.phone.toLowerCase().includes(Query) ||
                Val.name.toLowerCase().includes(Query)
        );
    };

    const LoadMore = () => {
        ShowingLimit = ShowingLimit + 100;
    };

    const AddContact = (Data, IsSuggestion) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Name",
                    Type: "TextField",
                    Data: {
                        Title: "Naam",
                        Icon: "user",
                        Value: Data?.Name || "",
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
                        Value: Data?.Phone || "",
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Name.length <= 0) return;
                if (Result.Phone.length <= 0) return;

                LoaderModal.set(true);
                SendEvent("Contacts/CreateContact", { ...Result, IsSuggestion }, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
                    ShowSuccessModal();
                });
            },
        });
    };

    const RemoveSuggestion = (Data) => {
        LoaderModal.set(true);
        SendEvent("Contacts/DeleteSuggested", { Phone: Data.Phone }, (Success, Data) => {
            LoaderModal.set(false);
            if (!Success) return;
            ShowSuccessModal();
        });
    };
    
    const RemoveContact = (Data) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: "Contact Verwijderen?",
                    Data: {
                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                    },
                },
            ],
            OnSubmit: () => {
                LoaderModal.set(true);
                SendEvent("Contacts/DeleteContact", { ContactId: Data.id }, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
                    ShowSuccessModal();
                });
            }
        });
    };

    const DialContact = (Data) => {
        SendEvent("Contacts/Call", {Phone: Data.phone})
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
                        Value: Data.phone,
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

    const EditContact = (Data) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Name",
                    Type: "TextField",
                    Data: {
                        Title: "Naam",
                        Icon: "user",
                        Value: Data.name,
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
                        Value: Data.phone,
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Name.length <= 0) return;
                if (Result.Phone.length <= 0) return;

                LoaderModal.set(true);
                SendEvent("Contacts/EditContact", { ...Result, Id: Data.id }, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
                    ShowSuccessModal();
                });
            },
        });
    }

    onMount(() => {
        SendEvent("Contacts/GetContacts", {}, (Success, Data) => {
            if (!Success) return;
            Contacts = Data;
            FilteredContacts = Data;
        });

        SendEvent("Contacts/GetSuggestions", {}, (Success, Data) => {
            if (!Success) return;
            Suggestions = Data;
        });
    });

    OnEvent("Contacts/SetContacts", (Data) => {
        Contacts = Data.Contacts;
        FilteredContacts = Data.Contacts;
    });

    OnEvent("Contacts/SetSuggestedContacts", (Data) => {
        Suggestions = Data.Contacts;
    });
</script>

<AppWrapper>
    <div class="phone-misc-icons">
        <i
            data-tooltip="Contact Toevoegen"
            data-position="left"
            class="fas fa-user-plus"
            on:keyup
            on:click={() => {
                AddContact({}, false);
            }}
        />
    </div>

    <TextField
        Title="Zoeken"
        Icon="search"
        SubSet={FilterContacts}
        class="phone-misc-input"
    />

    <PaperList>
        {#if Contacts.length == 0 && Suggestions.length == 0}
            <Empty />
        {/if}

        {#if Suggestions.length > 0}
            <p
                style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;"
            >
                Gedeelde Contact(en)
            </p>
            {#each Suggestions as Data, Id}
                <Paper
                    Icon="user-circle"
                    Title={Data.Name}
                    Description={FormatPhone(Data.Phone)}
                    HasActions={true}
                >
                    <i
                        on:keyup
                        on:click={() => {
                            RemoveSuggestion(Data);
                        }}
                        data-tooltip="Yeet"
                        class="fas fa-user-slash"
                    />
                    <i
                        on:keyup
                        on:click={() => {
                            AddContact(Data, true);
                        }}
                        data-tooltip="Contact Toevoegen"
                        class="fas fa-user-plus"
                    />
                </Paper>
            {/each}
            <div class="phone-contacts-seperator" />
        {/if}

        {#each FilteredContacts.slice(0, ShowingLimit) as Data, Id}
            <Paper
                Icon="user-circle"
                Title={Data.name}
                Description={FormatPhone(Data.phone)}
                HasActions={true}
            >
                <i
                    on:keyup
                    on:click={() => { RemoveContact(Data) }}
                    data-tooltip="Yeet"
                    class="fas fa-user-slash"
                />
                <i
                    on:keyup
                    on:click={() => { DialContact(Data) }}
                    data-tooltip="Bellen"
                    class="fas fa-phone"
                />
                <i
                    on:keyup
                    on:click={() => { MessageContact(Data) }}
                    data-tooltip="Berichten"
                    class="fas fa-comment"
                />
                <i
                    on:keyup
                    on:click={() => { CopyToClipboard(Data.phone) }}
                    data-tooltip="Nummer Kopiëren"
                    class="fas fa-clipboard"
                />
                <i
                    on:keyup
                    on:click={() => { EditContact(Data) }}
                    data-tooltip="Bewerken"
                    class="fas fa-pencil-alt"
                />
            </Paper>
        {/each}

        {#if FilteredContacts.length > ShowingLimit}
            <div style="display: flex; justify-content: center; width: 100%;">
                <Button Color="success" on:click={LoadMore}>Laad Meer</Button>
            </div>
        {/if}
    </PaperList>
</AppWrapper>

<style>
    .phone-contacts-seperator {
        width: 100%;
        height: 0.1vh;
        background-color: white;
        margin: 1vh 0;
    }
</style>
