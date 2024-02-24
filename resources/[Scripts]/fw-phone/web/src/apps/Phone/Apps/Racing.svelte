<script>
    import Ripple from '@smui/ripple';
    import AppWrapper from "../components/AppWrapper.svelte";

    import * as RC from "./_racing";
    import { Races, Tracks } from "./_racing";

    import PaperList from '../components/PaperList.svelte';
    import { onMount } from 'svelte';
    import Paper from '../components/Paper.svelte';
    import RacingPaper from '../components/RacingPaper.svelte';
    import { LoaderModal, PlayerData } from '../phone.stores';
    import TextField from '../../../components/TextField/TextField.svelte';
    import Button from '../../../components/Button/Button.svelte';
    import { ExtractImageUrls, OnEvent, SendEvent } from '../../../utils/Utils';

    import MessageTexts from './components/MessageTexts.svelte';

    let CurrentTab = "Races";
    let FilteredTracks = [];
    let CurrentLeaderboard = false;
    let LeaderboardClass = "Alles";

    let CanCreateTracks = false;
    let IsCreatingTrack = false;

    const OpenLeaderboard = (TrackId) => {
        CurrentTab = "Leaderboard";
        LeaderboardClass = "Alles";

        SendEvent("Racing/GetLeaderboard", {Id: TrackId}, (Success, Data) => {
            if (!Success) return;
            CurrentLeaderboard = Data;
        });
    };

    const SetCurrentTab = async (Tab) => {
        CurrentTab = Tab;
        if (Tab == 'Races') {
            RC.GetRaces()
        } else if (Tab == 'Tracks') {
            Tracks.set(await RC.GetTracks());
            FilteredTracks = $Tracks;
        };
    };

    const FilterTrack = (Query) => {
        Query = Query.toLowerCase();
        FilteredTracks = $Tracks.filter(Val => Val.Name.toLowerCase().includes(Query));
    }

    onMount(async () => {
        CanCreateTracks = await RC.CanCreateTracks();
        IsCreatingTrack = await RC.IsCreatingTrack();
        RC.GetRaces()
    });

    let ChatData = false;

    const OpenRacingChat = ({Id, Name}) => {
        LoaderModal.set(true);
        
        SendEvent("Racing/GetTexts", {Id}, (Success, Result) => {
            LoaderModal.set(false);
            if (!Success || !Result.Success) return;

            ChatData = {
                RaceId: Id,
                RaceTitle: Name,
                Texts: Result.Texts || []
            }

        })
    };

    const SendRacingMessage = (Text) => {
        if (Text.length <= 0) return;
        if (!ChatData || ChatData.RaceId == undefined) return;

        const [Attachments, Message] = ExtractImageUrls(Text);
        SendEvent("Racing/SendMessage", {
            RaceId: ChatData.RaceId,
            Attachments, Message
        });
    };

    const CloseRacingChat = () => {
        ChatData = false;
    };

    OnEvent("Racing/UpdateChat", (Data) => {
        if (!ChatData) return;

        ChatData.Texts = Data.Texts;
    });
</script>

<AppWrapper>
    {#if !ChatData}
        <div class="phone-racing-topbar">
            <div
                class="phone-racing-option"
                class:phone-racing-option-active={CurrentTab == 'Races'}
                use:Ripple={{ surface: true, active: true, color: 'primary' }}
                on:keyup on:click={() => { SetCurrentTab('Races') }}
            >
                <i class="fas fa-flag-checkered" />
            </div>
            <div
                class="phone-racing-option"
                class:phone-racing-option-active={CurrentTab == 'Tracks'}
                use:Ripple={{ surface: true, active: true, color: 'primary' }}
                on:keyup on:click={() => { SetCurrentTab('Tracks') }}
            >
                <i class="fas fa-map-marker" />
            </div>
            <div
                class="phone-racing-option"
                class:phone-racing-option-active={CurrentTab == 'Leaderboard'}
                use:Ripple={{ surface: true, active: true, color: 'primary' }}
                on:keyup on:click={() => { SetCurrentTab('Leaderboard') }}
            >
                <i class="fas fa-trophy" />
            </div>
        </div>

        <PaperList style="top: 8vh; height: 48.3vh;">
            {#if CurrentTab == 'Races'} <!-- List of Pending, Active and Completed races -->
                {#if $Races.some(Val => Val.State == "Pending")}
                    <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Afwachting</p>

                    {#each $Races.filter(Val => Val.State == "Pending") as Data (Data.Id)}
                        <RacingPaper
                            Title={Data.Name}
                            DescriptionHtml={true}
                            Description={RC.GetRaceDescription(Data)} 
                            HasDrawer={true}
                            HasActions={true}
                            Drawers={RC.GetRacersDrawer(Data)}
                        >
                            <i
                                data-tooltip="Zet GPS"
                                class="fas fa-map-marker"
                                on:keyup on:click={() => RC.SetGPS(Data.TrackId)}
                            />
                            <i
                                data-tooltip="Preview"
                                class="fas fa-eye"
                                on:keyup on:click={() => RC.Preview(Data.TrackId)}
                            />

                            {#if Data.Racers.find(Val => Val.Cid == $PlayerData.Cid)}
                                <i
                                    data-tooltip="Chat"
                                    class="fas fa-comment"
                                    on:keyup on:click={() => OpenRacingChat(Data)}
                                />

                                {#if Data.Creator == $PlayerData.Cid}
                                    <i
                                        data-tooltip="Race Starten"
                                        class="fas fa-arrow-circle-right"
                                        on:keyup on:click={() => RC.StartRace(Data)}
                                    />
                                    <i
                                        data-tooltip="Race Beëindigen"
                                        class="fas fa-flag-checkered"
                                        on:keyup on:click={() => RC.EndRace(Data)}
                                    />
                                {:else}
                                    <i
                                        data-tooltip="Race Verlaten"
                                        class="fas fa-user-minus"
                                        on:keyup on:click={() => RC.LeaveRace(Data)}
                                    />
                                {/if}
                            {:else}
                                <i
                                    data-tooltip="Deelnemen aan Race"
                                    class="fas fa-user-plus"
                                on:keyup on:click={() => RC.JoinRace(Data)}
                                />
                            {/if}
                        </RacingPaper>
                    {/each}
                {/if}

                {#if $Races.some(Val => Val.State == "Active")}
                    <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Actief</p>

                    {#each $Races.filter(Val => Val.State == "Active") as Data (Data.Id)}
                        <RacingPaper
                            Title={Data.Name}
                            DescriptionHtml={true}
                            Description={RC.GetRaceDescription(Data)} 
                            HasDrawer={true}
                            HasActions={Data.Racers.findIndex(Val => Val.Cid == $PlayerData.Cid) > -1}
                            Drawers={RC.GetRacersDrawer(Data)}
                        >
                            {#if Data.Racers.find(Val => Val.Cid == $PlayerData.Cid)}
                                {#if Data.Creator == $PlayerData.Cid}
                                    <i
                                        data-tooltip="Race Beëindigen"
                                        class="fas fa-flag-checkered"
                                        on:keyup on:click={() => RC.EndRace(Data)}
                                    />
                                {:else}
                                    <i
                                        data-tooltip="Race Verlaten"
                                        class="fas fa-user-minus"
                                        on:keyup on:click={() => RC.LeaveRace(Data)}
                                    />
                                {/if}
                            {/if}
                        </RacingPaper>
                    {/each}
                {/if}

                {#if $Races.some(Val => Val.State == "Completed")}
                    <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Voltooid</p>

                    {#each $Races.filter(Val => Val.State == "Completed") as Data (Data.Id)}
                        <RacingPaper
                            Title={Data.Name}
                            DescriptionHtml={true}
                            Description={RC.GetRaceDescription(Data)} 
                            HasActions={true}
                            HasDrawer={true}
                            Drawers={RC.GetRacersDrawer(Data)}
                        >
                            <i
                                data-tooltip="Leaderboard"
                                class="fas fa-trophy"
                                on:keyup on:click={() => OpenLeaderboard(Data.TrackId) }
                            />
                        </RacingPaper>
                    {/each}
                {/if}
            {:else if CurrentTab == 'Tracks'} <!-- List of Tracks -->
                <TextField
                    Title="Zoeken"
                    Icon="search"
                    SubSet={FilterTrack}
                    class="phone-misc-input"
                    style="margin-top: .5vh; width: 100%"
                />

                {#if CanCreateTracks}
                    <div style="display: flex; flex-direction: column; justify-content: center; align-items: center; width: 100%;">
                        {#if IsCreatingTrack}
                            <Button Color="success" on:click={async() => {
                                RC.SaveRaceTrack();
                                IsCreatingTrack = await RC.IsCreatingTrack();
                            }}>Track Opslaan</Button>
                            <Button Color="warning" on:click={async() => {
                                RC.CancelCreation();
                                IsCreatingTrack = await RC.IsCreatingTrack();
                            }}>Track Annuleren</Button>
                        {:else}
                            <Button Color="success" on:click={async() => {
                                RC.CreateRaceTrack();
                                IsCreatingTrack = await RC.IsCreatingTrack();
                            }}>Nieuwe Track Creëren</Button>
                        {/if}
                    </div>
                {/if}

                <PaperList style="top: {CanCreateTracks ? (IsCreatingTrack ? 14 : 10) : 6}vh; height: {CanCreateTracks ? (IsCreatingTrack ? 34.3 : 38.2) : 42.2}vh; width: 100%;">
                    {#each FilteredTracks as Data (Data.Id)}
                        <Paper
                            Title={Data.Name}
                            Description={Data.Type}
                            HasActions={true}
                            Aux="{Data.Distance.toFixed(2)}km"
                        >
                            <i
                                data-tooltip="Leaderboard"
                                class="fas fa-trophy"
                                on:keyup on:click={() => OpenLeaderboard(Data.Id)}
                            />
                            <i
                                data-tooltip="Preview"
                                class="fas fa-eye"
                                on:keyup on:click={() => RC.Preview(Data.Id)}
                            />
                            <i
                                data-tooltip="Zet GPS"
                                class="fas fa-map-marker"
                                on:keyup on:click={() => RC.SetGPS(Data.Id)}
                            />
                            <i
                                data-tooltip="Race Aanmaken"
                                class="fas fa-flag-checkered"
                                on:keyup on:click={() => RC.CreateRace(Data)}
                            />
                        </Paper>
                    {/each}
                </PaperList>
            {:else if CurrentTab == 'Leaderboard'} <!-- List of Tracks with Leaderboard -->
                {#if CurrentLeaderboard}
                    <h1>Best Lap Times</h1>
                    <h2 style="font-weight: normal;">{CurrentLeaderboard.Track}</h2>
                    <TextField
                        Title="Vehicle Class"
                        style="width: 100%;"
                        bind:Value={LeaderboardClass}
                        Select={[
                            { Text: "Alles" },
                            { Text: "S" },
                            { Text: "A" },
                            { Text: "B" },
                            { Text: "C" },
                            { Text: "D" },
                            { Text: "E" },
                            { Text: "M" },
                        ]}
                    />

                    <table
                        style="width: 100%; font-size: 1.3vh;"
                    >
                        <tr>
                            <th style="width: 2vh; text-align: center;">#</th>
                            <th style="text-align: left;">Best Lap Time</th>
                        </tr>
                        {#each CurrentLeaderboard.Players.filter(Val => {
                            if (LeaderboardClass == "Alles") return true;
                            return LeaderboardClass == Val.Class;
                        }) as Data, Id}
                            <tr>
                                <td style="width: 2vh; text-align: center;">{Data.Position}</td>
                                <td style="text-align: left;">{Data.Time}<br/>{Data.Alias} | {Data.Vehicle}</td>
                            </tr>
                        {/each}
                    </table>
                {/if}
            {/if}
        </PaperList>
    {:else}
        <div class="phone-misc-icons">
            <i
                data-tooltip="Sluiten"
                data-position="left"
                class="fas fa-times"
                on:keyup
                on:click={() => CloseRacingChat()}
            />
        </div>

        <div style="margin-top: 2.8vh; margin-left: 7%;">
            <h1>Chat</h1>
            <h2 style="font-weight: normal;">{ChatData.RaceTitle}</h2>
        </div>

        <MessageTexts
            style="top: 7.5vh; height: 44vh;"
            Texts={ChatData.Texts}
        />

        <TextField
            Title=''
            Placeholder="Verstuur bericht..."
            style="position: absolute; left: 0; right: 0; bottom: 4.7vh; margin: 0 auto; width: 89%;"
            OnSubmit={SendRacingMessage}
        />
    {/if}

</AppWrapper>

<style>
    .phone-racing-topbar {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        position: absolute;
        top: 3vh;
        left: 0;
        right: 0;
        width: 89%;
        height: 4.8vh;
        margin: 0 auto
    }

    .phone-racing-topbar > .phone-racing-option {
        flex-grow: 1;
        cursor: pointer;
        font-size: 1.5vh;
        color: #c1c3c8;
        line-height: 4.8vh;
        text-align: center
    }

    .phone-racing-option-active {
        color: #95ef77 !important;
        box-shadow: inset 0 -0.2vh 0 #95ef77
    }

    table {
        border-collapse: collapse;
    }

    th {
        border-bottom: .1vh solid #454b52;
        padding: 1vh .5vh;
    }

    td {
        border-bottom: .1vh solid #454b52;
        padding: 1vh .5vh;
    }
</style>