<script>
    import { SendEvent as _SendEvent, SetDropdown } from "../../../utils/Utils.js";
    import { JobVehicles } from "../config.js";
    import _$ from "jquery";

    const SendEvent = (Event, Parameters, Callback) => _SendEvent(Event, Parameters, Callback, "fw-mdw");

    export let Job = 'Police';
    export let Label = [];
    export let Units = [];

    const GetSingleUnits = (Cid) => {
        let Retval = [];

        for (let i = 0; i < Units.length; i++) {
            const Unit = Units[i];
            if (Unit.Units.length == 1 && Unit.Cid != Cid) Retval.push({
                Text: `${Unit.Units[0].Callsign} - ${Unit.Units[0].Name}`,
                Value: i,
                Callsign: Unit.Units[0].Callsign,
                Cb: () => {
                    SendEvent("Dispatch/AddUnit", { Job, Cid, UnitCid: Unit.Cid });
                }
            });
        }

        return Retval.sort((a, b) => {
            if (a.Callsign < b.Callsign) return -1;
            if (a.Callsign > b.Callsign) return 1;
            return 0;
        });
    };
    
    const GetJobVehicles = (Cid) => {
        let Retval = [];
        for (let i = 0; i < JobVehicles[Job].length; i++) {
            const Vehicle = JobVehicles[Job][i];
            Retval.push({
                Text: `Voertuig: ${Vehicle.Label}`,
                Value: Vehicle.Icon,
                Cb: (Value) => {
                    SendEvent("Dispatch/SetVehicle", { Job, Cid, Icon: Vehicle.Icon, Type: Vehicle.Type });
                }
            })
        };

        return Retval;
    };

    const OnUnitClick = (Element, Data) => {
        var Container = _$(Element.target).closest(".dispatch-units-item");
        var DropdownLeft = Element.pageX;

        if (DropdownLeft + ((_$('body').height() * 25) / 100) > _$('body').width()) {
            DropdownLeft = _$('body').width() - ((_$('body').height() * 25) / 100)
        };
        
        if (Element.target.className.includes('dispatch-unit-chip') && Element.target.dataset.unitcid != Data.Cid) {
            SetDropdown(true, [
                {
                    Text: "Eenheid Loskoppelen",
                    Cb: () => {
                        SendEvent("Dispatch/RemoveUnit", { Job, Cid: Data.Cid, UnitCid: Element.target.dataset.unitcid });
                    }
                },
            ], {
                Top: _$(Element.target).offset().top,
                Left: DropdownLeft
            })
            return
        };

        const UnitData = Units.find(Val => Val.Cid == Data.Cid);
        if (!UnitData) return;

        const SingleUnits = GetSingleUnits(Data.Cid);
        const DropdownHeight = 3.75 * (8 + SingleUnits.length)

        var DropdownTop = _$(Container).offset().top + _$(Container).height();
        if (DropdownTop + ((_$('body').height() * DropdownHeight) / 100) > _$('body').height()) {
            DropdownTop = _$('body').height() - ((_$('body').height() * DropdownHeight) / 100)
        };

        const Statusses = [];

        if (!UnitData.Busy) {
            Statusses.push({
                Text: `Markeer als 10-06`,
                Cb: () => {
                    SendEvent("Dispatch/SetStatus", { Job, Cid: Data.Cid, Busy: true, Unavailable: false });
                },
            })
        }

        if (!UnitData.Unavailable) {
            Statusses.push({
                Text: `Markeer als 10-07`,
                Cb: () => {
                    SendEvent("Dispatch/SetStatus", { Job, Cid: Data.Cid, Busy: false, Unavailable: true });
                },
            })
        }

        if (UnitData.Busy || UnitData.Unavailable) {
            Statusses.push({
                Text: `Markeer als 10-08`,
                Cb: () => {
                    SendEvent("Dispatch/SetStatus", { Job, Cid: Data.Cid, Busy: false, Unavailable: false });
                },
            })
        }

        SetDropdown(true, [
            ...Statusses,
            ...GetJobVehicles(Data.Cid),
            ...SingleUnits
        ], {
            Top: DropdownTop,
            Left: DropdownLeft
        })
    }
</script> 

<div class="dispatch-units-list" style={$$restProps?.style}>
    <p>{Label} ({Units.length} eenheden)</p>
    
    {#if Units}
        {#each Units as Data (Data)}
            {#if Data}
                <div on:keyup on:click={(e) => { OnUnitClick(e, Data) }} class="dispatch-units-item {Data.Busy ? "unit-busy" : (Data.Unavailable ? "unit-unavailable" : "")}">
                    <i class="fas {Data.Icon}"></i>
                    <div>
                        {#each Data.Units as Unit, Key}
                            <div data-unitCid={Unit.Cid} class="dispatch-unit-chip"><i class="fas fa-walkie-talkie"></i> {Unit.Radio} ({Unit.Callsign}) - {Unit.Name}</div>
                        {/each}
                    </div>
                </div>
            {/if}
        {/each}
    {:else}
        <h1>Geen eenheden dud</h1>
    {/if}
</div>

<style>
    .dispatch-units-list {
        height: 100%;
        width: 49.5%;
        overflow-y: auto
    }

    .dispatch-units-list::-webkit-scrollbar {
        display: none
    }

    .dispatch-units-list > p {
        font-family: Roboto;
        font-size: 1.5vh;
        font-weight: 600;
        margin-top: .7vh;
        color: white;
        margin-bottom: .2vh
    }

    .dispatch-units-item {
        position: relative;
        display: flex;
        flex-direction: row;
        background-color: #30475e;
        width: calc(100% - 1.4vh);
        padding: .7vh;
        margin-bottom: .5vh;
        align-items: center
    }

    .dispatch-units-item.unit-busy > i { color: #e43e59 }
    .dispatch-units-item.unit-busy .dispatch-unit-chip { background-color: #e43e59 }

    .dispatch-units-item.unit-unavailable > i { color: #ec842e }
    .dispatch-units-item.unit-unavailable .dispatch-unit-chip { background-color: #ec842e }

    .dispatch-units-item-chips {
        width: 80%
    }

    .dispatch-units-item > i {
        font-size: 2.2vh;
        color: #669b51;
        text-align: center;
        width: 3vh;
        margin-right: 1vh
    }

    .dispatch-units-item > p {
        position: absolute;
        top: 0;
        left: 0;

        color: white;
        font-family: Roboto;
        font-size: 1.2vh;

        padding: .5vh;
    }

    .dispatch-unit-chip {
        font-family: Roboto;
        font-size: 1.3vh;
        color: white;
        background-color: #669b51;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        max-width: 90%;
        width: max-content;
        padding: 0.35vh .75vh;
        border-radius: 2vh;
        margin-right: .5vh;
        margin-bottom: .3vh;
        height: fit-content
    }
</style> 