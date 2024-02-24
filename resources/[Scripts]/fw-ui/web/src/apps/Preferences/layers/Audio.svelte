<script>
    import Slider from '@smui/slider';
    import Checkbox from "../../../lib/Checkbox/Checkbox.svelte";
    import { MyPreferences } from '../preferences.store.js';
</script>

<p class="preferences-header">Radio</p>
<Checkbox
    Label="VoIP: Radiokliks (Uitgaand)"
    bind:Checked={$MyPreferences['Audio.RadioClicksOut']}
/>
<Checkbox
    Label="VoIP: Radiokliks (Inkomend)"
    bind:Checked={$MyPreferences['Audio.RadioClicksIn']}
/>

<hr/>
<p class="preferences-header">Volume</p>
<div class="preferences-flex column svelte-1fs4neh">
    <p style="font-family: Roboto; font-size: 1.5vh; color: white; margin: 0px;">Radio</p>
    <Slider
        step={0.01}
        min={0.0}
        max={1.0}
        bind:value={$MyPreferences['Audio.RadioVolume']}
        style="padding: 0px; margin: 0px;"
    />
    
    <p style="font-family: Roboto; font-size: 1.5vh; color: white; margin: 0px;">Telefoon</p>
    <Slider
        step={0.01}
        min={0.0}
        max={1.0}
        bind:value={$MyPreferences['Audio.PhoneVolume']}
        style="padding: 0px; margin: 0px;"
    />
</div>

<!--
    todo: add balancing
-->