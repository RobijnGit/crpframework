<script>
    import Button from "../../../components/Button/Button.svelte";
    import { IsEms, MdwCharges, MdwModalsChargeEditor, MdwModalsExport, ShowLoader } from "../../../stores";
    import { HasCidPermission, SendEvent } from "../../../utils/Utils";

    const DeleteCharge = (Id) => {
        ShowLoader.set(true);
        SendEvent("Config/DeleteCharge", {Id}, (Success, Data) => {
            ShowLoader.set(false);
            if (!Success) return;
            if (!Data.Success) MdwModalsExport.set({Show: true, Msg: Data.Msg});
            MdwCharges.set(Data.Charges);
        });
    };

</script>

<div style="width: 100%;">
    {#if HasCidPermission("Config.EditCharges")}
        <Button
            Color="success"
            click={() => MdwModalsChargeEditor.set({Show: true, Charge: {
                gov_type: $IsEms ? "ems" : "pd",
                category: "",
                fine: 0,
                jail: 0,
                points: 0,
                name: "",
                description: "",
                type: "",
                accomplice: {},
                attempted: {},
            }})}
        >Straf creëren</Button>
    {/if}
    
    <div class="charge-table-wrapper">
        <table>
            <thead>
                <tr>
                    <th style="width: 1.5vh;">#</th>
                    <th style="width: 8vh;">Gov Type</th>
                    <th style="width: 9vh;">Charge Type</th>
                    <th>Category</th>
                    <th>Name</th>
                    <th>Description</th>
                    <th style="width: 5.6vh;">Actions</th>
                </tr>
            </thead>
        
            <tbody>
                {#each $MdwCharges.filter(Val => Val != undefined && Val.deleted == 0) as Data (Data.id)}
                    <tr>
                        <td>{Data.id}</td>
                        <td>{Data.gov_type}</td>
                        <td class="charge-type-{Data.type}">{Data.type}</td>
                        <td>{Data.category}</td>
                        <td>{Data.name}</td>
                        <td>{Data.description}</td>
                        <td>
                            {#if HasCidPermission("Config.EditCharges")}
                                <i
                                    class="fas fa-edit"
                                    data-tooltip="Bewerken"
                                    on:keyup on:click={() => MdwModalsChargeEditor.set({Show: true, Charge: Data})}
                                />
                            {/if}

                            {#if HasCidPermission("Config.DeleteCharges")}
                                <i
                                    class="fas fa-trash"
                                    data-tooltip="Verwijderen"
                                    on:keyup on:click={() => DeleteCharge(Data.id)}
                                />
                            {/if}
                        </td>
                    </tr>
                {/each}
            </tbody>
        </table>
        
    </div>
</div>

<style>
    .charge-table-wrapper {
        margin-top: 4vh;

        height: 70vh;
        width: 100%;

        overflow-y: auto;

        color: white;
        font-family: Roboto;
        font-size: 1.3vh;
    }

    .charge-table-wrapper::-webkit-scrollbar { display: none; }

    .charge-table-wrapper > table {
        width: 100%;
        border-collapse: collapse;
    }

    .charge-type-normal {
        background-color: #406f10
    }

    .charge-type-major {
        background-color: #7e5802
    }

    .charge-type-extreme {
        background-color: #7c2000
    }

    td, th {
        border: 0.1vh solid rgba(0, 0, 0, 0.5);
        padding: .7vh;
    }

    thead th {
        position: sticky;
        background-color: #232730;
        top: -.1vh;
        border: .1vh solid rgba(0, 0, 0, 0.5);
        font-size: 1.6vh;
    }

    td > i {
        font-size: 1.6vh;
        margin: 0 .5vh;
    }
</style>