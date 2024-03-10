<script>
    import _$ from "jquery";

    import TextField from "../../../components/TextField/TextField.svelte"
    import Button from "../../../components/Button/Button.svelte"

    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import MdwChip from "../components/MdwChip.svelte"
    import MdwChargeCard from "../components/MdwChargeCard.svelte";

    import { IsEms, MdwCharges, MdwModalsCharges } from "../../../stores";
    import { GetChargeById, SetDropdown } from "../../../utils/Utils";
    import { onMount } from "svelte";

    let FilteredCharges = {};
    onMount(() => {
        FilterCharges("");
    });

    const FilterCharges = Value => {
        const Search = Value.toLowerCase();
        const FilteredResult = $MdwCharges.filter(Val => {
            return (Val.name.toLowerCase().includes(Search) || 
                Val.category.toLowerCase().includes(Search)) & Val.deleted == 0;
        });

        let NewCharges = {};
        for (let i = 0; i < FilteredResult.length; i++) {
            const Charge = FilteredResult[i];
            if (NewCharges[Charge.category] == undefined) {
                NewCharges[Charge.category] = [];
            };

            NewCharges[Charge.category].push(Charge);
        };

        FilteredCharges = NewCharges;
    };

    const IsChargeValid = (Data) => {
        if (
            (!Data || Data == "")
            || ((!Data.jail || Data.jail == "" || Data.jail == "0" || Data.jail <= 0)
            && (!Data.fine || Data.fine == "" || Data.fine == "0" || Data.fine <= 0)
            && (!Data.points || Data.points == "" || Data.points == "0" || Data.points <= 0))
        ) return false;

        return true;
    }

    const AddCharge = (Element, ChargeData) => {
        var Container = _$(Element.target).closest(".mdw-charge-container");
        var DropdownLeft = Element.pageX;

        if (DropdownLeft + ((_$('body').height() * 25) / 100) > _$('body').width()) {
            DropdownLeft = _$('body').width() - ((_$('body').height() * 25) / 100)
        }

        let Options = [
            {
                Text: `${$IsEms ? "Factuur" : "Straf"} Toevoegen`,
                Cb: () => {
                    $MdwModalsCharges.Charges = [...$MdwModalsCharges.Charges, { Id: ChargeData.id, Type: "Principal" }]
                }
            },
        ];

        const accomplice = ChargeData.accomplice;
        const attempted = ChargeData.attempted;

        if (IsChargeValid(accomplice)) {
            Options.push({
                Text: `${$IsEms ? "Factuur" : "Straf"} Toevoegen (Medeplichtigheid)`,
                Cb: () => {
                    $MdwModalsCharges.Charges = [...$MdwModalsCharges.Charges, { Id: ChargeData.id, Type: "Accomplice" }]
                }
            })
        };

        if (IsChargeValid(attempted)) {
            Options.push({
                Text: `${$IsEms ? "Factuur" : "Straf"} Toevoegen (Poging Tot)`,
                Cb: () => {
                    $MdwModalsCharges.Charges = [...$MdwModalsCharges.Charges, { Id: ChargeData.id, Type: "Attempted" }]
                }
            })
        };

        SetDropdown(true, Options, {
            Top: _$(Container).offset().top + _$(Container).height() + 5,
            Left: DropdownLeft
        })
    };
</script>

<div class="mdw-modal-charges">
    <div class="mdw-modal-charges-container">
        <div style="display: flex; justify-content: space-between;">
            <p>Huidige Straffen</p>
            <div>
                <Button click={() => { $MdwModalsCharges.Show = false }} Color="warning">Sluiten</Button>
                <Button click={() => {
                    $MdwModalsCharges.Cb($MdwModalsCharges.Charges)
                    MdwModalsCharges.set({
                        Show: false,
                        Charges: [],
                        Cb: () => {},
                    })
                }} Color="success">Opslaan</Button>
            </div>
        </div>

        <div style="margin-top: 0.5vh; display: flex; flex-wrap: wrap; box-sizing: border-box;">
            {#each $MdwModalsCharges.Charges as Data, Key}
                <MdwChip Text={(Data.Type != "Principal" ? (Data.Type == "Accomplice" ? "(Mp) " : "(Pt) ") : "") + GetChargeById(Data.Id).name} Color="#000000" SuffixIcon="times-circle" on:click={() => {
                    let NewCharges = [...$MdwModalsCharges.Charges];
                    NewCharges.splice(Key, 1);
                    $MdwModalsCharges.Charges = NewCharges;
                }} />
            {/each}
        </div>

        <hr style="border-top: none; border-right: none; border-bottom: 0.1vh solid white; border-left: none; border-image: initial; margin: 1.5vh 0px;"/>

        <MdwPanel style="width: 100%; margin-right: 0">
            <MdwPanel class="filled" style="width: 100%; margin: 0.5vh auto 0px; height: 6vh;">
                <MdwPanelHeader style="width: 98.6%;">
                    <h6>Straffen</h6>
                    <TextField Title='Zoeken' Icon='search' SubSet={FilterCharges} style="width: 20%;" />
                </MdwPanelHeader>
            </MdwPanel>

            {#each Object.entries(FilteredCharges) as [Category, Charges]}
                <MdwPanel class="filled" style="width: 100%; margin: 0.5vh auto 0px; height: max-content;">
                    <MdwPanelHeader style="width: 98.6%;">
                        <h6>{Category}</h6>
                    </MdwPanelHeader>

                    <div class="mdw-charges" style="width: 98.6%; margin: 0 auto;">
                        {#each Charges as Data, Key}
                            <MdwChargeCard {...Data} on:click={(e) => { AddCharge(e, Data) }} />
                        {/each}
                    </div>
                </MdwPanel>
            {/each}
        </MdwPanel>
    </div>
</div>

<style>
    .mdw-modal-charges {
        position: absolute;
        z-index: 998;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7)
    }

    .mdw-modal-charges-container {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 78.3%;
        height: max-content;
        max-height: 83.5vh;
        overflow-y: auto;
        padding: 1.4vh;
        transform: translate(-50%, -50%);
        background-color: rgb(34, 40, 49)
    }

    .mdw-modal-charges-container::-webkit-scrollbar {
        display: none
    }

    .mdw-modal-charges-container p {
        color: white;
        font-family: Roboto;
        font-size: 1.35vh;
        margin-bottom: 1.5vh
    }
</style>