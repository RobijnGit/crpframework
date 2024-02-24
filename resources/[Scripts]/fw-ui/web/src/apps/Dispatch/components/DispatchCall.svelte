<script>
    import { GetTimeLabel, SendEvent as _SendEvent, SetDropdown } from "../../../utils/Utils";
    import { DispatchUnits } from "../dispatch.store";
    const SendEvent = (Event, Parameters, Callback) => _SendEvent(Event, Parameters, Callback, "fw-mdw");

    export let Color = 'Blue';
    export let Animation = false;

    // Header
    export let Id = false;
    export let Code = false;
    export let Title = '';
    export let Coords = false;

    // Information
    export let Information = [];
    export let Radio = false;
    export let Timestamp = new Date().getTime();

    export let Units = { Police: [], EMS: [] };

    const GetUnits = (CallId) => {
        const Units = [...$DispatchUnits['Police'], ...$DispatchUnits['EMS']].sort((a, b) => {
            if (a.Callsign < b.Callsign) return -1;
            if (a.Callsign > b.Callsign) return 1;
            return 0;
        });

        let Retval = [];

        for (let i = 0; i < Units.length; i++) {
            const Unit = Units[i];
            Retval.push({
                Text: `${Unit.Units[0].Callsign} - ${Unit.Units[0].Name}`,
                Value: Unit.Cid,
                Cb: (Value) => {
                    SendEvent("Dispatch/ToggleCallUnit", { Cid: Value, Id: CallId })
                }
            });
        };

        return Retval;
    };

    const OnCallClick = (Element) => {
        if (!Id) return;

        if (Element.target.className === 'fas fa-map-marker-alt') {
            SendEvent("Dispatch/SetGPS", Coords);
            return;
        };

        var Container = Element.target.closest(".dispatch-call-container");
        var DropdownLeft = Element.pageX;

        if (DropdownLeft + (document.body.clientHeight * 25) / 100 > document.body.clientWidth) {
            DropdownLeft = document.body.clientWidth - (document.body.clientHeight * 25) / 100;
        };

        if (Color.toLowerCase() === 'active') {
            let Options = [
                {
                    Text: "Zet GPS Locatie",
                    Cb: () => {
                        SendEvent("Dispatch/SetGPS", Coords);
                    },
                },
                {
                    Text: "Zet Radio Frequentie",
                    Cb: () => {
                        SendEvent("Mdw/Close");
                        setTimeout(() => {
                            SendEvent("Dispatch/SetRadioFrequency", { Id });
                        }, 100);
                    },
                },
                ...GetUnits(Id),
                {
                    Text: "Melding Verwijderen",
                    Cb: () => {
                        SendEvent("Dispatch/Dismiss", { Id, IsCall: true });
                    },
                },
                {
                    Text: "Alle Eenheden Afkoppelen",
                    Cb: () => {
                        SendEvent("Dispatch/RemoveUnits", { Id });
                    },
                },
            ];

            if (!Coords) {
                Options.splice(0, 1);
            }

            SetDropdown(true, Options, {
                Top: Container.offsetTop + Container.offsetHeight,
                Left: DropdownLeft,
            });

            return;
        }

        let Options = [
            {
                Text: "Zet GPS Locatie",
                Cb: () => {
                    SendEvent("Dispatch/SetGPS", Coords);
                },
            },
            {
                Text: "Melding Creëren",
                Cb: () => {
                    SendEvent("Dispatch/CreateCall", { Id });
                },
            },
            {
                Text: "Ping Verwijderen",
                Cb: () => {
                    SendEvent("Dispatch/Dismiss", { Id, IsCall: false });
                },
            },
        ];

        if (!Coords) Options.splice(0, 1);

        SetDropdown(true, Options, {
            Top: Container.offsetTop + Container.offsetHeight,
            Left: DropdownLeft,
        });
    };
</script>

<div on:keyup on:click={OnCallClick} class="dispatch-call-container call-{Color.toLowerCase() || "blue"} {Animation ? `fade-${Animation}` : ""}" style="{Color.toLowerCase() == 'active' && Units.Police.length == 0 && Units.EMS.length == 0 ? "opacity: 0.3" : "opacity: 1.0" }">
    <div class="dispatch-call-header">
        {#if Id} <div style="background-color: #95ef77;" class="dispatch-call-chip">{Id}</div> {/if}
        {#if Code} <div style="background-color: #f2a365;" class="dispatch-call-chip">{Code}</div> {/if}
        <div class="dispatch-call-header-title">{Title}</div>
        {#if Coords} <div class="dispatch-call-header-marker"><i class="fas fa-map-marker-alt"></i></div> {/if}
    </div>

    {#if Information && Information.length > 0}
        <div class="dispatch-call-information">
            {#each Information as Data, Key}
                {#if Array.isArray(Data)}
                    <div style="display: flex; justify-content: space-between; width: 100%;">
                        {#each Data as Text}
                            <div class="dispatch-call-information-text">
                                {#if Text.Icon} <i class="fas {Text.Icon}"></i> {/if}
                                <p>{Text.Text}</p>
                            </div>
                        {/each}
                    </div>
                {:else}
                    <div class="dispatch-call-information-text">
                        {#if Data.Icon} <i class="fas {Data.Icon}"></i> {/if}
                        <p>{Data.Text}</p>
                    </div>
                {/if}
            {/each}

            {#if Radio}
                <div class="dispatch-call-information-text">
                    <i class="fas fa-signal"></i>
                    <p>{Radio}</p>
                </div>
            {/if}

            <div class="dispatch-call-information-text">
                <i class="fas fa-clock"></i>
                <p>{GetTimeLabel(Timestamp)}</p>
            </div>

            {#if Color.toLowerCase() == 'active'}
                <hr style="margin: 0.5vh 0px;">
                <div class="dispatch-call-information-text">
                    <p>Politie: ({Units.Police.length})</p>
                </div>
                <div class="dispatch-call-units">
                    {#each Units.Police as Data, Key}
                        <div style="background-color: #95ef77;" class="dispatch-call-chip dispatch-unit-chip">{Data.Callsign}</div>
                    {/each}
                </div>

                <div class="dispatch-call-information-text">
                    <p>Ambulance: ({Units.EMS.length})</p>
                </div>
                <div class="dispatch-call-units">
                    {#each Units.EMS as Data, Key}
                        <div style="background-color: #95ef77;" class="dispatch-call-chip dispatch-unit-chip">{Data.Callsign}</div>
                    {/each}
                </div>
            {/if}
        </div>
    {/if}
</div>

<style>
    .dispatch-call-container {
        width: calc(100% - 2.2vh);
        height: max-content;
        padding: .85vh;
        margin-bottom: .8vh;
        background-color: #003464d2;
        border-right: .5vh solid #1e7aca
    }

    .dispatch-call-container.call-active {
        background-color: #19237e;
        border-right: .5vh solid #1e7aca
    }

    .dispatch-call-container:hover {
        opacity: 1.0 !important;
    }

    .dispatch-call-container.call-red {
        background-color: #780f00d2;
        border-right: .5vh solid #e73718
    }

    .dispatch-call-container.fade-in {
        animation: fadeInRight 250ms;
        animation-fill-mode: forwards
    }

    .dispatch-call-container.fade-out {
        animation: fadeOutRight 250ms;
        animation-fill-mode: forwards
    }

    @keyframes fadeInRight {
        from {
            transform: translateX(105%)
        }

        to {
            transform: translateX(0%)
        }
    }

    @keyframes fadeOutRight {
        from {
            transform: translateX(0%)
        }

        to {
            transform: translateX(105%)
        }
    }

    .dispatch-call-header {
        display: flex;
        min-height: 3vh;
    }

    .dispatch-call-chip {
        font-family: Roboto;
        font-size: 1.3vh;
        color: black;
        padding: 0.35vh .75vh;
        border-radius: 2vh;
        margin-right: .5vh;
        height: fit-content
    }

    .dispatch-call-header-title {
        font-size: 1.3vh;
        font-style: normal;
        font-family: Arial, Helvetica, sans-serif;
        font-weight: 600;
        font-variant: small-caps;
        color: white;
        letter-spacing: 0px;
        text-transform: none;
        text-decoration: none;
        width: 67%;
        line-height: 2vh;
        text-shadow: rgb(55 71 79) -0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh -0.1vh 0, rgb(55 71 79) -0.1vh -0.1vh 0
    }

    .dispatch-call-header-marker {
        position: absolute;
        right: 2vh;
        font-size: 3vh;
        color: white;
        opacity: 0.9;
        cursor: pointer
    }

    .dispatch-call-header-marker:hover {
        opacity: 1.0
    }

    .dispatch-call-information-text {
        display: flex;
        align-items: center;
        font-size: 1.4vh;
        font-style: normal;
        font-family: Arial, Helvetica, sans-serif;
        font-weight: 600;
        font-variant: small-caps;
        color: white;
        letter-spacing: 0px;
        text-transform: none;
        text-decoration: none;
        width: 100%;
        line-height: 1.93vh;
        text-shadow: rgb(55 71 79) -0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh -0.1vh 0, rgb(55 71 79) -0.1vh -0.1vh 0
    }

    .dispatch-call-information-text > i {
        width: 2vh
    }

    .dispatch-call-units {
        width: 100%;
        clear: both;
        position: relative;
    }

    .dispatch-call-units > .dispatch-call-chip {
        display: inline-block;
        margin-bottom: 0.5vh;
    }
</style>