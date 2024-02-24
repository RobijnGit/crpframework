<script>
    import Checkbox from "../../../lib/Checkbox/Checkbox.svelte";
    import TextField from "../../../lib/TextField/TextField.svelte";
    import { MyPreferences } from "../preferences.store.js";
</script>

<p class="preferences-header">Misc</p>
<TextField
    Title="Merk"
    bind:RealValue={$MyPreferences['Phone.Brand']}
    Select={[
        { Text: "Android", Value: "Android" },
        { Text: "iOS", Value: "iOS" }
    ]}
/>

<TextField
    Title="Achtergrond URL (1:2.2 res)"
    Icon="images"
    bind:RealValue={$MyPreferences['Phone.Background']}
/>

<TextField
    Title="Telefoon Animatie"
    bind:RealValue={$MyPreferences['Phone.Animation']}
    Select={[
        { Text: "Rechteroor (Standaard)", Value: "Rechteroor" },
        { Text: "Linkeroor", Value: "Linkeroor" }
    ]}
/>

<TextField
    Title="Radio Animatie"
    bind:RealValue={$MyPreferences['Radio.Animation']}
    Select={[
        { Text: "Schouder (Standaard)", Value: "Schouder" },
        { Text: "Borst", Value: "Borst" }
    ]}
/>

<Checkbox
    Label="Movement uitschakelen (Aanbevolen)"
    bind:Checked={$MyPreferences['Phone.DisableMovement']}
/>

<hr/>
<p class="preferences-header">Notificaties</p>

<Checkbox
    Label="SMS Ontvangen"
    bind:Checked={$MyPreferences['Notifications.SMS']}
/>
<Checkbox
    Label="Nieuwe Twat"
    bind:Checked={$MyPreferences['Notifications.Tweet']}
/>
<Checkbox
    Label="Email Ontvangen"
    bind:Checked={$MyPreferences['Notifications.Email']}
/>

<hr/>
<p class="preferences-header">Afbeeldingen</p>

<Checkbox
    Label="Twitter/Bericht Bijlages Ingeschakeld"
    bind:Checked={$MyPreferences['Images.Embedded']}
/>