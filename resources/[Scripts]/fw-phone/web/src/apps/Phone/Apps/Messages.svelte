<script>
    import * as MSG from "./_messages";

    import { onMount } from "svelte";
    import { GetLongTimeLabel, GetTimeLabel, OnEvent, SendEvent } from "../../../utils/Utils";
    import { PlayerData, CurrentChat } from "../phone.stores";
    
    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import Paper from "../components/Paper.svelte";
    import ImageContainer from "../components/ImageContainer.svelte";
    import MessageTexts from "./components/MessageTexts.svelte";

    let Chats = [];
    let FilteredChats = [];
    let FilteredTexts = [];

    const FilterChats = (Value) => {
        const Query = Value.toLowerCase();
        FilteredChats = Chats.filter(
            (Val) => 
                Val.to_phone.includes(Query) ||
                Val.name.toLowerCase().includes(Query)
        );

        FilteredChats.sort((a, b) => b.messages[0].Timestamp - a.messages[0].Timestamp);
    };

    const FilterTexts = (Value) => {
        const Query = Value.toLowerCase();
        FilteredTexts = $CurrentChat.messages.filter(
            (Val) => 
                Val.Message.toLowerCase().includes(Query)
        );
    };

    OnEvent("Messages/SetChats", (Data) => {
        Chats = Object.values(Data.Chats);
        FilteredChats = Object.values(Data.Chats);
        FilterChats("");

        if ($CurrentChat) {
            const Chat = Chats.find(Val => Val.to_phone == $CurrentChat.to_phone);
            CurrentChat.set(Chat);
            FilterTexts("");
        };
    });

    onMount(() => {
        SendEvent("Messages/GetChats", {}, (Success, Data) => {
            if (!Success) return;
            Chats = Object.values(Data);
            FilteredChats = Object.values(Data);
            FilterChats("");

            if ($CurrentChat) {
                const Chat = Chats.find(Val => Val.to_phone == $CurrentChat.to_phone);
                CurrentChat.set(Chat);
                FilterTexts("");
            };
        });
    });
</script>

<AppWrapper>
    {#if !$CurrentChat}
        <div class="phone-misc-icons">
            <i
                data-tooltip="Vestuur Bericht"
                data-position="left"
                class="fas fa-comment"
                on:keyup
                on:click={MSG.SendMessageModal}
            />
        </div>

        <TextField
            Title="Zoeken"
            Icon="search"
            SubSet={FilterChats}
            class="phone-misc-input"
        />

        <PaperList>
            {#each FilteredChats as Data, Key}
                <Paper
                    Icon='user-circle'
                    Title={Data.name}
                    Notification={!MSG.IsMessageSender(Data.messages[0]) && Data.messages[0].Unread === 1}
                    Description={MSG.GetLastMessage(Data)}
                    DescriptionHtml={true}
                    on:click={() => {
                        CurrentChat.set(Data)
                        FilterTexts("");
                    }}
                />
            {/each}
        </PaperList>
    {:else}
        <div class="phone-misc-icons phone-misc-back">
            <i
                class="fas fa-chevron-left"
                on:keyup
                on:click={() => {
                    SendEvent("Messages/SetChatRead", {
                        ToPhone: $CurrentChat.to_phone,
                        FromPhone: $PlayerData.PhoneNumber
                    });
                    CurrentChat.set(false);
                }}
            />
        </div>

        <TextField
            Title="Zoeken"
            Icon="search"
            SubSet={FilterTexts}
            class="phone-misc-input phone-misc-input2"
        />

        <div class="phone-misc-icons">
            <i
                data-tooltip="Bellen"
                data-position="left"
                class="fas fa-phone"
                on:keyup
                on:click={() => MSG.CallContact($CurrentChat.to_phone)}
            />
        </div>

        <div class="phone-messages-texts-contact">
            <i class="fas fa-user-circle"/>
            <p>{@html MSG.GetContactInformation($CurrentChat)}</p>
        </div>

        <MessageTexts Texts={FilteredTexts} />

        <TextField
            Title=''
            Placeholder="Verstuur bericht..."
            style="position: absolute; left: 0; right: 0; bottom: 4.7vh; margin: 0 auto; width: 89%;"
            OnSubmit={MSG.SendMessage}
        />
    {/if}
</AppWrapper>

<style>
    .phone-messages-texts-contact {
        position: absolute;
        left: 2vh;
        top: 9.5vh;
        height: 3vh;
        display: flex;
        flex-direction: row
    }

    .phone-messages-texts-contact > i {
        color: black;
        font-size: 3vh;
        margin-right: 1vh
    }

    .phone-messages-texts-contact > p {
        margin: 0;
        position: relative;
        top: 50%;
        transform: translateY(-50%);
        font-size: 1.3vh;
        height: max-content
    }
</style>