<script>
    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import { MdwCharges } from "../../../stores";
    import MdwChargeCard from "../components/MdwChargeCard.svelte";
    import { onMount } from "svelte";

    let FilteredCharges = {};

    onMount(() => {
        FilterCharges("");
    })

    const FilterCharges = Value => {
        const Search = Value.toLowerCase();
        
        const FilteredResult = $MdwCharges.filter(Val => {
            return (Val.name.toLowerCase().includes(Search) || 
                Val.category.toLowerCase().includes(Search)) && Val.deleted == 0;
        });

        let NewCharges = {};
        for (let i = 0; i < FilteredResult.length; i++) {
            const Charge = FilteredResult[i];
            if (NewCharges[Charge.category] == undefined) {
                NewCharges[Charge.category] = [];
            }

            NewCharges[Charge.category].push(Charge);
        };

        FilteredCharges = NewCharges;
    };
</script>

<MdwPanel style="width: 100%; background-color: rgb(46, 70, 94);">
    <MdwPanel class="filled" style="width: 98.6%; margin: 0.5vh auto 0px; height: 6vh;">
        <MdwPanelHeader style="width: 98.6%;">
            <h6>Straffen</h6>
            <TextField Title='Zoeken' Icon='search' SubSet={FilterCharges} style="width: 20%;" />
        </MdwPanelHeader>
    </MdwPanel>

    {#each Object.entries(FilteredCharges) as [Category, Charges]}
        <MdwPanel class="filled" style="width: 98.6%; margin: 0.5vh auto 0px; height: max-content;">
            <MdwPanelHeader style="width: 98.6%;">
                <h6>{Category}</h6>
            </MdwPanelHeader>

            <div class="mdw-charges">
                {#each Charges as Data, Key}
                    <MdwChargeCard {...Data} />
                {/each}
            </div>
        </MdwPanel>
    {/each}
</MdwPanel>

<style>
    .mdw-charges {
        margin: 0 auto;
        margin-top: 1vh;
        width: 98.6%;
        height: max-content;
        overflow-y: auto
    }

    .mdw-charges::-webkit-scrollbar {
        display: none
    }
</style>