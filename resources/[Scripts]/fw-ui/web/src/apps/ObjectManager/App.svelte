<script>
    import AppWrapper from "../../components/AppWrapper.svelte";
    import PivotControls from "./PivotControls.svelte";
    import { OnEvent, SendEvent as _SendEvent } from "../../utils/Utils";

    const SendEvent = (Event, Parameters, Callback) => _SendEvent(Event, Parameters, Callback, "fw-editor");
    let Visible = false;

    OnEvent("ObjectManager", "SetVisibility", (Data) => {
        Visible = Data.Visibility
    })
</script>


<AppWrapper AppName="ObjectManager" Focused={Visible}>

    <!-- {#if Visible} -->
        <PivotControls/>
    <!-- {/if} -->

</AppWrapper>