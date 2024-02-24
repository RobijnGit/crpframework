<script>
    import ClothingTab from "../components/ClothingTab.svelte";
    import CardValue from "../components/CardValue.svelte";
    import CardSlider from "../components/CardSlider.svelte";
    import { ComponentsValues } from "../clothing.store";
</script>

<!-- Blemishes -->
<ClothingTab
    Title="Puisten"
    AmountComponents={$ComponentsValues?.Blemishes?.MaxComps}
    DisableTextureField={true}
>
    <CardValue componentId="Blemishes" valueType="Drawable"/>
    <CardSlider label="Opacity" componentId="Blemishes" valueId={1} style="width: 48.5%;"/>
</ClothingTab>

<!-- Ageing -->
<ClothingTab
    Title="Veroudering"
    AmountComponents={$ComponentsValues?.Ageing?.MaxComps}
    DisableTextureField={true}
>
    <CardValue componentId="Ageing" valueType="Drawable"/>
    <CardSlider label="Opacity" componentId="Ageing" valueId={1} style="width: 48.5%;"/>
</ClothingTab>

<!-- Complexion -->
<ClothingTab
    Title="Gezichtsvlekken"
    AmountComponents={$ComponentsValues?.Complexion?.MaxComps}
    DisableTextureField={true}
>
    <CardValue componentId="Complexion" valueType="Drawable"/>
    <CardSlider label="Opacity" componentId="Complexion" valueId={1} style="width: 48.5%;"/>
</ClothingTab>

<!-- Sun Damage -->
<ClothingTab
    Title="Zonneschade"
    AmountComponents={$ComponentsValues?.SunDamage?.MaxComps}
    DisableTextureField={true}
>
    <CardValue componentId="SunDamage" valueType="Drawable"/>
    <CardSlider label="Opacity" componentId="SunDamage" valueId={1} style="width: 48.5%;"/>
</ClothingTab>

<!-- Moles & Freckles -->
<ClothingTab
    Title="Mollen en Sproeten"
    AmountComponents={$ComponentsValues?.Moles?.MaxComps}
    DisableTextureField={true}
>
    <CardValue componentId="Moles" valueType="Drawable"/>
    <CardSlider label="Opacity" componentId="Moles" valueId={1} style="width: 48.5%;"/>
</ClothingTab>

<!-- Body Blemishes -->
<ClothingTab
    Title="Lichaamsvlekken"
    AmountComponents={$ComponentsValues?.BodyBlemishes?.MaxComps}
    DisableTextureField={true}
>
    <CardValue componentId="BodyBlemishes" valueType="Drawable"/>
    <CardSlider label="Opacity" componentId="BodyBlemishes" valueId={1} style="width: 48.5%;"/>
</ClothingTab>
