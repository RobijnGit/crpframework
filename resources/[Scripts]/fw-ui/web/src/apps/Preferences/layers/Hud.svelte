<script>
    import Checkbox from "../../../lib/Checkbox/Checkbox.svelte";
    import TextField from "../../../lib/TextField/TextField.svelte";
    import { MyPreferences } from "../preferences.store.js";

    let StatusHud = [
        ["Health", "Health"],
        ["Armor", "Armor"],
        ["Food", "Eten"],
        ["Water", "Drinken"],
    ]

</script>

<p class="preferences-header">Status</p>
<div class="preferences-flex column">
    {#each StatusHud as Data, Key}
        <div style="display: flex; justify-content: space-between;">
            <Checkbox
                Label="Toon {Data[1]}"
                bind:Checked={$MyPreferences[`Status.Show${Data[0]}`]}
            />
            <TextField
                Title="Verberg wanneer meer dan... (100 = nooit verbergen)"
                bind:RealValue={$MyPreferences[`Status.${Data[0]}Value`]}
            />
        </div>
    {/each}

    <div style="display: flex; justify-content: space-between;">
        <Checkbox
            Label="Toon Stress indien relevant"
            bind:Checked={$MyPreferences['Status.ShowStress']}
        />
        <Checkbox
            Label="Toon Oxygen indien relevant"
            bind:Checked={$MyPreferences['Status.ShowOxygen']}
        />
        <Checkbox
            Label="Toon Buffs indien relevant"
            bind:Checked={$MyPreferences['Status.ShowBuffs']}
        />
    </div>
</div>

<TextField
    Title="Toon Radio Kanaal"
    bind:RealValue={$MyPreferences['Status.RadioVisibility']}
    style="margin-top: 1vh;"
    Select={[
        { Text: "Relevant", Value: "Relevant" },
        { Text: "Altijd", Value: "Altijd" },
        { Text: "Nooit", Value: "Nooit" }
    ]}
/>

<hr/>
<p class="preferences-header">Voertuigen</p>
<Checkbox
    Label="Minimap Outline Ingeschakeld"
    bind:Checked={$MyPreferences['Vehicle.ShowMapOutline']}
/>

<hr/>
<p class="preferences-header">Kompas</p>
<Checkbox
    Label="Ingeschakeld"
    bind:Checked={$MyPreferences['Compass.Show']}
/>

<hr/>
<p class="preferences-header">Zwarte Balken</p>
<Checkbox
    Label="Ingeschakeld"
    bind:Checked={$MyPreferences['BlackBars.Show']}
/>
<TextField
    Title="Percentage van scherm"
    Icon="mask"
    bind:RealValue={$MyPreferences['BlackBars.Percentage']}
/>

<hr/>
<p class="preferences-header">Crosshair</p>
<Checkbox
    Label="Ingeschakeld"
    bind:Checked={$MyPreferences['Crosshair.Show']}
/>