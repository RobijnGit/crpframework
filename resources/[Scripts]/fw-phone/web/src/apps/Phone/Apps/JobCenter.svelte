<script>
    import * as JOB from "./_jobcenter";

    import { onDestroy, onMount } from "svelte";
    import { OnEvent, SendEvent } from "../../../utils/Utils";
    import { HasVpn, JobManager, PlayerData } from "../phone.stores";

    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";
    import Paper from "../components/Paper.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import Button from "../../../components/Button/Button.svelte";

    let Jobs = [];
    let FilteredJobs = [];
    let TimerInterval;
    let Timer = 0;
    let TimerString = '00:00:00'

    const ConvertMsToHMS = () => {
        const Seconds = Math.floor((Timer / 1000) % 60);
        const Minutes = Math.floor((Timer / (1000 * 60)) % 60);
        const Hours = Math.floor((Timer / (1000 * 60 * 60)) % 24);

        TimerString = `${Hours < 10 ? '0' : ''}${Hours}:${Minutes < 10 ? '0' : ''}${Minutes}:${Seconds < 10 ? '0' : ''}${Seconds}`;
    };

    const FilterJobs = (Value) => {
        const Query = Value.toLowerCase();
        FilteredJobs = Jobs.filter(Val => Val.JobName.toLowerCase().includes(Query));
    };

    let Groups = [];
    let IdleGroups = [];
    let BusyGroups = [];

    OnEvent("SetJobCenterGroups", (Data) => {
        Groups = Data.Groups || [];
        IdleGroups = Groups.filter(Val => Val && Val.State == "Idle")
        BusyGroups = Groups.filter(Val => Val && Val.State != "Idle")
    });

    onMount(() => {
        SendEvent("JobCenter/GetJobs", {}, (Success, Result) => {
            if (!Success) return;

            // Minimize data flow later on.
            const _Jobs = Result.map(({ EmployeeCount, GroupCount, Icon, JobId, JobName, VPNRequired, SalaryRate }) => ({
                EmployeeCount,
                GroupCount,
                Icon,
                JobId,
                JobName,
                VPNRequired,
                SalaryRate
            }));

            Jobs = _Jobs;
            FilteredJobs = _Jobs;
        });

        if ($JobManager.CurrentJob) {
            SendEvent("JobCenter/GetJobGroups", {}, (Success, Result) => {
                if (!Success) return;
                Groups = (Result || []);
                IdleGroups = Groups.filter(Val => Val.State == "Idle")
                BusyGroups = Groups.filter(Val => Val.State != "Idle")
            });

            if ($JobManager.CurrentGroup && $JobManager.CurrentGroup.Tasks.length > 0) {
                SendEvent("JobCenter/GetTaskActivity", {}, (Success, Data) => {
                    if (!Success) return;
                    Timer = Data;
                    ConvertMsToHMS(Timer);
                })

                TimerInterval = setInterval(() => {
                    Timer = Timer - 1000;
                    ConvertMsToHMS(Timer)
                }, 1000);
            };
        };
    });

    onDestroy(() => {
        clearInterval(TimerInterval);
    });
</script>

<AppWrapper>
    {#if !$JobManager.CurrentJob && !$JobManager.CurrentGroup}
        <TextField
            Icon="search"
            Title="Zoeken"
            SubSet={FilterJobs}
            class="phone-misc-input"
        />

        <PaperList>
            {#each FilteredJobs as Data, Id}
                {#if !Data.VPNRequired || $HasVpn}
                    <div class="phone-jobcenter-job-container">
                        <div class="phone-jobcenter-job-container-icon">
                            <i class={Data.Icon} />
                        </div>
                        <div class="phone-jobcenter-job-container-name" style="max-width: 51%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            {#if Data.VPNRequired}
                                <i class="fas fa-user-secret" />
                            {/if}
                            {Data.JobName}
                        </div>
                        <div class="phone-jobcenter-job-container-rate">
                            {#each Array(5) as _, i}
                                {#if (i + 1) > Data.SalaryRate}
                                    <i style="color: #617282;" class="fas fa-dollar-sign"/>
                                {:else}
                                    <i class="fas fa-dollar-sign"/>
                                {/if}
                            {/each}
                        </div>
                        <div class="phone-jobcenter-job-container-countGroups">{Data.GroupCount} <i class="fas fa-people-arrows" /></div>
                        <div class="phone-jobcenter-job-container-countEmployee">{Data.EmployeeCount} <i class="fas fa-user" /></div>
                
                        <div class="phone-card-actions">
                            <i
                                data-tooltip="Zet GPS"
                                class="tooltip fas fa-map-marked"
                                on:keyup on:click={() => { JOB.SetWaypoint(Id + 1) }}
                            />
                        </div>
                    </div>
                {/if}
            {/each}
        </PaperList>
    {:else if $JobManager.CurrentJob && !$JobManager.CurrentGroup}
        <div class="phone-jobcenter-groups-info">Word lid van een inactieve groep of maak je eigen groep aan..</div>
        <div class="phone-jobcenter-groups-info-buttons">
            <Button
                style="margin: 0;"
                Color="success"
                on:click={JOB.CreateGroup}
            >Groep Aanmaken</Button>
            <Button
                style="margin: 0;"
                Color="warning"
                on:click={JOB.Signout}
            >Uitklokken</Button>
        </div>
        
        <PaperList style="top: 13.5vh; height: 71%;">
            {#if IdleGroups.length > 0}
                <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Inactief</p>

                {#each IdleGroups as Data (Data.Id)}
                    <div class="phone-card-component">
                        <div class="phone-card-container">
                            <div class="phone-card-icon"><i class="fas fa-users-slash"></i></div>
                            <div class="phone-card-details">
                                <div class="phone-card-text">
                                    <p>{Data.Members[0].Name}</p>
                                </div>
                                <div class="phone-card-text">
                                    <p>
                                        <i
                                            data-tooltip="Verzoek voor Deelname"
                                            class="tooltip fas fa-sign-in"
                                            on:keyup on:click={() => { JOB.RequestToJoin(Data.Id) }}
                                        />
                                        </p>
                                    <p><i class="fas fa-people-arrows"/> {Data.MaxSize}<i class="fas fa-user" style="margin-left: 0.5vh;"/> {Data.Members.length}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                {/each}
            {/if}

            {#if BusyGroups.length > 0}
                <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Bezig</p>

                {#each BusyGroups as Data (Data.Id)}
                    <div class="phone-card-component">
                        <div class="phone-card-container">
                            <div class="phone-card-icon"><i class="fas fa-users-slash"></i></div>
                            <div class="phone-card-details">
                                <div class="phone-card-text">
                                    <p>{Data.Members[0].Name}</p>
                                </div>
                                <div class="phone-card-text">
                                    <p><i class="fas fa-people-arrows"/> {Data.MaxSize}<i class="fas fa-user" style="margin-left: 0.5vh;"/> {Data.Members.length}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                {/each}
            {/if}
        </PaperList>
    {:else if $JobManager.CurrentJob && $JobManager.CurrentGroup && $JobManager.CurrentGroup.Tasks.length == 0}
        {#if $JobManager.CurrentGroup.State == "Busy"}
            <div class="phone-jobcenter-members-waiting">
                <div class="phone-misc-ripple-container">
                    <div class="phone-misc-ripple">
                        <div></div>
                        <div></div>
                    </div>
                </div>
                <p>Wachten op Werkopdracht...</p>
            </div>
        {/if}

        <PaperList style={$JobManager.CurrentGroup.State == "Busy" ? "top: 14vh; height: 34.4vh;" : "top: 2.2vh; height: 46vh;"}>
            <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Leider</p>
            <Paper
                Icon="user-graduate"
                Title={$JobManager.CurrentGroup.Members[0].Name}
                Notification="green"
            />

            {#if $JobManager.CurrentGroup.Members.length > 1}
                <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Deelnemers</p>
                {#each $JobManager.CurrentGroup.Members.slice(1) as Data, Id}
                    <Paper
                        Icon="user"
                        Title={Data.Name}
                        Notification="green"
                        HasActions={$JobManager.CurrentGroup.Members[0].Cid == $PlayerData.Cid}
                    >
                        <i 
                            data-tooltip="Verwijder van Groep"
                            class="fas fa-user-minus"
                            on:keyup on:click={() => { JOB.KickFromGroup(Id + 2) }} 
                        />
                        <i 
                            data-tooltip="Promoveren naar Leider"
                            class="fas fa-user-graduate"
                            on:keyup on:click={() => { JOB.PromoteToLeader(Id + 2) }} 
                        />
                    </Paper>
                {/each}
            {/if}
        </PaperList>

        <div class="phone-jobcenter-members-buttons">
            {#if $JobManager.CurrentGroup.Members[0].Cid == $PlayerData.Cid}
                <Button Color="success" on:click={JOB.ToggleReady}>{$JobManager.CurrentGroup.State == "Busy" ? "Niet" : ""} Klaar om te Werken</Button>
                <Button Color="success" on:click={JOB.DeleteGroup}>Groep Verwijderen</Button>
            {:else}
                <Button Color="success" on:click={JOB.LeaveGroup}>Groep Verlaten</Button>
            {/if}
        </div>
    {:else}
        <div class="phone-jobcenter-tasks-container">
            <div class="phone-jobcenter-tasks-activity">
                <div class="phone-jobcenter-tasks-activity-container">
                    <div class="phone-jobcenter-tasks-activity-title">{$JobManager.CurrentGroup.Activity.Title}</div>
                    <div class="phone-jobcenter-tasks-activity-abandon">
                        <i
                            data-tooltip="Werkopdracht Annuleren"
                            data-position="left"
                            class="fas fa-times-circle"
                            on:keyup on:click={JOB.AbandonJob}
                        />
                        <div class="phone-jobcenter-tasks-activity-timer">{TimerString}</div>
                    </div>
                </div>
            </div>

            <div class="phone-jobcenter-tasks-list">
                <ul>
                    {#each $JobManager.CurrentGroup.Tasks as Data, Key}
                        <li>
                            <div class="jobcenter-task-seperator">
                                <span class="jobcenter-task-seperator-dot"></span>
                                <span class="jobcenter-task-seperator-connector"></span>
                            </div>
                            <div class="jobcenter-task-content">
                                <div class="jobcenter-task-content-activity-task">
                                    <div class="jobcenter-task-content-actity-task-container">
                                        <div class="jobcenter-task-content-actity-task-wrapper">
                                            {#if Data.Progress >= Data.RequiredProgress}
                                                <div style="text-decoration: line-through;" class="task-name">{Data.Title}</div>
                                                <div class="checkmark-wrapper svelte-p3lfy3">
                                                    <div class="phone-misc-checkmark">
                                                        <svg class="checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
                                                            <circle class="phone-misc-checkmark-circle" cx="26" cy="26" r="25" fill="none"></circle>
                                                            <path class="phone-misc-checkmark-check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"></path>
                                                        </svg>
                                                    </div>
                                                </div>
                                            {:else}
                                                <div class="task-name">{Data.Title}</div>
                                                <div class="task-progress">{Data.Progress} / {Data.RequiredProgress}</div>
                                            {/if}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </li>
                    {/each}
                </ul>
            </div>
        </div>
    {/if}
</AppWrapper>

<style>
    /* List of Jobs */
    .phone-jobcenter-job-container {
        position: relative;
        background-color: #30475d;
        height: max-content;
        min-height: 6vh;
        font-size: 1.4vh;
        margin-bottom: 2.8vh;
        border-top-left-radius: 0.5vh;
        border-top-right-radius: 0.5vh;
        border-bottom: 0.15vh solid white
    }

    .phone-jobcenter-job-container:hover .phone-card-actions {
        display: flex;
        justify-content: center;
        align-items: center
    }

    .phone-jobcenter-job-container-icon {
        float: left;
        width: 7vh;
        height: 6.5vh;
        margin-right: 0.2vh;
        font-size: 4.5vh;
        text-align: center;
        line-height: 6.5vh
    }

    .phone-jobcenter-job-container-name {
        position: relative;
        top: 0.75vh;
        max-width: 67%;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        letter-spacing: -0.035vh
    }

    .phone-jobcenter-job-container-rate {
        position: absolute;
        bottom: 0.6vh;
        left: 4.3vw;
        font-size: 1.7vh;
        max-width: 50%;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        letter-spacing: 1.2vh !important;
        color: #579c49;
    }

    .phone-jobcenter-job-container-countGroups {
        position: absolute;
        top: 0.8vh;
        right: 0.8vh;
        text-align: right
    }

    .phone-jobcenter-job-container-countEmployee {
        position: absolute;
        bottom: 0.9vh;
        right: 1vh;
        text-align: right
    }

    /* List of Job Groups */
    .phone-jobcenter-groups-info {
        position: relative;
        left: 0;
        right: 0;
        margin: 0 auto;
        margin-top: 3.8vh;
        width: 89%;
        font-size: 1.5vh;
        font-family: "Roboto";
        font-weight: 400;
        line-height: 1.43;
        letter-spacing: 0.005vh
    }

    .phone-jobcenter-groups-info-buttons {
        display: flex;
        flex-direction: row;
        justify-content: space-between;
        position: relative;
        left: 0;
        right: 0;
        overflow: hidden;
        margin: 0 auto;
        margin-top: 0.8vh;
        width: 89%;
        padding-bottom: 1.3vh;
        border-bottom: 0.2vh solid white
    }

    /* List of Members */
    .phone-jobcenter-members-waiting {
        position: relative;
        left: 0;
        right: 0;
        width: 89%;
        margin: 0 auto;
        padding-bottom: 0.8vh;
        border-bottom: 0.2vh solid white
    }

    .phone-jobcenter-members-waiting > .phone-misc-ripple-container {
        position: relative;
        left: 0;
        right: 0;
        margin: 0 auto;
        margin-top: 2.3vh;
        width: 8.8vh
    }

    .phone-jobcenter-members-waiting > p {
        text-align: center;
        margin: 0.2vh;
        font-size: 1.5vh;
    }

    .phone-jobcenter-members-buttons {
        position: absolute;
        bottom: 4vh;
        width: 100%;
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    /* Tasks */
    .phone-jobcenter-tasks-container {
        position: relative;
        margin-top: 2.8vh;
        height: 100%;
        width: 100%;
        margin-bottom: 1.4vh;
        font-size: 1.5vh;
        font-family: "Roboto";
        font-weight: 400;
        line-height: 1.43;
        letter-spacing: 0.005vh
    }

    .phone-jobcenter-tasks-activity-container  {
        position: relative;
        left: 0;
        right: 0;
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0.8vh 0;
        margin: 0;
        margin-left: auto;
        margin-right: auto;
        border-bottom: 0.1vh solid white;
        width: 88%
    }

    .phone-jobcenter-tasks-activity-container > .phone-jobcenter-tasks-activity-abandon  {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        align-items: flex-end
    }

    .phone-jobcenter-tasks-activity-container > .phone-jobcenter-tasks-activity-abandon > .phone-jobcenter-tasks-activity-timer  {
        font-size: 1.3vh
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list {
        position: relative;
        left: 0;
        right: 0;
        margin: 0 auto;
        width: 88%;
        max-height: 47.8vh;
        height: 100vh;
        overflow-y: scroll
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list::-webkit-scrollbar {
        display: none
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list>ul {
        display: flex;
        flex-direction: column;
        padding: .6vh 1.6vh;
        flex-grow: 1;
        padding: 0 !important
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li:before {
        flex: none !important;
        content: none !important
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li {
        list-style: none;
        display: flex;
        position: relative;
        min-height: 7vh
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-seperator {
        display: flex;
        flex-direction: column;
        flex: 0;
        align-items: center
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-seperator > .jobcenter-task-seperator-dot {
        display: flex;
        align-self: baseline;
        border-style: solid;
        border-width: .2vh;
        padding: .4vh;
        border-radius: 50%;
        box-shadow: 0 .2vh 0.1vh -0.1vh rgb(0 0 0 / 20%), 0 0.1vh 0.1vh 0 rgb(0 0 0 / 14%), 0 0.1vh 3px 0 rgb(0 0 0 / 12%);
        margin: 1vh 0;
        border-color: transparent;
        color: #fafafa;
        background-color: rgb(63, 81, 181)
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-seperator > .jobcenter-task-seperator-connector {
        width: .15vh;
        background-color: #bdbdbd;
        flex-grow: 1
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-content {
        margin-top: 0.4vh;
        font-size: 1.4vh;
        font-family: "Roboto";
        font-weight: 400;
        line-height: 1.5;
        letter-spacing: 0.005vh;
        flex: 1;
        padding: .5vh 1.4vh;
        text-align: left
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-content > .jobcenter-task-content-activity-task {
        width: 100%;
        position: relative;
        background-color: #30475d;
        height: max-content;
        min-height: 4.2vh;
        padding: 0.6vh;
        margin-bottom: 0.8vh;
        border-top-left-radius: 0.5vh;
        border-top-right-radius: 0.5vh;
        border-bottom: 0.15vh solid white
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-content > .jobcenter-task-content-activity-task > .jobcenter-task-content-actity-task-container {
        display: flex
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-content > .jobcenter-task-content-activity-task > .jobcenter-task-content-actity-task-container > .jobcenter-task-content-actity-task-wrapper {
        width: 100%
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-content > .jobcenter-task-content-activity-task > .jobcenter-task-content-actity-task-container > .jobcenter-task-content-actity-task-wrapper > .task-name,
    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-content > .jobcenter-task-content-activity-task > .jobcenter-task-content-actity-task-container > .jobcenter-task-content-actity-task-wrapper > .task-progress {
        display: flex;
        align-items: center
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-content > .jobcenter-task-content-activity-task > .jobcenter-task-content-actity-task-container > .jobcenter-task-content-actity-task-wrapper > .task-name {
        flex: 1 1
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-content > .jobcenter-task-content-activity-task > .jobcenter-task-content-actity-task-container > .jobcenter-task-content-actity-task-wrapper > .task-progress {
        justify-content: flex-end
    }

    .phone-jobcenter-tasks-container > .phone-jobcenter-tasks-list > ul > li > .jobcenter-task-content > .jobcenter-task-content-activity-task > .jobcenter-task-content-actity-task-container > .jobcenter-task-content-actity-task-wrapper > .checkmark-wrapper {
        position: absolute;
        z-index: 5;
        top: 0;
        right: 0;
        height: 100%;
        opacity: 0;
        pointer-events: none;
        animation: fadeoutpls;
        animation-duration: 5s;
        animation-iteration-count: 1
    }

    @keyframes fadeoutpls {
        0% {
            opacity: 1
        }

        100% {
            opacity: 0
        }
    }

    .phone-misc-checkmark .phone-misc-checkmark-circle {
        stroke-dasharray: 166;
        stroke-dashoffset: 166;
        stroke-width: 2;
        stroke-miterlimit: 10;
        stroke: #009688;
        fill: none;
        -webkit-animation: stroke .6s cubic-bezier(.65, 0, .45, 1) forwards;
        animation: stroke .6s cubic-bezier(.65, 0, .45, 1) forwards
    }

    .phone-misc-checkmark .checkmark {
        width: 5.6vh;
        height: 5.6vh;
        border-radius: 50%;
        display: block;
        stroke-width: 2;
        stroke: #fff;
        stroke-miterlimit: 10;
        margin: 10% auto;
        box-shadow: inset 0 0 0 #009688;
        animation: fill .4s ease-in-out .4s forwards, scale .3s ease-in-out .9s both
    }

    .phone-misc-checkmark .phone-misc-checkmark-check {
        -webkit-transform-origin: 50% 50%;
        transform-origin: 50% 50%;
        stroke-dasharray: 48;
        stroke-dashoffset: 48;
        animation: stroke .3s cubic-bezier(.65, 0, .45, 1) .8s forwards
    }

    @-webkit-keyframes stroke {
        to {
            stroke-dashoffset: 0
        }
    }

    @keyframes stroke {
        to {
            stroke-dashoffset: 0
        }
    }

    @-webkit-keyframes scale {

        0%,
        to {
            -webkit-transform: none;
            transform: none
        }

        50% {
            -webkit-transform: scale3d(1.1, 1.1, 1);
            transform: scale3d(1.1, 1.1, 1)
        }
    }

    @keyframes scale {

        0%,
        to {
            -webkit-transform: none;
            transform: none
        }

        50% {
            -webkit-transform: scale3d(1.1, 1.1, 1);
            transform: scale3d(1.1, 1.1, 1)
        }
    }

    @-webkit-keyframes fill {
        to {
            box-shadow: inset 0 0 0 30px #009688
        }
    }

    @keyframes fill {
        to {
            box-shadow: inset 0 0 0 30px #009688
        }
    }
</style>