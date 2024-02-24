<script>
    import TextField from "../../../components/TextField/TextField.svelte";
    import Button from "../../../components/Button/Button.svelte";
    import { CurrentApps, PlayerData } from "../../../stores";
    import AppContainer from "./components/AppContainer.svelte";
    import ModalContainer from "./components/ModalContainer.svelte";
    import { onMount } from "svelte";
    import { ExtractImageUrls, GetLongTimeLabel, GetTimeLabel, OnEvent, SendEvent } from "../../../utils/Utils";
    import ImageContainer from "./components/ImageContainer.svelte";

    // Basic Application Functions
    const CloseApp = () => {
        CurrentApps.set($CurrentApps.filter(Val => Val.Id != "Unknown"));
        if ($CurrentApps.length > 0) FocusedApp.set($CurrentApps[$CurrentApps.length - 1].Id);
    };

    let innerWidth = 0
    let innerHeight = 0
    
    let DraggingApp = false;
    let Left = 0;
    let Top = 0;

    // center shit dud
    onMount(() => {
        Left = innerWidth * 0.0843749999;
        Top = innerHeight * 0.0851851852;
    })

	const onMouseDown = () => {
		DraggingApp = true;
	}
	
	const onMouseMove = e => {
		if (!DraggingApp) return;

        Left += e.movementX;
        Top += e.movementY;

        if (Left < 0) Left = 0;
        if (Top < 0) Top = 0;
	}
	
	const onMouseUp = () => {
		DraggingApp = false;
	}

    // In-app Functions
    let CurrentTab = "Info";
    let GroupData = {};
    let ChatMessages = [];

    let AddingMember = false;
    let MemberCid = '';

    onMount(() => {
        SendEvent("Unknown/FetchGang", {}, (Success, Data) => {
            if (!Success) return;
            GroupData = Data;
        });
    });

    const ToggleDiscoveredGraffitis = () => {
        SendEvent("Unknown/ToggleDiscoveredGraffitis")
    };

    const ToggleContestedGraffitis = () => {
        SendEvent("Unknown/ToggleContestedGraffitis")
    };

    const FetchGangMessages = () => {
        SendEvent("Unknown/GetMessages", {}, (Success, Data) => {
            ChatMessages = Data;
        });
    };

    const IsMessageSender = Message => {
        return Message.Sender == $PlayerData.Cid;
    };

    const SendChat = (Text) => {
        if (Text.length <= 0) return;
        let [Attachments, Message] = ExtractImageUrls(Text)

        SendEvent("Unknown/SendMessage", { Attachments, Message });
    };

    OnEvent("Unknown/SetMessages", (Data) => {
        ChatMessages = Data;
    })
</script>

<svelte:window bind:innerWidth bind:innerHeight />

<!-- Would rather have the modals in another file, but fuck it, its just one modal here. -->
{#if AddingMember}
    <ModalContainer>
        <h1 style="color: white; text-align: center; text-shadow: 0 0 .5vh rgb(255, 255, 255); font-size: 2vh; font-family: 'Crimson Pro'; font-weight: 500; margin-bottom: 2vh;">Add Group Member</h1>
        <div style="width: 90%; margin: 0 auto;">
            <TextField Title="BSN" Icon="id-card" style="width: 100%" bind:RealValue={MemberCid}/>
            <Button Color="green" style="width: calc(100% - 2vh); text-align: center; margin: 0;" click={() => {
                SendEvent("Unknown/AddMember", { Cid: MemberCid })
                AddingMember = false;
                MemberCid = ''
            }}>ADD MEMBER</Button>
        </div>
    </ModalContainer>
{/if}

<AppContainer class="app-unknown-container" AppId="Unknown" style="left: {Left}px; top: {Top}px;" HideTopbar={true}>
    <div class="app-topbar" on:mousedown={onMouseDown} on:mouseup={onMouseUp} on:mouseleave={onMouseUp} on:mousemove={onMouseMove}>
        <div on:keyup on:click={() => { CurrentTab = "Info" }} class="app-topbar-item {CurrentTab == "Info" ? "active" : ""}"><p>Group Info</p></div>
        <div on:keyup on:click={() => { CurrentTab = "Progression" }} class="app-topbar-item {CurrentTab == "Progression" ? "active" : ""}"><p>Progression</p></div>
        <div on:keyup on:click={() => { CurrentTab = "Members" }} class="app-topbar-item {CurrentTab == "Members" ? "active" : ""}"><p>Members</p></div>
        <div on:keyup on:click={() => { CurrentTab = "Chat"; FetchGangMessages() }} class="app-topbar-item {CurrentTab == "Chat" ? "active" : ""}"><p>Chat</p></div>
        <div on:keyup on:click={CloseApp} class="app-topbar-item"><i class="fas fa-times"></i></div>
    </div>

    <div class="app-container">
        {#if CurrentTab == "Info"}
            <h1>Group Information</h1>
            <p>Current Group: {GroupData?.Label || "No Gang"}</p>
            
            {#if GroupData.Id}
                <div style="display: flex; justify-content: center; width: 70%; margin: 0 auto; margin-top: 5vh;">
                    <div>
                        <h1 style="font-size: 2.5vh;">Current Members</h1>
                        <p style="font-size: 1.7vh;">{1 + GroupData.Members.length}</p>
                    </div>
                    <!-- <div>
                        <h1 style="font-size: 2.5vh;">Sales Today</h1>
                        <p style="font-size: 1.7vh;">{GroupData.Sales}</p>
                    </div>
                    <div>
                        <h1 style="font-size: 2.5vh;">Money Collected</h1>
                        <p style="font-size: 1.7vh;">{FormatCurrency.format(GroupData.TotalCollected)}</p>
                    </div> -->
                </div>

                <div style="display: flex; justify-content: space-between; width: 70%; margin: 0 auto; margin-top: 5vh;">
                    <div>
                        <h1 style="font-size: 2.5vh;">Toggle Discovered Graffiti</h1>
                        <div style="width: 100%; display: flex; justify-content: center;">
                            <Button Color="green" click={ToggleDiscoveredGraffitis}>Toggle</Button>
                        </div>
                    </div>
                    <div>
                        <h1 style="font-size: 2.5vh;">Toggle Contested Graffitis</h1>
                        <div style="width: 100%; display: flex; justify-content: center;">
                            <Button Color="green" click={ToggleContestedGraffitis}>Toggle</Button>
                        </div>
                    </div>
                </div>
            {/if}
        {:else if CurrentTab == "Progression"}
            <h1>Current Progression</h1>

            {#if !GroupData.Id}
                <p>You must be in a gang to see progression.</p>
            {:else}
                <p>Current Graffitis: {GroupData.TotalSprays}</p>
                <div class="gang-progressions-slots">
                    <div class="progression-slot {GroupData.TotalSprays >= 4 ? "unlocked" : ""}">
                        <p style="color: white">{GroupData.TotalSprays >= 4 ? "Known" : "?"}</p>
                        <p style="color: #00a378; font-size: 1.5vh;">Graffitis Needed: 4</p>
                    </div>
                    <div class="progression-slot {GroupData.TotalSprays >= 8 ? "unlocked" : ""}">
                        <p style="color: white">{GroupData.TotalSprays >= 8 ? "Well-Known" : "?"}</p>
                        <p style="color: #00a378; font-size: 1.5vh;">Graffitis Needed: 8</p>
                    </div>
                    <div class="progression-slot {GroupData.TotalSprays >= 16 ? "unlocked" : ""}">
                        <p style="color: white">{GroupData.TotalSprays >= 16 ? "Established" : "?"}</p>
                        <p style="color: #00a378; font-size: 1.5vh;">Graffitis Needed: 16</p>
                    </div>
                    <div class="progression-slot {GroupData.TotalSprays >= 24 ? "unlocked" : ""}">
                        <p style="color: white">{GroupData.TotalSprays >= 24 ? "Respected" : "?"}</p>
                        <p style="color: #00a378; font-size: 1.5vh;">Graffitis Needed: 24</p>
                    </div>
                    <div class="progression-slot {GroupData.TotalSprays >= 36 ? "unlocked" : ""}">
                        <p style="color: white">{GroupData.TotalSprays >= 36 ? "Feared" : "?"}</p>
                        <p style="color: #00a378; font-size: 1.5vh;">Graffitis Needed: 36</p>
                    </div>
                    <div class="progression-slot {GroupData.TotalSprays >= 54 ? "unlocked" : ""}">
                        <p style="color: white">{GroupData.TotalSprays >= 54 ? "Powerful" : "?"}</p>
                        <p style="color: #00a378; font-size: 1.5vh;">Graffitis Needed: 54</p>
                    </div>
                </div>
            {/if}
        {:else if CurrentTab == "Members"}
            <h1>Current Members ({GroupData?.Members?.length + 1 || 0})</h1>
            {#if !GroupData.Id}
                <p>You must be in a gang to manage members.</p>
            {:else}
                <div style="width: 100%; display: flex; justify-content: center;">
                    <Button Color="green" click={() => { AddingMember = true }}>Add Member</Button>
                </div>

                <div class="gang-member-slots">
                    <div class="member-slot">
                        <p style="color: white">{GroupData.Leader.Name}</p>
                        <p style="color: #a30000; opacity: 0.3; font-size: 1.5vh;">Leader cannot be kicked</p>
                    </div>
                    {#each GroupData.Members as Data, Key}
                        <div class="member-slot">
                            <p style="color: white">{Data.Name}</p>
                            <p style="cursor: pointer; color: #a30000; font-size: 1.5vh;" on:keyup on:click={() => {
                                GroupData.Members.splice(Key, 1);
                                GroupData.Members = GroupData.Members;
                                SendEvent("Unknown/KickMember", { Cid: Data.Cid })
                            }}>Kick Member</p>
                        </div>
                    {/each}
                </div>
            {/if}
        {:else if CurrentTab == "Chat"}
            {#if !GroupData.Id}
                <h1>Oh-oh..</h1>
                <p>You must be in a gang to use chat.</p>
            {:else if GroupData.TotalSprays < 16}
                <h1>Oh-oh..</h1>
                <p>Insufficient reputation to use chat, you need at least level 3.</p>
            {:else}
                <div class="app-unknown-chat-wrapper">
                    <div class="app-unknown-chat-texts">
                        {#each ChatMessages as Data, Id}
                            <div class="app-unknown-chat-text" class:text-out={IsMessageSender(Data)}>
                                {#if Data.Message && Data.Message.length > 0}
                                    <div class="inner" class:text-out={IsMessageSender(Data)}>
                                        <p style="color: white; text-align: right;">{Data.Message}</p>
                                    </div>
                                {/if}

                                {#if Data.Attachments.length > 0}
                                    <ImageContainer Attachments={Data.Attachments} />
                                {/if}
            
                                <div data-tooltip={GetLongTimeLabel(Data.Timestamp)} class="timestamp">
                                    <p>{Data.SenderName} - {GetTimeLabel(Data.Timestamp)}</p>
                                </div>
                            </div>
                        {/each}
                    </div>

                    <TextField
                        Title=''
                        Placeholder='Bericht'
                        OnSubmit={SendChat}
                    />
                </div>
            {/if}
        {/if}
    </div>
</AppContainer>

<style>
    :global(.app-unknown-container)::before {
        display: block;
        content: "";

        pointer-events: none;

        position: absolute;
        width: 100%;
        height: 100%;

        background: url(../images/unknown/background.jpg);
        background-size: cover;
        background-position: center 0;

        opacity: 0.015;
        filter: blur(.2vh);
    }

    :global(.app-unknown-container) {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: #0b0d11 !important;
    }

    .app-topbar {
        display: flex;
        height: 6.5vh;
        width: 100%;
        border-bottom: 0.1vh solid rgba(255, 255, 255, 0.5);
        cursor: grab;
    }

    .app-topbar > .app-topbar-item {
        height: 100%;
        line-height: 6.5vh;
        
        padding: 0 3vh;
        text-align: center;
        color: white;
        
        font-family: 'Crimson Pro';
        font-size: 1.7vh;

        cursor: pointer;
    }

    .app-topbar > .app-topbar-item.active {
        color: rgb(216, 255, 245);
        text-shadow: 0 0 .9vh rgb(0, 255, 187);
    }

    .app-topbar > .app-topbar-item:last-of-type {
        margin-left: auto;
    }

    .app-container {
        margin: 6vh auto 0 auto;

        width: 80%;
        height: 70%;
    }

    .app-container h1 {
        color: white;
        text-align: center;
        text-shadow: 0 0 .5vh rgb(255, 255, 255);

        font-size: 3vh;
        font-family: 'Crimson Pro';
        font-weight: 500;
        margin-bottom: .5vh;
    }

    .app-container p {
        color: rgba(255, 255, 255, 0.3);
        text-align: center;

        font-size: 2vh;
        font-family: 'Crimson Pro';
        font-weight: normal;
    }

    /* Progression */
    .gang-progressions-slots::-webkit-scrollbar { display: none }
    .gang-progressions-slots {
        width: 100%;
        height: fit-content;
        max-height: 37.3vh;

        padding: .2vh;
        margin: 0 auto;
        margin-top: 2vh;

        overflow-y: auto;

        display: grid;
        grid-template-columns: repeat(4, 22.9vh);
        grid-column-gap: 1.5vh;
        grid-row-gap: 1.5vh;
    }

    .progression-slot.unlocked { box-shadow: 0 0 .2vh rgba(0, 255, 187, 0.4); }
    .progression-slot {
        width: 100%;
        padding: 3vh 0;

        background: linear-gradient(180deg, rgb(15, 15, 20) 0%, rgb(10, 10, 10) 100%);
        box-shadow: 0 0 .2vh rgba(0, 0, 0, 1.0);
    }

    /* Members */
    .gang-member-slots::-webkit-scrollbar { display: none }
    .gang-member-slots {
        width: 100%;
        height: fit-content;
        max-height: 37.3vh;

        padding: .2vh;
        margin: 0 auto;
        margin-top: 2vh;

        overflow-y: auto;

        display: grid;
        grid-template-columns: repeat(2, calc(47.4vh - 2vh));
        grid-column-gap: 3.5vh;
        grid-row-gap: 1.5vh;
    }

    .member-slot {
        display: flex;
        justify-content: space-between;

        width: 100%;
        padding: 1.5vh 1vh;

        background: linear-gradient(180deg, rgb(15, 15, 20) 0%, rgb(10, 10, 10) 100%);
        box-shadow: 0 0 .2vh rgba(0, 255, 187, 0.4);
    }

    /* Chat */
    .app-unknown-chat-wrapper {
        position: relative;
        top: -2.5vh;
        left: 0;
        right: 0;
        margin: 0 auto;

        width: 35%;
        height: 53.5vh;
    }

    .app-unknown-chat-texts {
        left: 0;
        right: 0;
        margin: 0 auto;
        width: 100%;
        height: 50.5vh;
        overflow: hidden;
        overflow-y: auto;
        display: flex;
        flex-direction: column-reverse;
    }

    .app-unknown-chat-texts::-webkit-scrollbar {
        display: none
    }

    .app-unknown-chat-texts > .app-unknown-chat-text {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-items: flex-start
    }

    .app-unknown-chat-texts > .app-unknown-chat-text.text-out {
        align-items: flex-end
    }

    .app-unknown-chat-texts > .app-unknown-chat-text > .timestamp {
        display: flex;
        margin-top: 0.18vh;
        padding: 0 0.2vh
    }

    .app-unknown-chat-texts > .app-unknown-chat-text > .timestamp > p {
        color: #9e9e9e;
        text-align: right;
        font-size: 1.1vh;
        margin: 0
    }

    .app-unknown-chat-texts > .app-unknown-chat-text > .inner {
        width: max-content;
        max-width: 90%;
        border-radius: 1.1vh;
        padding: 0.7vh;
        margin: 2vh 0 0;
        background-color: #37474f
    }

    .app-unknown-chat-texts > .app-unknown-chat-text > .inner.text-out {
        background-color: #08443a;
        text-align: right
    }

    .app-unknown-chat-texts > .app-unknown-chat-text > .inner > p {
        font-size: 1.35vh;
        margin: 0.2vh;
        overflow-wrap: anywhere
    }
</style>