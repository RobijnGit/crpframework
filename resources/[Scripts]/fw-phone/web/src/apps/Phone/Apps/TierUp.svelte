<script>
    import { onMount } from "svelte";
    import { SendEvent, SetDropdown, ShowSuccessModal } from "../../../utils/Utils";
    import { InputModal, LoaderModal, PlayerData } from "../phone.stores";

    import Button from "../../../components/Button/Button.svelte"

    import AppWrapper from "../components/AppWrapper.svelte";
    import Paper from "../components/Paper.svelte";
    import PaperList from "../components/PaperList.svelte";

    let CurrentGroup = false;

    const FetchGroup = () => {
        SendEvent("TierUp/GetGroup", {}, (Success, Data) => {
            if (!Success) return;
            CurrentGroup = Data;
        })
    };

    const CreateGroup = () => {
        LoaderModal.set(true);

        SendEvent("TierUp/CreateGroup", {}, (Success, Data) => {
            LoaderModal.set(false);
            if (!Success) return;

            if (Data.Success) {
                FetchGroup();
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
    };

    const AddParticipant = () => {
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

                SendEvent("TierUp/InviteParticipate", {...Result}, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;

                    if (Data.Success) {
                        FetchGroup();
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

    const LeaveGroup = () => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: "Weet je zeker dat je de groep wilt verlaten?",
                    Data: {
                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                    },
                },
            ],
            OnSubmit: () => {
                LoaderModal.set(true);
                SendEvent("TierUp/LeaveGroup", {}, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
    
                    if (Data.Success) {
                        FetchGroup();
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
                        ]
                    })
    
                })
            }
        })
    };
    
    const DeleteGroup = () => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: "Weet je zeker dat je de groep wilt verwijden?",
                    Data: {
                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                    },
                },
            ],
            OnSubmit: () => {
                LoaderModal.set(true);
                SendEvent("TierUp/DeleteGroup", {}, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
    
                    if (Data.Success) {
                        FetchGroup();
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
                        ]
                    })
    
                })
            }
        })
    };
    
    const KickMember = (Data) => {
        LoaderModal.set(true);
        SendEvent("TierUp/KickMember", {...Data}, (Success, Data) => {
            LoaderModal.set(false);
            if (!Success) return;

            if (Data.Success) {
                FetchGroup();
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
                ]
            })
        });
    };

    const TransferOwnership = (Data) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: "Weet je zeker dat je de groep eigenaarschap wilt overdragen?",
                    Data: {
                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                    },
                },
            ],
            OnSubmit: () => {
                LoaderModal.set(true);
                SendEvent("TierUp/TransferOwnership", {...Data}, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
    
                    if (Data.Success) {
                        FetchGroup();
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
                        ]
                    })
    
                })
            }
        })
    };

    const GetOptionsDropdown = () => {
        let Retval = [];

        Retval.push({
            Icon: "user-plus",
            Text: "Uitnodigen",
            Cb: AddParticipant,
        });

        if (CurrentGroup.members[0].Cid != $PlayerData.Cid) {
            Retval.push({
                Icon: "sign-out",
                Text: "Verlaten",
                Cb: LeaveGroup,
            });
        } else {
            Retval.push({
                Icon: "trash-alt",
                Text: "Verwijderen",
                Cb: DeleteGroup,
            });
        }

        return Retval;
    };

    onMount(() => {
        FetchGroup();
    });
</script>

<AppWrapper>
    {#if CurrentGroup}
        <div class="phone-misc-icons">
            <i
                class="fas fa-ellipsis-v"
                on:keyup
                on:click={(event) => {
                    const IconPosition = event.target.getBoundingClientRect();
                    const Left = IconPosition.left;
                    const Top = IconPosition.bottom - 15;
                    SetDropdown(true, GetOptionsDropdown(), { Left, Top });
                }}
            />
        </div>
    {/if}

    <div class="tierup-logo">
        <img src="./images/tierup-logo.png" alt="">
    </div>

    {#if CurrentGroup}
        <div class="tierup-progress">
            <p>Level {CurrentGroup.Progression.CurrentLevel}</p>
            <div class="tierup-progress-bar">
                <div class="tierup-progress-bar__fill" style="width: {CurrentGroup.Progression.Progress}%;" />
            </div>
            <p>Level {CurrentGroup.Progression.NextLevel}</p>
        </div>
    {/if}

    <PaperList style="top: 14.7vh; height: 41.5vh">
        {#if !CurrentGroup}
            <div style="display: flex; justify-content: center;">
                <Button
                    Color="success"
                    style="margin: 0 auto; margin-top: 1vh;"
                    on:click={CreateGroup}
                >Groep Aanmaken</Button>
            </div>
        {:else}
            <Paper
                Icon="fa fa-user-graduate"
                Title={CurrentGroup.members[0].Name}
                Notification={CurrentGroup.members[0].Online ? "green" : "red"}
            />

            {#if CurrentGroup.members.length > 1}
                <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Deelnemers</p>

                {#each CurrentGroup.members.slice(1) as Data, Key}
                    <Paper
                        Icon="fas fa-user"
                        Title={Data.Name}
                        Notification={Data.Online ? "green" : "red"}
                        HasActions={CurrentGroup.members[0].Cid == $PlayerData.Cid}
                    >
                        <i
                            data-tooltip="Kick"
                            class="fas fa-user-times"
                            on:keyup on:click={() => { KickMember(Data) }}
                        />
                        <i
                            data-tooltip="Eigenschap overdragen"
                            class="fas fa-user-graduate"
                            on:keyup on:click={() => { TransferOwnership(Data) }}
                        />
                    </Paper>
                {/each}
            {/if}
        {/if}
    </PaperList>
</AppWrapper>

<style>
    .tierup-logo {
        margin: 0 auto;

        width: 75%;
        margin-top: 5vh;
    }

    .tierup-logo > img {
        width: 100%;
        height: auto;
    }

    .tierup-progress {
        margin: 0 auto;
        display: flex;

        width: 90%;

        justify-content: space-between;

        font-family: Roboto;
        font-size: 1vh;

        color: white;

        margin-top: 1vh;
    }

    .tierup-progress-bar {
        width: 67%;
        background-color: #30475e;

        border-radius: 5vh;

        height: 0.5vh;
        margin: auto 0;
    }

    .tierup-progress-bar__fill {
        width: 0%;
        height: 100%;
        background: #69cbd3;
        border-radius: 5vh;
    }
</style>
