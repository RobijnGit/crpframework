<script>
    import AppWrapper from "../../components/AppWrapper.svelte";
    import Cash from "./layers/Cash.svelte";
    import Compass from "./layers/Compass.svelte";
    import Status from "./layers/Status.svelte";
    import Vehicle from "./layers/Vehicle.svelte";
</script>

<AppWrapper AppName="Hud" Focused={false}>
    <Cash/>
    <Compass/>
    <Vehicle/>
    <Status/>
</AppWrapper>