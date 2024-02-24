<script>
    import ClothingTab from "../components/ClothingTab.svelte";
    import CardValue from "../components/CardValue.svelte";
    import { ComponentsValues, CurrentSkin } from "../clothing.store";
    import { SendEvent as _SendEvent } from "../../../utils";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-clothes")
    };

    const ClearTattoos = (Zone) => {
        SendEvent("Clothes/ClearTattoos", { Zone }, () => {
            $CurrentSkin[Zone] = [ 0 ];
        })
    }
</script>

<ClothingTab
    Title="Borst"
    AmountComponents={$ComponentsValues?.TattoosTorso?.MaxComps}
>
    <div on:keyup on:click={() => ClearTattoos("TattoosTorso")} class="tattoos-clear" data-tooltip="Tattoos verwijderen" data-position="left">
        <i class="far fa-times"></i>
    </div>

    <p class="tattoos-layer-text">Laag</p>
    <div style="display: flex; width: 100%; justify-content: space-between;">
        <CardValue componentId="TattoosTorso" valueType="Drawable"/>
        <CardValue componentId="TattoosTorso" valueType="Layer"/>
    </div>
</ClothingTab>

<ClothingTab
    Title="Hoofd"
    AmountComponents={$ComponentsValues?.TattoosHead?.MaxComps}
>
    <div on:keyup on:click={() => ClearTattoos("TattoosHead")} class="tattoos-clear" data-tooltip="Tattoos verwijderen" data-position="left">
        <i class="far fa-times"></i>
    </div>

    <p class="tattoos-layer-text">Laag</p>
    <div style="display: flex; width: 100%; justify-content: space-between;">
        <CardValue componentId="TattoosHead" valueType="Drawable"/>
        <CardValue componentId="TattoosHead" valueType="Layer"/>
    </div>
</ClothingTab>

<ClothingTab
    Title="Linker Arm"
    AmountComponents={$ComponentsValues?.TattoosLArm?.MaxComps}
>
    <div on:keyup on:click={() => ClearTattoos("TattoosLArm")} class="tattoos-clear" data-tooltip="Tattoos verwijderen" data-position="left">
        <i class="far fa-times"></i>
    </div>

    <p class="tattoos-layer-text">Laag</p>
    <div style="display: flex; width: 100%; justify-content: space-between;">
        <CardValue componentId="TattoosLArm" valueType="Drawable"/>
        <CardValue componentId="TattoosLArm" valueType="Layer"/>
    </div>
</ClothingTab>

<ClothingTab
    Title="Rechter Arm"
    AmountComponents={$ComponentsValues?.TattoosRArm?.MaxComps}
>
    <div on:keyup on:click={() => ClearTattoos("TattoosRArm")} class="tattoos-clear" data-tooltip="Tattoos verwijderen" data-position="left">
        <i class="far fa-times"></i>
    </div>

    <p class="tattoos-layer-text">Laag</p>
    <div style="display: flex; width: 100%; justify-content: space-between;">
        <CardValue componentId="TattoosRArm" valueType="Drawable"/>
        <CardValue componentId="TattoosRArm" valueType="Layer"/>
    </div>
</ClothingTab>

<ClothingTab
    Title="Linker Been"
    AmountComponents={$ComponentsValues?.TattoosLLeg?.MaxComps}
>
    <div on:keyup on:click={() => ClearTattoos("TattoosLLeg")} class="tattoos-clear" data-tooltip="Tattoos verwijderen" data-position="left">
        <i class="far fa-times"></i>
    </div>

    <p class="tattoos-layer-text">Laag</p>
    <div style="display: flex; width: 100%; justify-content: space-between;">
        <CardValue componentId="TattoosLLeg" valueType="Drawable"/>
        <CardValue componentId="TattoosLLeg" valueType="Layer"/>
    </div>
</ClothingTab>

<ClothingTab
    Title="Rechter Been"
    AmountComponents={$ComponentsValues?.TattoosRLeg?.MaxComps}
>
    <div on:keyup on:click={() => ClearTattoos("TattoosRLeg")} class="tattoos-clear" data-tooltip="Tattoos verwijderen" data-position="left">
        <i class="far fa-times"></i>
    </div>

    <p class="tattoos-layer-text">Laag</p>
    <div style="display: flex; width: 100%; justify-content: space-between;">
        <CardValue componentId="TattoosRLeg" valueType="Drawable"/>
        <CardValue componentId="TattoosRLeg" valueType="Layer"/>
    </div>
</ClothingTab>

<style>
    .tattoos-clear {
        position: absolute;
        top: 1.2vh;
        right: 1.2vh;

        color: white;
        font-size: 1.75vh;
    }

    .tattoos-layer-text {
        position: absolute;
        margin-left: 9vh;
        top: 3.4vh;

        font-size: 1.25vh;
        font-weight: 400;
        color: #ffffffb3;
    }
</style>