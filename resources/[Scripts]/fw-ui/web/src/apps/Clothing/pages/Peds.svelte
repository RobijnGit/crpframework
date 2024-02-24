<script>
    import ClothingTab from "../components/ClothingTab.svelte";
    import CardValue from "../components/CardValue.svelte";
    import TextField from "../../../lib/TextField/TextField.svelte";
    import { ClothingPrice, ComponentsValues, CustomPeds, IsCustomPed, PedId } from "../clothing.store";
    import { AsyncSendEvent, SendEvent as _SendEvent } from "../../../utils";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-clothes")
    };
</script>

<!-- Ped -->
<ClothingTab
    Title="Ped"
    AmountComponents={$ComponentsValues?.Peds?.MaxComps}
    DisableTextureField={true}
    style="padding-bottom: 1vh;"
>
    <div style="width: 100%;">
        <CardValue componentId="Peds" valueType="Drawable" value={$IsCustomPed ? 0 : $PedId} ignoreAutoValue={true}/>
    </div>
</ClothingTab>

<!-- Custom Ped -->
{#if $CustomPeds.length > 0}
    <ClothingTab
        Title="Custom Ped"
        DisableTextureField={true}
    >
        <div style="width: 98%;">
            <TextField
                Title="{$CustomPeds.length} {$CustomPeds.length == 1 ? "component" : "components"}"
                Icon="user-check"
                style="margin: 0;"
                Select={$CustomPeds.map((ped) => ({ Text: ped }))}
                SubSet={(_, Value) => {
                    SendEvent("Clothing/SetCustomPed", {
                        Ped: Value
                    }, async () => {
                        const [Success, NewPrice] = await AsyncSendEvent("Clothing", "GetClothesPrice", {__resource: "fw-clothes"});
                        if (Success) ClothingPrice.set(NewPrice);
                    });
                }}
            />
        </div>
    </ClothingTab>
{/if}
